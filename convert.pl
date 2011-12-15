:- use_module(library(sgml)).
:- use_module(library(sgml_write)).
:- use_module(library(xpath)).
:- use_module(library(apply)).
:- dynamic(id_to_term/2).
:- dynamic(processed/1).

map_dom(P, [], []).
map_dom(P, [H | T], [H0 | T0]) :-
    map_dom(P, H, H0),
    map_dom(P, T, T0).
map_dom(P, X, Y) :- call(P, X, Y), !.
map_dom(P, element(Name, Attr, Children), element(Name, Attr, DChildren)) :-
    map_dom(P, Children, DChildren).
map_dom(_, X, X).

sew_dom(P, [], [], S, S).
sew_dom(P, [H | T], [H0 | T0], S0, S1) :-
    sew_dom(P, H, H0, S0, St),
    sew_dom(P, T, T0, St, S1).
sew_dom(P, X, Y, S0, S1) :- call(P, X, Y, S0, S1), !.
sew_dom(P, element(Name, Attr, Children), element(Name, Attr, DChildren), S0, S1) :-
    sew_dom(P, Children, DChildren, S0, S1).
sew_dom(P, X, X, S, S).

process_attr_template(_, [], []).
process_attr_template(element(_, Attrs, _),
                      [Name = & | T], [Name = Val | T0]) :-
    memberchk(Name = Val, Attrs), !,
    process_attr_template(Dom, T, T0).
process_attr_template(Dom, [_ | T], T0) :-
    process_attr_template(Dom, T, T0).
process_attr_template(Dom, [Name = &(XPath) | T], T1) :-
    findall(X, xpath(Dom, XPath, X), Slots),
    process_attr_template(Dom, T, T0),
    maybe_add_value(Name, Slots, T0, T1).
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
    delete(X = _, State, State0).
eval_state(State, X, [X = true | State]) :-
    delete(X = _, State, State0).
    
process_template(_, _, [], []).
process_template(State, Dom, [H | T], Result) :-
    process_template(State, Dom, H, Result1),
    process_template(State, Dom, T, Result2),
    append(Result1, Result2, Result).
process_template(State, Dom, element(Name, Attrs, Children),
                 [element(Name, ResAttrs, Result)]) :-
    process_attr_template(Dom, Attrs, ResAttrs),
    process_template(State, Children, Result).
process_template(State, element(_, _, Children), &, Result) :-
    tei_to_html(State, Children, Result).
process_template(State, Dom, &(XPath), Result) :-
    findall(X, xpath(Dom, XPath, X), Children),
    tei_to_html(State, Children, Result).
process_template(State, Dom, id(XPath), Result) :-
    xpathchk(Dom, XPath, Id),
    id_to_term(Id, Target),
    tei_to_html(State, Target, Result).
process_template(State, Dom, NewState : Next, Result) :-
    eval_state(State, NewState, RealNewState),
    process_template([NewState | State], Dom, Nex, Result).
process_template(_, Dom, map(F), [Result]) :-
    map_dom(F, Dom, Result).
process_template(State, Dom, map(F, Sub), Result) :-
    process_template(State, Dom, Sub, Result0),
    map_dom(F, Result0, Result).
process_template(State, Dom, call(F), Result) :-
    call(F, State, Dom, Result).
process_template(State, Dom, (A ; B), Result) :-
    process_template(State, Dom, A, ResultA),
    ResultA = [] -> process_template(State, Dom, B, Result); Result = ResultA.
process_template(_, _, X, [X]).

tei_to_html(_, [], []).
tei_to_html(State, [H | T], Result) :-
    tei_to_html(State, H, Result1),
    tei_to_html(State, T, Result2),
    append(Result1, Result2, Result),    
tei_to_html(State, Source, Result) :-
    teirule(Source, Template, ReqState),
    (var(ReqState); subset(ReqState, State)),
    process_template(State, Source, Template, Result).
tei_to_html(State, element(_, _, Children), Result) :-
    tei_to_html(State, Children, Result).
tei_to_html(State, _, []) :- memberchk(notext, State), !.
tei_to_html(_, X, [X]).

teirule(element(tei.2, _, _), element(html, [],
                                      element(body, [], &)), _).

teirule(element(bibl, _, _), bibl : & , _).
teirule(element(title, _, _), ['"', &, '"'], [bibl = true]).
teirule(element(title, Attrs, _), [call(mkheading)], _) :-
teirule(element(forename, _, _), [&, ' '], _).
teirule(element(surname, _, _), [&, ' '], _).
teirule(element(div, _, _), [element(div, [class='tei-div'],
                                     (level = level + 1) : &)], _).
teirule(element(div0, _, _), [element(div, [class='tei-div'],
                                      (level = 0) : &)], _).
teirule(element(div1, _, _), [element(div, [class='tei-div'],
                                      (level = 1) : &)], _).
teirule(element(div2, _, _), [element(div, [class='tei-div'],
                                      (level = 2) : &)], _).
