#include "oo-stdlib.h"
#include "oo-runtime.h"

int main() {
    // let i: integer = 42
    integer_box* i = (integer_box*) oo_alloc(__oo_ISOLATED, &__integer_box_info);
    i->boxed = 42;

    // print i
    print_desc(i);

    i = oo_release(&i->header);
    return 0;
}
