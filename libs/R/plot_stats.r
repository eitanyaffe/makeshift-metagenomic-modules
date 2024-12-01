
plot.stats=function(ifn.reads.count, ifn.reads.yield, ifn.bps.count, ifn.bps.yield,
                    min.read.count.m, min.trimmo.bp.yield, min.dup.read.yield, min.deconseq.read.yield,
                    fdir)
{
    read.count = load.table(ifn.reads.count)
    bp.count = load.table(ifn.bps.count)
    read.yield = load.table(ifn.reads.yield)
    bp.yield = load.table(ifn.bps.yield)
    
    system(paste("mkdir -p", fdir))

    read.count$final.m = read.count$final/10^6
    bp.count$final.g = bp.count$final/10^9
    
    plot.f=function(df, field, type, cutoff, xlab="yield (%)") {
        fig.start(fdir=fdir, type="pdf", width=4, height=4,
                  ofn=paste(fdir, "/", field, "_", type, "_ecdf.pdf", sep=""))
        main = paste(field, type, "yield")
        main = if (!is.na(cutoff)) sprintf("%s\ncutoff=%.0f", main, cutoff) else main
        plot(ecdf(df[,field]), main=main, ylab="fraction", xlab=xlab)
        if (!is.na(cutoff)) abline(v=cutoff, col="gray", lty=3)
        fig.end()
    }
    
    plot.f(df=read.count, field="final.m", type="reads", cutoff=min.read.count.m, xlab="reads (M)")
    plot.f(df=bp.count, field="final.g", type="bp", cutoff=NA, xlab="bps (G)")
    
    plot.f(df=read.yield, field="duplicate", type="reads", cutoff=min.dup.read.yield)
    plot.f(df=read.yield, field="deconseq", type="reads", cutoff=min.deconseq.read.yield)

    plot.f(df=bp.yield, field="trimmomatic", type="bp", cutoff=min.trimmo.bp.yield)
}
