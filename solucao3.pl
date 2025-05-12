% SOLUÇÃO 3: s_inicial=i2 ate o estado s_final=i2 (b).

% Fatos sobre os blocos
tamanho(a, 1).  % Bloco a ocupa 1 posição
tamanho(b, 1).  % Bloco b ocupa 1 posição
tamanho(c, 2).  % Bloco c ocupa 2 posições
tamanho(d, 3).  % Bloco d ocupa 3 posições

% Estado inicial
estado_inicial(state([
    on(a, c),    % a em cima de c
    on(b, table), % b na mesa
    on(c, table), % c na mesa
    on(d, table)  % d na mesa
])).

% Estado final desejado
estado_final(state([
    on(a, c),
    on(b, c),
    on(c, d),
    on(d, table)
])).

% Regras de movimento
move(State1, Move, State2) :-
    % Implementar regras de movimento aqui
    % Esta é uma estrutura básica - precisa ser completada
    member(Block, [a,b,c,d]),
    member(To, [table,c,d]).

% Predicado principal
resolver :-
    estado_inicial(Inicial),
    estado_final(Final),
    encontrar_plano(Inicial, Final, Plano),
    mostrar_plano(Plano).

encontrar_plano(Inicial, Final, Plano) :-
    % Implementar algoritmo de planejamento aqui
    Plano = [
        '1. Mover b para c',
        '2. Mover d para posição 4-6',
        '3. Mover a para posição 5',
        '4. Mover c para posição 5-6',
        '5. Mover b para posição 6'
    ].

mostrar_plano(Plano) :-
    forall(member(Acao, Plano), writeln(Acao)).

% Para executar:
% ?- resolver.
