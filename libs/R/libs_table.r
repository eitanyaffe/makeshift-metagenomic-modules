make.table=function(ifn, idir, limit.aids, limit.sids, ofn)
{
    df = load.table(ifn)
    
    if (limit.aids != "NA")
        df = df[is.element(df$assembly, limit.aids),]
    if (limit.sids[1] != "NA")
        df = df[is.element(df$lib, limit.sids),]
    
    rr = data.frame(LIB_ID=df$lib)
    
    is.paired = is.element("R2", names(df))
    
    rr$LIB_INPUT_R1_GZ_FN = df$R1
    if (is.paired)
        rr$LIB_INPUT_R2_GZ_FN = df$R2
    rr$LIBS_FILESIZE_MB = 0

    get.size=function(fns.str) {
        fns = paste(idir, "/", strsplit(fns.str, ",")[[1]], sep="")
        rr = sum(file.info(fns)$size)
        if (is.na(rr))
            stop(paste("cannot retrieve file size:", paste0(fns, collapse=",")))
        rr
    }
    cat(sprintf("retrieving file sizes for %d libraries\n", dim(rr)[1]))
    for (i in 1:dim(rr)[1]) {
        size1 = get.size(rr$LIB_INPUT_R1_GZ_FN[i])
        if (is.paired)
            size2 = get.size(rr$LIB_INPUT_R2_GZ_FN[i])
        else
            size2 = 0
        rr$LIBS_FILESIZE_MB[i] = round((size1 + size2) / 10^6)
    }    
    save.table(rr, ofn)
}
