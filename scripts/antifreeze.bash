#!/bin/bash

jobname=llc1080
rundir=/glade/scratch/dussin/RUNS_MITgcm/run_notides_test2
max_hours=12 # hours
monitor_every_N_min=10 # minutes

#---------------------------------------------------------------------------
# number of tests to perform
nbtests=$(( $max_hours * 60 / $monitor_every_N_min ))
# init size to negative values
oldsizestdout=-1

for ktime in $( seq 1 $nbtests ) ; do

    # check status of job
    jobinfo=$( qstat -u $(whoami) | grep $jobname )
    jobid=$( echo $jobinfo | sed -e "s/\./ /" | awk '{ print $1 }' )
    jobstatus=$( echo $jobinfo | awk '{ print $10 }' )

    # running job
    if [[ $jobstatus == 'R' ]] ; then
       # check if completed
       lastline=$( tail -1 $rundir/STDOUT.0000 )
       if [[ $lastline == 'PROGRAM MAIN: Execution ended Normally' ]] ; then
          date
          echo job is completed
          oldsizestdout=-1
       else
          # job is still running, check that STDOUT is growing
          sizestdout=$( du -b $rundir/STDOUT.0000 | awk '{ print $1 }' )
          if [[ $sizestdout > $oldsizestdout ]] ; then
             date
             echo 'coasting !!'
             oldsizestdout=$sizestdout
          else
             date
             echo $oldsizestdout $sizestdout
             # check for files newer than previous check
             previous_check=$( date -d -${monitor_every_N_min}min )
             nnewfiles=$( find . -newermt "$(date -d -20min ) " | wc -l )
             if [[ $nnewfiles > 0 ]] ; then
                echo 'writing large file'
             else
                echo 'run is frozen, calling it quits'
                echo qdel $jobid
             fi
          fi
       fi
    else
       if [[ $jobstatus == 'Q' ]] ; then
          date
          echo 'Job is in queue'
       else
          date
          if [[ $jobstatus == '' ]] ; then
              echo 'No jobs in queue'
          else 
              echo 'Jobs has status : ' $jobstatus
          fi
      fi
    fi

    sleep $(( $monitor_every_N_min * 60 ))
done
