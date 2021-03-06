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
