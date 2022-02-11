exec=function(command)
{
    cat(sprintf("running command: %s\n", command))
    if (system(command) != 0)
        stop(cat("error in command: %s\n", command))
}

merge.bam=function(ifn, threads, idir, ofn)
{
    df = load.table(ifn)
    fns1 = paste(idir, "/", df$chunk, "/R1.bam", collapse=" ", sep="")
    fns2 = paste(idir, "/", df$chunk, "/R2.bam", collapse=" ", sep="")
    command = sprintf("samtools merge -n -@%d -f %s %s %s", threads, ofn, fns1, fns2)
    exec(command)
}

merge.pairs=function(ifn, idir, ofn)
{
    df = load.table(ifn)
    fns = paste(idir, "/", df$chunk, "/paired.tab", sep="")
    exec(sprintf("head -n +1 %s > %s", fns[1], ofn))
    for (fn in fns)
        exec(sprintf("tail -n +2 %s >> %s", fn, ofn))
}

merge.sides=function(ifn, idir,
                     ofn.filtered.1, ofn.filtered.2,
                     ofn.nonpaired.1, ofn.nonpaired.2)
{
    df = load.table(ifn)

    merge.f=function(sfn, ofn) {
        fns = paste(idir, "/", df$chunk, "/", sfn, sep="")
        exec(sprintf("head -n +1 %s > %s", fns[1], ofn))
        for (fn in fns)
            exec(sprintf("tail -n +2 %s >> %s", fn, ofn))
    }

    # filtered, without pairing
    merge.f(sfn="R1.filtered", ofn=ofn.filtered.1)
    merge.f(sfn="R2.filtered", ofn=ofn.filtered.2)

    # non-paired
    merge.f(sfn="non_paired_R1.tab", ofn=ofn.nonpaired.1)
    merge.f(sfn="non_paired_R2.tab", ofn=ofn.nonpaired.2)
    
    ## fns1 = paste(idir, "/", df$chunk, "/non_paired_R1.tab", sep="")
    ## exec(sprintf("head -n +1 %s > %s", fns1[1], ofn1))
    ## for (fn in fns1)
    ##     exec(sprintf("tail -n +2 %s >> %s", fn, ofn1))
    
    ## fns2 = paste(idir, "/", df$chunk, "/non_paired_R2.tab", sep="")
    ## exec(sprintf("head -n +1 %s > %s", fns2[1], ofn2))
    ## for (fn in fns2)
    ##     exec(sprintf("tail -n +2 %s >> %s", fn, ofn2))
}
