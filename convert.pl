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

eval_attr_template(element(_, Attrs, _), Name, &, Val) :- !,
    memberchk(Name = Val, Attrs).
eval_attr_template(element(_, Attrs, _), _, @Name, Val) :- !,
    memberchk(Name = Val, Attrs).
eval_attr_template(Dom, Name, (X ; Y), Val) :- !,
    (eval_attr_template(Dom, Name, X, Val);
     eval_attr_template(Dom, Name, Y, Val)).
eval_attr_template(Dom, Name, &(XPath), Val) :- !,
    findall(X, xpath(Dom, XPath, X), Slots),
    Slots /= [],
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
    delete(X = _, State, State0).
eval_state(State, X, [X = true | State]) :-
    delete(X = _, State, State0).

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

process_template(_, _, [], []).
process_template(State, Dom, [H | T], Result) :-
    process_template(State, Dom, H, Result1), !,
    process_template(State, Dom, T, Result2), 
    append(Result1, Result2, Result).
process_template(State, Dom, [_ | T], Result) :-
    process_template(State, Dom, T, Result), !.
process_template(State, Dom, element(Name, Attrs, Children),
                 [element(Name, ResAttrs, Result)]) :- !,
    process_attr_template(Dom, Attrs, ResAttrs),
    process_template(State, Children, Result).
process_template(State, element(_, _, Children), &, Result) :- !,
    tei_to_html(State, Children, Result).
process_template(State, Dom, &(XPath), Result) :- !,
    findall(X, xpath(Dom, XPath, X), Children),
    tei_to_html(State, Children, Result).
process_template(State, Dom, id(XPath), Result) :- !,
    xpathchk(Dom, XPath, Id),
    id_to_term(Id, Target),
    tei_to_html(State, Target, Result).
process_template(State, element(Name, Attrs, Children), (Cond -> Next), Result) :- !,
    check_cond(State, Attrs, Cond),
    process_template(State, element(Name, Attrs, Children), Next, Result).
process_template(State, Dom, NewState : Next, Result) :- !,
    eval_state(State, NewState, RealNewState),
    process_template([NewState | State], Dom, Nex, Result).
process_template(State, Dom, once(Next), Result) :- !,
    Dom = element(_, Attrs, _), 
    memberchk(id = Id, Attrs),
    \+ processed(Id),
    process_template(State, Dom, Next, Result).
process_template(_, Dom, map(F), [Result]) :- !,
    map_dom(F, Dom, Result).
process_template(State, Dom, map(F, Sub), Result) :- !,
    process_template(State, Dom, Sub, Result0),
    map_dom(F, Result0, Result).
process_template(State, Dom, call(F), Result) :- !,
    call(F, State, Dom, Result).
process_template(State, Dom, call(F, Sub), Result) :- !,
    process_template(State, Dom, Sub, Result0),
    call(F, State, Dom, Result0, Result).
process_template(State, Dom, (A ; B), Result) :- !,
    (process_template(State, Dom, A, ResultA),  ResultA /= []) ->
    Result = ResultA ;
    process_template(State, Dom, B, Result).
process_template(State, Dom, (A , B), Result) :- !,
    process_template(State, Dom, A, ResultA),
    (ResultA /= [] -> (process_template(State, Dom, B, ResultB), append(ResultA, ResultB, Result)) ; Result = ResultA).
process_template(_, _, X, [X]).

tei_to_html(_, [], []).
tei_to_html(State, [H | T], Result) :-
    tei_to_html(State, H, Result1),
    tei_to_html(State, T, Result2),
    append(Result1, Result2, Result),    
tei_to_html(State, Source, Result) :-
    teirule(Source, Template),
    process_template(State, Source, Template, Result),
    make_processed(Source).
tei_to_html(State, X, Result) :-
    X = element(_, _, Children), 
    tei_to_html(State, Children, Result),
    make_processed(X).
tei_to_html(State, _, []) :- memberchk(notext, State), !.
tei_to_html(_, X, [X]).

