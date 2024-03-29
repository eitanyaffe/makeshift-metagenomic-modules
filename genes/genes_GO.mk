####################################################################################
# init database, call through p_uniref_db
####################################################################################

GO_TREE_DONE?=$(GO_DIR)/.done_tree
$(GO_TREE_DONE):
	$(call _start,$(GO_DIR))
	perl $(_md)/pl/parse_go_obo.pl \
		$(GO_BASIC_OBO) \
		$(GO_TREE)
	$(_end_touch)
GO_tree: $(GO_TREE_DONE)

UNIPARC2UNIPROT_DONE?=$(GO_DIR)/.done_uniparc2uniprot
$(UNIPARC2UNIPROT_DONE):
	$(call _start,$(GO_DIR))
	$(call _time,$(GO_DIR),uniparc2uniprot_table) \
		perl $(_md)/pl/parse_uniparc_all.pl \
		$(UNIPARC_XML_IFN) \
		$(UNIPARC2UNIPROT_LOOKUP)
	$(_end_touch)
uniparc_lookup: $(UNIPARC2UNIPROT_DONE)

UNIPROT2GO_DONE?=$(GOA_UNIPROT_DIR)/.done_uniprot2go
$(UNIPROT2GO_DONE):
	$(call _start,$(GOA_UNIPROT_DIR))
	$(call _time,$(GOA_UNIPROT_DIR),uniprot_go_table) \
		perl $(_md)/pl/parse_goa_gaf.pl \
		$(GOA_UNIPROT_TABLE) \
		$(UNIPROT2GO_LOOKUP)
	$(_end_touch)
uniprot_go_table: $(UNIPROT2GO_DONE)

genes_GO_init: $(GO_TREE_DONE) $(UNIPARC2UNIPROT_DONE) $(UNIPROT2GO_DONE)

####################################################################################
# GO annotation
####################################################################################

UNIREF_GO_DONE?=$(UNIREF_GENE_DIR)/.done_GO
$(UNIREF_GO_DONE):
	$(call _start,$(UNIREF_GENE_DIR))
	perl $(_md)/pl/annotate_GO.pl \
		$(UNIREF_GENE_TAX_TABLE) \
		$(UNIREF_TAX_LOOKUP) \
		$(UNIPROT2GO_LOOKUP) \
		$(UNIPARC2UNIPROT_LOOKUP) \
		T \
		$(UNIREF_GENE_GO)
	$(_end_touch)
genes_GO: $(UNIREF_GO_DONE)
