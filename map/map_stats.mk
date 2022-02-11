STATS_DONE?=$(MAP_MULTI_STATS_DIR)/.done
$(STATS_DONE):
	$(call _start,$(MAP_MULTI_STATS_DIR))
	$(_R) $(_md)/R/map_stats.r collect.stats \
		ifn=$(MAP_ASSEMBLY_TABLE) \
		idir=$(MAP_ROOT_DIR) \
		ofn.bwa=$(MAP_STATS_BWA) \
		ofn.filter=$(MAP_STATS_FILTER) \
		ofn.paired=$(MAP_STATS_PAIRED)
	$(_end_touch)
map_stats: $(STATS_DONE)

d_map_stats:
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(MAP_MULTI_DIR) \
		PAR_MODULE=map \
		PAR_NAME=map_stats \
		PAR_ODIR_VAR=MAP_MULTI_STATS_DIR \
		PAR_TARGET=map_stats \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"

plot_stats:
	$(_R) $(_md)/R/map_stats.r plot.stats \
		ifn.bwa=$(MAP_STATS_BWA) \
		ifn.filter=$(MAP_STATS_FILTER) \
		ifn.paired=$(MAP_STATS_PAIRED) \
		fdir=$(MAP_FDIR)
