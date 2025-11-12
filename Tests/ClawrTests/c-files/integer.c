#include "clawr-stdlib.h"
#include "clawr-runtime.h"

int main() {
//        print 42
    string* const s = integer_toString(42);
    print(s);
    releaseRC(s);
    return 0;
}
