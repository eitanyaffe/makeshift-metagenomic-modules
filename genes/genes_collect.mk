GENES_COLLECT_DONE?=$(GENES_COLLECT_DIR)/.done_collect_genes
$(GENES_COLLECT_DONE):
	$(call _start,$(GENES_COLLECT_DIR))
	$(_R) R/genes_collect.r genes.collect \
		ifn=$(GENES_ASSEMBLY_TABLE) \
	 	template.fns=$(foreach X,$(GENES_COLLECT_VARS),$(call reval,$X,ASSEMBLY_ID=DUMMY)) \
		idir=$(GENES_ROOT_DIR)/$(GENES_COLLECT_ASSEMBLY_ID) \
		odir=$(GENES_COLLECT_DIR) \
		collect.id=$(GENES_COLLECT_ASSEMBLY_ID)
	$(_end_touch)
genes_collect: $(GENES_COLLECT_DONE)

UNIREF_COLLECT_DONE?=$(UNIREF_COLLECT_DIR)/.done_collect_uniref
$(UNIREF_COLLECT_DONE):
	$(_start)
	$(_R) R/genes_collect.r genes.collect \
		ifn=$(GENES_ASSEMBLY_TABLE) \
	 	template.fns=$(foreach X,$(UNIREF_COLLECT_VARS),$(call reval,$X,ASSEMBLY_ID=DUMMY)) \
		idir=$(UNIREF_ROOT_DIR)/$(GENES_COLLECT_ASSEMBLY_ID) \
		odir=$(UNIREF_COLLECT_DIR) \
		collect.id=$(GENES_COLLECT_ASSEMBLY_ID)
	$(_end_touch)
uniref_collect: $(UNIREF_COLLECT_DONE)

####################################################################################
####################################################################################

S_GENES_COLLECT_DONE?=$(GENES_MULTI_DIR)/.done_collect_genes_$(GENES_COLLECT_VER)
$(S_GENES_COLLECT_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=genes \
		PAR_NAME=genes_collect \
		PAR_WORK_DIR=$(GENES_MULTI_DIR) \
		PAR_ODIR_VAR=GENES_COLLECT_DIR \
		PAR_TARGET=genes_collect \
		PAR_DISK_GB=128 \
		PAR_MACHINE=e2-highmem-8 \
		PAR_PREEMTIBLE=0 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_genes_collect: $(S_GENES_COLLECT_DONE)

S_UNIREF_COLLECT_DONE?=$(GENES_MULTI_DIR)/.done_collect_uniref_$(GENES_COLLECT_VER)
$(S_UNIREF_COLLECT_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=genes \
		PAR_NAME=uniref_collect \
		PAR_WORK_DIR=$(GENES_MULTI_DIR) \
		PAR_ODIR_VAR=UNIREF_COLLECT_DIR \
		PAR_TARGET=uniref_collect \
		PAR_DISK_GB=128 \
		PAR_MACHINE=e2-highmem-8 \
		PAR_PREEMTIBLE=0 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_uniref_collect: $(S_UNIREF_COLLECT_DONE)
