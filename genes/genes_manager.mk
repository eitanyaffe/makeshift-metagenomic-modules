s_genes:
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(GENES_INFO_DIR) \
		PAR_MODULE=genes \
		PAR_NAME=genes_single \
		PAR_ODIR_VAR=PRODIGAL_DIR \
		PAR_TARGET=prodigal \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"

# predict genes
GENES_MULTI_DONE?=$(GENES_MULTI_DIR)/.done_genes
$(GENES_MULTI_DONE):
	$(_start)
	$(MAKE) m=par par_tasks_complex \
		PAR_MODULE=genes \
		PAR_NAME=genes_task \
		PAR_WORK_DIR=$(GENES_MULTI_DIR) \
		PAR_TARGET=prodigal \
		PAR_TASK_ITEM_TABLE=$(GENES_ASSEMBLY_TABLE) \
		PAR_TASK_ITEM_VAR=ASSEMBLY_ID \
		PAR_TASK_ODIR_VAR=PRODIGAL_DIR \
		PAR_PREEMTIBLE=3 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_genes_multi: $(GENES_MULTI_DONE)

################################################################################################

s_uniref:
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(UNIREF_INFO_DIR) \
		PAR_MODULE=genes \
		PAR_NAME=uniref \
		PAR_ODIR_VAR=UNIREF_DIR \
		PAR_TARGET=genes_uniref \
		PAR_DISK_GB=$(UNIREF_DISK_GB) \
		PAR_MACHINE=$(UNIREF_MACHINE_TYPE) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"

# both steps
# s_uniref_GO: genes_uniref genes_GO

UNIREF_MULTI_DONE?=$(UNIREF_MULTI_DIR)/.done_uniref
$(UNIREF_MULTI_DONE):
	$(_start)
	$(MAKE) m=par par_tasks_complex \
		PAR_MODULE=genes \
		PAR_NAME=uniref \
		PAR_WORK_DIR=$(UNIREF_MULTI_DIR) \
		PAR_TARGET=genes_uniref \
		PAR_TASK_ITEM_TABLE=$(GENES_ASSEMBLY_TABLE) \
		PAR_TASK_ITEM_VAR=ASSEMBLY_ID \
		PAR_TASK_ODIR_VAR=UNIREF_DIR \
		PAR_DISK_GB=$(UNIREF_DISK_GB) \
		PAR_MACHINE=$(UNIREF_MACHINE_TYPE) \
		PAR_PREEMTIBLE=3 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_uniref_multi: $(UNIREF_MULTI_DONE)

################################################################################################

UNIREF_GO_MULTI_DONE?=$(UNIREF_MULTI_DIR)/.done_uniref_GO
$(UNIREF_GO_MULTI_DONE):
	$(_start)
	$(MAKE) m=par par_tasks_complex \
		PAR_MODULE=genes \
		PAR_NAME=go \
		PAR_WORK_DIR=$(UNIREF_MULTI_DIR) \
		PAR_TARGET=genes_GO \
		PAR_TASK_ITEM_TABLE=$(GENES_ASSEMBLY_TABLE) \
		PAR_TASK_ITEM_VAR=ASSEMBLY_ID \
		PAR_TASK_ODIR_VAR=UNIREF_DIR \
		PAR_DISK_GB=$(UNIREF_DISK_GB) \
		PAR_MACHINE=$(UNIREF_MACHINE_TYPE) \
		PAR_PREEMTIBLE=3 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_uniref_GO_multi: $(UNIREF_GO_MULTI_DONE)
