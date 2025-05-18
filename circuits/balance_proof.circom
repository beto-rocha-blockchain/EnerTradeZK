pragma circom 2.1.6;
include "circomlib/circuits/comparators.circom";

template BalanceProof(nBits) {
    signal input balance;
    signal input threshold;
    signal output valid;

    component lt = LessThan(nBits);
    lt.in[0] <== threshold;
    lt.in[1] <== balance;
    valid <== 1 - lt.out; // valid = 1 se balance >= threshold
}

component main = BalanceProof(16); // 16 bits para saldos até 65535 