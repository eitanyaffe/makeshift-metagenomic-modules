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

    ix = read.count$trimmomatic == 0
    if (any(ix)) {
        cat(sprintf("skipping missing libraries: %s\n", paste(read.count$id[ix], collapse=",")))
        read.count = read.count[!ix,]
        bp.count = bp.count[!ix,]
        read.yield = read.yield[!ix,]
        bp.yield = bp.yield[!ix,]
    }
    # try to sort by lib index if possible
    df$index = as.numeric(sapply(strsplit(df$lid, "_"), function(x) { x[2] }))
    if (!any(is.na(df$index)))
        df = df[order(df$aid, df$index),]
    
    get.loss=function(dfx, field) {
        ix = match(df$lid, dfx$id) 
        100 - ifelse(!is.na(ix), dfx[ix,field], 0)
    }
    get.f=function(dfx, field) {
        ix = match(df$lid, dfx$id) 
        ifelse(!is.na(ix), dfx[ix,field], 0)
    }
    df$read.count.m = get.f(dfx=read.count, field="final") / 10^6
    df$trimmo.loss = get.loss(dfx=bp.yield, field="trimmomatic")
    df$dup.loss = get.loss(dfx=read.yield, field="duplicate")
    df$human.loss = get.loss(dfx=read.yield, field="deconseq")

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
        ylim = c(0, max(df[,field]))
        for (aid in aids) {
            dfa = df[df$aid == aid,]
            mm = barplot(dfa[,field], col=dfa$col, border=dfa$border, ylim=ylim, main=aid, lwd=2, las=2)
            if (lid.labels) mtext(dfa$lid, side=1, line=0, cex=0.3, at=mm, las=2)
            
        }
        fig.end()
    }
    for (lid.labels in c(T,F)) {
        plot.f(field="read.count.m", title="reads_millions", lid.labels=lid.labels)
        plot.f(field="trimmo.loss", title="trimmo_loss_percent", lid.labels=lid.labels)
        plot.f(field="dup.loss", title="dup_loss_percent", lid.labels=lid.labels)
        plot.f(field="human.loss", title="human_loss_percent", lid.labels=lid.labels)
    }
}
