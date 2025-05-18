pragma circom 0.5.46;

template GreaterEq() {
    signal private input in[2];
    signal output out;

    // Implementação direta da comparação maior ou igual
    signal diff;
    diff <== in[0] - in[1];
    
    // Se diff >= 0, então in[0] >= in[1]
    out <== diff >= 0 ? 1 : 0;
} 