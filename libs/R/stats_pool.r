
# M: number of reads
# N: number of molecules
get.unique=function(M, N)
{    
    Mx = min(10000, M)

    # probability of each multiplicity
    pp = dbinom(2:Mx, size=M, p=1/N)

    # number of unique reads
    M.unique = M - sum(pmax(0, N * pp * (2:Mx - 1)))
    M.unique
}

infer.pool.size=function(ifn, molecule.length, use.baseline, ofn)
{
    df = load.table(ifn)

    # max number of molecules
    max.molecules = 10^10

    bp.ng = 1.08E-12
    
    rng = c(0, max.molecules)

    df$M = df$trimmomatic
    df$M.unique = df$duplicate
    df$dup.percent = 100 * (df$M - df$M.unique) / df$M

    if (use.baseline) {
        ff = 1 - min(df$dup.percent) / 100
    } else {
        ff = 1
    }
    
    rr = NULL
    for (i in 1:dim(df)[1]) {
        M = df$M[i] * ff
        M.unique = df$M.unique[i]
        id = df$id[i]
        dup.percent = df$dup.percent[i]

        # infer pool size
        opt = optimize(function(N) { abs(M.unique - get.unique(M=M, N=N)) },
                       interval=rng)
        N = round(opt$minimum)

        # infer pool weight
        ng = (N * molecule.length) * bp.ng
        
        rr = rbind(rr, data.frame(id=id, dup.percent=dup.percent, read.count=M,
                                  unique.read.count=M.unique, molecule.count.million=round(N/10^6), ng=ng))
    }
    save.table(rr, ofn)
    
}

