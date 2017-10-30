#!/bin/bash
usage() {
    cat <<EOM
    Usage:
    $(basename $0) source_directory source_timestep [target_timestep]

EOM
    exit 0
}

source_directory=$1
source_timestep=$( printf %010d $2 )
if [[ -z $3 ]]
then
	target_timestep=$source_timestep
else
	target_timestep=$( printf %010d $3 )
fi

source_files=$( ls $source_directory/pickup*.data | grep $source_timestep )
for f in $source_files; do
	target=$( basename $f | sed "s/$source_timestep/$target_timestep/" ) 
	f_meta=$( echo $f | sed "s/data/meta/" )
	target_meta=$( echo $target | sed "s/data/meta/" )
	ln -sv $f $target
	ln -sv $f_meta $target_meta
done
