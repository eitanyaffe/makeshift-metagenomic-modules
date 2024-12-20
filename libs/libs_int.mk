#####################################################################################################
# register module
#####################################################################################################

units:=manager.mk gzip.mk trimmomatic.mk duplicates.mk split.mk deconseq.mk pair.mk \
clean.mk libs_merge.mk libs_multi.mk libs_stats.mk libs_upload.mk \
libs_export.mk libs_plot.mk libs_top.mk

LIBS_VER?=v1.03
$(call _register_module,libs,LIBS_VER,$(units))

#####################################################################################################
# version log
#####################################################################################################

# TBD v1.04: added support for single-sided library
# v1.03: solved bug in counting trimmomatic output (non_paired were included)

#####################################################################################################
# basic input/output dirs
#####################################################################################################

# root of input and output
INPUT_DIR?=$(GCP_MOUNT_BASE_DIR)/input
OUTPUT_DIR?=$(GCP_MOUNT_BASE_DIR)/output

# makeshift binary files
BIN_DIR?=$(GCP_MOUNT_BASE_DIR)/bin

# optional limit to specific assembly ids
LIBS_LIMIT_AIDS?=NA

# optional limit to specific library ids
LIBS_LIMIT_SIDS?=NA

# used for most tasks
LIBS_BASIC_MACHINE?=n1-standard-2

#####################################################################################################
# Module input:
# LIB_ID: identifier of library
# LIB_INPUT_R1_GZ_FN: Comma-separated list of R1 fastq compressed files, relative path in input dir
# LIB_INPUT_R2_GZ_FN: Same for R2
#####################################################################################################

# PE: pair-ended, fully supported
# SE: single-sided libraries are converted to pair-ended by splitting reads in the middle
LIB_MODE?=PE

# lib id
LIB_ID?=specify_lib_id

# relative path in input dir
LIB_INPUT_R1_GZ_FN?=specify_fastq_R1
LIB_INPUT_R2_GZ_FN?=specify_fastq_R2

LIB_INPUT_R1_GZ?=$(addprefix $(INPUT_DIR)/,$(subst $(__comma),$(__space),$(LIB_INPUT_R1_GZ_FN)))
LIB_INPUT_R2_GZ?=$(addprefix $(INPUT_DIR)/,$(subst $(__comma),$(__space),$(LIB_INPUT_R2_GZ_FN)))

# can be changed to position under different dir structure
LIBS_OUT_DIR?=$(OUTPUT_DIR)

# versions allow to keep output easily
LIBS_BASE_DIR?=$(OUTPUT_DIR)/libs/$(LIBS_VER)

LIBS_WORK_DIR?=$(LIBS_BASE_DIR)/work

LIB_BASE_DIR?=$(LIBS_BASE_DIR)/$(LIB_ID)
LIB_WORK_DIR?=$(LIB_BASE_DIR)/work
LIB_INFO_DIR?=$(LIB_BASE_DIR)/info
LIB_OUT_DIR?=$(LIB_BASE_DIR)/out

LIBS_FDIR?=$(FIGURE_DIR)/libs/$(LIBS_VER)

#####################################################################################################
# input table of all libraries
#####################################################################################################

# table with libraries, specified by user
# fields:
# assembly: assembly identifier
# lib: library identifier
# type: optional library classification (e.g. pre/mid/post)
# R1/R2: Relative path to fastq files within the input bucket
LIBS_INPUT_TABLE?=$(INPUT_DIR)/library_table.txt

# fields in table
LIBS_INPUT_TABLE_LIB_FIELD?=lib
LIBS_INPUT_TABLE_ASSEMBLY_FIELD?=assembly

# optionaly labels (used in plotting in restrict) are in separate table
# used currently for plot_response_complete in the dyn module
# note that it does not have to be canonic 
LIBS_LABEL_TABLE?=$(LIBS_CANON_TABLE)
LIBS_LABEL_FIELD?=canon

#####################################################################################################
# multiple libs
#####################################################################################################

# identifier of library set
LIBS_MULTI_SET?=default
LIBS_MULTI_DIR?=$(LIBS_BASE_DIR)/multi/$(LIBS_MULTI_SET)

# input table with LIB_ID, LIB_INPUT_R1_GZ, LIB_INPUT_R2_GZ
# generated in the config-module
LIBS_TABLE?=$(LIBS_MULTI_DIR)/libs_table

#####################################################################################################
# disk size and type
#####################################################################################################

