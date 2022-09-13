#####################################################################################################
# register module
#####################################################################################################

units:=input_sra.mk
INPUT_VER?=v1.01
$(call _register_module,input,INPUT_VER,$(units))

#####################################################################################################
# work dirs
#####################################################################################################

INPUT_DOWNLOAD_DIR?=$(OUTPUT_DIR)/input/$(INPUT_VER)

INPUT_INFO_DIR?=$(INPUT_DOWNLOAD_DIR)/info

INPUT_BUCKET?=specify_input_bucket
INPUT_TABLE_FILENAME?=library_table.txt

#####################################################################################################
# download sra 
#####################################################################################################

# input table with samples and their accessions
# fields: assembly, lib, accession
INPUT_SRA_TABLE?=specify_sra_input_table

INPUT_LIB?=$(lib)
INPUT_ACCESSION?=$(accession)

#INPUT_LIB?=$(LIB_ID)
#INPUT_ACCESSION?=$(ACCESSION)

# limit spots
#INPUT_SRA_MAX_SPOT_ID?=10000
INPUT_SRA_MAX_SPOT_ID?=0

INPUT_SRA_WORK_DIR?=$(INPUT_DOWNLOAD_DIR)/libs/$(INPUT_LIB)
