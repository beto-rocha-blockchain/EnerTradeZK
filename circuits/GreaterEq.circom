pragma circom 2.0.0;

template GreaterEq(n) {
    signal input in[2];
    signal output out;

    // in[0] >= in[1]
    signal diff;

    diff <== in[0] - in[1];

    // Aqui uma simplificação:
    // Se diff >= 0, out = 1, caso contrário out = 0.
    // Para provar isso em circom, normalmente fazemos:
    // out será 1 se diff >= 0, senão 0.
    // Como circom não tem operadores booleanos simples, precisa usar lógica binária para isso.
    // Exemplo simplificado:

    component isNonNegative = IsNonNegative();
    isNonNegative.in <== diff;

    out <== isNonNegative.out;
}

// Componente auxiliar que verifica se um número é não-negativo (exemplo básico)
template IsNonNegative() {
    signal input in;
    signal output out;

    // Implementar lógica de sinal positivo no campo finito é complexo,
    // mas para números pequenos pode ser feito verificando os bits.

    // Aqui vai uma implementação simplificada e incompleta,
    // para fins de exemplo:

    out <== in >= 0 ? 1 : 0; // **Isso NÃO funciona direto em circom.**

    // Você terá que implementar uma verificação de bit para
    // garantir que `in` não é negativo no campo finito.

    // Use bibliotecas externas para isso, ou crie sua própria lógica.
}

template BalanceCheck() {
    signal input balance;
    signal input threshold;
    signal output out;

    component ge = GreaterEq(32); // Exemplo: usando 32 bits
    ge.in[0] <== balance;
    ge.in[1] <== threshold;

    out <== ge.out;
}

component main = BalanceCheck();
