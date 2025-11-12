#include "clawr-stdlib.h"

int main() {
    // print "string"
    string* s = string_format("string");
    print(s);
    releaseRC(s);
    return 0;
}
