units:=map_input.mk map_index.mk map_chunks.mk map_merge.mk map_manager.mk \
map_multi.mk map_stats.mk map_export.mk map_top.mk

MAP_VER?=v1.05
$(call _register_module,map,MAP_VER,$(units))

#####################################################################################################
# tools
#####################################################################################################

BWA_BIN?=bwa
SAMTOOLS_BIN?=samtools

#####################################################################################################
# GCP specs
#####################################################################################################

# input and split
MAP_INPUT_MACHINE_TYPE?=e2-standard-2
MAP_PIGZ_THREADS?=2

# create bwa index
MAP_INDEX_MACHINE_TYPE?=e2-highmem-2

# map chunk and parse results
MAP_CHUNK_MACHINE_TYPE?=e2-standard-4
MAP_BWA_THREADS?=8
MAP_SAMTOOLS_SORT_THREADS?=8

# merge chunk bams and tables
MAP_MERGE_MACHINE_TYPE?=e2-highcpu-8
MAP_SAMTOOLS_MERGE_THREADS?=8

# merge chunk bams and tables
MAP_UNION_MACHINE_TYPE?=e2-highcpu-8

# disk sizes
MAP_INDEX_DISK_GB?=32
MAP_INPUT_DISK_GB?=256
MAP_CHUNK_DISK_GB?=32
MAP_MERGE_DISK_GB?=256
MAP_UNION_DISK_GB?=512

# chunk tries
MAP_CHUNCK_PREEMTIBLE?=1
MAP_INPUT_PREEMTIBLE?=0

#####################################################################################################
# input
#####################################################################################################

# input reference fasta sequence
MAP_CONTIG_FILE?=$(FULL_CONTIG_FILE)

# by default looks for files processed by the lib module
MAP_INPUT_BASE_DIR?=$(LIBS_BASE_DIR)

# single lib
MAP_LIB_ID?=$(LIB_ID)
MAP_INPUT_R1_GZ?=$(LIBS_BASE_DIR)/$(MAP_INPUT_R1_GZ_FN)
MAP_INPUT_R2_GZ?=$(LIBS_BASE_DIR)/$(MAP_INPUT_R2_GZ_FN)

# if input is not compressed it should be specified using variables MAP_INPUT_R[12]
MAP_INPUT_COMPRESSED?=T

#####################################################################################################
# base directories
#####################################################################################################

MAP_ROOT_DIR?=$(OUTPUT_DIR)/map/$(MAP_VER)
MAP_BASE_DIR?=$(MAP_ROOT_DIR)/$(ASSEMBLY_ID)

MAP_FDIR?=$(FIGURE_DIR)/map/$(MAP_VER)

# base library output dir
MAP_DIR?=$(MAP_BASE_DIR)/libs/$(MAP_LIB_ID)

#####################################################################################################
# get input and uncompress
#####################################################################################################

MAP_SPLIT_DIR?=$(MAP_DIR)/split

MAP_INPUT_DIR?=$(MAP_SPLIT_DIR)/input
MAP_INPUT_R1?=$(MAP_INPUT_DIR)/R1.fastq
MAP_INPUT_R2?=$(MAP_INPUT_DIR)/R2.fastq

#####################################################################################################
# split into chunks
#####################################################################################################

# work on chunks here
MAP_CHUNK_TABLE?=$(MAP_SPLIT_DIR)/chunk.tab

# by default map entire read
MAP_SPLIT_TRIM?=F
MAP_SPLIT_READ_OFFSET?=10
MAP_SPLIT_READ_LENGTH?=40

# split input reads before mapping
MAP_SPLIT_READS_PER_FILE?=2000000

MAP_CHUNK_ID?=1
MAP_CHUNK_INPUT_R1?=$(MAP_SPLIT_DIR)/$(MAP_CHUNK_ID)_R1.fastq
MAP_CHUNK_INPUT_R2?=$(MAP_SPLIT_DIR)/$(MAP_CHUNK_ID)_R2.fastq

# work on chunks
MAP_CHUNKS_DIR?=$(MAP_DIR)/chunks
MAP_CHUNK_DIR?=$(MAP_CHUNKS_DIR)/$(MAP_CHUNK_ID)

# used for dsub
MAP_INFO_DIR?=$(MAP_DIR)/info

#####################################################################################################
# bwa index file
#####################################################################################################

# bwa index file
MAP_INDEX_DIR?=$(MAP_BASE_DIR)/index

MAP_INDEX_PREFIX?=$(MAP_INDEX_DIR)/idx

#####################################################################################################
# process chunk
#####################################################################################################

# raw output
MAP_CHUNK_SAM_R1?=$(MAP_CHUNK_DIR)/R1.sam
MAP_CHUNK_SAM_R2?=$(MAP_CHUNK_DIR)/R2.sam

# sorted bams (required for final merge of bams)
MAP_CHUNK_BAM_R1?=$(MAP_CHUNK_DIR)/R1.bam
MAP_CHUNK_BAM_R2?=$(MAP_CHUNK_DIR)/R2.bam

# sorted bams (required for final merge of bams)
MAP_CHUNK_PARSE_R1?=$(MAP_CHUNK_DIR)/R1.tab
MAP_CHUNK_PARSE_R2?=$(MAP_CHUNK_DIR)/R2.tab

MAP_STATS_R1?=$(MAP_CHUNK_DIR)/R1.stats
MAP_STATS_R2?=$(MAP_CHUNK_DIR)/R2.stats

# should verify parse step
MAP_SHOULD_VERIFY?=T

#####################################################################################################
# filtering
#####################################################################################################

