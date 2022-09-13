
S_ASSEMBLY_TOP_DONE?=$(TOP_WORK_DIR)/.done_assembly_$(_module_version)
$(S_ASSEMBLY_TOP_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(TOP_WORK_DIR)/assembly \
		PAR_MODULE=assembly \
		PAR_NAME=top_assembly \
		PAR_ODIR_VAR=ASSEMBLY_INFO_DIR \
		PAR_TARGET=s_assembly \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_assembly: $(S_ASSEMBLY_TOP_DONE)

S_ASSEMBLIES_TOP_DONE?=$(TOP_WORK_DIR)/.done_assemblies_$(_module_version)
$(S_ASSEMBLIES_TOP_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(TOP_WORK_DIR)/assembly \
		PAR_MODULE=assembly \
		PAR_NAME=top_assemblies \
		PAR_ODIR_VAR=ASSEMBLY_MULTI_DIR \
		PAR_TARGET=s_assemblies \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_assembly_all: $(S_ASSEMBLIES_TOP_DONE)

