#ifndef OO_STDLIB_H
#define OO_STDLIB_H

#include <inttypes.h> // PRIx64, uint64_t, int64_t
#include <stdio.h>    // printf
#include "oo-string.h"

typedef int64_t integer;

typedef struct integer_box
{
    __oo_rc_header header;
    integer boxed;
} integer_box;

// model integer: HasStringRepresentation {
//     func toString() { ... }
// }
static inline string* const integer_toString(integer const self) {
    return string_format("%" PRId64, self);
}
static inline string* integer_box_toString(void* self) {
    return integer_toString(((integer_box*)self)->boxed);
}
static const HasStringRepresentation_vtable integer_HasStringRepresentation_vtable = {
    .toString = integer_box_toString
};

static __oo_struct_type __integer_box_info = {
    .size = sizeof(integer_box),
    .trait_descs = (__oo_trait_descriptor*[]) { &HasStringRepresentation_trait },
    .trait_vtables = (void*[]) { &integer_HasStringRepresentation_vtable },
    .trait_count = 1
};

typedef uint64_t bitfield;

static inline string* const bitfield_toString(bitfield const self) {
    return string_format("%018#" PRIx64, self);
}

#endif /* OO_STDLIB_H */
