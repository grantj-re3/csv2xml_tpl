#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# Copyright (c) 2019, Flinders University, South Australia. All rights reserved.
# Contributors: Library, Corporate Services, Flinders University.
# See the accompanying LICENSE file (or http://opensource.org/licenses/BSD-3-Clause).
#
# Win10 usage:  c:\Python34\python.exe  csv2xml_tpl.py  >  outfile
#
# The purpose of this program is to read a CSV file as input then
# produce an "output document" where each "record" in the output
# uses data from the CSV. In particular, the motivation for
# the program has been to produce an XML output document (but
# other output formats are also feasible).
#
# The method of producing the (usually XML) output document is by invoking
# a Python (Mako) template once for each record. The intention is
# that this Python program can remain mostly the same but anyone who has
# some basic understanding of programming (eg. perhaps someone who
# is capable of programming spreadsheet formulae) can program and
# format the template.
#
# Tested in the following environments:
# - Python 3.4.2, Windows 10, Command Prompt
# - Python 3.5.2, Linux, Fedora release 25
#
# Assumptions:
# - You run this program with Python 3.x.
# - It is expected that the CSV input file is UTF-8 if it contains
#   non-ASCII characters (eg. non-English characters, smart quotes,
#   long-hyphens). However you can set it with ENCODING_CSV_IN below.
# - It is expected that the (usually XML) output file is UTF-8 if
#   the CSV input file contains non-ASCII characters. However you
#   can set it with ENCODING_XML_OUT below.
#
# Gotchas:
# - You might be able to obtain a UTF-8 CSV file by:
#   * saving as "CSV UTF-8" from Excel or similar spreadsheet software
#   * saving as CSV, then using another program (such as "iconv") to
#     convert from your CSV character encoding to UTF-8. Eg.
#       iconv -f WINDOWS-1252 -t UTF8 input.csv > output_utf8.csv
# - If your UTF-8 CSV file contains a unicode Byte Order Mark (BOM)
#   the best method to deal with it may be to set ENCODING_CSV_IN
#   to "utf-8-sig" (which is a BOM-aware version of "utf-8").
# - If you run this program under Microsoft Windows "Command Prompt"
#   and print to STDOUT, you are likely to have problems with
#   character encoding (in Australia mine appears to be CP850) and the
#   display font.
#   * You can work-around some of these problems by redirecting STDOUT
#     to a file (as per the Win10 example above).
#   * You can usually avoid these problems by directly writing to a
#     file within the Python program.
#
##############################################################################
import csv
import os
import platform

from mako.template import Template
from xml.sax.saxutils import escape
from textwrap import dedent

