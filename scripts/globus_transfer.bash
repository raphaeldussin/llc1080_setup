#!/bin/bash

# Globus endpoints need to be activated from website before using this

# Endpoint IDs found with >>> globus endpoint search [name]
epcheyenne=d33b3614-6d04-11e5-ba46-22000b92c6ec
epgyre=9b53dc32-e4c1-11e6-b97a-22000b9a448b

fromdir_cheyenne=/glade/scratch/dussin/RUNS_MITgcm/run_tides
todir_gyre=/swot/SUM04/llc1080/run_tides

# create list of files on production machine
globus ls $epcheyenne:$fromdir_cheyenne > files_on_prod.txt
# create list of files on storage machine
globus ls $epgyre:$todir_gyre > files_on_storage.txt # down

# make diff of lists and grep for (*.meta, *.mdata) files only present on production machine
diff files_on_prod.txt files_on_storage.txt | grep '^<' | grep -E "\.meta|\.data" | awk '{print $2}' > tmp
paste tmp tmp > outputs_transfer_list.txt

# since batch mode reads from stdin, we can direct input from a .txt file
# all paths from stdin are relative to the paths supplied here
globus transfer $epcheyenne:$fromdir_cheyenne $epgyre:$todir_gyre \
                --batch --label "Transfer llc1080 Batch" < outputs_transfer_list.txt

# clean up
rm files_on_prod.txt files_on_storage.txt tmp outputs_transfer_list.txt
