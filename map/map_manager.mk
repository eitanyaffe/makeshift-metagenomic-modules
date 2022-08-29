####################################################################################
# index is one per assembly
####################################################################################

S_MAP_INDEX_DONE?=$(MAP_SET_DIR)/.done_index
$(S_MAP_INDEX_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=map \
		PAR_NAME=map_index \
		PAR_MACHINE=$(MAP_INDEX_MACHINE_TYPE) \
		PAR_DISK_TYPE=pd-ssd \
		PAR_DISK_GB=$(MAP_INDEX_DISK_GB) \
		PAR_WORK_DIR=$(MAP_SET_DIR) \
		PAR_ODIR_VAR=MAP_INDEX_DIR \
		PAR_TARGET=map_index \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_map_index: $(S_MAP_INDEX_DONE)

####################################################################################
# multiple libs per assembly
####################################################################################

S_MAP_INPUT_DONE?=$(MAP_INFO_DIR)/.done_input
$(S_MAP_INPUT_DONE):
	$(call _start,$(MAP_INFO_DIR))
	$(MAKE) m=par par \
		PAR_MODULE=map \
		PAR_NAME=map_input \
		PAR_MACHINE=$(MAP_INPUT_MACHINE_TYPE) \
		PAR_DISK_GB=$(MAP_INPUT_DISK_GB) \
		PAR_WORK_DIR=$(MAP_INFO_DIR) \
		PAR_ODIR_VAR=MAP_SPLIT_DIR \
		PAR_TARGET=map_split \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_map_input: $(S_MAP_INPUT_DONE)

S_MAP_CHUNKS_DONE?=$(MAP_INFO_DIR)/.done_chunks
$(S_MAP_CHUNKS_DONE): $(S_MAP_INPUT_DONE)
	$(_start)
	$(MAKE) m=par par_tasks_table \
		PAR_MODULE=map \
		PAR_NAME=map_chunk \
		PAR_TARGET=map_chunk \
		PAR_MACHINE=$(MAP_CHUNK_MACHINE_TYPE) \
		PAR_DISK_TYPE=pd-ssd \
		PAR_DISK_GB=$(MAP_CHUNK_DISK_GB) \
		PAR_WORK_DIR=$(MAP_INFO_DIR) \
		PAR_TASK_ODIR_VAR=MAP_CHUNK_DIR \
		PAR_TASK_ITEM_VAR=MAP_CHUNK_ID \
		PAR_TASK_ITEM_TABLE=$(MAP_CHUNK_TABLE) \
		PAR_TASK_ITEM_FIELD=chunk \
		PAR_EMAIL=F \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_map_chunks: $(S_MAP_CHUNKS_DONE)

####################################################################################
# merge chunks
####################################################################################

S_MAP_MERGE_DONE?=$(MAP_INFO_DIR)/.done_merge
$(S_MAP_MERGE_DONE): $(S_MAP_CHUNKS_DONE)
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=map \
		PAR_NAME=map_merge \
		PAR_MACHINE=$(MAP_MERGE_MACHINE_TYPE) \
		PAR_DISK_GB=$(MAP_MERGE_DISK_GB) \
		PAR_WORK_DIR=$(MAP_INFO_DIR) \
		PAR_ODIR_VAR=MAP_OUT_DIR \
		PAR_TARGET=map_merge \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_map_merge: $(S_MAP_MERGE_DONE)

####################################################################################
# cleanup
####################################################################################

S_MAP_CLEAN_DONE?=$(MAP_INFO_DIR)/.done_clean
$(S_MAP_CLEAN_DONE): $(S_MAP_MERGE_DONE)
	$(_start)
ifeq ($(MAP_PURGE_TEMP),T)
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(MAP_INPUT_DIR) \
		PAR_REMOVE_NAME_PATTERN="*fastq"
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(MAP_SPLIT_DIR) \
		PAR_REMOVE_NAME_PATTERN="*fastq"
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(MAP_CHUNKS_DIR) \
		PAR_REMOVE_NAME_PATTERN="*bam"
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(MAP_CHUNKS_DIR) \
		PAR_REMOVE_NAME_PATTERN="*sam"
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(MAP_CHUNKS_DIR) \
		PAR_REMOVE_NAME_PATTERN="*tab"
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(MAP_CHUNKS_DIR) \
		PAR_REMOVE_NAME_PATTERN="*filtered"
endif
	$(_end_touch)
s_map_clean: $(S_MAP_CLEAN_DONE)

s_map: $(S_MAP_CLEAN_DONE)

