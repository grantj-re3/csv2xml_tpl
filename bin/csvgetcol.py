#!/usr/bin/python
# Python 2 or 3

# Extract one column from a CSV file. Handles quoted columns.
##############################################################################
import sys
import csv

if len(sys.argv) != 3:
  print("Usage:  %s  COLUMN_NUM_BASE0  CSV_FILENAME" % sys.argv[0])
  sys.exit()

col_num = int(sys.argv[1])
fname_csv = sys.argv[2]

##############################################################################
with open(fname_csv, 'r') as csvfile:
  reader = csv.reader(csvfile, quotechar='"')

  for row in reader:
    print(row[col_num])

