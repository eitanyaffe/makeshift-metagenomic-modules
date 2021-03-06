ASSEMBLY_INPUT_DONE?=$(ASSEMBLY_INPUT_DIR)/.done_input
$(ASSEMBLY_INPUT_DONE):
	$(call _start,$(ASSEMBLY_INPUT_DIR))

################################################################################
# source of fastq files
################################################################################
ifeq ($(ASSEMBLY_INPUT_SOURCE),libs_module)
	df -h
	$(foreach X,$(ASSEMBLY_LIB_IDS), \
		cp $(call reval,FINAL_R1,LIB_ID=$X) $(ASSEMBLY_INPUT_DIR)/$X_R1.fastq.gz; $(ASSERT);)
	$(foreach X,$(ASSEMBLY_LIB_IDS),\
		cp $(call reval,FINAL_R2,LIB_ID=$X) $(ASSEMBLY_INPUT_DIR)/$X_R2.fastq.gz; $(ASSERT);)
	df -h
	$(foreach X,$(ASSEMBLY_LIB_IDS), \
		pigz -d -c -p $(ASSEMBLY_PIGZ_THREADS) \
		$(ASSEMBLY_INPUT_DIR)/$X_R1.fastq.gz >> \
		$(ASSEMBLY_INPUT_BASE_FASTQ); $(ASSERT);)
	$(foreach X,$(ASSEMBLY_LIB_IDS), \
		pigz -d -c -p $(ASSEMBLY_PIGZ_THREADS) \
		$(ASSEMBLY_INPUT_DIR)/$X_R2.fastq.gz >> \
		$(ASSEMBLY_INPUT_BASE_FASTQ); $(ASSERT);)
	df -h
else ifeq ($(ASSEMBLY_INPUT_SOURCE),direct)
	$(foreach X,$(ASSEMBLY_LIB_IDS), \
		cat $(call reval,$(ASSEMBLY_USER_INPUT_VARIABLE_R1),$(ASSEMBLY_USER_LIB_VARIABLE)=$X) >> \
		$(ASSEMBLY_INPUT_BASE_FASTQ); $(ASSERT);)
	$(foreach X,$(ASSEMBLY_LIB_IDS), \
		cat $(call reval,$(ASSEMBLY_USER_INPUT_VARIABLE_R2),$(ASSEMBLY_USER_LIB_VARIABLE)=$X) >> \
		$(ASSEMBLY_INPUT_BASE_FASTQ); $(ASSERT);)
else
	echo "undefined ASSEMBLY_INPUT_SOURCE: $(ASSEMBLY_INPUT_SOURCE)"
endif
################################################################################

################################################################################
# fastq input style
################################################################################

ifeq ($(ASSEMBLY_INPUT_STYLE),none)
	mv $(ASSEMBLY_INPUT_BASE_FASTQ) $(ASSEMBLY_INPUT_FASTQ)
else ifeq ($(ASSEMBLY_INPUT_STYLE),khmer)
	normalize-by-median.py --force_single \
		-k $(ASSEMBLY_NORM_KSIZE) \
		-C $(ASSEMBLY_NORM_CUTOFF) \
		-M $(ASSEMBLY_NORM_MEMORY) \
		-R $(ASSEMBLY_NORM_REPORT) \
		-o $(ASSEMBLY_INPUT_FASTQ) \
		$(ASSEMBLY_INPUT_BASE_FASTQ)
else
	perl $(_md)/pl/subsample.pl \
		$(ASSEMBLY_INPUT_BASE_FASTQ) \
		$(ASSEMBLY_NORM_MAX_READS) \
		$(ASSEMBLY_RANDOM_SEED) \
		$(ASSEMBLY_INPUT_FASTQ)
endif
################################################################################

	rm -f $(ASSEMBLY_INPUT_DIR)/*gz $(ASSEMBLY_INPUT_BASE_FASTQ)
	$(_end_touch)
assembly_input: $(ASSEMBLY_INPUT_DONE)


