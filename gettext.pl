#! /usr/bin/swipl -q -g main -t halt -f none -s
:- use_module('teitools.pl').
:- use_module('teihtml.pl').
:- use_module(library(pwp)).
:- use_module(library(cgi)).

main :-
    catch(main0, E, on_error(E)).

main0 :-
    cgi_get_form(Arguments),
    getenv('PATH_INFO', Filename),
    sub_atom(Filename, 1, _, 0, Filename0),
    current_output(Stdout),
    open('www/templates/gettext.pwp', read, Template, [encoding(octet)]),
    load_tei(Filename0, Source),
    tei_to_html([], Source, Formatted), !,
    writeln('Content-Type: text/xhtml; charset=utf-8'),
    nl,
    pwp_stream(Template, Stdout, ['Path' = Filename,
                                  'Source' = Source,
                                  'Contents' = Formatted]).

main0 :- writeln('Content-Type: text/plain'),
    writeln('Status: 404 Not Found'),
    nl,
    writeln('Not found').

on_error(E) :-
    print_message(error, E),
    writeln('Content-Type: text/plain'),
    writeln('Status: 500 Internal Server Error'),
    nl,
    write(E).
