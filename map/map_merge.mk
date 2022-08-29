#################################################################################
# library output
#################################################################################

# create single index file
MERGE_BAM_DONE?=$(MAP_OUT_DIR)/.done_merge_bams
$(MERGE_BAM_DONE):
	$(call _start,$(MAP_OUT_DIR))
	$(_R) R/map_merge.r merge.bam \
		ifn=$(MAP_CHUNK_TABLE) \
		threads=$(MAP_SAMTOOLS_MERGE_THREADS) \
		idir=$(MAP_CHUNKS_DIR) \
		ofn=$(MAP_BAM_FILE)
	$(_end_touch)
map_bam_merge: $(MERGE_BAM_DONE)

# create single index file
MERGE_BAM_SIDES_DONE?=$(MAP_OUT_DIR)/.done_merge_bams_sides
$(MERGE_BAM_SIDES_DONE):
	$(call _start,$(MAP_OUT_DIR))
	$(_R) R/map_merge.r merge.bam.sides \
		ifn=$(MAP_CHUNK_TABLE) \
		threads=$(MAP_SAMTOOLS_MERGE_THREADS) \
		idir=$(MAP_CHUNKS_DIR) \
		ofn1=$(MAP_BAM_R1) \
		ofn2=$(MAP_BAM_R2)
	$(_end_touch)
map_bam_merge_sides: $(MERGE_BAM_SIDES_DONE)

MERGE_CHUNKS_DONE?=$(MAP_OUT_DIR)/.done_merge_chunks
$(MERGE_CHUNKS_DONE):
	$(call _start,$(MAP_OUT_DIR))
	$(_R) R/map_merge.r merge.pairs \
		ifn=$(MAP_CHUNK_TABLE) \
		idir=$(MAP_CHUNKS_DIR) \
		ofn=$(MAP_PAIRED)
	$(_R) R/map_merge.r merge.sides \
		ifn=$(MAP_CHUNK_TABLE) \
		idir=$(MAP_CHUNKS_DIR) \
		ofn.filtered.1=$(MAP_R1) \
		ofn.filtered.2=$(MAP_R2) \
		ofn.nonpaired.1=$(MAP_NON_PAIRED_R1) \
		ofn.nonpaired.2=$(MAP_NON_PAIRED_R2)
	$(_end_touch)
map_pair_merge: $(MERGE_CHUNKS_DONE)

map_merge: $(MERGE_BAM_DONE) $(MERGE_BAM_SIDES_DONE) $(MERGE_CHUNKS_DONE)

#################################################################################
# assembly output
#################################################################################


# create single index file
MAP_UNION_DONE?=$(MAP_UNION_DIR)/.done_union
$(MAP_UNION_DONE):
	$(call _start,$(MAP_UNION_DIR))
	$(_R) R/map_merge.r union.bam.sides \
		ifn=$(MAP_LIBS_TABLE) \
		threads=$(MAP_SAMTOOLS_MERGE_THREADS) \
		template.fn1=$(call reval,MAP_BAM_R1,MAP_LIB_ID=DUMMY) \
		template.fn2=$(call reval,MAP_BAM_R2,MAP_LIB_ID=DUMMY) \
		ofn1=$(MAP_UNION_BAM_R1) \
		ofn2=$(MAP_UNION_BAM_R2)
	$(_end_touch)
map_union: $(MAP_UNION_DONE)
