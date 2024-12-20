#####################################################################################################
# register module
#####################################################################################################

units=genes_prodigal.mk genes_uniref.mk genes_diamond.mk genes_blast_nt.mk genes_GO.mk \
genes_bins.mk genes_rna.mk genes_manager.mk genes_coverage.mk genes_collect.mk \
genes_export.mk genes_top.mk

GENES_VER?=v1.01
$(call _register_module,genes,GENES_VER,$(units))

#####################################################################################################
# input and databases locations
#####################################################################################################

# input fasta
GENES_FASTA_INPUT?=$(ASSEMBLY_CONTIG_FILE)

#####################################################################################################
# basic output dirs
#####################################################################################################

# output directory
GENES_ROOT_DIR?=$(OUTPUT_DIR)/genes/$(GENES_VER)

# multiple assemblies
GENES_MULTI_LABEL?=$(ASSEMBLY_MULTI_LABEL)
GENES_MULTI_DIR?=$(GENES_ROOT_DIR)/assembly_sets/$(GENES_MULTI_LABEL)
GENES_ASSEMBLY_TABLE?=$(ASSEMBLY_TABLE)

GENES_BASE_DIR?=$(GENES_ROOT_DIR)/$(ASSEMBLY_ID)
GENES_INFO_DIR?=$(GENES_BASE_DIR)/info

PRODIGAL_DIR?=$(GENES_BASE_DIR)/prodigal

#####################################################################################################
# uniref output dirs
#####################################################################################################

# place uniref under separate dir
UNIREF_VER?=v1.02
UNIREF_ROOT_DIR?=$(OUTPUT_DIR)/uniref/$(UNIREF_VER)
UNIREF_BASE_DIR?=$(UNIREF_ROOT_DIR)/$(ASSEMBLY_ID)
UNIREF_INFO_DIR?=$(UNIREF_BASE_DIR)/info

UNIREF_MULTI_LABEL?=$(ASSEMBLY_MULTI_LABEL)
UNIREF_MULTI_DIR?=$(UNIREF_ROOT_DIR)/assembly_sets/$(UNIREF_MULTI_LABEL)

#####################################################################################################
# GCP params
#####################################################################################################

UNIREF_DISK_GB?=256
UNIREF_MACHINE_TYPE?=n2-standard-80

#####################################################################################################
# prodigal.mk
#####################################################################################################

# prodigal is installed in the gcp/containers/mdocker Dockerfile
PRODIGAL_BIN?=prodigal

# parameters: https://github.com/hyattpd/prodigal/wiki/cheat-sheet
PRODIGAL_SELECT_PROCEDURE?=meta

# translation table
PRODIGAL_TRANSLATION_TABLE?=11

# input
PRODIGAL_INPUT?=$(GENES_FASTA_INPUT)

# output
PRODIGAL_AA_BASE?=$(PRODIGAL_DIR)/genes.faa
PRODIGAL_NT_BASE?=$(PRODIGAL_DIR)/genes.fna
PRODIGAL_OUTPUT_RAW?=$(PRODIGAL_DIR)/prodigal.out

# clean fasta headers
PRODIGAL_AA?=$(PRODIGAL_DIR)/genes_final.faa
PRODIGAL_NT?=$(PRODIGAL_DIR)/genes_final.fna

# gene table
PRODIGAL_GENE_TABLE?=$(PRODIGAL_DIR)/gene.tab

# by default use prodigal genes
GENE_FASTA_AA?=$(PRODIGAL_AA)
GENE_FASTA_NT?=$(PRODIGAL_NT)
GENE_TABLE?=$(PRODIGAL_GENE_TABLE)

#####################################################################################################
# blastn
#####################################################################################################

# blastn binary
BLAST_BIN?=blastn

BLAST_THREADS=40
BLAST_EVALUE=0.001

#####################################################################################################
# diamond
#####################################################################################################

# diamond binary
DIAMOND_BIN?=diamond

DIAMOND_BLOCK_SIZE?=20
DIAMOND_INDEX_CHUNKS?=1
DIAMOND_THREADS?=80
DIAMOND_EVALUE?=0.001
DIAMOND_BLAST_PARAMS?=
#DIAMOND_BLAST_PARAMS?=--sensitive

#####################################################################################################
# uniref
#####################################################################################################

