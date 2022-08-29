####################################################################################
# prepare table
####################################################################################

S_MAP_INPUT_TABLE?=$(MAP_SET_DIR)/.done_input_table
$(S_MAP_INPUT_TABLE):
	$(call _start,$(MAP_SET_DIR))
	$(_R) R/map_table.r make.table \
		assembly.id=$(ASSEMBLY_ID) \
		ifn=$(MAP_LIBS_INPUT_TABLE) \
		prefix=$(MAP_INPUT_PREFIX) \
		ofn=$(MAP_LIBS_TABLE)
	$(_end_touch)
s_map_input_table: $(S_MAP_INPUT_TABLE)

####################################################################################
# process all libs
####################################################################################

S_MAP_SET_DONE?=$(MAP_SET_DIR)/.done_map_set
$(S_MAP_SET_DONE): $(S_MAP_INPUT_TABLE) $(S_MAP_INDEX_DONE)
	$(_start)
	$(MAKE) m=par par_tasks_complex \
		PAR_MODULE=map \
		PAR_NAME=map_task \
		PAR_WORK_DIR=$(MAP_SET_DIR) \
		PAR_TARGET=s_map \
		PAR_TASK_ITEM_TABLE=$(MAP_LIBS_TABLE) \
		PAR_TASK_ITEM_VAR=MAP_LIB_ID \
		PAR_TASK_ODIR_VAR=MAP_INFO_DIR \
		PAR_PREEMTIBLE=0 \
		PAR_NON_PREEMTIBLE_RETRIES=1 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_map_set: $(S_MAP_SET_DONE)

####################################################################################
# create union bam files per assembly
####################################################################################

S_MAP_UNION_DONE?=$(MAP_SET_DIR)/.done_union_bam
$(S_MAP_UNION_DONE): $(S_MAP_SET_DONE)
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=map \
		PAR_NAME=map_union \
		PAR_MACHINE=$(MAP_UNION_MACHINE_TYPE) \
		PAR_DISK_GB=$(MAP_UNION_DISK_GB) \
		PAR_WORK_DIR=$(MAP_SET_DIR) \
		PAR_ODIR_VAR=MAP_UNION_DIR \
		PAR_TARGET=map_union \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_map_union: $(S_MAP_UNION_DONE)

####################################################################################
# map libs of all assemblies
####################################################################################

S_MAP_ALL_DONE?=$(MAP_MULTI_DIR)/.done_map_all
$(S_MAP_ALL_DONE):
	$(call _start,$(MAP_MULTI_DIR))
	$(MAKE) m=par par_tasks_complex \
		PAR_MODULE=map \
		PAR_NAME=map_assembly \
		PAR_WORK_DIR=$(MAP_MULTI_DIR) \
		PAR_TARGET=s_map_union \
		PAR_TASK_ITEM_TABLE=$(MAP_ASSEMBLY_TABLE) \
		PAR_TASK_ITEM_VAR=ASSEMBLY_ID \
		PAR_TASK_ODIR_VAR=MAP_SET_DIR \
		PAR_PREEMTIBLE=0 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_map_all: $(S_MAP_ALL_DONE)
