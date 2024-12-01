upload.files=function(ifn,
                      idir,
                      address,
                      user,
                      password,
                      base.dir,
                      name,
                      n.parallel,
                      limit.aids,
                      limit.sids,
                      work.dir)
{
    df = load.table(ifn)
    if (limit.aids != "NA")
        df = df[is.element(df$assembly, limit.aids),]
    if (limit.sids[1] != "NA")
        df = df[is.element(df$lib, limit.sids),]
    cat(sprintf("uploading %d libs\n", dim(df)[1]))
    
    #################################################################################
    # run commands directly
    #################################################################################

    run.commands = function(cmds, fail.on.error=T) {
        command = sprintf("lftp -c '%s'", paste0(cmds, collapse=" && "))
        cat(sprintf("running command: %s\n", command))
        if (system(command) != 0 && fail.on.error)
            stop("stopping on error")
    }

    #################################################################################
    # run commands from script
    #################################################################################

    run.script = function(cmds, fail.on.error=T, title) {
        sfn = paste0(work.dir, "/", title, ".lftp")
        fc = file(sfn)
        writeLines(cmds, fc)
        close(fc)
        
        command = sprintf("lftp -f %s", sfn)
        cat(sprintf("running command: %s\n", command))
        if (system(command) != 0 && fail.on.error)
            stop("stopping on error")
    }

    para = sprintf("set cmd:parallel %d", n.parallel)
    open = sprintf("open -u %s,%s %s", user, password, address)
    mkdir = sprintf("cd %s && mkdir %s", base.dir, name)
    cd = sprintf("cd %s/%s", base.dir, name)

    rr = c(para, open, cd)
    for (i in 1:dim(df)[1]) {
        id = df$lib[i]
        fn1 = paste0(idir, "/", id, "/work/input/", id, "_R1.fastq.gz")
        fn2 = paste0(idir, "/", id, "/work/input/", id, "_R2.fastq.gz")
        cmd1 = sprintf("put -c %s", fn1)
        cmd2 = sprintf("put -c %s", fn2)
        rr = c(rr, cmd1, cmd2)
    }

    # make output directory
    run.commands(cmds=c(open, mkdir), fail.on.error=F)

    # upload files 
    run.script(cmds=rr, title="upload")
}
