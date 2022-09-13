S_MAP_TOP_DONE?=$(TOP_WORK_DIR)/.done_map_$(_module_version)
$(S_MAP_TOP_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(TOP_WORK_DIR)/map \
		PAR_MODULE=map \
		PAR_NAME=map_set \
		PAR_ODIR_VAR=MAP_SET_DIR \
		PAR_TARGET=s_map_set \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_map: $(S_MAP_TOP_DONE)

S_MAP_ALL_TOP_DONE?=$(TOP_WORK_DIR)/.done_map_all_$(_module_version)
$(S_MAP_ALL_TOP_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(TOP_WORK_DIR)/map \
		PAR_MODULE=map \
		PAR_NAME=map_all \
		PAR_ODIR_VAR=MAP_MULTI_DIR \
		PAR_TARGET=s_map_all \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_map_all: $(S_MAP_ALL_TOP_DONE)

