csv2xml_tpl
-----------

## Purpose

Convert a CSV file to XML (or almost any other format) via a template.

The purpose of this program is to read a CSV file as input then
produce an "output document" where each "record" in the output
uses data from the CSV. In particular, the motivation for
the program has been to produce an XML output document (but
other output formats are also feasible).

The method of producing the (usually XML) output document is by invoking
a Python (Mako) template once for each record. The intention is
that this Python program can remain mostly the same but anyone who has
some basic understanding of programming (eg. perhaps someone who
is capable of programming spreadsheet formulae) can program and
format the template.

