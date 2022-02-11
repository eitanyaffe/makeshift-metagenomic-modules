make.table=function(assembly.id, ifn, prefix, ofn)
{
    df = load.table(ifn)
    if (sum(df$assembly == assembly.id) == 0)
        stop(sprintf("no libs found for assembly %s in table %s", assembly.id, ifn))
    df = df[df$assembly == assembly.id,]
    rr = data.frame(ASSEMBLY_ID=assembly.id, MAP_LIB_ID=df$lib)
    if (prefix != "NA") {
        rr$MAP_INPUT_R1_GZ_FN = paste0(df$lib, "/", prefix, "/R1.fastq.gz")
        rr$MAP_INPUT_R2_GZ_FN = paste0(df$lib, "/", prefix, "/R2.fastq.gz")
    } else {
        rr$MAP_INPUT_R1_GZ_FN = paste0(df$lib, "/R1.fastq.gz")
        rr$MAP_INPUT_R2_GZ_FN = paste0(df$lib, "/R2.fastq.gz")
    }
    save.table(rr, ofn)
}
