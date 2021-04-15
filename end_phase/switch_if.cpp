#include<iostream>
using namespace std;

int main(){
    int day = 4;
    int a= 9;
    if(day ==1){
        a = 4;
    }
    else{
        a=8;
    }

    int x = 9;

// day = 4
// a = 9
// T0 = day == 1
// IFSTMT
// T1 = not T0
// if T1 goto L0
// a = 4
// T2 = day == 2
// elif
// L0: 
// T3 = not T2
// if T3 goto L1
// a = 5
// T4 = day == 3
// elif
// L1: 
// T5 = not T4
// if T5 goto L2
// a = 7
// if_else_cleanup
// L2: 
// a = 8
}