# the uniref directory should be supplied by user directly or through mounted GCP bucket, e.g.:
# $(call _class_instance,gmount,DE,gs://yaffe-uniref standard UNIREF_DB_ROOT_DIR)
UNIREF_DB_ROOT_DIR?=$(GCP_MOUNT_BASE_DIR)/uniref

# UniRef from ftp://ftp.uniprot.org/pub/databases/uniprot/uniref
GENE_REF_ID?=2020_07
UNIREF_DB_BASE_DIR?=$(UNIREF_DB_ROOT_DIR)/UniRef100/$(GENE_REF_ID)

GENE_REF_IFN?=$(UNIREF_DB_BASE_DIR)/uniref100.fasta
GENE_REF_XML_IFN=$(UNIREF_DB_BASE_DIR)/uniref100.xml

# UniProt from ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.xml.gz
UNIPROT_ID?=2020_07
UNIPROT_XML_IFN?=/relman01/shared/databases/UniProt/versions/$(UNIPROT_ID)/uniprot_sprot.xml

UNIREF_DIAMOND_DB_DIR?=$(UNIREF_DB_BASE_DIR)/diamond
UNIREF_DIAMOND_DB_INFO_DIR?=$(UNIREF_DB_BASE_DIR)/diamond_info
UNIREF_DIAMOND_DB?=$(UNIREF_DIAMOND_DB_DIR)/index

# uniref table
UNIREF_TABLE_DIR?=$(UNIREF_DB_BASE_DIR)/files
UNIREF_TABLE?=$(UNIREF_TABLE_DIR)/table
UNIREF_GENE_TABLE?=$(UNIREF_TABLE_DIR)/genes

# uniprot and taxa id lookup
UNIREF_TAX_LOOKUP?=$(UNIREF_TABLE_DIR)/tax_lookup

UNIREF_DIR?=$(UNIREF_BASE_DIR)/$(GENE_REF_ID)

# uniref search result
UNIREF_RAW_OFN?=$(UNIREF_DIR)/raw_table
UNIREF_OFN_UNIQUE?=$(UNIREF_DIR)/table_uniq
UNIREF_GENE_TAX_TABLE?=$(UNIREF_DIR)/table_uniq_taxa

TOP_IDENTITY_RATIO=2
TOP_IDENTITY_DIFF=5
UNIREF_TOP?=$(UNIREF_DIR)/top_uniref_top

# gene general stats
UNIREF_POOR_ANNOTATION?="uncharacterized_protein hypothetical_protein MULTISPECIES:_hypothetical_protein Putative_uncharacterized_protein"
UNIREF_STATS?=$(UNIREF_DIR)/gene_stats

# final annotated table, with GO
UNIREF_GENE_DIR?=$(UNIREF_DIR)/GO
UNIREF_GENE_GO?=$(UNIREF_GENE_DIR)/table_GO

#####################################################################################################
# Gene Ontology
#####################################################################################################

# GO database is located alongside uniref100
GO_BASE_DIR?=$(UNIREF_DB_ROOT_DIR)/GO

# GO table from http://purl.obolibrary.org/obo/go/go-basic.obo
GO_OBO_ID?=2019-03-14
GO_BASIC_OBO?=$(GO_BASE_DIR)/go-basic.obo-$(GO_OBO_ID)

# UniProt to GO: ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/goa_uniprot_all.gaf.gz
GOA_UNIPROT_ID?=2019-03-14
GOA_UNIPROT_DIR?=$(GO_BASE_DIR)/goa_uniprot/$(GOA_UNIPROT_ID)
GOA_UNIPROT_TABLE?=$(GOA_UNIPROT_DIR)/goa_uniprot_all.gaf
UNIPROT2GO_LOOKUP?=$(GOA_UNIPROT_DIR)/goa_uniprot_all.gaf.parsed

# UniParc table: ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/uniparc/uniparc_all.xml.gz
UNIPARC_ID?=March_2019
UNIPARC_XML_IFN?=$(UNIREF_DB_ROOT_DIR)/Uniparc/$(UNIPARC_ID)/uniparc_all.xml

GO_ID?=2019_03
GO_DIR?=$(GO_BASE_DIR)/$(GO_ID)
GO_TREE?=$(GO_DIR)/go_tree

# uniparc to uniprot lookup
UNIPARC2UNIPROT_LOOKUP?=$(GO_DIR)/uniparc2uniprot_lookup

#####################################################################################################
# gene to bin
#####################################################################################################

# contig-bin table
GENES_C2B_TABLE?=$(C2B_TABLE)
GENE2BIN_TABLE?=$(PRODIGAL_DIR)/gene2bin

