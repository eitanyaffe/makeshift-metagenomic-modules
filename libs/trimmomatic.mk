trimmomatic:
	$(MAKE) m=par par_direct \
		PAR_NAME=lib_trimmo \
		PAR_WORK_DIR=$(LIB_INFO_DIR) \
		PAR_GCR_IMAGE_PATH=biocontainers/trimmomatic:v0.38dfsg-1-deb_cv1 \
		PAR_DIRECT_ODIR_VAR=TRIMMOMATIC_OUTDIR \
		PAR_DIRECT_IFN_VARS="TRIMMOMATIC_IN_R1 TRIMMOMATIC_IN_R2" \
		PAR_DIRECT_OFN_VARS="TRIMMOMATIC_PAIRED_R1 TRIMMOMATIC_PAIRED_R2 TRIMMOMATIC_NONPAIRED_R1 TRIMMOMATIC_NONPAIRED_R2" \
		PAR_MACHINE=n1-standard-4 \
		PAR_DISK_GB=$(LIBS_DISK_GB) \
		PAR_DISK_TYPE=$(LIBS_DISK_TYPE) \
		PAR_DIRECT_COMMAND=$(TRIMMO_COMMAND)
