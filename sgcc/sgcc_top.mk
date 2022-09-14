
S_SGCC_TOP_DONE?=$(TOP_WORK_DIR)/.done_sgcc_$(_module_version)
$(S_SGCC_TOP_DONE):
	$(call _start,$(TOP_WORK_DIR))
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(TOP_WORK_DIR)/sgcc \
		PAR_MODULE=sgcc \
		PAR_NAME=sgcc \
		PAR_ODIR_VAR=SGCC_INFO_DIR \
		PAR_TARGET=s_sgcc \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_NOTIFY_MAX_LEVEL=1 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_sgcc: $(S_SGCC_TOP_DONE)