#####################################################################################################
# RNA uniref analysis
#####################################################################################################

# input fastq
# RNA_UNIREF_INPUT?=$(PAIRED_R1) $(PAIRED_R2) 
RNA_UNIREF_QUERY?=$(PAIRED_R1)

RNA_UNIREF_ODIR_BASE?=$(GENES_BASE_DIR)/rna_uniref/$(UNIREF_VER)
RNA_UNIREF_DIR?=$(RNA_UNIREF_ODIR_BASE)/$(GENE_REF_ID)

# united input file
# RNA_UNIREF_QUERY?=$(RNA_UNIREF_DIR)/reads.fq

# result
RNA_UNIREF_SAM?=$(RNA_UNIREF_DIR)/uniref.sam
RNA_UNIREF_UNIQUE?=$(RNA_UNIREF_DIR)/unique.sam

#####################################################################################################
# library table
#####################################################################################################

GENES_LIB_ID?=$(MAP_LIB_ID)
GENES_LIB_INPUT_R1?=$(MAP_R1)
GENES_LIB_INPUT_R2?=$(MAP_R2)
GENES_LIBS_TABLE?=$(MAP_LIBS_TABLE)

#####################################################################################################
# gene coverage summary
#####################################################################################################

# remove if read clipped at all
GENES_COVERAGE_REMOVE_CLIP?=T
GENES_COVERAGE_MIN_SCORE?=60
GENES_COVERAGE_MAX_EDIT_DISTANCE?=2
GENES_COVERAGE_MIN_MATCH_LENGTH?=100

# base dir for all libs
# GENES_COVERAGE_DIR?=$(GENES_BASE_DIR)/coverage
GENES_COVERAGE_VER=v1.00
GENES_COVERAGE_DIR?=$(GENES_ROOT_DIR)/coverage/$(GENES_COVERAGE_VER)/$(ASSEMBLY_ID)

# working dir for parallel runs
GENES_COVERAGE_INFO_DIR?=$(GENES_COVERAGE_DIR)/info

# library dir
GENES_COVERAGE_LIB_DIR?=$(GENES_COVERAGE_DIR)/libs/$(GENES_LIB_ID)

GENES_COVERAGE_LIB_TABLE?=$(GENES_COVERAGE_LIB_DIR)/gene.table
GENES_COVERAGE_LIB_STATS?=$(GENES_COVERAGE_LIB_DIR)/gene.stats

# gene counts trajectory over libs
GENES_COVERAGE_OUT_DIR?=$(GENES_COVERAGE_DIR)/out
GENES_COVERAGE_GENE_MATRIX?=$(GENES_COVERAGE_OUT_DIR)/gene.matrix

# multiple libs
GENES_COVERAGE_MULTI_DIR?=$(GENES_ROOT_DIR)/coverage_assembly_sets/$(GENES_MULTI_LABEL)

#####################################################################################################
# genes_collect.mk: collect tables across assemblies
#####################################################################################################

GENES_COLLECT_VER?=v3
GENES_COLLECT_ASSEMBLY_ID?=MERGE/$(GENES_COLLECT_VER)
GENES_COLLECT_DIR?=$(GENES_ROOT_DIR)/$(GENES_COLLECT_ASSEMBLY_ID)
UNIREF_COLLECT_DIR?=$(UNIREF_ROOT_DIR)/$(GENES_COLLECT_ASSEMBLY_ID)

# basic tables, without trajectory data 
GENES_COLLECT_VARS?=PRODIGAL_GENE_TABLE
UNIREF_COLLECT_VARS?=UNIREF_GENE_TAX_TABLE UNIREF_GENE_GO

$(call _sub_variables,$(GENES_COLLECT_VARS),_MERGE,$(ASSEMBLY_ID),$(GENES_COLLECT_ASSEMBLY_ID))
$(call _sub_variables,$(UNIREF_COLLECT_VARS),_MERGE,$(ASSEMBLY_ID),$(GENES_COLLECT_ASSEMBLY_ID))

#####################################################################################################
# export gene data
#####################################################################################################

GENES_EXPORT_DIR?=$(BASE_EXPORT_DIR)/genes_$(GENES_VER)

GENES_EXPORT_VARS?=\
GENE_FASTA_AA GENE_FASTA_NT \
GENE_TABLE \
GENES_COVERAGE_GENE_MATRIX
