:- module(sgmltools, [map_dom/3, sew_dom/5, transform_dom/4,
                      id_to_term/2, complete_ids/2,
                      reset_transform/0]).
:- use_module(library(debug)).
:- use_module(library(sgml)).
:- use_module(library(xpath)).
:- use_module(library(apply)).
:- dynamic(id_to_term/2).
:- dynamic(processed/1).
:- meta_predicate map_dom(2, +, ?).
:- meta_predicate sew_dom(4, +, ?, +, ?).
:- meta_predicate transform_dom(2, +, +, ?).

map_dom(_, [], []).
map_dom(P, [H | T], [H0 | T0]) :-
    map_dom(P, H, H0),
    map_dom(P, T, T0).
map_dom(P, X, Y) :- call(P, X, Y), !.
map_dom(P, element(Name, Attr, Children), element(Name, Attr, DChildren)) :-
    map_dom(P, Children, DChildren).
map_dom(_, X, X).

sew_dom(_, [], [], S, S).
sew_dom(P, [H | T], [H0 | T0], S0, S1) :-
    sew_dom(P, H, H0, S0, St),
    sew_dom(P, T, T0, St, S1).
sew_dom(P, X, Y, S0, S1) :- call(P, X, Y, S0, S1), !.
sew_dom(P, element(Name, Attr, Children), element(Name, Attr, DChildren), S0, S1) :-
    sew_dom(P, Children, DChildren, S0, S1).
sew_dom(_, X, X, S, S).

eval_attr_template(element(_, Attrs, _), Name, &, Val) :- !,
    memberchk(Name = Val, Attrs).
eval_attr_template(element(_, Attrs, _), _, @Name, Val) :- !,
    memberchk(Name = Val, Attrs).
eval_attr_template(Dom, Name, (X ; Y), Val) :- !,
    (eval_attr_template(Dom, Name, X, Val);
     eval_attr_template(Dom, Name, Y, Val)).
eval_attr_template(Dom, _, &(XPath), Val) :- !,
    findall(X, xpath(Dom, XPath, X), Slots),
    Slots \= [],
    (Slots = [Val] ; Slots = Val).
eval_attr_template(Dom, _, call(F), Val) :- !,
    call(F, Dom, Val).
eval_attr_template(Dom, Name, call(F, X), Val) :- !,
    eval_attr_template(Dom, Name, X, Val0),
    call(F, Dom, Val0, Val).
eval_attr_template(Dom, Name, (X : Y), Val) :- !,
    eval_attr_template(Dom, Name, X, Val1),
    eval_attr_template(Dom, Name, Y, Val2),
    atom_concat(Val1, Val2, Val).
eval_attr_template(Dom, Name, (X - Y), Val) :- !,
    eval_attr_template(Dom, Name, X, Val1),
    eval_attr_template(Dom, Name, Y, Val2),
    atom_concat(Val, Val2, Val1).
eval_attr_template(_, _, X, X).

process_attr_template(_, [], []).
process_attr_template(Dom, [Name = Src | T], [Name = Val | T0]) :-
    eval_attr_template(Dom, Name, Src, Val), !,
    process_attr_template(Dom, T, T0).
process_attr_template(Dom, [_ | T], T0) :-
    process_attr_template(Dom, T, T0).

process_attr_template(Dom, [Name = call(F) | T], [Name = Y | T0]) :- !,
    call(F, Dom, Y),
    process_attr_template(Dom, T, T0).
process_attr_template(Dom, [Name = X | T], [Name = X | T0]) :-
    process_attr_template(Dom, T, T0).

maybe_add_value(_, [], X, X) :- !.
maybe_add_value(Name, [V], X, [Name = V | X]) :- !.
maybe_add_value(Name, Vs,  X, [Name = Vs | X]).

eval_state(State, X = X + N, [X = K | State0]) :-
    selectchk(X = M, State, State0), !,
    K is M + N.
eval_state(State, X = X + N, [X = N | State]) :- !.
eval_state(State, X = Y, [X = Y | State0]) :- !,
    (delete(X = _, State, State0) ; State0 = State).
eval_state(State, X, [X = true | State0]) :-
    delete(X = _, State, State0) ; State0 = State.

check_cond(State, Attrs, (C1, C2)) :-
    check_cond(State, Attrs, C1),
    check_cond(State, Attrs, C2), !.
check_cond(State, Attrs, (C1; C2)) :-
    (check_cond(State, Attrs, C1); 
     check_cond(State, Attrs, C2)), !.
check_cond(State, Attrs, \+ C) :- \+ check_cond(State, Attrs, C), !.
check_cond(_, Attrs, (@X = Y)) :- memberchk(X = Y, Attrs), !.
check_cond(_, Attrs, @X) :- memberchk(X = _, Attrs), !.
check_cond(State, _, (X = Y)) :- memberchk(X = Y, State), !.
check_cond(State, _, X) :- memberchk(X = true, State).

