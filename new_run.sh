#!/bin/bash

mkdir $1
cd $1
ln -sf $HOME/MITgcm_contrib/llc_hires/llc_1080/build_66h_sgi-mpt_60x60/mitgcmuv .
ln -sf ../run_template/* .
#ln -sf ../ECMWF_operational/* .
ln -sf ../ECMWF_operational/NEW/EOG* .
# ln -sf ../pickup/run_2011/pick*354240* .
ln -sf ../pickup/run_year1/pick*157680* .
cp $HOME/MITgcm_contrib/llc_hires/llc_1080/input/* .
cp $HOME/dimitris_inputs/run_EOG/data .
cp ../ECMWF_operational/NEW/data.exf_noTIDE data.exf
mv data.exch2_60x60x2872 data.exch2
cp ../scripts/jobscript_60x60x2872.sh jobscript.sh

