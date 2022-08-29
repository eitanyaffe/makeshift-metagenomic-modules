
genes.collect=function(ifn, aid.template, collect.id, template.fns,
                       idir, odir)
{
    df = load.table(ifn)
    cat(sprintf("number of assemblies: %d\n", dim(df)[1]))

    for (tfn in template.fns) {
        ofn = gsub("DUMMY", collect.id, tfn)
        ofn = gsub(idir, odir, ofn)
        odir = dirname(ofn)
        cat(sprintf("collecting data for file: %s\n", ofn))
        system(paste("mkdir -p", odir))
        rr = NULL
        for (i in 1:dim(df)[1]) {
            aid = df$ASSEMBLY_ID[i]
            ifn = gsub("DUMMY", aid, tfn)
            xx = read.delim(ifn)
            rr = rbind(rr, data.frame(aid=aid, xx))
        }
        save.table(rr, ofn)
    }
}
