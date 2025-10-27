genes.query=function(uniref.ifn, gene.ifn, pattern, field, window, odir)
{
    # load tables
    uniref.table = load.table(uniref.ifn)
    gene.table = load.table(gene.ifn)
    cat(sprintf("loaded uniref table with %d genes\n", nrow(uniref.table)))
    cat(sprintf("loaded gene table with %d genes\n", nrow(gene.table)))
    
    # validate field exists in uniref table
    if (!field %in% colnames(uniref.table)) {
        stop(sprintf("error: field '%s' not found in uniref table. available fields: %s", 
                    field, paste(colnames(uniref.table), collapse = ", ")))
    }
    
    # handle pattern as single string (R argument parsing may split it)
    if (length(pattern) > 1) {
        pattern = paste(pattern, collapse = " ")
    }
    # remove quotes from pattern if present
    pattern = gsub("^[\"']|[\"']$", "", pattern)
    cat(sprintf("searching for pattern '%s' in field '%s'\n", pattern, field))
    
    # case-insensitive grepl search on uniref table to get matching gene IDs
    matches = grepl(pattern, uniref.table[[field]], ignore.case = TRUE)
    matched.uniref = uniref.table[matches, ]
    
    cat(sprintf("found %d matching genes in uniref table\n", nrow(matched.uniref)))
    
    # get the gene IDs that match
    if (!"gene" %in% colnames(matched.uniref)) {
        stop("error: 'gene' column not found in uniref table")
    }
    
    matching.gene.ids = matched.uniref$gene
    cat(sprintf("extracted %d unique gene IDs\n", length(unique(matching.gene.ids))))
    
    # filter gene table to only include matching genes
    if (!"gene" %in% colnames(gene.table)) {
        stop("error: 'gene' column not found in gene table")
    }
    
    # use match to add coordinate columns from gene table to uniref table
    gene_match_idx = match(matched.uniref$gene, gene.table$gene)
    
    # add coordinate columns using match
    matched.uniref$contig = gene.table$contig[gene_match_idx]
    matched.uniref$start = gene.table$start[gene_match_idx]
    matched.uniref$end = gene.table$end[gene_match_idx]
    matched.uniref$strand = gene.table$strand[gene_match_idx]
    
    cat(sprintf("added coordinate columns, result has %d genes\n", nrow(matched.uniref)))
    
    # validate required columns exist
    if (nrow(matched.uniref) > 0) {
        required_cols = c("gene", "aid", "contig", "start", "end")
        missing_cols = setdiff(required_cols, colnames(matched.uniref))
        if (length(missing_cols) > 0) {
            stop(sprintf("error: missing required columns: %s", paste(missing_cols, collapse = ", ")))
        }
    }
    
    # split by aid and save separate files
    unique_aids = unique(matched.uniref$aid)
    cat(sprintf("found %d unique assembly IDs: %s\n", length(unique_aids), paste(unique_aids, collapse = ", ")))
    
    for (aid in unique_aids) {
        aid_genes = matched.uniref[matched.uniref$aid == aid, ]
        cat(sprintf("processing aid '%s' with %d genes\n", aid, nrow(aid_genes)))
        
        # save genes table for this aid
        gene_ofn = file.path(odir, paste0(aid, "_genes.txt"))
        save.table(aid_genes, gene_ofn)
        cat(sprintf("saved genes table to: %s\n", gene_ofn))
        
        # create regions table for this aid
        if (nrow(aid_genes) > 0) {
            # create zoom windows around genes with margin
            zoom_start = pmax(1, aid_genes$start - window)
            zoom_end = aid_genes$end + window
            
            # create regions table with mview format
            regions.table = data.frame(
                id = as.character(seq_len(nrow(aid_genes))),
                level = rep(1L, nrow(aid_genes)),
                description = paste0(aid_genes$gene, " - ", aid_genes[[field]]),
                assembly = aid_genes$aid,
                contigs = aid_genes$contig,
                zoom_start = zoom_start,
                zoom_end = zoom_end,
                segment_contig = aid_genes$contig,
                segment_start = as.integer(aid_genes$start),
                segment_end = as.integer(aid_genes$end),
                single_contig = rep(TRUE, nrow(aid_genes)),
                stringsAsFactors = FALSE
            )
        } else {
            # create empty regions table with proper structure
            regions.table = data.frame(
                id = character(),
                level = integer(),
                description = character(),
                assembly = character(),
                contigs = character(),
                zoom_start = numeric(),
                zoom_end = numeric(),
                segment_contig = character(),
                segment_start = integer(),
                segment_end = integer(),
                single_contig = logical(),
                stringsAsFactors = FALSE
            )
        }
        
        # save regions table for this aid
        regions_ofn = file.path(odir, paste0(aid, "_regions.txt"))
        save.table(regions.table, regions_ofn)
        cat(sprintf("saved regions table to: %s\n", regions_ofn))
    }
}
