make.table=function(ifn, idir, ofn)
{
    df = load.table(ifn)
    rr = data.frame(LIB_ID=df$lib)
    rr$LIB_INPUT_R1_GZ_FN = df$R1
    rr$LIB_INPUT_R2_GZ_FN = df$R2
    rr$LIBS_FILESIZE_MB = 0

    get.size=function(fns.str) {
        fns = paste(idir, "/", strsplit(fns.str, ",")[[1]], sep="")
        sum(file.info(fns)$size)
    }
    cat(sprintf("retrieving file sizes for %d libraries\n", dim(rr)[1]))
    for (i in 1:dim(rr)[1]) {
        size1 = get.size(rr$LIB_INPUT_R1_GZ_FN[i])
        size2 = get.size(rr$LIB_INPUT_R2_GZ_FN[i])
        rr$LIBS_FILESIZE_MB[i] = round((size1 + size2) / 10^6)
    }    
    save.table(rr, ofn)
}
