#ifndef OO_STDLIB_H
#define OO_STDLIB_H

#include <inttypes.h> // PRIx64, uint64_t, int64_t
#include <stdio.h>    // printf
#include "oo-string.h"

typedef uint64_t bitfield;

static inline string* const bitfield_toString(uint64_t const value) {
    return string_format("%018#" PRIx64, value);
}

/// @brief Implementation of bitfield.print()
/// @param self the target bitfield “object”
static inline void bitfield_print(bitfield self) {
    // Print using "0x" prefix and 16 hex digits
    string* description = bitfield_toString(self);
    printf("%s\n", description->buffer);
    free(description);
}

#endif /* OO_STDLIB_H */
