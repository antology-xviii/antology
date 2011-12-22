:- module(teihtml, [tei_to_html/3]).
:- use_module('sgmltools.pl').
:- use_module(library(xpath)).

tei_to_html(State, In, Out) :-
    reset_transform,
    transform_dom(teirule, State, In, Out).

corresp_term(Id, X) :- id_to_term(_, X),
    X = element(_, Attrs, _),
    memberchk(id = Id, Attrs).

find_corresponding(State, element(_, Attrs, _), Result) :-
    memberchk(id = Id, Attrs),
    findall(X, corresp_term(Id, X), List),
    tei_to_html(State, List, Result).

dateprefix(_, element(_, Attrs, _), [Cert]) :-
    memberchk(certainty = Cert0, Attrs),
    Cert0 = 'ca' -> Cert = 'около ';
    Cert0 = 'before' -> Cert = 'до ' ;
    Cert0 = 'after' -> Cert = 'после '.   
dateprefix(_, _, []).


noteresp(_, element(_, Attrs, _), element(em, [class='tei-note.resp'],
                                          ['(Прим. ', RespStr, ')'])) :-
    memberchk(resp = Resp, Attrs),
    Resp = 'author' -> RespStr = 'авт.' ;
    Resp = 'editor' -> RespStr = 'ред.'.

teirule(element('tei.2', _, _), [element(div, [],
                                         [&(teiheader/filedesc/titlestmt/author),
                                          &(teiheader/filedesc/titlestmt/title),
                                          &(text)]), element(hr, [], []), footnotes : &(//note)]).

teirule(element(bibl, _, _), bibl : &).
teirule(element(author, _, _), bibl -> &).
teirule(element(author, _, _), element(p, [class='tei-author'], &)).
teirule(element(title, _, _), (reference -> &)).
teirule(element(title, _, _), (bibl -> ['"', &, '"'])).
teirule(element(title, _, _), (@type = subordinate -> element(h : (level + 1), [], &))).
teirule(element(title, _, _), (@type = subordinate -> element(h2, [], &))).
teirule(element(title, _, _), element(h : +level, [class='tei-title'], &)).
teirule(element(title, _, _), element(h1, [class='tei-title'], &)).
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
teirule(element(name, _, _), [element(a, [class = 'tei-name.' : &(/self(@type)), name = &(/self(@id))], &)]).
teirule(element(add, _, _), [element(small, [class='tei-add'], &)]).
teirule(element(abbr, _, _), [&, '. ']).
teirule(element(space, _, _), (@dim = horizontal -> [element(hr,
                                                                 [height = 0,
                                                                  width = (&(/self(@extent)) - ' characters') : 'em'])])).
teirule(element(anchor, _, []), ['||']).

teirule(element(item, _, _), (list = definition -> [element(dt, [class = 'tei-label'], &(label/'*')),
                                                    element(dd, [class = 'tei-item'], &)])).
teirule(element(head, _, _), (list = bill -> [element(tr, [class = tei-head],
                                                      [element(th, [colspan=2], &)])])).
teirule(element(item, _, _), (list = bill -> [element(tr, [class = 'tei-item'],
                                                      [element(td, [], [&, element(hr, [], [])]),
                                                       element(td, [class = 'tei-label'], &(label/'*'))
                                                      ])])).
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

teirule(element(head, _, _), (list = sync ->
                                  [element(tr, [class='tei-head'],
                                           [element(th, [], &),
                                            (list = synced) : id(/self(@corresp))])])).

teirule(element(item, _, _), (list = sync -> [element(tr, [class='tei-item'],
                                                                 [element(td, [], &),
                                                                  (list = synced) : id(/self(@corresp))])])).
teirule(element(item, _, _), [element(li, [class='tei-item'], &)]).
teirule(element(head, _, _), (list = _ -> [element(p, [class='tei-head'], &)])).
teirule(element(label, _, _), ((list = synced ; list = simple ; list = sync) -> &)).
teirule(element(label, _, _), []).

teirule(element(list, _, _), (@type = ordered -> (list = ordered) : [&(head),
                                                 element(ol, [class='tei-list-ordered'], &(item))])).
teirule(element(list, _, _), (@type = bulleted -> (list = bulleted) : [&(head), 
                                                  element(ul, [class='tei-list-bulleted'], &(item))])).
teirule(element(list, _, _), (@type = dialogue -> (list = definition) : [&(head), 
                                                  element(dl, [class='tei-list-dialogue'], &(item))])).
teirule(element(list, _, _), (@type = bill -> (list = bill) :
                             element(table, [class='tei-list-bill'], &))).
teirule(element(list, _, _), ((@type = simple , @corresp) -> once([element(table, [class='tei-list-simple'],
                                                                               (list = sync) : &)]))).
teirule(element(list, _, _), (@type = simple -> element(table, [class = 'tei-list-simple'],
                                                        (list = simple) : &))).
teirule(element(table, _, _), [element(table, [class='tei-table'], &)]).
teirule(element(tr, _, _), [element(tr, [class='tei-row'], &)]).
teirule(element(cell, _, _), [element(td, [class='tei-cell', rowspan = &(/self(@))], [& ; sdata(nbsp)])]).
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
                                          [element(em, [], &)])]).
