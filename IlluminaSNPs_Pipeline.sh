#!/bin/bash
#===============================================================================
#
#          FILE:  IlluminaSNPs_Pipeline.sh
# 
#         USAGE:  ./IlluminaSNPs_Pipeline.sh 
# 
#   DESCRIPTION:  Illumina MiSeq Data Ingestion and Analysis Pipeline Script
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  GNU parallel: https://www.gnu.org/software/parallel
#  REQUIREMENTS:  Parallel Implementation of GZIP (PIGZ): https://zlib.net/pigz
#          BUGS:  ---
#         NOTES:  Developed for the NTI DNA Mixture Analysis (IR20-068) project
#        AUTHOR:  Adam Michaleas (), adam.michaleas@ll.mit.edu
#       COMPANY:  MIT Lincoln Laboratory
#       VERSION:  1.0
#       CREATED:  09/16/2020 04:57:39 PM EST
#      REVISION:  1.0
#===============================================================================

# DISTRIBUTION STATEMENT A. Approved for public release. Distribution is unlimited.

# This material is based upon work supported by the United States Air Force under Air Force Contract No. FA8702-15-D-0001. Any opinions, findings, conclusions or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of the United States Air Force.

# © 2020 Massachusetts Institute of Technology.

# Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)

# The software/firmware is provided to you on an As-Is basis

# Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, U.S. Government rights in this work are defined by DFARS 252.227-7013 or DFARS 252.227-7014 as detailed above. Use of this work other than as specifically authorized by the U.S. Government may violate any copyrights that exist in this work.

### Global Variable Declarations ###

DATADIR=/mnt/MiSeq
FILE_COMBINE=/tmp/.illumina_filecombine.txt
COMBINE_CMDS=/tmp/.illumina_combine_commands.txt
ISNPS=/data1/SNP_Caller/Illumina-MiSeq
PREV_RUNS=/tmp/.illumina_prev_runs.txt
CURR_RUNS=/tmp/.illumina_curr_runs.txt
PEND_RUNS=/tmp/.illumina_pend_runs.txt
FQFILES=/tmp/.illumina_fastqfiles.txt
FQCMDGEN=/tmp/.illumina_fastqcmdgen.txt
FQCPCMDS=/tmp/.illumina_fastqcpfiles.txt
GUNZIPCMDS=/tmp/.illumina_gunzip_cmds.txt
PID_FILE=/tmp/.illumina_analyze.pid

### If files for tracking runs do not exist, create them ###

if [ ! -f $PREV_RUNS ]; then
   touch $PREV_RUNS
fi

if [ ! -f $CURR_RUNS ]; then
   touch $CURR_RUNS
fi

### If it doesn't already exist, create a PID file (lock file) to manage Illumina data ingestion/analysis process ###

if [ -f $PID_FILE ];
   then echo "There is an instance of the Illumina MiSeq data ingestion and analysis pipeline already running.  Exiting script!";
   echo "";
   exit 1;
fi

if [ ! -f $PID_FILE ];
   then echo $$ > $PID_FILE;
   echo "";
fi

### If directories for storing the original R1/R2 consolidated fastq files, and results do not exist, create them ###


if [ ! -d $ORIG_FILES ]; then
   mkdir $ORIG_FILES
fi

if [ ! -d $RESULTS_FILES ]; then
   mkdir $RESULTS_FILES
fi

### Create a trap function that will remove the PID file (lock file) if a SIGINT is sent to this script (Ctrl-C, etc.) ###

function finish() {
   rm $PID_FILE; exit 1;
}

trap finish SIGINT

### Display MITLL Illumina MiSeq data ingestion and analysis pipeline banner ###

echo "MIT Lincoln Laboratory Illumina MiSeq data ingestion and analysis pipeline ver (1.0):"
echo "-------------------------------------------------------------------------------------"
echo "";
echo "Hostname = `hostname`"
echo "`uname -a`"
echo "Date: `date "+%Y-%m-%d"`"
echo "CPU Type/Thread count:`cat /proc/cpuinfo | grep "model name"  | uniq | cut -f 2 -d ":"` / `cat /proc/cpuinfo | grep processor | wc -l` CPU threads"
echo "Memory Installed: `cat /proc/meminfo | grep -i Memtotal | awk -F ' ' '{print $2}' | awk '{$1=$1/(1024^2); print $1,"GB";}'`"
echo ""

### Check to see if there are new Illumina MiSeq RUO Runs ###