# total size of input files in MB
LIBS_FILESIZE_MB?=3000

# Disk size in GB: 8 * ceiling(N), where is is the total input file sizes in GB
# for example, the default expected file size is 3GB (1500MB for each read side)
# which results in a disk of 32GB
LIBS_DISK_FACTOR?=10
LIBS_DISK_GB?=$(shell echo "(1+$(LIBS_FILESIZE_MB)/1000)*$(LIBS_DISK_FACTOR)" | bc)

# trimmomatic needs a bit more
TRIMMO_DISK_FACTOR?=15
TRIMMO_DISK_GB?=$(shell echo "(1+$(LIBS_FILESIZE_MB)/1000)*$(TRIMMO_DISK_FACTOR)" | bc)

# pd-ssd or pd-standard
LIBS_DISK_TYPE?=pd-ssd

#####################################################################################################
# subsample reads
#####################################################################################################

# use up to this number of reads from each library (in millions)
LIBS_MAX_MREADS?=25

# discard reads shorter than threshold, used only in SE mode
LIBS_FASTQ_MIN_LENGTH?=80

# half from each read side 
LIBS_FASTQ_READ_COUNT=$(shell echo $(LIBS_MAX_MREADS)\*1000000 | bc)

# random seed for library rarefaction
LIBS_SUBSAMPLE_SEED?=1

#####################################################################################################
# (i) gzip.mk
#####################################################################################################

LIB_INPUT_DIR?=$(LIB_WORK_DIR)/input
LIBS_INPUT_R1?=$(LIB_INPUT_DIR)/R1.fastq
LIBS_INPUT_R2?=$(LIB_INPUT_DIR)/R2.fastq

# sub-sample stats
LIBS_SUBSAMPLE_STATS?=$(LIB_INPUT_DIR)/subsample.stats

PIGZ_THREADS?=2

COUNT_INPUT?=$(LIB_INPUT_DIR)/.count_input

#####################################################################################################
# (ii) trimmomatic.mk
#####################################################################################################

############################################################################
# NOTE:
# to properly trim adapters, please remember to set TRIMMOMATIC_ADAPTER_SFN
# according to the way the library was prepared
############################################################################

TRIMMOMATIC_IN_R1?=$(LIBS_INPUT_R1)
TRIMMOMATIC_IN_R2?=$(LIBS_INPUT_R2)

TRIMMOMATIC_OUTDIR?=$(LIB_WORK_DIR)/trimmomatic

# lib-prep style
#   NexteraPE-PE.fa: Designed for Nextera
#   TruSeq3-PE-2.fa: Cover all TrueSeq options
TRIMMOMATIC_ADAPTER_SFN?=NexteraPE-PE.fa
TRIMMOMATIC_ADAPTER_FN?=/usr/share/trimmomatic/$(TRIMMOMATIC_ADAPTER_SFN)

TRIMMOMATIC_MODE?=PE
TRIMMOMATIC_LEADING?=20
TRIMMOMATIC_TRAILING?=3
TRIMMOMATIC_ILLUMINACLIP?=2:30:10:1:true
TRIMMOMATIC_MAXINFO?=60:0.1

TRIMMOMATIC_THREADS?=4

TRIMMOMATIC_PARAMS?=\
ILLUMINACLIP:$(TRIMMOMATIC_ADAPTER_FN):$(TRIMMOMATIC_ILLUMINACLIP) \
LEADING:$(TRIMMOMATIC_LEADING) \
TRAILING:$(TRIMMOMATIC_TRAILING) \
MAXINFO:$(TRIMMOMATIC_MAXINFO) -phred33

# non-paired
TRIMMOMATIC_NONPAIRED_R1?=$(TRIMMOMATIC_OUTDIR)/non_paired_R1.fastq
TRIMMOMATIC_NONPAIRED_R2?=$(TRIMMOMATIC_OUTDIR)/non_paired_R2.fastq

TRIMMOMATIC_PAIRED_R1?=$(TRIMMOMATIC_OUTDIR)/paired_R1.fastq
TRIMMOMATIC_PAIRED_R2?=$(TRIMMOMATIC_OUTDIR)/paired_R2.fastq

TRIMMO_COMMAND?='Trimmomatic$(TRIMMOMATIC_MODE) -threads $(TRIMMOMATIC_THREADS) \
$$$${TRIMMOMATIC_IN_R1} $$$${TRIMMOMATIC_IN_R2} \
$$$${TRIMMOMATIC_PAIRED_R1} $$$${TRIMMOMATIC_NONPAIRED_R1} \
$$$${TRIMMOMATIC_PAIRED_R2} $$$${TRIMMOMATIC_NONPAIRED_R2} \
$(TRIMMOMATIC_PARAMS)'