# Phred of read
MAP_MIN_QUALITY_SCORE?=30

# in nt, the total length of all M segments in the CIGAR
MAP_MIN_LENGTH?=30

# The sam NM score as reported by bwa
MAP_MIN_EDIT_DISTANCE?=30

MAP_FILTERED_R1?=$(MAP_CHUNK_DIR)/R1.filtered
MAP_FILTERED_R2?=$(MAP_CHUNK_DIR)/R2.filtered

MAP_FILTERED_STATS_R1?=$(MAP_CHUNK_DIR)/R1.filtered.stats
MAP_FILTERED_STATS_R2?=$(MAP_CHUNK_DIR)/R2.filtered.stats

#####################################################################################################
# pairing
#####################################################################################################

# select single side with maximal value, based on field
MAP_PAIR_FIELD?=match_length

MAP_PAIRED_CHUNK?=$(MAP_CHUNK_DIR)/paired.tab
MAP_ONLY_R1_CHUNK?=$(MAP_CHUNK_DIR)/non_paired_R1.tab
MAP_ONLY_R2_CHUNK?=$(MAP_CHUNK_DIR)/non_paired_R2.tab
MAP_PAIRED_STATS?=$(MAP_CHUNK_DIR)/paired.stats

#####################################################################################################
# merge (final lib output)
#####################################################################################################

MAP_OUT_DIR?=$(MAP_DIR)/out

# both sides
MAP_BAM_FILE?=$(MAP_OUT_DIR)/merged.bam

# separate sides
MAP_BAM_R1?=$(MAP_OUT_DIR)/merged_R1.bam
MAP_BAM_R2?=$(MAP_OUT_DIR)/merged_R2.bam

# filtered reads, without pairing
MAP_R1?=$(MAP_OUT_DIR)/merged_R1.tab
MAP_R2?=$(MAP_OUT_DIR)/merged_R2.tab

# paired reads
MAP_PAIRED?=$(MAP_OUT_DIR)/merged_paired.tab

# non-paired sides
MAP_NON_PAIRED_R1?=$(MAP_OUT_DIR)/non_paired_R1.tab
MAP_NON_PAIRED_R2?=$(MAP_OUT_DIR)/non_paired_R2.tab

#####################################################################################################
# union (assembly output)
#####################################################################################################

# single bam needed for DomCycle and is turned off by default
MAP_PERFORM_UNION?=F

# bwa index file
MAP_UNION_DIR?=$(MAP_BASE_DIR)/union

# separate sides
MAP_UNION_BAM_R1?=$(MAP_UNION_DIR)/union_R1.bam
MAP_UNION_BAM_R2?=$(MAP_UNION_DIR)/union_R2.bam

#####################################################################################################
# stats
#####################################################################################################

# input reads
MAP_INPUT_STAT?=$(MAP_DIR)/stats_input

# parse reads
PARSE_STAT_DIR?=$(MAP_DIR)/parse_stat
PARSE_STAT_FILE?=$(MAP_DIR)/parse_stat.table

# filtering reads
FILTER_STAT_DIR?=$(MAP_DIR)/filter_stat_$(FILTER_ID)
FILTER_STAT_FILE?=$(MAP_DIR)/filter_stat_$(FILTER_ID).table

# pairing reads
PAIRED_STAT_DIR?=$(MAP_DIR)/pair_stat_$(FILTER_ID)
PAIRED_STAT_FILE?=$(MAP_DIR)/pair_stat_$(FILTER_ID).table

#####################################################################################################
# coverage
#####################################################################################################

MAP_BINSIZE?=100
COVERAGE_TABLE=$(MAP_DIR)/coverage.table
CONTIG_FIELD?=contig

#####################################################################################################
# collect stats
#####################################################################################################

MAP_MULTI_STATS_DIR?=$(MAP_MULTI_DIR)/stats

# bwa step
MAP_STATS_BWA?=$(MAP_MULTI_STATS_DIR)/bwa_stats.txt

# filter step
MAP_STATS_FILTER?=$(MAP_MULTI_STATS_DIR)/filter_stats.txt

# pairing step
MAP_STATS_PAIRED?=$(MAP_MULTI_STATS_DIR)/paired_stats.txt

# should remove all temporary files
MAP_PURGE_TEMP?=T

#####################################################################################################
# mutliple libs per assembly
#####################################################################################################

# table with fields: assembly,lib
MAP_LIBS_INPUT_TABLE=$(LIBS_INPUT_TABLE)

MAP_SET_DIR?=$(MAP_BASE_DIR)/set

# prefixe added to MAP_INPUT_R[12]_GZ_FN, can be NA to add none
MAP_INPUT_PREFIX?=out

# table with MAP_LIB_ID and MAP_INPUT_R[12]_GZ
MAP_LIBS_TABLE?=$(MAP_SET_DIR)/libs_table.txt

#####################################################################################################
# multiple assemblies
#####################################################################################################

MAP_MULTI_LABEL?=$(ASSEMBLY_MULTI_LABEL)
MAP_MULTI_DIR?=$(MAP_ROOT_DIR)/assembly_sets/$(MAP_MULTI_LABEL)
MAP_ASSEMBLY_TABLE?=$(ASSEMBLY_TABLE)

#####################################################################################################
# export data
#####################################################################################################

MAP_EXPORT_DIR?=$(BASE_EXPORT_DIR)/map_$(MAP_VER)

#MAP_EXPORT_VARS?=MAP_STATS_BWA MAP_STATS_FILTER MAP_STATS_PAIRED
MAP_EXPORT_VARS?=
