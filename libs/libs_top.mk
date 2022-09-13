
# single lib
S_LIB_TOP_DONE?=$(TOP_WORK_DIR)/.done_lib_$(_module_version)
$(S_LIB_TOP_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(TOP_WORK_DIR)/libs \
		PAR_MODULE=libs \
		PAR_NAME=lib_top \
		PAR_ODIR_VAR=LIB_INFO_DIR \
		PAR_TARGET=s_lib \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_lib: $(S_LIB_TOP_DONE)

# all libs
S_LIBS_TOP_DONE?=$(TOP_WORK_DIR)/.done_libs_$(_module_version)
$(S_LIBS_TOP_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(TOP_WORK_DIR)/libs \
		PAR_MODULE=libs \
		PAR_NAME=libs_top \
		PAR_ODIR_VAR=LIBS_MULTI_DIR \
		PAR_TARGET=s_libs_post \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_libs: $(S_LIBS_TOP_DONE)
