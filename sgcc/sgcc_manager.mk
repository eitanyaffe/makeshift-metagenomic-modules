#####################################################################################################
# prepare table
#####################################################################################################

S_SGCC_TABLE_DONE?=$(SGCC_INFO_DIR)/.done_table
$(S_SGCC_TABLE_DONE):
	$(call _start,$(SGCC_TABLE_DIR))
	$(_R) R/sgcc.r make.table \
		ifn=$(SGCC_LIBS_INPUT_TABLE) \
		idir=$(INPUT_DIR) \
		ofn=$(SGCC_TABLE)
	$(_end_touch)
s_table: $(S_SGCC_TABLE_DONE)

#####################################################################################################
# compute signatures
#####################################################################################################

S_SGCC_SIGS_DONE?=$(SGCC_INFO_DIR)/.done_sig_all
$(S_SGCC_SIGS_DONE): $(S_SGCC_TABLE_DONE)
	$(_start)
	$(MAKE) m=par par_tasks_complex \
		PAR_MODULE=sgcc \
		PAR_WORK_DIR=$(SGCC_INFO_DIR) \
		PAR_NAME=sgcc_sig_task \
		PAR_TARGET=s_sig \
		PAR_TASK_ITEM_TABLE=$(SGCC_TABLE) \
		PAR_TASK_ITEM_VAR=SGCC_LIB_ID \
		PAR_TASK_ODIR_VAR=SGCC_LIB_INFO_DIR \
		PAR_NOTIFY_MAX_LEVEL=1 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_sigs: $(S_SGCC_SIGS_DONE)

#####################################################################################################
# compare signatures
#####################################################################################################

S_SGCC_COMPARE_DONE?=$(SGCC_INFO_DIR)/.done_compare_sig
$(S_SGCC_COMPARE_DONE): $(S_SGCC_SIGS_DONE)
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=sgcc \
		PAR_WORK_DIR=$(SGCC_INFO_DIR) \
		PAR_NAME=sgcc_cmp \
		PAR_TARGET=sgcc_compare \
		PAR_ODIR_VAR=SGCC_COMPARE_DIR \
		PAR_MACHINE=$(SGCC_CMP_MACHINE_TYPE) \
		PAR_DISK_TYPE=$(SGCC_CMP_DISK_TYPE) \
		PAR_DISK_GB=$(SGCC_CMP_DISK_GB) \
		PAR_PREEMTIBLE=0 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_sgcc: $(S_SGCC_COMPARE_DONE)
