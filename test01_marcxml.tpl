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
  <record>
    ##########################################################################
    ## Constant
    <leader>01216cdt a2200373 i 4500</leader>
    <controlfield tag="008">060906s198u    xra    f      000 0|eng d</controlfield>
    <datafield tag="042" ind1=" " ind2=" ">
      <subfield code="a">anuc</subfield>
    </datafield> \

    ##########################################################################
    ## 245
    <datafield tag="245" ind1="1" ind2="0">
      <subfield code="a">${field[1]}</subfield>
      <subfield code="k">file</subfield>
    </datafield> \

    ##########################################################################
    ## 264: Omit subfield-c if field[3] empty
    <datafield tag="264" ind1=" " ind2="0">
      <subfield code="a">England, U.K.</subfield>
      <subfield code="b">Shakespeare Collection</subfield>
      % if field[3]:
      <subfield code="c">${field[3]}</subfield>
      % endif
    </datafield> \

    ##########################################################################
    ## 500: Omit datafield-500 if field[11] empty
    % if field[11]:
    <datafield tag="500" ind1=" " ind2=" ">
      <subfield code="a">Coverage: ${field[11]}</subfield>
    </datafield>
    % endif \

    ##########################################################################
    ## 651: Optionally empty field; repeated fields; specified subfields
    % if field[7]:
    % for fld_val in field[7].split(delim_rf):
    <datafield tag="651" ind1=" " ind2="0">
      % for i,sub_val in enumerate(fld_val.split(delim_sf)):
<%
            if i == 0:
                # Subfield-code not specified for first subfield; assume "a"
                code, val = "a", sub_val
            else:
                # Subfield-code specified by first char 
                code, val = sub_val[0:1], sub_val[1:]
%>\
      <subfield code="${code}">${val}</subfield>
      % endfor
    </datafield>
    % endfor
    % endif \

    ##########################################################################
  </record>
% endif
