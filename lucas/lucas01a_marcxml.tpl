<%page args="fnames, field, rec_num, delim_rf, delim_sf, elem, is_debug_tpl"/> \
##
## Copyright (c) 2019, Flinders University, South Australia. All rights reserved.
## Contributors: Library, Corporate Services, Flinders University.
## See the accompanying LICENSE file (or http://opensource.org/licenses/BSD-3-Clause).
##
<%!
  import re
  import datetime
%>\

% if is_debug_tpl:
DEBUG TEMPLATE (rec_num ${rec_num}):
% for i,v in enumerate(field):
  field[${i}] = ${type(v)} "${v}"
% endfor \

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
    #now = datetime.datetime(2019, 6, 12, 17, 41, 31)	# For debug
    now_yymmdd = now.strftime("%y%m%d")			# 6 chars: YYMMDD
    marc005 = now.strftime("%Y%m%d%H%M%S.0")		# 16 chars: yyyymmdd + hhmmss.f
    # Pos:    "0-56667-0123456789 123456789 123456789"
    marc008 = "%6s%1s%4s####io #####r###########eng#d" % (now_yymmdd, date_type, date1)
%>\
    <${elem['cf']} tag="005">${marc005}</${elem['cf']}>
    <${elem['cf']} tag="008">${marc008}</${elem['cf']}>\

    ##########################################################################
    ## 024 So we can update this record during future imports
    ## Eg. csv2xml_tpl.py:lucas01a:WS/Ref/001
<%
    field0_wo_spaces = re.sub(r'\s+', "", field[0])
%>\
    <${elem['df']} tag="024" ind1="8" ind2=" ">
      <${elem['sf']} code="a">csv2xml_tpl.py:lucas01a:${field0_wo_spaces}</${elem['sf']}>
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
    ## 100: Optionally empty field. Only the first author should appear in
    ## non-repeating 100 field. Second and subsequent authors should be in MARC 700.
    % if field[2]:
    <${elem['df']} tag="100" ind1="1" ind2=" ">
      <${elem['sf']} code="a">${field[2]}</${elem['sf']}>
      <${elem['sf']} code="e">author.</${elem['sf']}>
    </${elem['df']}>
    % endif \

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
    ## 264: $c Optionally empty subfield; expect empty or YYYY or YYYY-YYYY
    <${elem['df']} tag="264" ind1=" " ind2="0">
      <${elem['sf']} code="a">Adelaide, S.A.</${elem['sf']}>
      <${elem['sf']} code="b">Anton Lucas Collection</${elem['sf']}>
      % if field[3]:
      <${elem['sf']} code="c">${field[3]}</${elem['sf']}>
      % endif
    </${elem['df']}>\

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
    % endif \

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
    % endif \

    ##########################################################################
    ## Constant
    <${elem['df']} tag="506" ind1="1" ind2=" ">
      <${elem['sf']} code="a">General Special Collections conditions of access apply.</${elem['sf']}>
      <${elem['sf']} code="u">https://libraryflin.flinders.edu.au/about/collections/special</${elem['sf']}>
    </${elem['df']}>\

    ##########################################################################
    ## 520 Always populated
    <${elem['df']} tag="520" ind1=" " ind2=" ">
      <${elem['sf']} code="a">${field[4]}</${elem['sf']}>
    </${elem['df']}>\

    ##########################################################################
    ## 546 Optionally empty field
    % if field[10]:
    <${elem['df']} tag="546" ind1=" " ind2=" ">
      <${elem['sf']} code="a">In ${field[10]}.</${elem['sf']}>
    </${elem['df']}>
    % endif \

    ##########################################################################
    ## Constant
    <${elem['df']} tag="561" ind1="1" ind2=" ">
      <${elem['sf']} code="a">This file was donated by Anton Lucas.</${elem['sf']}>
    </${elem['df']}>\

    ##########################################################################
    ## 600: Optionally empty field; repeated fields; specified subfields
    % if field[9]:
      % for fld_val in field[9].split(delim_rf):
    <${elem['df']} tag="600" ind1="1" ind2="0">
        % for i,sub_val in enumerate(fld_val.split(delim_sf)):
