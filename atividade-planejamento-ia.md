# Diagnóstico de Código Prolog: Planejamento de Preenchimento de Grade 4x4

Este documento descreve os erros do código Prolog original e as correções realizadas para que ele funcionasse corretamente, mantendo a mesma estrutura e nomes de variáveis.

---

## ❌ Erros no Código Original

### 1. **Erro de Sintaxe em Expressões Aritméticas**
```prolog
SubRow is ((Row
1) // 2) * 2 + 1
```
- **Problema**: Faltava o operador `-` entre `Row` e `1`.
- **Consequência**: Causa erro de compilação ou falha na execução.

---

### 2. **Ordem Incorreta dos Casos de plan_step/4**
```prolog
plan_step(FinalState, FinalState, Plan, Plan).  % vinha antes
plan_step(CurrentState, FinalState, PartialPlan, Plan).  % vinha depois
```
- **Problema**: O caso base vinha antes do caso recursivo.
- **Consequência**: Prolog tentava verificar se a grade já estava completa antes de preencher qualquer célula, encerrando prematuramente.

---

### 3. **Erro em Decremento de Índice**
```prolog
NextPos is Pos
1
```
- **Problema**: Faltava o operador `-`.
- **Correção**: Deve ser `NextPos is Pos - 1`.

---

## ✅ Correções Aplicadas

### 1. **Correção das Expressões Aritméticas**
```prolog
SubRow is ((Row - 1) // 2) * 2 + 1
SubCol is ((Col - 1) // 2) * 2 + 1
```
- Adicionados corretamente os operadores de subtração.

---

### 2. **Troca da Ordem dos Casos de plan_step/4**
```prolog
% Primeiro o caso recursivo
plan_step(CurrentState, FinalState, PartialPlan, Plan) :- ...

% Depois o caso base
plan_step(FinalState, FinalState, Plan, Plan).
```
- **Agora o preenchimento ocorre antes da verificação de término**.

---

### 3. **Correção no replace/4**
```prolog
NextPos is Pos - 1
```
- Corrigido o erro de sintaxe que impedia o funcionamento da substituição de elementos.

---

## ✅ Resultado Esperado

O código funcional é capaz de:
- Preencher corretamente a grade 4x4 com os números de 1 a 4.
- Respeitar as restrições de linhas, colunas e subgrades 2x2.
- Gerar um plano de ações na ordem correta.

---

## Diferença entre Means-Ends Analysis e Goal Regression

### Características do **Means-Ends Analysis**:

- Foco em reduzir a diferença entre o estado atual e o objetivo.
- Analisa a diferença entre onde se está e onde se quer chegar, selecionando ações que diminuam essa diferença.
- Comum em sistemas de IA clássicos.
- Trabalha progressivamente do estado inicial até o objetivo.

### Características do **Goal Regression**:

- Foco em decompor o objetivo em sub-objetivos menores.
- Trabalha de trás para frente: a partir do objetivo, busca quais ações permitiriam alcançá-lo.
- Mais comum em planejamento baseado em lógica (e.g., STRIPS).
- Regressão de objetivos até encontrar condições iniciais que os satisfazem.

---

## Código Corrigido

```prolog
% Define numbers 1-4
num(1). num(2). num(3). num(4).

% Main planning predicate
plan(InitialState, FinalState, Plan) :-
    % Copy InitialState to work on it
    copy_term(InitialState, CurrentState),
    % Generate the plan by filling empty cells
    plan_step(CurrentState, FinalState, [], Plan).

% Recursive case: Find an empty cell, fill it, and continue.
plan_step(CurrentState, FinalState, PartialPlan, Plan) :-
    % Find an empty cell (0) at (Row, Col)
    nth1(Row, CurrentState, RowList),
    nth1(Col, RowList, 0),
    % Try filling it with Num (1-4)
    num(Num),
    % Check if Num is valid (no conflicts)
    is_valid(CurrentState, Row, Col, Num),
    % Fill the cell
    fill_cell(CurrentState, Row, Col, Num, NewState),
    % Record the action
    Action = fill(Row, Col, Num),
    % Continue planning
    plan_step(NewState, FinalState, [Action | PartialPlan], Plan).

% Base case: If CurrentState matches FinalState, stop.
plan_step(FinalState, FinalState, Plan, Plan).

% Check if Num can be placed at (Row, Col) without conflicts
is_valid(State, Row, Col, Num) :-
    % Check Row
    nth1(Row, State, RowList),
    \+ member(Num, RowList),
    % Check Column
    column(State, Col, ColumnList),
    \+ member(Num, ColumnList),
    % Check 2x2 sub-square
    subgrid(State, Row, Col, Subgrid),
    \+ member(Num, Subgrid).

% Extract a column from the grid
column([], _, []).
column([Row|Rest], Col, [Value|Values]) :-
    nth1(Col, Row, Value),
    column(Rest, Col, Values).

% Extract the 2x2 subgrid containing (Row, Col)
subgrid(State, Row, Col, Subgrid) :-
    % Determine top-left corner of the subgrid
    SubRow is ((Row - 1) // 2) * 2 + 1,
    SubCol is ((Col - 1) // 2) * 2 + 1,
    % Extract 4 cells
    nth1(SubRow, State, Row1),
    RowNext is SubRow + 1,
    nth1(RowNext, State, Row2),
    nth1(SubCol, Row1, A), SubCol1 is SubCol + 1, nth1(SubCol1, Row1, B),
    nth1(SubCol, Row2, C), nth1(SubCol1, Row2, D),
    Subgrid = [A, B, C, D].

% Fill cell (Row, Col) with Num
fill_cell(State, Row, Col, Num, NewState) :-
    nth1(Row, State, RowList),
    replace(RowList, Col, Num, NewRowList),
    replace(State, Row, NewRowList, NewState).

% Helper: Replace element at position in a list
replace([_|T], 1, X, [X|T]).
replace([H|T], Pos, X, [H|NewT]) :-
    Pos > 1,
    NextPos is Pos - 1,
    replace(T, NextPos, X, NewT).
```