ls $DATADIR > $CURR_RUNS
comm -13 $PREV_RUNS $CURR_RUNS > $PEND_RUNS

### Check to see if there are new Illumina MiSeq RUO Runs ###

ls $DATADIR > $CURR_RUNS
comm -13 $PREV_RUNS $CURR_RUNS > $PEND_RUNS

### Check to see if there are new Illumina MiSeq runs to review. If there are none, exit the script ###

COUNT=`comm -13 $PREV_RUNS $CURR_RUNS | wc -l`

if [ $COUNT -gt 0 ];
   then echo "New Illumina MiSeq runs have been detected. Moving on to next steps."
fi

if [ $COUNT == 0 ];
   then echo "No new Illumina MiSeq runs have been detected at this time. Exiting script."
   echo ""
   rm $PID_FILE ; exit 1;
fi

### Confirm that the run completed successfully.  If a run is not complete, exit the script ###

for f in `cat $PEND_RUNS` ; 
   do RUN_STATUS=`cat $DATADIR/$f/RunCompletionStatus.xml | grep -i "/CompletionStatus" | cut -f 2 -d ">" | cut -f 1 -d "<"` ; 

   echo "Run Name: $f" ;
   echo "Run status: $RUN_STATUS"; 
   echo "";

done

### If the the Illumina MiSeq run has completed successfully, then proceed with data ingestion and analysis steps ###

for f in `cat $PEND_RUNS` ; 
   do RUN_STATUS_CHECK=`cat $DATADIR/$f/RunCompletionStatus.xml | grep -i "/CompletionStatus" | cut -f 2 -d ">" | cut -f 1 -d "<" | grep SuccessfullyCompleted | wc -l` ; 

   if [ $RUN_STATUS_CHECK == 1 ] ; 
      then echo "The run $f has been successfully been sequenced by the Illumina MiSeq Instrument"  
      echo "";
      echo "The fastq data ingestion and analysis for this run will now begin..." ; 
      echo "";
   fi ; 

done

### If the MiSeq run is still in progress or has failed, exit the script ###

for f in `cat $PEND_RUNS`; 
   do RUN_STATUS_CHECK=`cat $DATADIR/$f/RunCompletionStatus.xml | grep -i "/CompletionStatus" | cut -f 2 -d ">" | cut -f 1 -d "<" | grep SuccessfullyCompleted | wc -l` ; 

   if [ $RUN_STATUS_CHECK == 0 ] ; 
      then echo "The run is bad" && exit 1 ; 
   fi ; 

done

### Parallelize the copying data from the Illumina MiSeq server to a data analysis directory for processing by the IdPrism pipeline ###

cat /dev/null > $FQFILES

for f in `cat $PEND_RUNS` ;
   do echo "`cd $DATADIR/$f/Data/Intensities/Basecalls && find . -type f \( -iname "*.fastq.gz" ! -iname "Undetermined_**" \) | cut -f 2 -d "/"`" >> $FQFILES
done

cat /dev/null > $FQCMDGEN

for f in `cat $FQFILES`;
   do echo "`find $DATADIR -name $f`" >> $FQCMDGEN
done

cat /dev/null > $FQCPCMDS

for f in `cat $FQCMDGEN`;
   do echo "cp -pr $f $ISNPS/" >> $FQCPCMDS
done

parallel --will-cite < $FQCPCMDS

### Paralleize the decompression of the Illumina MiSeq fastq files ###

cat /dev/null > $FILE_COMBINE

cat /dev/null > $GUNZIPCMDS

for f in `cat $FQFILES`;
   do echo "gunzip $f" >> $GUNZIPCMDS
done

cd $ISNPS && parallel --will-cite < $GUNZIPCMDS

cd $ISNPS && ls *.fastq | cut -f 1 -d _ | sort -u | uniq >> $FILE_COMBINE

### Combine R1 and R2 data for each fastq file pair into a single fastq file ###

cat /dev/null > $COMBINE_CMDS

for f in `cat $FILE_COMBINE`
   do echo "ls | grep $f | xargs -t cat > $f.fastq" >> $COMBINE_CMDS ;
done

cd $ISNPS && parallel --will-cite < $COMBINE_CMDS

### Insert pipeline automation code here when ready to perform data anlaysis on each consolidated .fastq file ###



### Concatenate $CURR_RUNS into $PREV_RUNS so that they are equivalent until new data is generated on the MiSeq ###

cat $CURR_RUNS > $PREV_RUNS

### Remove PID file upon successful completion of automated pipeline ###

rm $PID_FILE;
