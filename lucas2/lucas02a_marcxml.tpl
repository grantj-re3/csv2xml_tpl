<%page args="fnames, field, rec_num, delim_rf, delim_sf, elem, is_debug_tpl"/>\
##
## Copyright (c) 2020-2021, Flinders University, South Australia. All rights reserved.
## Contributors: Library, Corporate Services, Flinders University.
## See the accompanying LICENSE file (or http://opensource.org/licenses/BSD-3-Clause).
##
<%!
  import re
  import datetime
%>\

##########################################################################
## def mkfield_empty_repeats_subfields()
##########################################################################
## Optionally empty field; repeated fields; specified subfields.
<%def name="mkfield_empty_repeats_subfields(marc_tag, ind1, ind2, field_index)">
  % if field[field_index]:
    % for fld_val in field[field_index].split(delim_rf):
    <${elem['df']} tag="${marc_tag}" ind1="${ind1}" ind2="${ind2}">\

      % for i,sub_val in enumerate(fld_val.split(delim_sf)):
<%
            if i == 0:
              # Subfield-code not specified for first subfield; assume "a"
              code, val = "a", sub_val.strip()
            else:
              # Subfield-code specified by first char
              code, val = sub_val[0:1], sub_val[1:].strip()
%>\
      <${elem['sf']} code="${code}">${val}</${elem['sf']}>
      % endfor\

    </${elem['df']}>
    % endfor
  % endif
</%def>\

##########################################################################
## def mkauthorfields()
##########################################################################
## For MARC 100 & 700. In the CSV, MARC 100 & 700 are in the same column.
## Optionally empty field; repeated fields; specified subfields; add subfield $e.
## - For MARC 100, call with isFirstFieldOnly True; then only the 1st
##   author will appear in the non-repeating 100 field.
## - For MARC 700, call with isFirstFieldOnly False; then 2nd, 3rd, etc.
##   authors will appear in the repeating 700 fields.
<%def name="mkauthorfields(marc_tag, ind1, ind2, field_index, isFirstFieldOnly)">
  % if field[field_index]:
    % for fld_i,fld_val in enumerate(field[field_index].split(delim_rf)):
      % if (fld_i == 0 and isFirstFieldOnly) or (fld_i > 0 and not isFirstFieldOnly):
    <${elem['df']} tag="${marc_tag}" ind1="${ind1}" ind2="${ind2}">\

        % for i,sub_val in enumerate(fld_val.split(delim_sf)):
<%
            if i == 0:
              # Subfield-code not specified for first subfield; assume "a"
              code, val = "a", sub_val.strip()
            else:
              # Subfield-code specified by first char
              code, val = sub_val[0:1], sub_val[1:].strip()
%>\
      <${elem['sf']} code="${code}">${val}</${elem['sf']}>
        % endfor\

      <${elem['sf']} code="e">author.</${elem['sf']}>
    </${elem['df']}>
      % endif
    % endfor
  % endif
</%def>\

##########################################################################
## get_lang_codes
##########################################################################
<%def name="get_lang_codes(str_lang, is_get_only_first_code=False)">
<%
  default_lang_code = "eng"	# Use this code if is_get_only_first_code is True but no language-name in str_lang
  unknown_lang_code = "und"	# Use this code if str_lang contains an unrecognised language-name

	# https://www.loc.gov/marc/languages/language_code.html
	# Use the language name to lookup the language code
  codes = {
    "mandarin":		"chi",	# Chinese
    "dutch":		"dut",
    "english":		"eng",
    "indonesian":	"ind",
    "japanese":		"jpn",
    "sudanese":		"ara",	# FIXME: Arabic is the official language of Sudan
  }
  drop_words = [
    "and",
  ]

  lang_list1 = re.split(r"[ ,;.]+", str_lang.strip().lower())	# Split into tokens
  lang_list2 = []							# Drop meaningless tokens
  for s in lang_list1:
    if re.fullmatch(r"^\s*$", s):
      continue
    if s in drop_words:
      continue
    lang_list2.append(s)

  # "und" = Undetermined language for MARC 008
  codes_list = list(map(lambda str: codes.get(str, unknown_lang_code), lang_list2))

  if is_get_only_first_code:
    # Return one code
    if len(codes_list) > 0:
      return codes_list[0]
    else:
      return default_lang_code
  else:
    # Return all codes in a list
    return codes_list
%>\
</%def>\

##########################################################################
% if is_debug_tpl:
DEBUG TEMPLATE (rec_num ${rec_num}):
% for i,v in enumerate(field):
  field[${i}] = ${type(v)} "${v}"
% endfor\