make_name(State, X : Y, Z) :- !,
    make_name(State, X, Z0),
    make_name(State, Y, Z1),
    atomic_concat(Z0, Z1, Z).
make_name(State, +X, Y) :- !,
    memberchk(X = Y, State).
make_name(State, X + N, Y) :- !,
    memberchk(X = Y0, State) -> Y is Y0 + N ; Y = N.
make_name(_, X, X).

process_template(_, _, _, [], []).
process_template(Rules, State, Dom, [H | T], Result) :-
    process_template(Rules, State, Dom, H, Result1), !,
    process_template(Rules, State, Dom, T, Result2), 
    append(Result1, Result2, Result).
process_template(Rules, State, Dom, [_ | T], Result) :-
    process_template(Rules, State, Dom, T, Result), !.
process_template(Rules, State, Dom, element(Name, Attrs, Children),
                 [element(MkName, ResAttrs, Result)]) :- !,
    make_name(State, Name, MkName),
    process_attr_template(Dom, Attrs, ResAttrs),
    process_template(Rules, State, Dom, Children, Result).
process_template(Rules, State, element(_, _, Children), &, Result) :- !,
    transform_dom(Rules, State, Children, Result).
process_template(Rules, State, Dom, &(XPath), Result) :- !,
    findall(X, xpath(Dom, XPath, X), Children),
    transform_dom(Rules, State, Children, Result).
process_template(Rules, State, Dom, id(XPath), Result) :- !,
    xpath_chk(Dom, XPath, Id),
    id_to_term(Id, Target),
    transform_dom(Rules, State, Target, Result).
process_template(Rules, State, element(Name, Attrs, Children), (Cond -> Next), Result) :- !,
    check_cond(State, Attrs, Cond),
    process_template(Rules, State, element(Name, Attrs, Children), Next, Result).
process_template(Rules, State, Dom, NewState : Next, Result) :- !,
    eval_state(State, NewState, RealNewState),
    process_template(Rules, RealNewState, Dom, Next, Result).
process_template(Rules, State, Dom, once(Next), Result) :- !,
    Dom = element(_, Attrs, _), 
    memberchk(id = Id, Attrs),
    \+ processed(Id),
    process_template(Rules, State, Dom, Next, Result).
process_template(_, _, Dom, map(F), [Result]) :- !,
    map_dom(F, Dom, Result).
process_template(Rules, State, Dom, map(F, Sub), Result) :- !,
    process_template(Rules, State, Dom, Sub, Result0),
    map_dom(F, Result0, Result).
process_template(_, State, Dom, call(F), Result) :- !,
    call(F, State, Dom, Result).
process_template(Rules, State, Dom, call(F, Sub), Result) :- !,
    process_template(Rules, State, Dom, Sub, Result0),
    call(F, State, Dom, Result0, Result).
process_template(Rules, _State, Dom, (A ; B), Result) :- !,
    (process_template(Rules, State, Dom, A, ResultA),  ResultA \= []) ->
    Result = ResultA ;
    process_template(Rules, State, Dom, B, Result).
process_template(Rules, State, Dom, (A , B), Result) :- !,
    process_template(Rules, State, Dom, A, ResultA),
    (ResultA \= [] ->
     (process_template(Rules, State, Dom, B, ResultB), append(ResultA, ResultB, Result)) ;
     Result = ResultA).
process_template(_, _, _, X, [X]) :- assertion(atom(X) ; X = sdata(_) ; X = ndata(_) ; X = pi(_)).

transform_dom(_, _, [], []).
transform_dom(Rules, State, [H | T], Result) :-
    transform_dom(Rules, State, H, Result1),
    transform_dom(Rules, State, T, Result2),
    append(Result1, Result2, Result).
transform_dom(Rules, State, Source, Result) :-
    call(Rules, Source, Template),
    process_template(Rules, State, Source, Template, Result),
    make_processed(Source).
transform_dom(Rules, State, X, Result) :-
    X = element(_, _, Children),
    transform_dom(Rules, State, Children, Result),
    make_processed(X).
transform_dom(_, _, pi(_), []).
transform_dom(_, _, ndata(_), []).
transform_dom(_, State, _, []) :- memberchk(notext, State), !.
transform_dom(_, _, X, [X]) :- assertion(atom(X) ; X = sdata(_)).

make_processed(element(_, Attrs, _)) :-
    memberchk(id = Id, Attrs),
    asserta(processed(Id)).
make_processed(_).
                                             
make_id(X, element(Name, Attrs0, XChildren), N, M) :-
    X = element(Name, Attrs, Children),
    (memberchk(id = Id, Attrs) ->
     Attrs0 = Attrs, N0 = N ;
     atomic_list_concat(['gen.', Name, '.', N], Id),
     Attrs0 = [id = Id | Attrs],
     N0 is N + 1),
    asserta(id_to_term(Id, X)),
    sew_dom(make_id, Children, XChildren, N0, M).

reset_transform :- abolish(processed/1).

complete_ids(Src, Dst) :-
    sew_dom(make_id, Src, Dst, 0, _).
