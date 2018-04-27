#!/bin/bash

### Job Name
#PBS -N llc1080
### Project code
#PBS -A UCLB0005
#PBS -l walltime=0:59:00
#PBS -q regular
### Merge output and error files
#PBS -j oe
### Select 79 nodes with 36 CPUs and then 1 node with remaining cores needed
#PBS -l select=79:ncpus=36:mpiprocs=36+1:ncpus=28:mpiprocs=28
### Send email on abort, begin and end
#PBS -m abe
### Specify mail recipient
#PBS -M rdussin@ldeo.columbia.edu

#--------------------------------- parameters --------------------------------------

rundir=/glade/scratch/dussin/RUNS_MITgcm/run_notides_test2
days_per_job=1
njobs=6

#--------------------------------- let's go ----------------------------------------

ctrldir=$( pwd )
cd $rundir

#--------------------------------- what is my job number ---------------------------

if [ ! -f jobscompleted ] ; then touch jobscompleted ; fi

lastjob=$( tail -1 jobscompleted )
thisjob=$(( $lastjob + 1 )) # if file empty, takes job number one

#--------------------------------- pick the most recent checkpoint -----------------
nstepA=$( cat pickup.ckptA.meta | grep timeStepNumber | awk '{ print $4 }' )
nstepB=$( cat pickup.ckptB.meta | grep timeStepNumber | awk '{ print $4 }' )

if [[ $nstepA > $nstepB ]] ; then
   echo ckptA $nstepA is more advanced than ckptB $nstepB
   nstep=$nstepA
   latest=ckptA
else
   echo ckptB $nstepB is more advanced than ckptA $nstepA
   nstep=$nstepB
   latest=ckptB
fi

nstep10=$( printf "%.10i" $nstep )

ln -s pickup.${latest}.data pickup.${nstep10}.data
ln -s pickup.${latest}.meta pickup.${nstep10}.meta

ln -s pickup_seaice.${latest}.data pickup_seaice.${nstep10}.data
ln -s pickup_seaice.${latest}.meta pickup_seaice.${nstep10}.meta

#--------------------------------- archive the previous namelist ------------------

mv data data.to.$nstep10

#--------------------------------- set the number of steps to run -----------------

days_to_run=$days_per_job
deltaT=$( cat data.to.$nstep10 | grep deltaT | sed -e "s/,//g" -e "s/\.//g" | awk '{ print $NF }' )
steps2run=$(( $days_to_run * 86400 / $deltaT ))

oldnIter0=$( awk 'match($0,/(nIter0=)/,a) ' data.to.$nstep10 )
newnIter0="nIter0=$nstep,"

oldnTimeSteps=$( awk 'match($0,/(nTimeSteps=)/,a) ' data.to.$nstep10 )
newnTimeSteps="nTimeSteps=$steps2run,"

cat data.to.$nstep10 | sed -e "s/$oldnIter0/$newnIter0/g" -e "s/$oldnTimeSteps/$newnTimeSteps/g" > data

#--------------------------------- run MITgcm -------------------------------------

date
mpiexec_mpt dplace -s 1 -n 2872 ./mitgcmuv
date

#--------------------------------- check status of run ----------------------------

lastline=$( tail -1 STDOUT.0000 )
if [[ $lastline == 'PROGRAM MAIN: Execution ended Normally' ]] ; then
   # clean up
   if [ ! -d archive.$thisjob ] ; then mkdir archive.$thisjob ; fi
   if [ ! -d logs ] ; then mkdir logs ; fi
   mv scratch* ./archive.$thisjob/.
   cp STDOUT.0000 ./logs/STDOUT.0000.$thisjob
   cp STDERR.0000 ./logs/STDERR.0000.$thisjob

   # notify completion
   echo $thisjob >> jobscompleted
   # test for resubmission
   if [[ $thisjob < $njobs ]] ; then 
      cd $ctrldir
      qsub run_llc1080_cheyenne.bash
   else
      # final job
      echo this is the last job
   fi
else
   # run blew up
   exit 1
fi