% else:
  <${elem['rec']}>
    ##########################################################################
    ## Constant
    ## LDR/06="t" => "Unpublished" (in the Trove zone "Diaries, letters, archives")
    ## Pos:         0123456789 123456789 123
    <${elem['ldr']}>     ctm#a22     #i#4500</${elem['ldr']}>\

    ##########################################################################
<%
    # If date field not None and is YYYY or YYYY- or YYYY-YYYY, then
    # substitute first 4 chars into 008 pos 7-10.
    date0 = re.sub(r'[\[\]\?]', "", field[3]) if field[3] else ""  # Excl probable date chars "[]?"
    if re.search(r'^\d{4}(-(\d{4})?)?$', date0, re.ASCII):
        date1 = date0[0:4]	# First 4 chars of YYYY or YYYY- or YYYY-YYYY
        date_type = "s"

    else:
        date1 = 'uuuu'
        date_type = "n"
    now = datetime.datetime.now()
    # FIXME: COMMENT OUT DEBUG LINE BELOW
    #now = datetime.datetime(2021, 1,  28, 11,  41,  8)	# For debug
    #now = datetime.datetime(2021,  7,   5, 17,  55, 14)	# For debug
    #now = datetime.datetime(2021,  7,   2, 18,  8, 24)	# For debug
    now = datetime.datetime(2021,  6,  30, 18, 11, 46)	# For debug
    #now = datetime.datetime(2021,  7,   6, 16,  0,  0)	# For debug
    now_yymmdd = now.strftime("%y%m%d")			# 6 chars: YYMMDD
    marc005 = now.strftime("%Y%m%d%H%M%S.0")		# 16 chars: yyyymmdd + hhmmss.f

    # FIXME: Lang code test
    #langcode = Csv2XmlTemplate.get_lang_codes("japanese", True)
    langcode = get_lang_codes("japanese", True)
    langcode = get_lang_codes(field[10], True)
    #langcode = "GGG"


    # Pos:    "0-56667-0123456789 123456789 123456789"
    marc008 = "%6s%1s%4s####io #####r#####000#0#%3s#d" % (now_yymmdd, date_type, date1, langcode)
%>\
    <${elem['cf']} tag="005">${marc005}</${elem['cf']}>
    <${elem['cf']} tag="008">${marc008}</${elem['cf']}>\

    ##########################################################################
    ## 035 So we can update this record during future imports.
    ## Also for new records, export a spreadsheet of an Alma set or collection
    ## which shows the mapping between 035 & MMS ID. (024 does not appear
    ## on the Alma "Import Profile report" spreadsheet.)
    ## Eg. csv2xml_tpl.py:lucas01a:WS/Ref/001
<%
    field0_wo_spaces = re.sub(r'\s+', "", field[0])
%>\
    <${elem['df']} tag="035" ind1=" " ind2=" ">
      <${elem['sf']} code="a">csv2xml_tpl.py:lucas02a:${field0_wo_spaces}</${elem['sf']}>
    </${elem['df']}>\

    ##########################################################################
    ## Constant
    <${elem['df']} tag="040" ind1=" " ind2=" ">
      <${elem['sf']} code="a">SFU</${elem['sf']}>
      <${elem['sf']} code="b">eng</${elem['sf']}>
      <${elem['sf']} code="c">SFU</${elem['sf']}>
      <${elem['sf']} code="e">rda</${elem['sf']}>
    </${elem['df']}>
    <${elem['df']} tag="042" ind1=" " ind2=" ">
      <${elem['sf']} code="a">anuc</${elem['sf']}>
    </${elem['df']}>
    <${elem['df']} tag="043" ind1=" " ind2=" ">
      <${elem['sf']} code="a">u-at-sa</${elem['sf']}>
      <${elem['sf']} code="a">a-io---</${elem['sf']}>
    </${elem['df']}>\

    ##########################################################################
    ## 100:
    ${mkauthorfields("100", "1", " ", 2, True)}\

    ##########################################################################
    ## 245 Always populated
<%
    # The presence of 100/1XX should change 245 ind1 from "0" to "1".
    if field[2]:	# MARC 100
      ind1 = "1"
    else:
      ind1 = "0"
%>\
    <${elem['df']} tag="245" ind1="${ind1}" ind2="0">
      <${elem['sf']} code="a">${field[1]}</${elem['sf']}>
      <${elem['sf']} code="k">file</${elem['sf']}>
    </${elem['df']}>\

    ##########################################################################
    ## 264: No repeated fields (||); No subfields specified (^^x)
    ## 264: $a,$b Optionally empty subfields
    ## 264: $c Optionally empty subfield; expect empty or YYYY or YYYY-YYYY
    ## In the CSV, these 3 fields are in 3 separate columns.
