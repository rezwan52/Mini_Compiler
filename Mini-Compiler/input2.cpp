#include <iostream>
using namespace std;

int main() {
    int a, b;
    a = 77;
    b = 33;
    int result1;

    if (a > b) {
        result1 = a + b + 11;
    } else {
        result1 = 0;
        a = a + b;
    }

    return 0;
}