<%
            if i == 0:
                # Subfield-code not specified for first subfield; assume "a"
                code, val = "a", sub_val
            else:
                # Subfield-code specified by first char 
                code, val = sub_val[0:1], sub_val[1:]
%>\
      <${elem['sf']} code="${code}">${val}</${elem['sf']}>
        % endfor
    </${elem['df']}>
      % endfor
    % endif \

    ##########################################################################
    ## 610: Optionally empty field; repeated fields; specified subfields
    % if field[8]:
      % for fld_val in field[8].split(delim_rf):
    <${elem['df']} tag="610" ind1="1" ind2="0">
        % for i,sub_val in enumerate(fld_val.split(delim_sf)):
<%
            if i == 0:
                # Subfield-code not specified for first subfield; assume "a"
                code, val = "a", sub_val
            else:
                # Subfield-code specified by first char 
                code, val = sub_val[0:1], sub_val[1:]
%>\
      <${elem['sf']} code="${code}">${val}</${elem['sf']}>
        % endfor
    </${elem['df']}>
      % endfor
    % endif \

    ##########################################################################
    ## 650: Optionally empty field; repeated fields; specified subfields
    % if field[6]:
      % for fld_val in field[6].split(delim_rf):
    <${elem['df']} tag="650" ind1=" " ind2="0">
        % for i,sub_val in enumerate(fld_val.split(delim_sf)):
<%
            if i == 0:
                # Subfield-code not specified for first subfield; assume "a"
                code, val = "a", sub_val
            else:
                # Subfield-code specified by first char 
                code, val = sub_val[0:1], sub_val[1:]
%>\
      <${elem['sf']} code="${code}">${val}</${elem['sf']}>
        % endfor
    </${elem['df']}>
      % endfor
    % endif \

    ##########################################################################
    ## 651: Optionally empty field; repeated fields; specified subfields
    % if field[7]:
      % for fld_val in field[7].split(delim_rf):
    <${elem['df']} tag="651" ind1=" " ind2="0">
        % for i,sub_val in enumerate(fld_val.split(delim_sf)):
<%
            if i == 0:
                # Subfield-code not specified for first subfield; assume "a"
                code, val = "a", sub_val
            else:
                # Subfield-code specified by first char 
                code, val = sub_val[0:1], sub_val[1:]
%>\
      <${elem['sf']} code="${code}">${val}</${elem['sf']}>
        % endfor
    </${elem['df']}>
      % endfor
    % endif \

    ##########################################################################
    ## 653: Optionally empty field; repeated fields; specified subfields
    % if field[12]:
      % for fld_val in field[12].split(delim_rf):
    <${elem['df']} tag="653" ind1=" " ind2=" ">
        % for i,sub_val in enumerate(fld_val.split(delim_sf)):
<%
            if i == 0:
                # Subfield-code not specified for first subfield; assume "a"
                code, val = "a", sub_val
            else:
                # Subfield-code specified by first char 
                code, val = sub_val[0:1], sub_val[1:]
%>\
      <${elem['sf']} code="${code}">${val}</${elem['sf']}>
        % endfor
    </${elem['df']}>
      % endfor
    % endif \

    ##########################################################################
    ## 700: Optionally empty field; repeated fields.
    ## Second and subsequent authors should be in MARC 700. First author
    ## should be in non-repeating 100 field.
    % if field[13]:
      % for fld_i,fld_val in enumerate(field[13].split(delim_rf)):
<%
          val_trim = fld_val.strip()
%>\
    <${elem['df']} tag="700" ind1="1" ind2=" ">
      <${elem['sf']} code="a">${val_trim}</${elem['sf']}>
      <${elem['sf']} code="e">author.</${elem['sf']}>
    </${elem['df']}>
      % endfor
    % endif \

    ##########################################################################
    ## 856
    <${elem['df']} tag="856" ind1="4" ind2="2">
      <${elem['sf']} code="u">https://libraryflin.flinders.edu.au/about/collections/special/anton-lucas-collection</${elem['sf']}>
      <${elem['sf']} code="z">About the Anton Lucas Collection</${elem['sf']}>
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
% endif \
