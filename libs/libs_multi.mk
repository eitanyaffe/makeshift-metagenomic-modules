LIBS_MULTI_TABLE_DONE?=$(LIBS_MULTI_DIR)/.done_table
$(LIBS_MULTI_TABLE_DONE):
	$(call _start,$(LIBS_MULTI_DIR))
	$(_R) R/libs_table.r make.table \
		ifn=$(LIBS_INPUT_TABLE) \
		idir=$(INPUT_DIR) \
		ofn=$(LIBS_TABLE)
	$(_end_touch)
s_libs_table: $(LIBS_MULTI_TABLE_DONE)

LIBS_MULTI_DONE?=$(LIBS_MULTI_DIR)/.done_run
$(LIBS_MULTI_DONE): $(LIBS_MULTI_TABLE_DONE)
	$(_start)
	$(MAKE) m=par par_tasks_complex \
		PAR_MODULE=libs \
		PAR_NAME=lib_task \
		PAR_WORK_DIR=$(LIBS_MULTI_DIR) \
		PAR_TARGET=s_lib \
		PAR_TASK_DIR=$(LIBS_MULTI_DIR) \
		PAR_TASK_ITEM_TABLE=$(LIBS_TABLE) \
		PAR_TASK_ITEM_VAR=LIB_ID \
		PAR_TASK_ODIR_VAR=LIB_INFO_DIR \
		PAR_DISK_TYPE=pd-standard \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_libs: $(LIBS_MULTI_DONE)

####################################################################################

# collect stats and select libs
libs_post: libs_stats libs_dup_stats libs_select

# collect stats after libs done
S_LIBS_POST_DONE?=$(LIBS_MULTI_DIR)/.done_libs_post
$(S_LIBS_POST_DONE): $(LIBS_MULTI_DONE)
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(LIBS_MULTI_DIR) \
		PAR_MODULE=libs \
		PAR_NAME=libs_post \
		PAR_ODIR_VAR=LIBS_POST_DIR \
		PAR_TARGET=libs_post \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_libs_post: $(S_LIBS_POST_DONE)
