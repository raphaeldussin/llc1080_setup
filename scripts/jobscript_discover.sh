#!/bin/bash

# number of cores needed
#SBATCH -n 2872
#SBATCH -J llc1080
#SBATCH --constrain=hasw
#SBATCH --time=12:00:00
#SBATCH --mail-user=rpa@ldeo.columbia.edu
#SBATCH --mail-type=ALL

# https://modelingguru.nasa.gov/thread/5100
ulimit -s unlimited
ulimit -v unlimited

NPROC=2872

source /usr/share/modules/init/bash
module purge

module load comp/intel-16.0.2.181 mpi/sgi-mpt-2.15
#module load comp/intel-17.0.2.174 mpi/sgi-mpt-2.15

export MPI_DSM_VERBOSE=1
export MPI_VERBOSE=1
export MPI_DISPLAY_SETTINGS=1

mpiexec_mpt -n $NPROC ./mitgcmuv

