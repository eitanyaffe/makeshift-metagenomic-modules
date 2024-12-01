
# generate raw libs
lib_raw:
	$(MAKE) lib_extract_base
	$(MAKE) lib_compress \
		MERGED_R1=$(LIBS_INPUT_R1) \
		MERGED_R2=$(LIBS_INPUT_R2) \
		FINAL_R1=$(LIB_INPUT_DIR)/$(LIB_ID)_R1.fastq.gz \
		FINAL_R2=$(LIB_INPUT_DIR)/$(LIB_ID)_R2.fastq.gz \
		LIB_OUT_DIR=$(LIB_INPUT_DIR)


LIBS_UPLOAD_DONE?=$(LIBS_UPLOAD_DIR)/.done_upload
$(LIBS_UPLOAD_DONE):
	$(call _start,$(LIBS_UPLOAD_DIR))
	$(_R) R/libs_upload.r upload.files \
		ifn=$(LIBS_INPUT_TABLE) \
		idir=$(LIBS_BASE_DIR) \
		address=$(LIBS_FTP_ADDRESS) \
		user=$(LIBS_FTP_USERNAME) \
		password=$(LIBS_FTP_PASSWORD) \
		base.dir=$(LIBS_FTP_BASE_FOLDER) \
		name=$(LIBS_FTP_NAME) \
		n.parallel=$(LIBS_FTP_PARALLEL_COUNT) \
		limit.aids=$(LIBS_LIMIT_AIDS) \
		limit.sids=$(LIBS_LIMIT_SIDS) \
		work.dir=$(LIBS_UPLOAD_DIR)
	$(_end_touch)
libs_upload: $(LIBS_UPLOAD_DONE)

S_LIBS_UPLOAD_DONE?=$(LIBS_MULTI_DIR)/.done_upload
$(S_LIBS_UPLOAD_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(LIBS_MULTI_DIR) \
		PAR_MODULE=libs \
		PAR_NAME=libs_upload \
		PAR_ODIR_VAR=LIBS_UPLOAD_DIR \
		PAR_TARGET=libs_upload \
		PAR_PREEMTIBLE=0 \
		PAR_WAIT=$(TOP_WAIT) \
		PAR_MACHINE=e2-standard-16 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_libs_upload: $(S_LIBS_UPLOAD_DONE)
