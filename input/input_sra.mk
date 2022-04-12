INPUT_SRA_DONE?=$(INPUT_SRA_WORK_DIR)/.done
$(INPUT_SRA_DONE):
	$(call _start,$(INPUT_SRA_WORK_DIR))
	$(_R) R/input_sra.r get.sra.files \
		id=$(INPUT_ACCESSION) \
		tdir=$(INPUT_SRA_WORK_DIR) \
		max.spot.id=$(INPUT_SRA_MAX_SPOT_ID) \
		bucket=$(INPUT_BUCKET)
	$(_end_touch)
input_sra: $(INPUT_SRA_DONE)

INPUT_SRA_SUMMARY_DONE?=$(INPUT_INFO_DIR)/.done_summary
$(INPUT_SRA_SUMMARY_DONE):
	$(call _start,$(INPUT_INFO_DIR))
	$(_R) R/input_sra.r get.sra.table \
		ifn=$(INPUT_SRA_TABLE) \
		tdir=$(INPUT_INFO_DIR) \
		bucket=$(INPUT_BUCKET) \
		fn=$(INPUT_TABLE_FILENAME)
	$(_end_touch)
input_sra_summary: $(INPUT_SRA_SUMMARY_DONE)

S_INPUT_SRA_DONE?=$(INPUT_INFO_DIR)/.done_step
$(S_INPUT_SRA_DONE): $(INPUT_SRA_SUMMARY_DONE)
	$(call _start,$(INPUT_INFO_DIR))
	$(MAKE) m=par par_tasks_complex \
		PAR_MODULE=input \
		PAR_NAME=download_sra \
		PAR_WORK_DIR=$(INPUT_INFO_DIR) \
		PAR_TARGET=input_sra \
		PAR_TASK_DIR=$(INPUT_SRA_WORK_DIR) \
		PAR_TASK_ITEM_TABLE=$(INPUT_SRA_TABLE) \
		PAR_TASK_ITEM_VAR=lib \
		PAR_TASK_ODIR_VAR=INPUT_SRA_WORK_DIR \
		PAR_MACHINE=n2-standard-2 \
		PAR_DISK_TYPE=pd-ssd \
	        PAR_DISK_GB=100 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
d_input_sra: $(S_INPUT_SRA_DONE)
