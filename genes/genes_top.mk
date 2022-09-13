
S_GENES_TOP_DONE?=$(TOP_WORK_DIR)/.done_genes_$(ASSEMBLY_ID)_$(_module_version)
$(S_GENES_TOP_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(TOP_WORK_DIR)/genes \
		PAR_MODULE=genes \
		PAR_NAME=top_genes_single \
		PAR_ODIR_VAR=GENES_INFO_DIR \
		PAR_TARGET=s_genes \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_genes: $(S_GENES_TOP_DONE)

S_GENES_ALL_TOP_DONE?=$(TOP_WORK_DIR)/.done_genes_all_$(_module_version)
$(S_GENES_ALL_TOP_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(TOP_WORK_DIR)/genes \
		PAR_MODULE=genes \
		PAR_NAME=top_genes \
		PAR_ODIR_VAR=GENES_MULTI_DIR \
		PAR_TARGET=s_genes_multi \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_genes_all: $(S_GENES_ALL_TOP_DONE)

#####################################################################################################

S_GENES_COV_TOP_DONE?=$(TOP_WORK_DIR)/.done_genes_cov_$(ASSEMBLY_ID)_$(_module_version)
$(S_GENES_COV_TOP_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(TOP_WORK_DIR)/genes_cov \
		PAR_MODULE=genes \
		PAR_NAME=top_genes_cov \
		PAR_ODIR_VAR=GENES_COVERAGE_INFO_DIR \
		PAR_TARGET=s_genes_cov_mat \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_genes_cov: $(S_GENES_COV_TOP_DONE)

S_GENES_COV_ALL_TOP_DONE?=$(TOP_WORK_DIR)/.done_genes_cov_all_$(_module_version)
$(S_GENES_COV_ALL_TOP_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(TOP_WORK_DIR)/genes_cov \
		PAR_MODULE=genes \
		PAR_NAME=top_genes_cov \
		PAR_ODIR_VAR=GENES_COVERAGE_MULTI_DIR \
		PAR_TARGET=s_genes_cov_multi \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_genes_cov_all: $(S_GENES_COV_ALL_TOP_DONE)

#####################################################################################################

S_UNIREF_TOP_DONE?=$(TOP_WORK_DIR)/.done_uniref_$(ASSEMBLY_ID)_$(_module_version)
$(S_UNIREF_TOP_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(UNIREF_INFO_DIR) \
		PAR_MODULE=genes \
		PAR_NAME=top_uniref_single \
		PAR_ODIR_VAR=UNIREF_INFO_DIR \
		PAR_TARGET=s_uniref \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_uniref: $(S_UNIREF_TOP_DONE)

S_UNIREF_ALL_TOP_DONE?=$(TOP_WORK_DIR)/.done_uniref_all_$(_module_version)
$(S_UNIREF_ALL_TOP_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(TOP_WORK_DIR)/uniref \
		PAR_MODULE=genes \
		PAR_NAME=top_uniref_all \
		PAR_ODIR_VAR=UNIREF_MULTI_DIR \
		PAR_TARGET=s_uniref_multi \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_uniref_all: $(S_UNIREF_ALL_TOP_DONE)

#####################################################################################################

S_GO_ALL_TOP_DONE?=$(TOP_WORK_DIR)/.done_GO_all_$(_module_version)
$(S_GO_ALL_TOP_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(TOP_WORK_DIR)/GO \
		PAR_MODULE=genes \
		PAR_NAME=top_go_all \
		PAR_ODIR_VAR=UNIREF_MULTI_DIR \
		PAR_TARGET=s_uniref_GO_multi \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_GO_all: $(S_GO_ALL_TOP_DONE)

#####################################################################################################

# collect gene tables across assemblies
genes_collect_all:
	$(MAKE) m=genes s_genes_collect s_uniref_collect

S_GENES_COLLECT_TOP_DONE?=$(TOP_WORK_DIR)/.done_genes_collect_$(_module_version)
$(S_GENES_COLLECT_TOP_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(TOP_WORK_DIR)/genes_collect \
		PAR_MODULE=genes \
		PAR_NAME=genes_collect \
		PAR_ODIR_VAR=GENES_MULTI_DIR \
		PAR_TARGET=genes_collect_all \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
top_genes_collect: $(S_GENES_COLLECT_TOP_DONE)
