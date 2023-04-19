# database for hg38 created following instructions on https://deconseq.sourceforge.net/manual.html#DB
# 1. assembly used: https://ftp.ncbi.nih.gov/genomes/refseq/vertebrate_mammalian/Homo_sapiens/all_assembly_versions/GCF_000001405.26_GRCh38/GCF_000001405.26_GRCh38_genomic.fna.gz
# 2. cat GCF_000001405.26_GRCh38_genomic.fna | perl -p -e 's/N\n/N/' | perl -p -e 's/^N+//;s/N+$//;s/N{200,}/\n>split\n/' > hs_ref_GRCh38.fa

DECONSEQ_DONE?=$(DECONSEQ_DIR)/.done
$(DECONSEQ_DONE):
	$(call _start,$(DECONSEQ_DIR))
	cp $(DECONSEQ_BIN_DIR)/bwa64 /tmp
	chmod +x /tmp/bwa64
	export DECONSEQ_BIN_DIR=$(DECONSEQ_BIN_DIR); $(call _time,$(DECONSEQ_DIR),deconseq_R1) \
		perl $(DECONSEQ_SCRIPT) \
		-threads $(DECONSEQ_THREADS) \
		-c $(DECONSEQ_COVERAGE) \
		-i $(DECONSEQ_IDENTITY) \
		-f $(DECONSEQ_IFN_R1) \
		-id R1 \
		-dbs hsref \
		-out_dir $(DECONSEQ_DIR)
	export DECONSEQ_BIN_DIR=$(DECONSEQ_BIN_DIR); $(call _time,$(DECONSEQ_DIR),deconseq_R2) \
		perl $(DECONSEQ_SCRIPT) \
		-threads $(DECONSEQ_THREADS) \
		-c $(DECONSEQ_COVERAGE) \
		-i $(DECONSEQ_IDENTITY) \
		-f $(DECONSEQ_IFN_R2) \
		-id R2 \
		-dbs hsref \
		-out_dir $(DECONSEQ_DIR)
	$(_end_touch)
deconseq_base: $(DECONSEQ_DONE)

$(PP_COUNT_DECONSEQ_CHUCK): $(DECONSEQ_DONE)
	$(_start)
	perl $(_md)/pl/count_fastq.pl $(DECONSEQ_DIR) '*' '*clean.fq' deconseq $@
	$(_end)
deconseq: $(PP_COUNT_DECONSEQ_CHUCK)