#####################################################################################################
# (iii) duplicates.mk
#####################################################################################################

DUP_DIR?=$(LIB_WORK_DIR)/dup
DUP_INPUT_DIR?=$(TRIMMOMATIC_OUTDIR)

DUP_R1?=$(DUP_DIR)/R1.fastq
DUP_R2?=$(DUP_DIR)/R2.fastq

COMPLEXITY_TABLE?=$(DUP_DIR)/dup_complexity.table
SUMMARY_TABLE?=$(DUP_DIR)/dup_summary.table

# copy 
FINAL_COMPLEXITY_TABLE?=$(LIB_INFO_DIR)/dup_complexity.table
FINAL_SUMMARY_TABLE?=$(LIB_INFO_DIR)/dup_summary.table

COUNT_DUPS?=$(DUP_DIR)/.count_dups

#####################################################################################################
# (iv) split.mk
#####################################################################################################

SPLIT_INPUT_R1?=$(DUP_R1)
SPLIT_INPUT_R2?=$(DUP_R2)

SPLIT_DIR?=$(LIB_WORK_DIR)/split

# table with all chunks and reads/chunk
CHUNK_TABLE?=$(SPLIT_DIR)/chunk.tab

# reads per chunk
SPLIT_SIZE?=4000000

CHUNK_ID?=1
SPLIT_R1?=$(SPLIT_DIR)/$(CHUNK_ID)_R1.fastq
SPLIT_R2?=$(SPLIT_DIR)/$(CHUNK_ID)_R2.fastq

# chunk disk size in GB: 2 + R, where R is the number of chunk reads in millions
LIBS_CHUNK_DISK_GB?=$(shell echo "2+$(SPLIT_SIZE)/1000000" | bc)
LIBS_CHUNK_DISK_TYPE?=pd-ssd

#####################################################################################################
# (v) deconseq.mk
#####################################################################################################

# from here on we work on chunks
CHUNKS_DIR?=$(LIB_WORK_DIR)/chunks
CHUNK_DIR?=$(CHUNKS_DIR)/$(CHUNK_ID)

# deconseq directory should be supplied by user directly or through mounted GCP bucket, e.g.:
# $(call _class_instance,gmount,DE,gs://yaffe-deconseq  standard DECONSEQ_BASE_DIR)
DECONSEQ_BASE_DIR?=$(GCP_MOUNT_BASE_DIR)/deconseq

DECONSEQ_BIN_DIR?=$(DECONSEQ_BASE_DIR)/deconseq-standalone-0.4.3

DECONSEQ_SCRIPT?=$(DECONSEQ_BIN_DIR)/deconseq.pl

# input
DECONSEQ_IFN_R1?=$(SPLIT_R1)
DECONSEQ_IFN_R2?=$(SPLIT_R2)

# Alignment coverage threshold in percentage
DECONSEQ_COVERAGE?=10

# Alignment identity threshold in percentage
DECONSEQ_IDENTITY?=80

# threads
DECONSEQ_THREADS?=4

# Name of deconseq database to use (human)
DECONSEQ_DBS?=hsref

# output
DECONSEQ_DIR?=$(CHUNK_DIR)/remove_human
DECONSEQ_OUT_R1?=$(DECONSEQ_DIR)/R1_clean.fq
DECONSEQ_OUT_R2?=$(DECONSEQ_DIR)/R2_clean.fq

#####################################################################################################
# (vi) paired reads
#####################################################################################################

PAIRED_IN_R1?=$(DECONSEQ_OUT_R1)
PAIRED_IN_R2?=$(DECONSEQ_OUT_R2)

PAIRED_DIR?=$(CHUNK_DIR)/paired

PAIRED_R1?=$(PAIRED_DIR)/paired_R1.fastq
PAIRED_R2?=$(PAIRED_DIR)/paired_R2.fastq

NON_PAIRED_R1?=$(PAIRED_DIR)/non_paired_R1.fastq
NON_PAIRED_R2?=$(PAIRED_DIR)/non_paired_R2.fastq

#####################################################################################################
# (vii) merge chunks and compress
#####################################################################################################

