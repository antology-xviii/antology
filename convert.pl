:- use_module(library(sgml)).
:- use_module(library(sgml_write)).
:- use_module(library(xpath)).
:- use_module(library(apply)).
:- initialize(nb_setval(next_id, 0)).
:- dynamic(id_to_term/2).
:- dynamic(correspondence/1).

make_identifiers([X | T], [X0 | T0]) :-
    make_identifiers(X, X0),
    make_identifiers(T, T0).
make_identifiers(element(Name, Attrs, Children), element(Name, [id = NewId | Attrs], Children0)) :-
    \+ memberchk(id = _, Attrs),
    nb_getval(next_id, Old), New is Old + 1, nb_setval(next_id, New),
    atom_concat('auto.', Name, Name0),
    atomic_concat(Name0, New, NewId),
    asserta(id_to_term(NewId, element(Name, Attrs, Children))),
    make_identifiers(Children, Children0).
make_identifiers(element(Name, Attrs, Children), element(Name, Attrs, Children0))) :-
    memberchk(id = Id, Attrs),
    asserta(id_to_term(Id, element(Name, Attrs, Children))),
    make_identifiers(Children, Children0).
make_identifiers(X, X).

process_template(_, _, [], []).
process_template(State, Dom, [H | T], Result) :-
    process_template(State, Dom, H, Result1),
    process_template(State, Dom, T, Result2),
    append(Result1, Result2, Result).
process_template(State, Dom, element(Name, Attrs, Children), [element(Name, Attrs, Result)]) :-
    process_template(State, Children, Result).
process_template(State, element(_, _, Children), down([]), Result) :-
    tei_to_html(State, Children, Result).
process_template(State, Dom, down(XPath), Result) :-
    findall(X, xpath(Dom, XPath, X), Children),
    tei_to_html(State, Children, Result).
process_template(State, Dom, with(NewState), Result) :-
    append(NewState, State, State1),
    tei_to_html(State1, Dom, Result).
process_template(State, Dom, with(NewState, Next), Result) :-
    append(NewState, State, State1),
    process_template(State1, Dom, Nex, Result).
process_template(_, _, X, [X]).

tei_to_html(_, [], []).
tei_to_html(State, [H | T], Result) :-
    tei_to_html(State, H, Result1),
    tei_to_html(State, T, Result2),
    append(Result1, Result2, Result),    
tei_to_html(State, Source, Result) :-
    teirule(Source, Template, State),
    process_template(State, Source, Template, Result).