<%
    a_trim = field[15].strip()
    b_trim = field[16].strip()
    c_trim = field[3].strip()
%>\
    % if a_trim or b_trim or c_trim:
    <${elem['df']} tag="264" ind1=" " ind2="0">
      % if a_trim:
      <${elem['sf']} code="a">${a_trim}</${elem['sf']}>
      % endif
      % if b_trim:
      <${elem['sf']} code="b">${b_trim}</${elem['sf']}>
      % endif
      % if c_trim:
      <${elem['sf']} code="c">${c_trim}</${elem['sf']}>
      % endif
    </${elem['df']}>
    % endif\

    ##########################################################################
    ## 300: Optionally empty field; repeated fields
    % if field[5]:
      % for fld_val in field[5].split(delim_rf):
<%
          val_trim = fld_val.strip()
%>\
        % if val_trim != "":
    <${elem['df']} tag="300" ind1=" " ind2=" ">
      <${elem['sf']} code="a">${val_trim}</${elem['sf']}>
    </${elem['df']}>
        % endif
      % endfor
    % endif\

    ##########################################################################
    ## Constant
    <${elem['df']} tag="336" ind1=" " ind2=" ">
      <${elem['sf']} code="a">text</${elem['sf']}>
      <${elem['sf']} code="b">txt</${elem['sf']}>
      <${elem['sf']} code="2">rdacontent</${elem['sf']}>
    </${elem['df']}>
    <${elem['df']} tag="337" ind1=" " ind2=" ">
      <${elem['sf']} code="a">unmediated</${elem['sf']}>
      <${elem['sf']} code="b">n</${elem['sf']}>
      <${elem['sf']} code="2">rdamedia</${elem['sf']}>
    </${elem['df']}>
    <${elem['df']} tag="338" ind1=" " ind2=" ">
      <${elem['sf']} code="a">sheet</${elem['sf']}>
      <${elem['sf']} code="b">nb</${elem['sf']}>
      <${elem['sf']} code="2">rdacarrier</${elem['sf']}>
    </${elem['df']}>\

    ##########################################################################
    ## 500 Optionally empty field
    % if field[11]:
    <${elem['df']} tag="500" ind1=" " ind2=" ">
      <${elem['sf']} code="a">Coverage: ${field[11]}</${elem['sf']}>
    </${elem['df']}>
    % endif\

    ##########################################################################
    ## 520 Always populated
    <${elem['df']} tag="520" ind1=" " ind2=" ">
      <${elem['sf']} code="a">${field[4]}</${elem['sf']}>
    </${elem['df']}>\

    ##########################################################################
    ## 542 Always populated; repeated subfield $d
    <${elem['df']} tag="542" ind1="1" ind2=" ">
    % for sub_val in field[14].split(delim_rf):
      <${elem['sf']} code="d">${sub_val}</${elem['sf']}>
    % endfor
    </${elem['df']}>\

    ##########################################################################
    ## 546 Optionally empty field
    % if field[10]:
    <${elem['df']} tag="546" ind1=" " ind2=" ">
      <${elem['sf']} code="a">In ${field[10]}.</${elem['sf']}>
    </${elem['df']}>
    % endif\

    ##########################################################################
    ## Constant
    <${elem['df']} tag="561" ind1="1" ind2=" ">
      <${elem['sf']} code="a">This file was donated by Anton Lucas.</${elem['sf']}>
    </${elem['df']}>\

    ##########################################################################
    ## 600, 610, 650, 651, 653:
    ${mkfield_empty_repeats_subfields("600", "1", "0", 9)}\
    ${mkfield_empty_repeats_subfields("610", "1", "0", 8)}\
    ${mkfield_empty_repeats_subfields("650", " ", "0", 6)}\
    ${mkfield_empty_repeats_subfields("651", " ", "0", 7)}\
    ${mkfield_empty_repeats_subfields("653", "0", "0", 12)}\

    ##########################################################################
    ## 700:
    ${mkauthorfields("700", "1", " ", 2, False)}\

    ##########################################################################
    ## 830: Constant
    <${elem['df']} tag="830" ind1=" " ind2="0">
      <${elem['sf']} code="a">Anton Lucas Collection</${elem['sf']}>
    </${elem['df']}>\

    ##########################################################################
    ## 984
    <${elem['df']} tag="984" ind1=" " ind2=" ">
      <${elem['sf']} code="a">SFU</${elem['sf']}>
      <${elem['sf']} code="c">${field0_wo_spaces}</${elem['sf']}>
      <${elem['sf']} code="d">Special Collections Anton Lucas Collection</${elem['sf']}>
    </${elem['df']}>\

    ##########################################################################
  </${elem['rec']}>
% endif\