teirule(element(epigraph, _, _), [element(p, [class='tei-epigraph'], &)]).

teirule(element(sp, _, _), (aligned -> [element(tr, [], [element(td, [class='tei-sp'], &)])])).
teirule(element(sp, _, _), (@corresp -> once(element(table, [class='tei-sp-corresp'],
                                                      [(aligned = true) : &(/self),
                                                       (aligned = true) : call(teihtml:find_corresponding),
                                                       element(big, [class='tei-sp-corresp'], ['}'])])))).

teirule(element(speaker, _, _), [element(strong, [class='tei-speaker'], &)]).
teirule(element(stage, _, _), (@type = delivery -> [element(em, [class='tei-stage-delivery'], &)])).
teirule(element(stage, _, _), element(p, [class='tei-stage'], &)).
teirule(element(move, _, _), []).
teirule(element(castlist, _, _), (list = cast) : [&(head), element(ul, [class='tei-castlist'], &(castitem))]).
teirule(element(castitem, _, _), element(li, [class='tei-castitem'], &)).
teirule(element(head, _, _), (list = cast -> element(h2, &))).
teirule(element(role, _, _), [element(span, [class='tei-role'], &), ' ']).
teirule(element(roledesc, _, _), element(span, [class='tei-roledesc'], &)).
teirule(element(set, _, _), element(p, [class='tei-set'], &)).
teirule(element(performance, _, _), []).
teirule(element(dateline, _, _), element(p, [class='tei-dateline'], [element(em, [], &)])).
teirule(element(xref, _, _), element(a, [class='tei-xref', href=''], &)).
teirule(element(figure, _, _), []).
teirule(element(date, _, _), [call(teihtml:dateprefix), (&, " г.")]).
teirule(element(emph, _, _), element(em, [class='tei-emph'], &)).
teirule(element(term, _, _), element(strong, [class='tei-term'], &)).
teirule(element(mentioned, _, _), element(em, [class='tei-mentioned'], &)).
teirule(element(foreign, _, _), element(em, [class='tei-foreign'], &)).
teirule(element(socalled, _, _), element(em, [class='tei-socalled'], &)).
teirule(element(hi, _, _), element(em, [class='tei-hi'], &)).
teirule(element(trailer, _, _), element(p, [class='tei-trailer'], &)).
teirule(element(closer, _, _), element(p, [class='tei-closer'], &)).
teirule(element(note, _, _), ((footnote, @place = inline) -> [])).
teirule(element(note, _, _), (@place = inline -> element(small, [class='tei-note-inline'], &))).
teirule(element(note, _, _), (footnote -> [element(sup, [class='tei-note-footnote'],
                                                   element(a, [class='tei-note-footnote',
                                                               name='note-footnote.' : &(/self(@id)),
                                                               href='#note.anchor.' : &(/self(@id))],
                                                           [&(/self(@n))])),
                                           &, call(noteresp)])).
teirule(element(note, _, _), element(sup, [class='tei-note'],
                                     element(a, [class='tei-note',
                                                 name='note.anchor.' : &(/self(@id)),
                                                 href='#note.footnote.' : &(/self(@id))],
                                             [&(/self(@n))]))).

