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
    ## Pos:         0123456789 123456789 123
    <${elem['ldr']}>     cpm#a22     #i#4500</${elem['ldr']}>\

    ##########################################################################
    ## FIXME: How to deal with YYYY-YYYY
<%
    # If date field not NONE and is 4 digits, then substitute into 008 pos 7-10.
    if field[3] and re.search('^\d{4}$', field[3], re.ASCII):
        date1 = field[3]				# 4 chars: YYYY
    else:
        date1 = '    '
    now = datetime.datetime.now()
    # FIXME: COMMENT OUT DEBUG LINE BELOW
    #now = datetime.datetime(2019, 6, 12, 17, 41, 31)	# For debug
    now_yymmdd = now.strftime("%y%m%d")			# 6 chars: YYMMDD
    marc005 = now.strftime("%Y%m%d%H%M%S.0")		# 16 chars: yyyymmdd + hhmmss.f
    # Pos:    "0-567-0123456789 123456789 123456789"
    marc008 = "%6ss%4s####io######r###########eng#d" % (now_yymmdd, date1)
%>\
    <${elem['cf']} tag="005">${marc005}</${elem['cf']}>
    <${elem['cf']} tag="008">${marc008}</${elem['cf']}>\

    ##########################################################################
    ## 024 So we can update this record during future imports
    ## Eg. csv2xml_tpl.py:lucas01a:WS/Ref/001
    <${elem['df']} tag="024" ind1="8" ind2=" ">
      <${elem['sf']} code="a">csv2xml_tpl.py:lucas01a:${field[0]}</${elem['sf']}>
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
    ## 100: Optionally empty field; only the first author should appear in
    ## non-repeating 100 field. 2nd and subsequent authors should be in MARC 700.
    ## FIXME: Review
    ## 100 FIXME: $e? Indicators?
    ## FIXME: Add report to show EMPTY SUBFIELDS!
    % if field[2]:
    <${elem['df']} tag="100" ind1="1" ind2=" ">
      <${elem['sf']} code="a">${field[2]}</${elem['sf']}>
      <${elem['sf']} code="e">author.</${elem['sf']}>
    </${elem['df']}>
    % endif \

    ##########################################################################
    ## 245
    ## FIXME: $k, not $b?
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
    ## 264: $c may be empty or YYYY
    <${elem['df']} tag="264" ind1=" " ind2="0">
      <${elem['sf']} code="a">Adelaide, S.A.</${elem['sf']}>
      <${elem['sf']} code="b">Anton Lucas Collection</${elem['sf']}>
      % if field[3]:
      <${elem['sf']} code="c">${field[3]}</${elem['sf']}>
      % endif
    </${elem['df']}>\

    ##########################################################################
    ## 300: Optionally empty field; repeated fields
    ## FIXME: Review
    ## 300 FIXME: Spreadsheet column says "Manuscript"; where does that info fit in 300?
    ## 300$a in markup example says: "leaf/leaves pages"
    % if field[5]:
      % for fld_val in field[5].split(delim_rf):
<%
          val_trim = fld_val.strip()
%>\
        % if val_trim != "":
    <${elem['df']} tag="300" ind1=" " ind2=" ">
      <${elem['sf']} code="a">${val_trim}</${elem['sf']}>
      <${elem['sf']} code="c">30 cm.</${elem['sf']}>
      <${elem['sf']} code="e">In manila folder.</${elem['sf']}>
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
    ## 500
    % if field[11]:
    <${elem['df']} tag="500" ind1=" " ind2=" ">
      <${elem['sf']} code="a">Coverage: ${field[11]}</${elem['sf']}>
    </${elem['df']}>
    % endif \

    ##########################################################################
    ## Constant
    <${elem['df']} tag="506" ind1="1" ind2=" ">
      <${elem['sf']} code="a">General Special Collections conditions of access apply.</${elem['sf']}>
    </${elem['df']}>
    <${elem['df']} tag="506" ind1="1" ind2=" ">
      <${elem['sf']} code="a">Access conditions</${elem['sf']}>
      <${elem['sf']} code="u">http://www.flinders.edu.au/library/info/collections/special/conditions.cfm</${elem['sf']}>
    </${elem['df']}>\

    ##########################################################################
    ## 520
    <${elem['df']} tag="520" ind1=" " ind2=" ">
      <${elem['sf']} code="a">${field[4]}</${elem['sf']}>
    </${elem['df']}>\

    ##########################################################################
    ## 546
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
    ## 600
    % if field[9]:
    <${elem['df']} tag="600" ind1="1" ind2="0">
      <${elem['sf']} code="a">${field[9]}</${elem['sf']}>
      <${elem['sf']} code="v">Sources.</${elem['sf']}>
    </${elem['df']}>
    % endif \

    ##########################################################################
    ## 610: Optionally empty field; [repeated fields - not in spreadsheet yet]; specified subfields
    ## FIXME: Review
    ## 610 FIXME: $a? Indicators?
    % if field[8]:
      % for fld_val in field[8].split(delim_rf):
    <${elem['df']} tag="610" ind1="1" ind2="0">
        % for i,sub_val in enumerate(fld_val.split(delim_sf)):
<%
            if i == 0:
                # FIXME: Is this assumption correct?
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
    ## FIXME: Review
    ## 650 FIXME: Spreadsheet says "Three Regions Affair; Peristiwa Tiga Daerah". Template says "Files (Records)".
    % if field[6]:
      % for fld_val in field[6].split(delim_rf):
    <${elem['df']} tag="650" ind1=" " ind2="0">
        % for i,sub_val in enumerate(fld_val.split(delim_sf)):
<%
            if i == 0:
                # FIXME: Is this assumption correct?
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
                # FIXME: Is this assumption correct?
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
    ## FIXME: Review
    % if field[12]:
      % for fld_val in field[12].split(delim_rf):
    <${elem['df']} tag="653" ind1=" " ind2=" ">
        % for i,sub_val in enumerate(fld_val.split(delim_sf)):
<%
            if i == 0:
                # FIXME: Is this assumption correct?
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
    ## 700: Optionally empty field; 2nd and subsequent authors should be
    ## in MARC 700. First author should be in non-repeating 100 field.
    ## FIXME: Review
    ## 700 FIXME: $e? Indicators?
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
    ## 984
    <${elem['df']} tag="984" ind1=" " ind2=" ">
      <${elem['sf']} code="a">SFU</${elem['sf']}>
      <${elem['sf']} code="c">${field[0]}</${elem['sf']}>
      <${elem['sf']} code="d">Special Collections Anton Lucas Collection</${elem['sf']}>
    </${elem['df']}>\

    ##########################################################################
  </${elem['rec']}>
% endif \
