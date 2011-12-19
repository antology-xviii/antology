#! /usr/bin/swipl -q -g main -t halt -f none -s
:- use_module('teitools.pl').
:- use_module('teihtml.pl').
:- use_module(library(pwp)).
:- use_module(library(cgi)).

main :-
    cgi_get_form(Arguments),
    getenv('PATH_INFO', Filename),
    sub_atom(Filename, 1, _, 0, Filename0),
    current_output(Stdout),
    open('www/templates/gettext.pwp', read, Template),
    load_tei(Filename0, Source),
    tei_to_html([], Source, Formatted),
    writeln('Content-Type: text/html; charset=utf-8'),
    nl,
    pwp_stream(Template, Stdout, ['Source' = Source, 'Contents' = Formatted]).