teirule(element(div3, _, _), [element(div, [class='tei-div'],
                                      (level = 3) : &)], _).
teirule(element(name, Attrs, _), [element(a, [class = Class, name = &(/self(@id))])], _) :-
    memberchk(type = Type, Attrs),
    atom_concat('tei-name.', Type, Class).
teirule(element(add, _, _), [element(small, [class='tei-add'], &)], _).
teirule(element(abbr, _, _), [&, '. '], _).
teirule(element(space, Attrs, _), [element(hr, [height = 0, width = Width])], _) :-
    memberchk(dim = horizontal, Attrs),
    memberchk(extent = Extent, Attrs),
    atom_concat(WidthN, ' characters', Extent),
    atom_concat(WidthN, 'em', Width).

teirule(element(anchor, _, []), ['||'], _).

teirule(element(item, _, _), [element(dt, [class = 'tei-label'], &(label/'*')),
                              element(dd, [class = 'tei-item'], &)],
        [list = definition]).
teirule(element(head, _, _), [element(tr, [class = tei-head],
                                      [element(th, [colspan=2], &)])],
        [list = bill]).
teirule(element(item, _, _), [element(tr, [class = 'tei-item'],
                                      [element(td, [], [&, element(hr, [], [])]),
                                       element(td, [class = 'tei-label'], &(label/'*'))
                                      ])],
        [list = bill]).
teirule(element(head, _, _), [element(th, [class='tei-head'], &)], [list = synced]).
teirule(element(item, _, _), [element(td, [class='tei-item'], &)], [list = synced]).

teirule(element(head, _, _), [element(tr, [class='tei-head'],
                                      [element(th, [], &)])],
        [list = simple]).
teirule(element(item, _, _), [element(tr, [class='tei-item'],
                                      [element(td, [], &)])],
        [list = simple]).

teirule(element(head, Attrs, _), [element(tr, [class='tei-head'],
                                          [element(th, [], &),
                                           (list = synced) : id(self(@corresp))])],
        [list = sync]).

teirule(element(item, Attrs, Children), [element(tr, [class='tei-item'],
                                          [element(td, [], &),
                                           (list = synced) : id(self(@corresp))])],
        [list = sync]).

teirule(element(item, _, _), [element(li, [class='tei-item'], &)], _).
teirule(element(head, _, _), [element(p, [class='tei-head'], &)], [list = _]).
teirule(element(label, _, _), &, [list = synced]).
teirule(element(label, _, _), &, [list = simple]).
teirule(element(label, _, _), &, [list = sync]).
teirule(element(label, _, _), [], _).

teirule(element(list, Attrs, _), [call(listhead), (list = ordered) :
                                 element(ol, [class='tei-list.ordered'], &)], _) :-
    memberchk(type = ordered, Attrs).
teirule(element(list, Attrs, _), [call(listhead), (list = bulleted) :
                                 element(ul, [class='tei-list.bulleted'], &)], _) :-
    memberchk(type = bulleted, Attrs).
teirule(element(list, Attrs, _), [call(listhead), (list = definition) :
                                 element(dl, [class='tei-list.dialogue'], &)], _) :-
    memberchk(type = dialogue, Attrs).
teirule(element(list, Attrs, _), [(list = bill) :
                                 element(table, [class='tei-list.bulleted'], &)], _) :-
    memberchk(type = bill, Attrs).
teirule(element(list, Attrs, _), Result, _) :-
    memberchk(type = simple, Attrs),
    memberchk(corresp = Id, Attrs),
    processed(Id) -> Result = [] ;
    Result = [element(table, [class='tei-list.simple'],
                      (list = sync) : &), call(mkprocessed)].
teirule(element(table, _, _), [element(table, [class='tei-table'], &)], _).
teirule(element(tr, _, _), [element(tr, [class='tei-row'], &)], _).
teirule(element(cell, _, _), [element(td, [class='tei-cell', rowspan = &(self(@))], [& ; sdata(nbsp)])], _).
teirule(element(lg, _, _), [element(p, [class='tei-lg'], &)], _).
teirule(element(lg1, _, _), [element(p, [class='tei-lg1'], &)], _).
teirule(element(lg2, _, _), [element(p, [class='tei-lg2'], &)], _).
teirule(element(l, _, _), [element(span, [class='tei-l'], &), element(br, [], [])], _).
teirule(element(p, _, _), [element(p, [class='tei-p'], &)], _).
teirule(element(q, _, _), ['"', &, '"'], _).
teirule(element(quote, _, _), [element(em, [class='tei-quote'], &)], _).
teirule(element(salute, _, _), [element(p, [class='tei-salute'], &)], _).
teirule(element(signed, _, _), [element(p, [class='tei-signed'], &)], _).
teirule(element(argument, _, _), [element(p, [class='tei-signed'],
                                          [element(em, [], &)])], _).
teirule(element(epigraph, _, _), [element(p, [class='tei-epigraph'], &)], _).