#ifndef OO_RUNTIME_H
#define OO_RUNTIME_H

#include <stdlib.h>      // malloc, size_t, NULL
#include <stdatomic.h>   // atomic_uintptr_t, atomic_init, _Atomic
#include <string.h>      // memcpy
#include <unistd.h>      // usleep
#include <stdio.h>       // stderr, fprintf
#include "oo-alloc.h"

/*
    Implementation of copy-on-write memory handling.

    Thread safety is guaranteed using std::atomic.
    NOTE: The current strategy has not been tested thouroughly.
    - How *do* you test low-level concurrency?
    - How do you test that memory is actually freed?

    The std:atomic (sometimes ‘C++0x’) functions guarantee read/write atomicity per operation.
    They enable **optimistic concurrency**. Races will still happen, but values are not updated
    if they have been changed by another thread between separate load and store operations.

    I haven't found good documentation on this, but it matches my own implementation of adding
    events to entities in Segerfeldt.EventStore (C#).
 */

/// @brief Flag to indicate variable semantics for an entity’s allocated memory block
typedef enum {
    /// @brief Reference Semantics (`ref` variable) - One entity, multiple variables
    __oo_REFERENCE,
    /// @brief Isolation Semantics (`let`, `mut` variable) - Variables modified independently
    __oo_ISOLATED,
} __oo_var_semantics;

enum {
    // Assuming 64-bit registers
    __oo_COPYING_FLAG = ~INT64_MAX,
    __oo_REFC_BM      = INT64_MAX,
};

/// @brief Information about an entity’s type (`struct` or `object`)
/// This should include:
/// - inheritance and conformance information
/// - method lookup table if `object` type
/// - field layout info if `struct` type
typedef struct __oo_struct_type {
    /// @brief The size of the entity payload for this type
    size_t size;
} __oo_struct_type;

/// A header that is prefixed on all programmer types
typedef struct __oo_rc_header {
    /// @brief Copy or reference + Polymorphism or data semantics
    __oo_var_semantics semantics;
    /// @brief Reference counter
    atomic_uintptr_t refs;
    /// @brief Pointer to type data
    __oo_struct_type* is_a;
} __oo_rc_header;

// -------- Implementation -------- ||

/// @brief Allocate reference-counted entity in memory
/// @param semantics the semantics, copy or reference, to apply when assigning and modifying the entity
/// @param typeInfo pointer to an object that represents the entity’s type
static inline void* oo_alloc(__oo_var_semantics const semantics, __oo_struct_type* const typeInfo) {
    __oo_rc_header* const header = (__oo_rc_header*)__oo_alloc(typeInfo->size);
    header->semantics = semantics;
    header->is_a = typeInfo;
    atomic_init(&header->refs, 1);
    return header;
}

/// @brief Increment a reference counter
/// @param header the header of the entity to retain
static inline __oo_rc_header* oo_retain(__oo_rc_header* const header) {
    if (header) atomic_fetch_add_explicit(&header->refs, 1, memory_order_relaxed);
    return header;
}

/// @brief Decrement the reference counter of an entity
/// If the reference counter becomes zero, the entity is descoped
/// @param header the header of the entity to release
/// @returns `NULL` so that the variable can be assigned to the function call.
static inline void* oo_release(__oo_rc_header* const header) {
    if (header && (atomic_fetch_sub_explicit(&header->refs, 1, memory_order_acq_rel) & __oo_REFC_BM) == 1) {
        free(header);
    }
    return NULL;
}

/// @brief Copy-on-write action. Call before modifications.
/// Maintains variable isolation by creating a copy of the entity
/// — if it has `__oo_ISOLATED` semantics and there are multipe referents.
/// Always replace the variable with the return value.
/// @param header the entity to modify
/// @return the entity itself or a copy if CoW was triggered
/// @example
/// @code
/// ```
/// MyType* x = oo_alloc(__oo_ISOLATED, &__MyType_info);
/// // Initialize x and use it
/// x = oo_preModify(x);
/// // Make isolated changes to x
/// ```
/// @endcode
static inline void* oo_preModify(__oo_rc_header* const header) {
    if (!header) return NULL;
    if (header->semantics == __oo_REFERENCE) {
        // No copy for reference semantics
        return header;
    }

    // Flag for copying.
    // refs |= __oo_COPYING_FLAG
    uintptr_t refs = atomic_fetch_or_explicit(&header->refs, __oo_COPYING_FLAG, memory_order_acquire);
    if (refs == 1) {
        // No copy necessary for uniquely referenced entity. Unset the copying flag immediately.
        // refs &= ~__oo_COPYING_FLAG
        atomic_fetch_and_explicit(&header->refs, ~__oo_COPYING_FLAG, memory_order_acquire);
        return header;
    } else if (refs & __oo_COPYING_FLAG) {
        usleep(100);
        return oo_preModify(header);
    }

    // Copy payload for copy semantics with shared ownership
    __oo_struct_type* const typeInfo = header->is_a;
    __oo_rc_header* const newEntity = (__oo_rc_header*)__oo_alloc(typeInfo->size);
    memcpy(newEntity, header, typeInfo->size);
    atomic_init(&newEntity->refs, 1);

    // Finished copying. Drop our strong ref to the original entity and unset the flag.
    atomic_fetch_and_explicit(&header->refs, ~__oo_COPYING_FLAG, memory_order_acquire);
    oo_release(header);

    return newEntity;
}

#endif /* OO_RUNTIME_H */
