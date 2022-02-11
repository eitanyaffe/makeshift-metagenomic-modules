make.table=function(ifn, ofn)
{
    df = load.table(ifn)
    ss = split(df$lib, df$assembly)
    rr = data.frame(ASSEMBLY_ID=names(ss), LIB_IDS=sapply(ss, function(x) paste(x, collapse=",")))
    rr = rr[order(match(rr$ASSEMBLY_ID, df$assembly)),]
    save.table(rr, ofn)
}
