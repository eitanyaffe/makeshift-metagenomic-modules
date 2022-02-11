#####################################################################################################
# register module
#####################################################################################################

units:=input_sra.mk
$(call _register_module,input,$(units),)

INPUT_VER?=v1.00

#####################################################################################################
# work dirs
#####################################################################################################

INPUT_DOWNLOAD_DIR?=$(OUTPUT_DIR)/input/$(INPUT_VER)

INPUT_BUCKET?=specify_input_bucket
INPUT_TABLE_FILENAME?=library_table.txt

#####################################################################################################
# download sra 
#####################################################################################################

# input table with samples and their accessions
# fields: assembly, lib, SRA
INPUT_SRA_TABLE?=specify_sra_input_table

# limit spots
# !!!
INPUT_SRA_MAX_SPOT_ID?=10000

INPUT_SRA_WORK_DIR?=$(INPUT_DOWNLOAD_DIR)/sra
