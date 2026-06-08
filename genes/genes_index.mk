#####################################################################################################
# index output files for the genes module
#####################################################################################################

_genes_index_tmpl_assembly=$(foreach x,$1,$x=$(call reval3,$x,ASSEMBLY_ID=ASSEMBLY_ID))

GENES_INDEX_DESCRIPTIONS?=$(_md)/docs/$(mname)_variables.json

GENES_INDEX_ASSEMBLY_DONE?=$(GENES_INDEX_DIR)/.done_assembly
$(GENES_INDEX_ASSEMBLY_DONE):
	$(call _start,$(GENES_INDEX_DIR))
	@rm -f $(GENES_INDEX_DIR)/assembly*.txt
	$(MAKE) m=index index_set \
		INDEX_TAG=assembly \
		INDEX_TABLE=$(GENES_INDEX_DIR)/assembly.txt \
		INDEX_DESCRIPTIONS=$(GENES_INDEX_DESCRIPTIONS) \
		INDEX_TABLE_INPUT=$(GENES_ASSEMBLY_TABLE) \
		INDEX_DYN_VARIABLES=ASSEMBLY_ID \
		INDEX_VARIABLES="$(GENES_INDEX_ASSEMBLY_VARS)" \
		$(call _genes_index_tmpl_assembly,$(GENES_INDEX_ASSEMBLY_VARS))
	$(_end_touch)
genes_index_assembly: $(GENES_INDEX_ASSEMBLY_DONE)

GENES_INDEX_GLOBAL_DONE?=$(GENES_INDEX_DIR)/.done_global
$(GENES_INDEX_GLOBAL_DONE):
	$(call _start,$(GENES_INDEX_DIR))
	@rm -f $(GENES_INDEX_DIR)/global*.txt
	$(MAKE) m=index index_files \
		INDEX_TAG=global \
		INDEX_TABLE=$(GENES_INDEX_DIR)/global.txt \
		INDEX_DESCRIPTIONS=$(GENES_INDEX_DESCRIPTIONS) \
		INDEX_VARIABLES="$(GENES_INDEX_GLOBAL_VARS)"
	$(_end_touch)
genes_index_global: $(GENES_INDEX_GLOBAL_DONE)

genes_index: genes_index_assembly genes_index_global
