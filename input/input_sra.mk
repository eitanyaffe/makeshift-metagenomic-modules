INPUT_SRA_DONE?=$(INPUT_SRA_WORK_DIR)/.done
$(INPUT_SRA_DONE):
	$(call _start,$(INPUT_SRA_WORK_DIR))
	$(_R) R/input_sra.r get.sra \
		ifn=$(INPUT_SRA_TABLE) \
		tdir=$(INPUT_SRA_WORK_DIR) \
		max.spot.id=$(INPUT_SRA_MAX_SPOT_ID) \
		bucket=$(INPUT_BUCKET) \
		fn=$(INPUT_TABLE_FILENAME)
	$(_end_touch)
input_sra: $(INPUT_SRA_DONE)

S_INPUT_SRA_DONE?=$(INPUT_SRA_WORK_DIR)/.done_step
$(S_INPUT_SRA_DONE):
	$(call _start,$(INPUT_SRA_WORK_DIR))
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(INPUT_SRA_WORK_DIR) \
		PAR_MODULE=input \
		PAR_MACHINE=n2-standard-2 \
		PAR_DISK_TYPE=pd-ssd \
		PAR_DISK_GB=200 \
		PAR_BOOT_GB=200 \
		PAR_NAME=download_sra \
		PAR_ODIR_VAR=INPUT_SRA_WORK_DIR \
		PAR_TARGET=input_sra \
		PAR_PREEMTIBLE=0 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
d_input_sra: $(S_INPUT_SRA_DONE)