teirule(element(title, _, _), ['"', down([]), '"'], State) :- memberchk(bibl, State), !.
teirule(element(title, _, _), 

teirule(Source, Template, _) :- teirule(Source, Template).
teirule(element(_, _, _), down([]), _).
teirule(X, [], State) :- memberchk(notext, State).
teirule(X, [X], _).

teirule(element(bibl, _, _), with([bibl], down([]))).
teirule(element(title

tei_to_html(State, element(bibl, _, Children), Result) :-
    tei_descend([bibl | State], Children, Result).

tei_to_html(State, element(title, _, Children), Result) :-
    memberchk(bibl, State), !,
    tei_descend(State, Children, Title),
    enclose('"', Title, '"', Result).

tei_to_html(State, element(title, Attrs, Children), [element(Heading, [class=title], HChildren)]) :-
    tei_descend(State, Children, HChildren),
    (memberchk(level = L, State); L = 0),
    (memberchk(kind = subordinate, Attrs) -> I = 2; I = 1),
    L0 is L + I,
    mkheadertag(L0, Heading).

tei_to_html(State, element(forename, _, Children), Result) :-
    tei_descend(State, Childen, Result0),
    append(Result, [' '], Result).

tei_to_html(State, element(surname, _, Children), Result) :-
    tei_descend(State, Childen, Result0),
    append(Result, [' '], Result).

tei_to_html(State, element(div, _, Children), [element(div, [], HChildren)]) :-
    next_level(State, State0),
    tei_descend(State0, Children, HChildren).

tei_to_html(State, element(div0, _, Children), [element(div, [], HChildren)]) :-
    tei_descend([level = 0 | State], Children, HChildren).

tei_to_html(State, element(div1, _, Children), [element(div, [], HChildren)]) :-
    tei_descend([level = 1 | State], Children, HChildren).

tei_to_html(State, element(div2, _, Children), [element(div, [], HChildren)]) :-  
    tei_descend([level = 2 | State], Children, HChildren).

tei_to_html(State, element(div3, _, Children), [element(div, [], HChildren)]) :-
    tei_descend([level = 3 | State], Children, HChildren).

tei_to_html(State, element(name, Attrs, Children), [element(a, [class=Class, name=Id], HChildren)]) :-
    memberchk(type = Type, Attrs),
    memberchk(id = Id, Attrs),
    tei_descend(State, Children, HChildren),
    atom_concat('tei-name.', Type, Class).

tei_to_html(State, element(add, _, Children), [element(small, [class='tei.add'], HChildren)]) :-
    tei_descend(State, Children, HChildren).

tei_to_html(State, element(abbr, _, Children), Result) :-
    tei_descend(State, Children, HChildren),
    append(HChildren, ['. '], Result).

tei_to_html(State, element(space, Attrs, []), [element(hr, [height = '0px', width = Width], [])]) :-
    memberchk(dim = horizontal, Attrs),
    memberchk(extent = Extent, Attrs),
    atom_concat(WidthN, ' characters', Extent),
    atom_concat(WidthN, 'em', Width).

tei_to_html(State, element(anchor, _, []), ['||']).

tei_to_html(State, element(item, _, Children), [element(dt, [], HLabel), element(dd, [], Result)]) :-
    memberchk(list = definition, State),
    memberchk(element(label, _, LChildren), Children),
    tei_descend(State, LChildren, HLabel),
    tei_descend(State, Children, Result).

tei_to_html(State, element(item, _, Children), [element(tr, [class='tei-item'],
                                                        [element(td, [], Result),
                                                         element(td, [], HLabel)])]) :-
    memberchk(list = bill, State),
    memberchk(element(label, _, LChildren), Children),
    tei_descend(State, LChildren, HLabel),
    tei_descend(State, Children, HChildren),
    append(HChildren, [element(hr, [], [])], Result).

tei_to_html(State, element(head, _, Children), [element(tr, [class='tei-head'],
                                                        [element(th, [colspan = '2'], Head)])]) :-
    memberchk(list = bill, State),
    tei_descend(State, Children, Head).

tei_to_html(State, element(head, _, Children), [element(th, [class='tei-head'], Head)]) :-
    memberchk(list = synced, State),
    tei_descend(State, Children, Head).

tei_to_html(State, element(item, _, Children), [element(td, [class='tei-item'], Result)]) :-
    memberchk(list = synced, State),
    tei_descend(State, Children, Result).

tei_to_html(State, element(head, _, Children), [element(tr, [class='tei-head'],
                                                        [element(th, [], Head)])]) :-
    memberchk(list = simple, State),
    tei_descend(State, Children, Head).

tei_to_html(State, element(item, _, Children), [element(tr, [class='tei-item'],
                                                        [element(td, [], Result)])]) :-
    memberchk(list = simple, State),
    tei_descend(State, Children, Result).

tei_to_html(State, element(head, Attrs, Children), [element(tr, [class='tei-head'],
                                                        [element(th, [], Head) | Sync])]) :-
    memberchk(list = sync, State),
    memberchk(corresp = Id, Attrs),
    id_to_term(Id, Corresp),
    tei_to_html([list = synced | State], Corresp, Sync),
    tei_descend(State, Children, Head).

tei_to_html(State, element(item, Attrs, Children), [element(tr, [class='tei-item'],
                                                        [element(td, [], Result) | Sync])]) :-
    memberchk(list = sync, State),
    memberchk(corresp = Id, Attrs),
    id_to_term(Id, Corresp),
    tei_to_html([list = synced | State], Corresp, Sync),
    tei_descend(State, Children, Result).

tei_to_html(State, element(item, _, Children), [element(li, [class='tei-item'], HChildren)]) :-
    tei_descend(State, Children, HChildren).

tei_to_html(State, element(head, _, Children), [element(p, [class='tei-head'], HChildren)]) :-
    memberchk(list = _, State),
    tei_descend(State, Children, HChildren).

tei_to_html(State, element(label, _, Children), Result) :-
    (memberchk(list = synced, State); memberchk(list = simple, State); memberchk(list = sync, State)), !,
    tei_descend(State, Children, Result).

tei_to_html(_, element(label, _, _), []).


tei_to_html(State, element(list, Attrs, Children), Result) :-
    memberchk(type = ordered, Attrs),
    State0 = [list = ordered | State],
    tei_descend(State0, Children, Result0
               ),
    maybelisthead(State0, Children,
                  element(ol, [class = 'tei-list.ordered'],
                          Result0
                         )).

tei_to_html(State, element(list, Attrs, Children), Result) :-
    memberchk(type = bulleted, Attrs),
    State0 = [list = bulleted | State],
    tei_descend(State0, Children, Result0),
    maybelisthead(State0, Children,
                  element(ul, [class = 'tei-list.bulleted'],
                          Result0
                         )).    

tei_to_html(State, element(list, Attrs, Children), Result) :-
    memberchk(type = definition, Attrs),
    State0 = [list = definition | State],
    tei_descend(State0, Children, Result0),
    maybelisthead(State0, Children,
                  element(dl, [class = 'tei-list.dialogue'],
                          Result0
                         )).    

tei_to_html(State, element(list, Attrs, Children),
            [element(table, [class='tei-list.bill'], Result)]) :-
    memberchk(type = bill, Attrs),
    State0 = [list = bill | State],
    tei_descend(State0, Children, Result0).

    
tei_to_html(State, element(Name, _, Children), HChildren) :-
    tei_descend(State, Children, HChildren).

tei_to_html(State, sdata(Text), []) :- memberchk(notext, State).
tei_to_html(_, sdata(Text), [Text]).
tei_to_html(State, Text, []) :- atom(Text), memberchk(notext, State).
tei_to_html(_, Text, [Text]) :- atom(Text).
tei_to_html(_, _, []).

tei_descend(State, Src, Dest) :-
    maplist(tei_to_html(State), Src, DestX),
    append(DestX, Dest).

enclose(Before, Body, After, [Before | App]) :-
    append(Body, [After], App).

next_level(Source, [level = L0 | Source]) :-
    memberchk(level = L, Source),
    L0 is L + 1.
next_level(Source, [level = 0 | Source]).

mkheadertag(L, Heading) :-
    atomic_concat(h, HL, Heading).   