##############################################################################
class Csv2XmlTemplate:
    # https://docs.makotemplates.org/en/latest/unicode.html
    # https://docs.python.org/3/howto/unicode.html
    # https://docs.python.org/3/library/codecs.html#standard-encodings
    # http://www.cogsci.nl/blog/a-simple-explanation-of-character-encoding-in-python.html

    # http://www.cp1252.com/

    ##########################################################################
    # Debug vars
    IS_DEBUG = True				# Enable debug output in this program
    IS_DEBUG_TPL = False			# Enable debug output within the template

    USE_ROW0_HDR_DEBUG = True			# Use row0 for header names in show_debug_summary_info_for_records()

    # Used to skip the header row0 (1) or not (0).
    # Also used for selecting a particular row for debuging. Eg. To only
    # process CSV row/index 3, set both values to 3.
    SKIP_CSV_ROWS_BEFORE = 1		# 0 = Do not skip row0; 1 = Skip row0
    SKIP_CSV_ROWS_AFTER  = 99999

    ##########################################################################
    # Files and their character encoding
    FNAME_CSV_IN  = "test01.csv"
    FNAME_TPL_IN  = "test01_marcxml.tpl"
    FNAME_XML_OUT = "test01_out.xml"

    # Common character encodings are:
    # - "cp1252" for Windows-1252 (eg. for Microsoft Excel CSV in Australia)
    # - "utf-8" without BOM-awareness (common for web/XML use)
    # - "utf-8-sig" with BOM-awareness (common for web/XML use)
    ENCODING_CSV_IN = "cp1252"
    ENCODING_XML_OUT = "utf-8"

    # If your input CSV contains normal (non-XML) text and your output
    # document is XML, set this to True.
    WILL_CONVERT_INPUT_TEXT_TO_XML = True

    ##########################################################################
    # CSV configs
    DELIM_REPEATED_FIELD = "||"		# CSV delimiter for a repeated field, eg. 651
    DELIM_SUBFIELD = "^^"		# CSV delimiter for a subfield, eg. 651$x

    # Mandatory (*) CSV columns. First CSV column is Python index 0.
    #  0: *Ref
    #  1: *Title of file (245)
    #  2: *Creator (100)
    #  3:  Date (264)
    #  4: *Description (free text) (520)
    #  5: *Format (300)
    #  6:  Subjects (650)
    #  7: *Geographic subjects (651)
    #  8:  Corporate Name (610)
    #  9:  Name (600)
    # 10:  Language (546)
    # 11:  COVERAGE
    MANDATORY_COLUMNS = (0, 1, 2, 4, 5, 7)	# FIXME: Give warning if mandatory column is empty!

    ##########################################################################
    # XML element list without XML namespace
    XML_ELEMENTS_WO_NS = {
            'rec':  "record",
            'ldr':  "leader",
            'cf':   "controlfield",

            'df':   "datafield",
            'sf':   "subfield",
            }

    # XML Namespace (with trailing colon) eg. "marc:"
    XML_NS = ""

    XML_ROOT_ELEMENT = "collection"
    PREAMBLE_XML  = "<%s%s>"  % (XML_NS, XML_ROOT_ELEMENT)
    POSTAMBLE_XML = "</%s%s>" % (XML_NS, XML_ROOT_ELEMENT)

    ##########################################################################
    # Class vars
    debug_summary_info = {
                'empty':        {},
                'has_delim_rf': {},
                'has_delim_sf': {},
                }

    ##########################################################################
    # Constructor
    ##########################################################################
    def __init__(self, fname_tpl_in, fname_csv_in, fname_xml_out):
        self.fname_csv_in = fname_csv_in
        self.fname_tpl_in = fname_tpl_in
        self.fname_xml_out = fname_xml_out

        # Prepend XML element list with XML namespace
        self.xml_elements = {k:self.XML_NS + v for (k,v) in self.XML_ELEMENTS_WO_NS.items()}

    ##########################################################################
    def show_heading(self):
        heading = """
            Program filename:         '%s'
            Input template filename:  '%s'
            Input CSV filename:       '%s'
            Output filename:          '%s'

            Python version:                      '%s'
            CSV-input file character encoding:   '%s'
            XML-output file character encoding:  '%s'
            XML namespace:                       '%s'

            CSV delimiter for repeated fields:   '%s'
            CSV delimiter for subfields:         '%s'
              (template assumes first subfield is 'a')
        """[1:] % (
                os.path.basename(__file__), self.fname_tpl_in,
                self.fname_csv_in, self.fname_xml_out,
                platform.python_version(), self.ENCODING_CSV_IN,
                self.ENCODING_XML_OUT, self.XML_NS,
                self.DELIM_REPEATED_FIELD, self.DELIM_SUBFIELD
                )
        print(dedent(heading))

    ##########################################################################
    def show_processed_records(self):
        with open(self.fname_csv_in, 'r', encoding=self.ENCODING_CSV_IN, newline='') as csvfile:
            with open(self.fname_xml_out, 'w', encoding=self.ENCODING_XML_OUT) as outfile:

                outfile.write(self.PREAMBLE_XML)

                tpl = Template(filename=self.fname_tpl_in, output_encoding=self.ENCODING_XML_OUT)
                reader = csv.reader(csvfile, delimiter=',', quotechar='"')
                for row_num, row in enumerate(reader):
                    if row_num < self.SKIP_CSV_ROWS_BEFORE or row_num > self.SKIP_CSV_ROWS_AFTER:
                        continue

                    rec = list(map(lambda s: escape(s) if self.WILL_CONVERT_INPUT_TEXT_TO_XML else s, row))
                    if "".join(rec) == "":
                        continue        # Skip empty lines

                    if self.IS_DEBUG:
                        print("=== row_num: %d ===" % (row_num))
                        print("  rec[0]: '%s'" % (rec[0]))
                        for i, v in enumerate(rec):
                            #print("      <field%d>%s</field%d>" % (i, v.encode('unicode-escape').decode(self.ENCODING_XML_OUT), i))
                            print("      field %2d: '%s'" % (i, v.encode('unicode-escape').decode(self.ENCODING_XML_OUT)))

                    outfile.write(tpl.render_unicode(
                        field = rec, rec_num = row_num,
                        delim_rf = self.DELIM_REPEATED_FIELD, delim_sf = self.DELIM_SUBFIELD,
                        elem = self.xml_elements, is_debug_tpl = self.IS_DEBUG_TPL
                        ))

                outfile.write(self.POSTAMBLE_XML)

    ##########################################################################
    def show_debug_summary_info_for_records(self):
        hdr_fields = ()
        col_name_len = 28 if self.USE_ROW0_HDR_DEBUG else 0
        s_col_name_len = str(col_name_len)
        with open(self.fname_csv_in, 'r', encoding=self.ENCODING_CSV_IN, newline='') as csvfile:
            reader = csv.reader(csvfile, delimiter=',', quotechar='"')
            for row_num, row in enumerate(reader):
                rec = row
                if row_num == 0:
                    hdr_fields = rec
                if "".join(rec) == "":
                    continue        # Skip empty lines
                self.get_debug_summary_info_for_1_record(rec, row_num)

        dsi = self.debug_summary_info
        fmt = "  Field %2d%-" + s_col_name_len + "s is empty in rows: %s"
        print("\nEmpty fields:")
        for i, s_row_nums in dsi['empty'].items():
            col_name = " <%s>" % hdr_fields[i] if self.USE_ROW0_HDR_DEBUG else ""
            print(fmt % (i, col_name, ",".join(s_row_nums)))

        fmt = "  Field %2d%-" + s_col_name_len + "s contains RF delimiter in rows: %s"
        print("\nRepeated-field (RF) delimiter:")
        for i, s_row_nums in dsi['has_delim_rf'].items():
            col_name = " <%s>" % hdr_fields[i] if self.USE_ROW0_HDR_DEBUG else ""
            print(fmt % (i, col_name, ",".join(s_row_nums)))

        fmt = "  Field %2d%-" + s_col_name_len + "s contains SF delimiter in rows: %s"
        print("\nSubfield (SF) delimiter:")
        for i, s_row_nums in dsi['has_delim_sf'].items():
            col_name = " <%s>" % hdr_fields[i] if self.USE_ROW0_HDR_DEBUG else ""
            print(fmt % (i, col_name, ",".join(s_row_nums)))

    ##########################################################################
    def get_debug_summary_info_for_1_record(self, rec, row_num):
        # Must re-initialise self.debug_summary_info if this method run more than once
        dsi = self.debug_summary_info       # Short cut to class var
        s_row_num = str(row_num)
        for i, v in enumerate(rec):
            if v:
                if v.find(self.DELIM_REPEATED_FIELD) != -1:
                    if i in dsi['has_delim_rf']:
                        dsi['has_delim_rf'][i].append(s_row_num)
                    else:
                        dsi['has_delim_rf'][i] = [ s_row_num ]

                if v.find(self.DELIM_SUBFIELD) != -1:
                    if i in dsi['has_delim_sf']:
                        dsi['has_delim_sf'][i].append(s_row_num)
                    else:
                        dsi['has_delim_sf'][i] = [ s_row_num ]

            else:
                if i in dsi['empty']:
                    dsi['empty'][i].append(s_row_num)
                else:
                    dsi['empty'][i] = [ s_row_num ]

##############################################################################
# main()
##############################################################################
t = Csv2XmlTemplate(
    Csv2XmlTemplate.FNAME_TPL_IN, 
    Csv2XmlTemplate.FNAME_CSV_IN, 
    Csv2XmlTemplate.FNAME_XML_OUT
)
t.show_heading()
t.show_processed_records()
if Csv2XmlTemplate.IS_DEBUG:
    t.show_debug_summary_info_for_records()

