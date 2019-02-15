<%page args="field, rec_num, delim_rf, delim_sf, elem, is_debug_tpl"/>
##
## Copyright (c) 2019, Flinders University, South Australia. All rights reserved.
## Contributors: Library, Corporate Services, Flinders University.
## See the accompanying LICENSE file (or http://opensource.org/licenses/BSD-3-Clause).
##
% if is_debug_tpl:
DEBUG TEMPLATE (rec_num ${rec_num}):
% for i,v in enumerate(field):
  field[${i}] = ${type(v)} "${v}"
% endfor
% endif \

% if not is_debug_tpl:
  <${elem['rec']}>
    ##########################################################################
    ## Constant
    <${elem['ldr']}>01216cdt a2200373 i 4500</${elem['ldr']}>
    <${elem['cf']} tag="008">060906s198u    xra    f      000 0|eng d</${elem['cf']}>
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
    </${elem['df']}> \

    ## FIXME: To satisfy Alma import match/no-match condition, consider adding 024 or 035?
    ## Eg. sfu:csv2xml_tpl:AL/Memoirs/001
    ##########################################################################
    ## 100 FIXME: $e? Indicators?
    <${elem['df']} tag="100" ind1="1" ind2=" ">
      <${elem['sf']} code="a">${field[2]}</${elem['sf']}>
      <${elem['sf']} code="e">author.</${elem['sf']}>
    </${elem['df']}> \

    ##########################################################################
    ## 245 FIXME: $k, not $b?
    <${elem['df']} tag="245" ind1="1" ind2="0">
      <${elem['sf']} code="a">${field[1]}</${elem['sf']}>
      <${elem['sf']} code="k">file</${elem['sf']}>
    </${elem['df']}> \

    ##########################################################################
    ## 264: $c may be empty
    <${elem['df']} tag="264" ind1=" " ind2="0">
      <${elem['sf']} code="a">Adelaide, S.A.</${elem['sf']}>
      <${elem['sf']} code="b">Anton Lucas Collection</${elem['sf']}>
      % if field[3]:
      <${elem['sf']} code="c">${field[3]}</${elem['sf']}>
      % endif
    </${elem['df']}> \

    ##########################################################################
    ## 300 FIXME: Spreadsheet column says "Manuscript"; where does that info fit in 300?
    <${elem['df']} tag="300" ind1=" " ind2=" ">
      <${elem['sf']} code="a">${field[5]}</${elem['sf']}>
      <${elem['sf']} code="c">30 cm.</${elem['sf']}>
      <${elem['sf']} code="c">In manila folder.</${elem['sf']}>
    </${elem['df']}> \

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
    </${elem['df']}> \

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
    </${elem['df']}> \

    ##########################################################################
    ## 520
    <${elem['df']} tag="520" ind1=" " ind2=" ">
      <${elem['sf']} code="a">${field[4]}</${elem['sf']}>
    </${elem['df']}> \

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
    </${elem['df']}> \

    ##########################################################################
    ## 600
    % if field[9]:
    <${elem['df']} tag="600" ind1="1" ind2="0">
      <${elem['sf']} code="a">${field[9]}</${elem['sf']}>
      <${elem['sf']} code="v">Sources.</${elem['sf']}>
    </${elem['df']}>
    % endif \

    ##########################################################################
    ## 610 FIXME: $a? Indicators?
    % if field[8]:
    <${elem['df']} tag="610" ind1="1" ind2="0">
      <${elem['sf']} code="a">${field[8]}</${elem['sf']}>
    </${elem['df']}>
    % endif \

    ##########################################################################
    ## 650 FIXME: Spreadsheet says "Three Regions Affair; Peristiwa Tiga Daerah". Template says "Files (Records)".
    % if field[6]:
    <${elem['df']} tag="650" ind1=" " ind2="0">
      <${elem['sf']} code="a">${field[6]}</${elem['sf']}>
    </${elem['df']}>
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
    ## Constant
    ## FIXME: Omit 700? Use 100 instead?
    <${elem['df']} tag="700" ind1="1" ind2=" ">
      <${elem['sf']} code="a">FIXME:Constant? What about 100 column? Lucas, Anton</${elem['sf']}>
      <${elem['sf']} code="e">author</${elem['sf']}>
    </${elem['df']}>
    ## FIXME: Cannot read URL for $u. Other subfields?
    <${elem['df']} tag="856" ind1="4" ind2="2">
      <${elem['sf']} code="u">http://FIXME.example.com/Cannot/Read</${elem['sf']}>
    </${elem['df']}> \

    ##########################################################################
    ## 984
    <${elem['df']} tag="984" ind1=" " ind2=" ">
      <${elem['sf']} code="a">SFU</${elem['sf']}>
      <${elem['sf']} code="c">${field[0]}</${elem['sf']}>
      <${elem['sf']} code="d">Special Collections Anton Lucas Collection</${elem['sf']}>
    </${elem['df']}> \

    ##########################################################################
  </${elem['rec']}>
% endif
