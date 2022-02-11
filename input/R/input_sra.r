get.sra=function(ifn, tdir, bucket, max.spot.id, fn)
{
    spot.str = if (max.spot.id != 0) sprintf("-X %d", max.spot.id) else ""
    
    df = load.table(ifn)
    
    df$R1 = ""
    df$R2 = ""
    cat(sprintf("number of accessions: %d\n", dim(df)[1]))
    for (i in 1:dim(df)[1]) {
        id = df$SRA[i]
        cat(sprintf("downloading accession: %s\n", id))

        # download
        command = paste("fastq-dump --split-files -O", tdir, spot.str, id)
        # command = paste("fasterq-dump --split-files -O", tdir, id)
        # command = sprintf("prefetch -v -v -O %s %s", tdir, id)
        cat(sprintf("command: %s\n", command))
        if (system(command) != 0)
            stop(sprintf("error in fastq-dump command: %s", command))
        fns = paste0(tdir, "/", id, "_", 1:2, ".fastq")
        sfns.gz = paste0(id, "_", 1:2, ".fastq.gz")
        
        # copy to bucket
        for (side in 1:2) {
            # compress
            command = sprintf("pigz -p 12 %s", fns[side])
            cat(sprintf("command: %s\n", command))
            if (system(command) != 0)
                stop(sprintf("error in gsutil command: %s", command))

            # cp to cloud
            command = sprintf("gsutil -m cp %s.gz %s/%s", fns[side], bucket, sfns.gz[side])
            cat(sprintf("command: %s\n", command))
            if (system(command) != 0)
                stop(sprintf("error in gsutil command: %s", command))
        }

        # remove file from local dir
        command = sprintf("rm -rf %s/*", tdir) 
        cat(sprintf("command: %s\n", command))
        if (system(command) != 0)
            stop(sprintf("error in rm: %s", command))
        
        df$R1[i] = sfns.gz[1]
        df$R2[i] = sfns.gz[2]
    }

    # copy library table
    ofn = paste0(tdir, "/", fn)
    save.table(df, ofn)
    command = paste("gsutil -m cp", ofn, bucket)
    cat(sprintf("command: %s\n", command))
    if (system(command) != 0)
        stop(sprintf("error in gsutil command: %s", command))

    command = sprintf("rm -rf %s/*", tdir) 
    cat(sprintf("command: %s\n", command))
    if (system(command) != 0)
        stop(sprintf("error in rm: %s", command))
}
