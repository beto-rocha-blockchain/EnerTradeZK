pragma circom 2.1.6;

template BalanceCheck() {
    signal input a;
    signal output b;
    b <== a;
}

component main = BalanceCheck();