---

## Código com Goal Regression

```prolog
% Define numbers 1-4
num(1). num(2). num(3). num(4).

% Main planning predicate (Goal Regression)
plan(FinalState, InitialState, Plan) :-
    plan_regress(FinalState, InitialState, [], Plan).  % <- sem reverse aqui

% Base case: FinalState igual a InitialState
plan_regress(State, State, Plan, Plan).

% Recursive case: desfaz uma ação do FinalState para chegar no InitialState
plan_regress(FinalState, InitialState, PartialPlan, Plan) :-
    nth1(Row, FinalState, FinalRow),
    nth1(Col, FinalRow, Num),
    Num \= 0,
    nth1(Row, InitialState, InitRow),
    nth1(Col, InitRow, 0),
    fill_cell(InitialState, Row, Col, Num, TempState),
    is_valid(InitialState, Row, Col, Num),
    Action = fill(Row, Col, Num),
    plan_regress(FinalState, TempState, [Action | PartialPlan], Plan).

% Check if Num can be placed at (Row, Col) without conflicts
is_valid(State, Row, Col, Num) :-
    nth1(Row, State, RowList),
    \+ member(Num, RowList),
    column(State, Col, ColumnList),
    \+ member(Num, ColumnList),
    subgrid(State, Row, Col, Subgrid),
    \+ member(Num, Subgrid).

% Extract a column from the grid
column([], _, []).
column([Row|Rest], Col, [Value|Values]) :-
    nth1(Col, Row, Value),
    column(Rest, Col, Values).

% Extract the 2x2 subgrid containing (Row, Col)
subgrid(State, Row, Col, Subgrid) :-
    SubRow is ((Row - 1) // 2) * 2 + 1,
    SubCol is ((Col - 1) // 2) * 2 + 1,
    nth1(SubRow, State, Row1),
    RowNext is SubRow + 1,
    nth1(RowNext, State, Row2),
    nth1(SubCol, Row1, A), SubCol1 is SubCol + 1, nth1(SubCol1, Row1, B),
    nth1(SubCol, Row2, C), nth1(SubCol1, Row2, D),
    Subgrid = [A, B, C, D].

% Fill cell (Row, Col) with Num
fill_cell(State, Row, Col, Num, NewState) :-
    nth1(Row, State, RowList),
    replace(RowList, Col, Num, NewRowList),
    replace(State, Row, NewRowList, NewState).

% Helper: Replace element at position in a list
replace([_|T], 1, X, [X|T]).
replace([H|T], Pos, X, [H|NewT]) :-
    Pos > 1,
    NextPos is Pos - 1,
    replace(T, NextPos, X, NewT).
```

------------------
% para testar:
/*
Final = [
     [1, 2, 3, 4],
     [3, 4, 1, 2],
     [2, 1, 4, 3],
     [4, 3, 2, 1]
   ],
   Initial = [
     [1, 0, 0, 0],
     [3, 4, 0, 0],
     [2, 0, 0, 0],
     [0, 0, 0, 0]
   ],
   plan(Final, Initial, Plan).
*/


/*
Alunos: 
Ana Letícia dos Santos Souza
Fernanda de Oliveira da Costa
Stanley de Carvalho Monteiro
Jhonatas Costa Oliveira
Ícaro Costa Moreira
Giulia Lima Duarte

*/
