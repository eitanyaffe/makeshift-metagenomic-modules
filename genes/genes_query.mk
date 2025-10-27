GENES_QUERY_DONE?=$(GENES_QUERY_DIR)/.done_query
$(GENES_QUERY_DONE):
	$(call _start,$(GENES_QUERY_DIR))
	$(_R) R/genes_query.r genes.query \
		uniref.ifn=$(UNIREF_GENE_TAX_TABLE_MERGE) \
		gene.ifn=$(PRODIGAL_GENE_TABLE_MERGE) \
		pattern=$(GENES_QUERY_PATTERN) \
		field=$(GENES_QUERY_FIELD) \
		window=$(GENES_QUERY_WINDOW) \
		odir=$(GENES_QUERY_DIR)
#	$(_end_touch)
genes_query: $(GENES_QUERY_DONE)