make_processed(element(_, Attrs, _)) :-
    memberchk(id = Id, Attrs),
    asserta(processed(Id)).
make_processed(_).

teirule(element(tei.2, _, _), [element(div, [], &(body)), element(hr, [], []), footnotes : &(//note)]).

teirule(element(bibl, _, _), bibl : &).
teirule(element(title, _, _), (bibl -> ['"', &, '"'])).
teirule(element(title, _, _), call(mkheading, &)).
teirule(element(forename, _, _), [&, ' ']).
teirule(element(surname, _, _), [&, ' ']).
teirule(element(div, _, _), [element(div, [class='tei-div'],
                                     (level = level + 1) : &)]).
teirule(element(div0, _, _), [element(div, [class='tei-div'],
                                      (level = 0) : &)]).
teirule(element(div1, _, _), [element(div, [class='tei-div'],
                                      (level = 1) : &)]).
teirule(element(div2, _, _), [element(div, [class='tei-div'],
                                      (level = 2) : &)]).
teirule(element(div3, _, _), [element(div, [class='tei-div'],
                                      (level = 3) : &)]).
teirule(element(name, Attrs, _), [element(a, [class = te, name = &(/self(@id))])]) :-
    memberchk(type = Type, Attrs),
    atom_concat('tei-name.', Type, Class).
teirule(element(add, _, _), [element(small, [class='tei-add'], &)]).
teirule(element(abbr, _, _), [&, '. ']).
teirule(element(space, Attrs, _), (@dim = horizontal -> [element(hr, [height = 0, width = Width])])) :-
    memberchk(extent = Extent, Attrs),
    atom_concat(WidthN, ' characters', Extent),
    atom_concat(WidthN, 'em', Width).

teirule(element(anchor, _, []), ['||']).

teirule(element(item, _, _), (list = definition -> [element(dt, [class = 'tei-label'], &(label/'*')),
                                                    element(dd, [class = 'tei-item'], &)])).
teirule(element(head, _, _), (list = bill -> [element(tr, [class = tei-head],
                                                      [element(th, [colspan=2], &)])]))
teirule(element(item, _, _), (list = bill -> [element(tr, [class = 'tei-item'],
                                                      [element(td, [], [&, element(hr, [], [])]),
                                                       element(td, [class = 'tei-label'], &(label/'*'))
                                                      ])]))
teirule(element(head, _, _), (list = synced ->
                              [element(th, [class='tei-head'], &)])).
teirule(element(item, _, _), (list = synced ->
                              [element(td, [class='tei-item'], &)])).

teirule(element(head, _, _), (list = simple ->
                              [element(tr, [class='tei-head'],
                                       [element(th, [], &)])])).
teirule(element(item, _, _), (list = simple ->
                              [element(tr, [class='tei-item'],
                                       [element(td, [], &)])])).                            

teirule(element(head, Attrs, _), (list = sync ->
                                  [element(tr, [class='tei-head'],
                                           [element(th, [], &),
                                            (list = synced) : id(self(@corresp))])])).

teirule(element(item, Attrs, Children), (list = sync -> [element(tr, [class='tei-item'],
                                                                 [element(td, [], &),
                                                                  (list = synced) : id(self(@corresp))])])).
teirule(element(item, _, _), [element(li, [class='tei-item'], &)]).
teirule(element(head, _, _), (list = _ -> [element(p, [class='tei-head'], &)])).
teirule(element(label, _, _), ((list = synced ; list = simple ; list = sync) -> &)).
teirule(element(label, _, _), []).

teirule(element(list, _, _), (@type = ordered -> (list = ordered) : [&(head),
                                                 element(ol, [class='tei-list.ordered'], &(item))])).
teirule(element(list, _, _), (@type = bulleted -> (list = bulleted) : [&(head), 
                                                  element(ul, [class='tei-list.bulleted'], &(item))])).
teirule(element(list, _, _), (@type = dialogue -> (list = definition) : [&(head), 
                                                  element(dl, [class='tei-list.dialogue'], &(item))])).
teirule(element(list, _, _), (@type = bill -> (list = bill) :
                                              element(table, [class='tei-list.bulleted'], &)).
teirule(element(list, _, _), ((@type = simple , @corresp) -> once([element(table, [class='tei-list.simple'],
                                                                               (list = sync) : &)]))) :- !.
teirule(element(list, _, _), (@type = simple -> element(table, [class = 'tei-list.simple'],
                                                        (list = simple) : &))).
teirule(element(table, _, _), [element(table, [class='tei-table'], &)]).
teirule(element(tr, _, _), [element(tr, [class='tei-row'], &)]).
teirule(element(cell, _, _), [element(td, [class='tei-cell', rowspan = &(self(@))], [& ; sdata(nbsp)])]).
teirule(element(lg, _, _), [element(p, [class='tei-lg'], &)]).
teirule(element(lg1, _, _), [element(p, [class='tei-lg1'], &)]).
teirule(element(lg2, _, _), [element(p, [class='tei-lg2'], &)]).
teirule(element(l, _, _), [element(span, [class='tei-l'], &), element(br, [], [])]).
teirule(element(p, _, _), [element(p, [class='tei-p'], &)]).
teirule(element(q, _, _), ['"', &, '"']).
teirule(element(quote, _, _), [element(em, [class='tei-quote'], &)]).
teirule(element(salute, _, _), [element(p, [class='tei-salute'], &)]).
teirule(element(signed, _, _), [element(p, [class='tei-signed'], &)]).
teirule(element(argument, _, _), [element(p, [class='tei-signed'],
                                          [element(em, [], &)])], _).
teirule(element(epigraph, _, _), [element(p, [class='tei-epigraph'], &)]).

teirule(element(sp, _, _), (aligned -> [element(tr, [], [element(td, [class='tei-sp'], &)])])).
teirule(element(sp, _, _), (@corresp -> once(element(table, [class='tei-sp.corresp'],
                                                      [(aligned = true) : &(self),
                                                       (aligned = true) : call(find_corresponding),
                                                       element(big, [class='tei-sp.corresp'], ['}'])])))).

teirule(element(speaker, _, _), [element(strong, [class='tei-speaker'], &)]).
teirule(element(stage, _, _), (@type = delivery -> [element(em, [class='tei-stage.delivery'], &)])) :- !.
teirule(element(stage, _, _), element(p, [class='tei-stage'], &)).
teirule(element(move, _, _), []).
teirule(element(castlist, _, _), (list = cast) : [&(head), element(ul, [class='tei-castlist'], &(castitem))]).
teirule(element(head, _, _), (list = cast -> element(h2, &))).
teirule(element(role, _, _), [&, ' ']).
teirule(element(roledesc, _, _), element(span, [class='tei-roledesc'], &)).
teirule(element(set, _, _), element(p, [class='tei-set'], &)).
teirule(element(performance, _, _), []).
teirule(element(dateline, _, _), element(p, [class='tei-dateline'], [element(em, [], &)])).
teirule(element(xref, _, _), element(a, [class='tei-xref', href=''], &)).
teirule(element(figure, _, _), []).
teirule(element(date, _, _), [call(dateprefix), (&, " г.")]).
teirule(element(emph, _, _), element(em, [class='tei-emph'], &)).
teirule(element(term, _, _), element(strong, [class='tei-term'], &)).
teirule(element(mentioned, _, _), element(em, [class='tei-mentioned'], &)).
teirule(element(foreign, _, _), element(em, [class='tei-foreign'], &)).
teirule(element(socalled, _, _), element(em, [class='tei-socalled'], &)).
teirule(element(hi, _, _), element(em, [class='tei-hi'], &)).
teirule(element(trailer, _, _), element(p, [class='tei-trailer'], &)).
teirule(element(closer, _, _), element(p, [class='tei-closer'], &)).
teirule(element(note, _, _), (@place = inline -> element(small, [class='tei-note.inline'], &))) :- !.
teirule(element(note, _, _), (footnote -> element(sup, [class='tei-note.index'],
                                                  element(a, [class='tei-note.index',
                                                              href=Href