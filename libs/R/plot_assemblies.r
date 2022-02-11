plot.by.assembly=function(ifn.assembly, lib.field, assembly.field,
                          ifn.selected,
                          ifn.reads.count, ifn.reads.yield, ifn.bps.count, ifn.bps.yield, fdir)
{
    df = load.table(ifn.assembly)
    df$aid = df[,assembly.field]
    df$lid = df[,lib.field]
    df = df[,c("aid", "lid")]
    
    df.selected = load.table(ifn.selected)
    
    read.count = load.table(ifn.reads.count)
    bp.count = load.table(ifn.bps.count)
    read.yield = load.table(ifn.reads.yield)
    bp.yield = load.table(ifn.bps.yield)

    ## explode.f=function(df) {
    ##     rr = NULL
    ##     for (i in 1:dim(df)[1]) {
    ##         ids = strsplit(df$LIB_IDS[i], split=",")[[1]]
    ##         N = length(ids)
    ##         rr = rbind(rr, data.frame(assembly.id=rep(df$ASSEMBLY_ID[i], N), id=ids))
    ##         }
    ##     rr
    ## }
    ## df.libs = explode.f(df.assembly)

    # try to sort by lib index if possible
    df$index = as.numeric(sapply(strsplit(df$lid, "_"), function(x) { x[2] }))
    if (!any(is.na(df$index)))
        df = df[order(df$aid, df$index),]
    
    get.f=function(dfx, field) {
        ix = match(df$lid, dfx$id) 
        ifelse(!is.na(ix), dfx[ix,field], 0)
    }
    df$read.count.m = get.f(dfx=read.count, field="final") / 10^6
    df$trimmo.yield = get.f(dfx=bp.yield, field="trimmomatic")
    df$dup.yield = get.f(dfx=read.yield, field="duplicate")
    df$human.yield = get.f(dfx=read.yield, field="deconseq")

    df$resequence = !is.element(df$lid, df.selected$id)

    df$col = ifelse(df$resequence, "red", "gray")
    df$border = ifelse(df$resequence, "red", NA)
        
    aids = sort(unique(df$aid))
    NN = length(aids)
    Nx = ceiling(sqrt(NN))
    Ny = ceiling(NN / Nx)
    plot.f=function(field, title, lid.labels) {
        size = if(lid.labels) 12 else 7
        fig.start(fdir=fdir, type="pdf", width=size, height=size,
                  ofn=paste(fdir, "/", if(lid.labels) "detailed_", title, ".pdf", sep=""))
        if (lid.labels)
            par(mai=c(0.25,0.25,0.25,0.1))
        else
            par(mai=c(0.1,0.3,0.25,0.1))
        layout(matrix(1:(Nx*Ny), Nx, Ny, byrow=T))
        for (aid in aids) {
            dfa = df[df$aid == aid,]
            mm = barplot(dfa[,field], col=dfa$col, border=dfa$border, main=aid, lwd=2, las=2)
            if (lid.labels) mtext(dfa$lid, side=1, line=0, cex=0.3, at=mm, las=2)
            
        }
        fig.end()
    }
    for (lid.labels in c(T,F)) {
        plot.f(field="read.count.m", title="reads_millions", lid.labels=lid.labels)
        plot.f(field="trimmo.yield", title="trimmo_yield_percent", lid.labels=lid.labels)
        plot.f(field="dup.yield", title="dup_yield_percent", lid.labels=lid.labels)
        plot.f(field="human.yield", title="human_yield_percent", lid.labels=lid.labels)
    }
}
