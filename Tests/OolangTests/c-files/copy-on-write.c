#include "oo-stdlib.h"
#include "oo-runtime.h"

//        struct Struct { value: integer }
struct __Struct_data { int64_t value; };
typedef struct Struct {
    struct __oo_rc_header header;
    struct __Struct_data Struct;
} Struct;
__oo_struct_type __Struct_info = {.size = sizeof(Struct)};

int main() {
//        mut x: Struct = { value: 42 }
    Struct* x = oo_alloc(__oo_ISOLATED, &__Struct_info);
    x->Struct.value = 42;

//        let y = x
    Struct* y = oo_retain(&x->header);

//        x.value = 2
    x = oo_preModify(&x->header);
    x->Struct.value = 2;

//        print y.value
    integer_box* yValue = oo_alloc(__oo_ISOLATED, &__integer_box_info);
    yValue->boxed = y->Struct.value;
    print_desc(yValue);
    yValue = oo_release(yValue);

    integer_box* xValue = oo_alloc(__oo_ISOLATED, &__integer_box_info);
    xValue->boxed = x->Struct.value;
    print_desc(xValue);
    xValue = oo_release(xValue);

    x = oo_release(&x->header);
    y = oo_release(&y->header);
    return 0;
}
