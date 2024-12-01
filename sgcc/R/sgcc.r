
make.table=function(ifn, idir, ofn)
{
    df = load.table(ifn)
    rr = data.frame(SGCC_LIB_ID=df$lib)
    rr$SGCC_R1_GZ_FN = df$R1
    rr$SGCC_R2_GZ_FN = df$R2

    f1 = paste0(idir, "/", rr$SGCC_R1_GZ_FN)
    f2 = paste0(idir, "/", rr$SGCC_R2_GZ_FN)
    cat(sprintf("retrieving size for %d files\n", 2*dim(rr)[1]))
    if (any(!file.exists(f1) | !file.exists(f2)) ) {
        ii = which(!file.exists(f1))
        if (length(ii) > 0)
            cat(sprintf("missing R1 files:\n %s\n", paste(f1[ii], sep="", collapse="\n ")))
        ii = which(!file.exists(f2))
        if (length(ii) > 0)
            cat(sprintf("missing R2 files:\n %s\n", paste(f2[ii], sep="", collapse="\n ")))
        stop("one or more files not found")
    }
    rr$SGCC_DISK_GB = 32 + 5 * round((file.info(f1)$size + file.info(f2)$size) / 10^9)
    
    cat(sprintf("number of samples: %d\n", dim(rr)[1]))
    save.table(rr, ofn)
}

compare=function(binary, ifn, idir, wdir, kmer, threads, ofn, ofn.stats)
{
    # collect signatures locally
    df = load.table(ifn)
    system(paste("mkdir -p", wdir))
    tfns =  paste0(wdir, "/", df$SGCC_LIB_ID, ".sig")

    # verify files exist
    missing.files = NULL
    cat(sprintf("locating %d signature files under: %s\n", dim(df)[1], idir))
    for (i in 1:dim(df)[1]) {
        fn = sprintf("%s/libs/%s/work/sourmash.sig", idir, df$SGCC_LIB_ID[i])
        if (!file.exists(fn))
            missing.files = c(missing.files, fn)
    }
    if (length(missing.files) > 0)
        stop(sprintf("signature file missing: %d\nfiles: %s\n", length(missing.files), paste(missing.files, collapse=",")))

    # copy files
    cat(sprintf("copying signature files: %d\n", dim(df)[1])) 
    for (i in 1:dim(df)[1]) {
        exec(sprintf("cp %s/libs/%s/work/sourmash.sig %s", idir, df$SGCC_LIB_ID[i], tfns[i]), verbose=F)
    }
    
    wfn = paste0(wdir, "/table")
    write.table(x=paste0(df$SGCC_LIB_ID, ".sig"), file=wfn, quote=F, row.names=F,col.names=F)

    # compare sigs
    exec(sprintf("cd %s && %s compare -k %d -p %d --from-file %s --csv %s",
                      wdir, binary, kmer, threads, wfn, ofn))
    system(paste("rm -rf", wdir))

    rr.stats = NULL
    for (i in 1:dim(df)[1]) {
        xx = read.delim(sprintf("%s/libs/%s/work/read_count", idir, df$SGCC_LIB_ID[i]), header=F)
        rr.stats = rbind(rr.stats, data.frame(id=xx[1,1], reads=sum(xx[,3]), bps=sum(xx[,4])))
    }
    save.table(rr.stats, ofn.stats)
}
