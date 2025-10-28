#include "oo-stdlib.h"
#include "oo-runtime.h"

int main() {
    // let bf: bitfield = 0x12
    bitfield_box* bf = (bitfield_box*) oo_alloc(__oo_ISOLATED, &__bitfield_box_info);
    bf->boxed = 0x12;

    // print bf
    print_desc(bf);

    bf = oo_release(&bf->header);
    return 0;
}
