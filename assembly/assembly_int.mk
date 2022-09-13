#####################################################################################################
# register module
#####################################################################################################

units:=assembly_input.mk megahit.mk assembly_manager.mk assembly_stats.mk assembly_export.mk \
assembly_top.mk

ASSEMBLY_VER?=v1.02
$(call _register_module,assembly,ASSEMBLY_VER,$(units))

#####################################################################################################
# multiple assemblies
#####################################################################################################

ASSEMBLY_MULTI_LABEL?=default
ASSEMBLY_MULTI_DIR?=$(ASSEMBLY_BASE_DIR)/multi/$(ASSEMBLY_MULTI_LABEL)

# table with fields: assembly,lib
ASSEMBLY_LIBS_INPUT_TABLE?=$(LIBS_INPUT_TABLE)

# input table with ASSEMBLY_ID and ASSEMBLY_LIB_IDS
# generated from the LIBS_TABLE
ASSEMBLY_TABLE?=$(ASSEMBLY_MULTI_DIR)/assembly_table

#####################################################################################################
# run specs
#####################################################################################################

# machine type overrides cpus/ram 
ASSEMBLY_MACHINE?=n1-standard-64
ASSEMBLY_THREADS?=64

#ASSEMBLY_MACHINE?=n2d-highcpu-224
#ASSEMBLY_MACHINE?=n2d-standard-128

# for megahit

# for uncompressing
ASSEMBLY_PIGZ_THREADS?=4

# special machine for input
ASSEMBLY_INPUT_MACHINE?=e2-standard-4

ASSEMBLY_INPUT_DISK_GB?=512
ASSEMBLY_INPUT_DISK_TYPE?=pd-standard

ASSEMBLY_DISK_GB?=256
ASSEMBLY_DISK_TYPE?=pd-ssd

#####################################################################################################
# basic assembly input and params
#####################################################################################################

ASSEMBLY_MAX_KMER?=77
ASSEMBLY_MIN_CONTIG?=200
ASSEMBLY_TAG?=k77_200M

ASSEMBLER?=megahit
ASSEMBLY_ID?=assembly1
ASSEMBLY_BASE_DIR?=$(OUTPUT_DIR)/assembly/$(ASSEMBLY_VER)
ASSEMBLY_DIR?=$(ASSEMBLY_BASE_DIR)/$(ASSEMBLY_ID)/$(ASSEMBLY_TAG)

ASSEMBLY_FDIR?=$(FIGURE_DIR)/assembly/$(ASSEMBLY_VER)

ASSEMBLY_INFO_DIR?=$(ASSEMBLY_DIR)/info
ASSEMBLY_WORK_DIR?=$(ASSEMBLY_DIR)/work

# by default all libs are used for the assemb\ly
ASSEMBLY_LIB_IDS?=$(subst  $(__comma),$(__space),$(LIB_IDS))

#####################################################################################################
# input
#####################################################################################################

# input source
# libs: generated by the libs module, using the FINAL_R[12] variables, expecting a compressed file
# direct: user-specified input files
ASSEMBLY_INPUT_SOURCE?=libs_module

# specify variable of non-compressed lib fastq of R1 and R2
# relevant if ASSEMBLY_INPUT_SOURCE is 'direct'
ASSEMBLY_USER_LIB_VARIABLE?=specify_lib_id_variable
ASSEMBLY_USER_INPUT_VARIABLE_R1?=specify_fastq_variable_R1
ASSEMBLY_USER_INPUT_VARIABLE_R2?=specify_fastq_variable_R2

# files are copied here and decompressed
ASSEMBLY_INPUT_DIR?=$(ASSEMBLY_DIR)/input

# single unified file
ASSEMBLY_INPUT_BASE_FASTQ?=$(ASSEMBLY_INPUT_DIR)/raw_reads.fastq

# normalize style
# none: keep all reads
# subsample: sub-sample input using a max number of reads
# khmer: use normalize-by-median.py
ASSEMBLY_INPUT_STYLE?=subsample

####################################
# subsample params
####################################

ASSEMBLY_RANDOM_SEED?=1

ASSEMBLY_NORM_MAX_READS?=200000000

####################################
# khmer params
####################################

# k-mer size to use
ASSEMBLY_NORM_KSIZE?=31

# when the median k-mer coverage level is above this number the read is not kept
ASSEMBLY_NORM_CUTOFF?=20

# maximum amount of memory to use for data structure
ASSEMBLY_NORM_MEMORY?=10000000000

# report file
ASSEMBLY_NORM_REPORT?=$(ASSEMBLY_INPUT_DIR)/report

# result
ASSEMBLY_INPUT_FASTQ?=$(ASSEMBLY_INPUT_DIR)/reads.fastq

#####################################################################################################
# megahit work
#####################################################################################################

# megahit is installed in the gcp/containers/mdocker Dockerfile where MEGAHIT_BIN is set
MEGAHIT_BIN?=megahit

MEGAHIT_MEMORY_CAP?=0.9

MEGAHIT_MIN_CONTIG_LENGTH?=$(ASSEMBLY_MIN_CONTIG)

MEGAHIT_MIN_KMER?=27
MEGAHIT_MAX_KMER?=$(ASSEMBLY_MAX_KMER)
MEGAHIT_KMER_STEP?=10

# other parameters here:
MEGAHIT_MISC?=--merge-level 20,0.95

# rsync megahit results in background to bucket (if running on GCP)
MEGAHIT_RSYNC_WAIT_TIME?=20m

# output
FULL_CONTIG_FILE?=$(ASSEMBLY_WORK_DIR)/contigs
FULL_CONTIG_TABLE?=$(ASSEMBLY_WORK_DIR)/contig_table

# select long contigs
ASSEMBLY_MIN_LEN?=1000
ASSEMBLY_CONTIG_FILE?=$(ASSEMBLY_WORK_DIR)/long_contigs
ASSEMBLY_CONTIG_TABLE?=$(ASSEMBLY_WORK_DIR)/long_contig_table

MEGAHIT_WORK_DIR?=$(ASSEMBLY_WORK_DIR)/run

# input for fastg converter
MEGAHIT_FASTA?=$(MEGAHIT_WORK_DIR)/intermediate_contigs/k$(MEGAHIT_MAX_KMER).contigs.fa

# fastg of result
MEGAHIT_FASTG?=$(ASSEMBLY_WORK_DIR)/k$(MEGAHIT_MAX_KMER).fastg

#####################################################################################################
# collect stats
#####################################################################################################

ASSEMBLY_MULTI_STATS_DIR?=$(ASSEMBLY_MULTI_DIR)/stats
ASSEMBLY_STATS_TABLE?=$(ASSEMBLY_MULTI_STATS_DIR)/summary.txt

#####################################################################################################
# export data
#####################################################################################################

ASSEMBLY_EXPORT_DIR?=$(BASE_EXPORT_DIR)/assembly_$(ASSEMBLY_VER)

ASSEMBLY_EXPORT_VARS?=\
ASSEMBLY_CONTIG_FILE ASSEMBLY_CONTIG_TABLE