# merge united paired file
LIB_MERGE_DIR?=$(LIB_WORK_DIR)/merge
MERGED_R1?=$(LIB_MERGE_DIR)/R1.fastq
MERGED_R2?=$(LIB_MERGE_DIR)/R2.fastq

COUNT_MERGE?=$(LIB_MERGE_DIR)/.count_merge

FINAL_R1?=$(LIB_OUT_DIR)/R1.fastq.gz
FINAL_R2?=$(LIB_OUT_DIR)/R2.fastq.gz

# remove temp files
LIBS_PURGE_TEMP?=T

#####################################################################################################
# upload
#####################################################################################################

LIBS_UPLOAD_DIR?=$(LIBS_MULTI_DIR)/upload

# preload for SRA
LIBS_FTP_ADDRESS?=ftp-private.ncbi.nlm.nih.gov
LIBS_FTP_USERNAME?=subftp

# get parameters from the SRA submission portal, define in the project config file
LIBS_FTP_PASSWORD?=NA
LIBS_FTP_BASE_FOLDER?=NA
LIBS_FTP_NAME?=$(PROJECT_NAME)

LIBS_FTP_PARALLEL_COUNT?=16

#####################################################################################################
# stats
#####################################################################################################

RUN_STATS_DIR=$(LIB_INFO_DIR)/run_stats

FREE_PREFIX='*'
FREE_SUFFIX='*'

READ_STATS_DIR=$(LIB_INFO_DIR)/read_stats

PP_COUNT_INPUT?=$(READ_STATS_DIR)/.count_input
PP_COUNT_TRIMMOMATIC?=$(READ_STATS_DIR)/.count_trimmomatic
PP_COUNT_DUPS?=$(READ_STATS_DIR)/.count_dups
PP_COUNT_DECONSEQ?=$(READ_STATS_DIR)/.count_deconseq
PP_COUNT_FINAL?=$(READ_STATS_DIR)/.count_final

# deconseq count results first measured per chunk
PP_COUNT_DECONSEQ_CHUCK?=$(DECONSEQ_DIR)/.count_deconseq

#####################################################################################################
# collect stats
#####################################################################################################

# place post files here
LIBS_POST_DIR?=$(LIBS_MULTI_DIR)/post

MULTI_STATS_DIR?=$(LIBS_POST_DIR)/stats

STATS_READS_COUNTS?=$(MULTI_STATS_DIR)/read_counts.txt
STATS_READS_YIELD?=$(MULTI_STATS_DIR)/read_yield.txt

STATS_BPS_COUNTS?=$(MULTI_STATS_DIR)/bps_counts.txt
STATS_BPS_YIELD?=$(MULTI_STATS_DIR)/bps_yield.txt

STATS_DUPS?=$(MULTI_STATS_DIR)/dups.txt

# relative a baseline of the best library
STATS_POOL_USE_BASELINE?=T

# inferred pool size
STATS_POOL_SIZE?=$(MULTI_STATS_DIR)/pool_size.txt

# used to estimate pool weight
STATS_MOLECULE_LENGTH?=300

LIB_STATS_FDIR?=$(LIBS_FDIR)/stats/$(LIB_STATS_LABEL)
LIB_STATS_LABELS?=$(LIB_STATS_IDS)

#####################################################################################################
# select high-quality libs
#####################################################################################################

# minimal final read pair count (M)
LIBS_SELECT_MIN_READ_COUNT?=6

# minimal yield (%) of trimmomatic bp clean-up step
LIBS_SELECT_MIN_TRIMMO_BP_YIELD?=80

# minimal yield (%) of duplicate reads removal step
LIBS_SELECT_MIN_DUPLICATE_READ_YIELD?=80

# minimal yield (%) of human-associated reads removal step
LIBS_SELECT_MIN_HUMAN_READ_YIELD?=80

# output here
LIBS_SELECT_DIR?=$(LIBS_POST_DIR)/select

# libs that passed filter
LIBS_SELECT_TABLE?=$(LIBS_SELECT_DIR)/libs_select.txt

# libs that failed filters or are completely missing
LIBS_MISSING_TABLE?=$(LIBS_SELECT_DIR)/libs_missing.txt

#####################################################################################################
# export data
#####################################################################################################

LIBS_EXPORT_DIR?=$(BASE_EXPORT_DIR)/libs_$(LIBS_VER)

LIBS_EXPORT_VARS?=\
STATS_READS_COUNTS STATS_READS_YIELD \
STATS_BPS_COUNTS STATS_BPS_YIELD \
STATS_DUPS
