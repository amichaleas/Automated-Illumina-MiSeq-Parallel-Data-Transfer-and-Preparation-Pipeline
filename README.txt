#===============================================================================
#
#          FILE:  README.txt
#
#
#   DESCRIPTION:  IlluminaSNPs_Pipeline.sh script README.txt
#
#        AUTHOR:  Adam Michaleas (), adam.michaleas@ll.mit.edu
#        AUTHOR:  Philip Fremont-Smith (), philip.fremont-smith@ll.mit.edu
#       COMPANY:  MIT Lincoln Laboratory
#       VERSION:  1.0
#       CREATED:  09/16/2020 05:17:12 PM EST
#      REVISION:  ---
#===============================================================================

# DISTRIBUTION STATEMENT A. Approved for public release. Distribution is unlimited.

# This material is based upon work supported by the United States Air Force under Air Force Contract No. FA8702-15-D-0001. Any opinions, findings, conclusions or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of the United States Air Force.

# © 2020 Massachusetts Institute of Technology.

# Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)

# The software/firmware is provided to you on an As-Is basis

# Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, U.S. Government rights in this work are defined by DFARS 252.227-7013 or DFARS 252.227-7014 as detailed above. Use of this work other than as specifically authorized by the U.S. Government may violate any copyrights that exist in this work.


### Instructions for configuring IlluminaSNPs_Pipeline.sh ###
 
1. Set the DATADIR variable to the location (local or network-based filesystem) containing the Illumina MiSeq datasets is mounted.
- (Ex. DATADIR=/data/Illumina_MiSeq_Datasets

2. Set the ISNPS variable to the location where IlluminaSNPs_Pipeline.sh will be executed from.
- (Ex. ISNPS=/data/IlluminaSNPs_Pipeline)

3. Set the PREV_RUNS variable to the location where IlluminaSNPs_Pipeline.sh will track all Illumina MiSeq data that has been ingested and prepared for analysis.
- (Ex. PREV_RUNS=/data/IlluminaSNPs_Pipeline/prev_runs.txt)

4. Set the CURR_RUNS variable to the location where IlluminaSNPs_Pipeline.sh will write a list of all current Illumina MiSeq sequencer runs residing in DATADIR.
- (Ex. CURR_RUNS=/data/IlluminaSNPs_Pipeline/curr_runs.txt)

5. Set the PEND_RUNS variable to the location where IlluminaSNPs_Pipeline.sh will write a list of all Illumina MiSeq sequencer runs (different between PREV_RUNS and CURR_RUNS) that are pending and need to be ingested and prepared for analysis.
- (Ex. PEND_RUNS=/data/IlluminaSNPs_Pipeline/pend_runs.txt)

6. Set the FQFILES variable to the location where IlluminaSNPs_Pipeline.sh will write a list of all FASTQ files detected for each of the Illumina MiSeq sequencer runs.
- (Ex. FQFILES=/data/IlluminaSNPs_Pipeline/.illumina_fastqfiles.txt)

7. Set the FQCMDGEN variable to the location where IlluminaSNPs_Pipeline.sh will generate a list of all commands that will be used for locating FASTQ files in parallel from the MiSeq run data directory.
- (Ex. FQCMDGEN=/data/IlluminaSNPs_Pipeline/.illumina_fastqcmdgen.txt

8. Set the FQCPCMDS variable to the location where IlluminaSNPs_Pipeline.sh will generate a list of all commands that will be used for copying the FASTQ files in parallel from the MiSeq run data directory to DATADIR.
- (Ex. FQCPCMDS=/data/IlluminaSNPs_Pipeline/.illumina_fastqcpfiles.txt)

9. Set the PID_FILE variable to the location where IlluminaSNPs_Pipeline.sh will generate a PID (lock file) for this pipeline.  This will prevent multiple people from running this pipeline at once.
- (Ex. PID_FILE=/data/IlluminaSNPs_Pipeline/.illumina_analyze.pid)


### Instructions for running IlluminaSNPs_Pipeline.sh ###

1. The IlluminaSNPs_Pipeline.sh script is currently supported for running on Linux, and Mac systems. 
2. The following packages must be installed to properly run IlluminaSNPs_Pipeline.sh:

- GNU parallel: https://www.gnu.org/software/parallel
- Parallel Implementation of GZIP (PIGZ): https://zlib.net/pigz

