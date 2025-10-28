#include "oo-stdlib.h"
#include "oo-runtime.h"

int main() {
    // let i: integer = 42
    integer_box* i = (integer_box*) oo_alloc(__oo_ISOLATED, &__integer_box_info);
    i->boxed = 42;

    // print i as HasStringRepresentation
    HasStringRepresentation_vtable* vtable =
        (HasStringRepresentation_vtable*) __oo_trait_vtable(&i->header, &HasStringRepresentation_trait);
    string* s = vtable->toString(i);
    print(s);

    s = oo_release(&s->header);
    i = oo_release(&i->header);
    return 0;
}
