plot_stats:
	$(_R) $(_md)/R/plot_stats.r plot.stats \
		ifn.reads.count=$(STATS_READS_COUNTS) \
		ifn.reads.yield=$(STATS_READS_YIELD) \
		ifn.bps.count=$(STATS_BPS_COUNTS) \
		ifn.bps.yield=$(STATS_BPS_YIELD) \
		min.read.count.m=$(LIBS_SELECT_MIN_READ_COUNT) \
		min.trimmo.bp.yield=$(LIBS_SELECT_MIN_TRIMMO_BP_YIELD) \
		min.dup.read.yield=$(LIBS_SELECT_MIN_DUPLICATE_READ_YIELD) \
		min.deconseq.read.yield=$(LIBS_SELECT_MIN_HUMAN_READ_YIELD) \
		fdir=$(LIBS_FDIR)/stats

plot_stats_by_assembly:
	$(_R) $(_md)/R/plot_assemblies.r plot.by.assembly \
		ifn.assembly=$(LIBS_INPUT_TABLE) \
		lib.field=$(LIBS_INPUT_TABLE_LIB_FIELD) \
		assembly.field=$(LIBS_INPUT_TABLE_ASSEMBLY_FIELD) \
		ifn.selected=$(LIBS_SELECT_TABLE) \
		ifn.reads.count=$(STATS_READS_COUNTS) \
		ifn.reads.yield=$(STATS_READS_YIELD) \
		ifn.bps.count=$(STATS_BPS_COUNTS) \
		ifn.bps.yield=$(STATS_BPS_YIELD) \
		fdir=$(LIBS_FDIR)/assemblies

libs_plot: plot_stats plot_stats_by_assembly
