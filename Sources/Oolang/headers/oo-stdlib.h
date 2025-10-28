#ifndef OO_STDLIB_H
#define OO_STDLIB_H

#include <inttypes.h> // PRIx64, uint64_t, int64_t
#include <stdio.h>    // printf
#include "oo-string.h"

typedef int64_t integer;

static inline string* const integer_toString(integer const self) {
    return string_format("%" PRId64, self);
}

typedef uint64_t bitfield;

static inline string* const bitfield_toString(bitfield const self) {
    return string_format("%018#" PRIx64, self);
}

#endif /* OO_STDLIB_H */
