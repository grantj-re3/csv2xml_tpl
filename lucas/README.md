# Alma configuration

## Introduction

The csv2xml_tpl.py script and corresponding template (lucas01a_marcxml.tpl)
in this folder can be used to create a MARC-XML file which can be loaded
into the Ex Libris integrated library system, Alma.

The purpose of the instructions on this page is to describe how to
create an Alma Import Profile which will:
- allow the MARC-XML file to be loaded into Alma (via the web user interface)
- create a bibliographic record for each MARC-XML record
- create a physical holding record for each bib record


## Create an Import Profile - Steps

- Resources > Import: Manage Import Profiles
- Add new profile > Repository > Next
- Part 1 - Profile Details
  * Profile name: Anton Lucas Collection MARC-XML Import
  * Profile description: Load MARC-XML to create bibliographic and physical holding records
  * Originating system: [Flinders University]
  * Import protocol: [Upload File/s]
  * Physical source format: [XML]
  * Source format: [MARC21 Bibliographic]
  * Status: Active
  * File name patterns: -
  * Cross walk: [No]
  * Target format: MARC21 Bibliographic
  * Click Next
- Part 2 - Normalization & Validation
  * Filter: Filter out the data using: -
  * Normalization: Correct the data using: [Marc21 Bib normalize on save] FIXME: Or none?
  * Validation Exception Profile: Handle invalid data using: MarcXML Bib Import
  * Click Next
- Part 3 - Match Profile
  * Match Profile
    + Match by Serial / Non Serial: [Yes]
    + Serial match method: [024/035 Match Method]
    + Non Serial match method: [024/035 Match Method]
  * Match Actions
    + Handling method: [Automatic]
    + Single match - match only record with the same inventory type (electronic/physical): - FIXME: [Check]?
    + Upon match: [Overlay]
    + Merge method: [Overlay all fields but local]
    + Select Action - Allow bibliographic record deletion: -
    + Select Action - Do not override/merge a record with lower brief version: -
    + Select Action - Unlink bibliographic records from community zone: -
    + Do not override Originating System: -
    + Do not override/ merge record with an older version: [Disabled]
  * Automatic Multi-Match Handling
    + Select Action - Disregard matches for bibliographic CZ linked records: -
    + Select Action - Disregard invalid/canceled system control number identifiers: -
    + Select Action - Prefer record with the same inventory type (electronic/physical): -
    + Select Action - Skip and do not import unresolved records: [Check]
  * Handle Record Redirection
    + Canceled record field: -
    + Canceled record subfield: -
    + Canceled record: [Delete]
    + Merge method: [Overlay all fields but local]
    + Update holdings call number: -
  * No Match
    + Upon no match: [Import]
  * Click Next
- Part 4 - Set Management Tags
  * Suppress record/s from publish/delivery: -
  * Synchronize with OCLC: [Don't publish] FIXME: ?
  * Synchronize with Libraries Australia: [Publish Bibliographic records] FIXME: ?
  * Condition: [Unconditionally]
  * Click Next
- Part 5 - Inventory Information
  * Inventory Operations: [Physical]
  * Physical Mapping
    + Mapping policy: [Basic]
    + Material type: [Mixed material]
    + Library field/subfield: - -
    + Location field/subfield: - -
    + Default library: [Special Collections]
    + Default location: [Central - Special - Anton Lucas Collection] ([DAL])
    + Map library/location: [Uncheck]
    + Number of items field/subfield: - -
    + Default number: -
    + Barcode field/subfield: 984 c
    + Item policy field/subfield: - -
    + Default item policy: -
    + Item Call Number: - -
  * Holding Records Mapping

Input record tag | Holdings record tag | Input record subfields | Holdings record subfields
----------|----------------------------|------------------------|--------------------------
024       | 024                        | a                      | a

  * Click Next
- Part 6 - Mapping
  * Location Mapping: -
  * Click Save

