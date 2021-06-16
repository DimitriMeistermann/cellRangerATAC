import glob, os, sys, json, shutil

WORKING_DIR = os.path.dirname(workflow.snakefile)
#CELLRANGER = "/homes/dmeister/bin/cellranger-atac-1.2.0"
CELLRANGER = WORKING_DIR+"/bin/cellranger-atac-2.0.0/cellranger-atac"

if config=={}:
	print("Default config file loaded, from " + WORKING_DIR + "/config.json")
	configfile: WORKING_DIR+"/config.json"

## creation of the logs subdirectory
if not os.path.exists(WORKING_DIR+"/log"):
	os.mkdir(WORKING_DIR+"/log")

#put all config variable as variable in the snakefile
for configVar in config:
	if isinstance(config[configVar], str): exec(configVar+"= '"+config[configVar]+"'")
	else: exec(configVar+"="+str(config[configVar]))

if(OUTPUT_PATH[-1] == "/") : OUTPUT_PATH = OUTPUT_PATH[:-1]

SAMPLES=list(dict.keys(SAMPLE_LIST))

####################

rule all:
	input: OUTPUT_PATH+"/AGGR"

rule mkfastq:
	input:	ILLUMINA_FOLDER
	output: directory(OUTPUT_PATH+"/MKFASTQ")
	shell: """
	cd {OUTPUT_PATH}
	{CELLRANGER} mkfastq --id=MKFASTQ \\
		--run={ILLUMINA_FOLDER} \\
		--csv={ILLUMINA_FOLDER}/SampleSheet.csv
	"""

rule createTempSampleList:
	input:	ILLUMINA_FOLDER
	output: temp(OUTPUT_PATH+"/{sample}.txt")
	run:
		sampleList=",".join(SAMPLE_LIST[wildcards.sample])
		with open(str(output),"w") as f:
			f.write(sampleList)

rule count:
	input:
		mkfastq=OUTPUT_PATH+"/MKFASTQ",
		sampleList=OUTPUT_PATH+"/{sample}.txt"
	output: directory(OUTPUT_PATH+"/COUNT_{sample}")
	shell: """
	cd {OUTPUT_PATH}
	{CELLRANGER} count --id=COUNT_{wildcards.sample} \\
		--reference={REFERENCE} \\
		--fastqs={OUTPUT_PATH}/MKFASTQ/outs/fastq_path \\
		--sample=$(cat {input.sampleList})
	"""

rule aggr:
	input:
		countFolder=expand(OUTPUT_PATH+"/COUNT_{sample}",sample=SAMPLES),
		libraryDescription=OUTPUT_PATH+"/libraryDescription.csv"
	output: directory(OUTPUT_PATH+"/AGGR")
	shell: """
	cd {OUTPUT_PATH}
	{CELLRANGER} aggr --id=AGGR \\
		--csv={input.libraryDescription} \\
		--normalize={AGGR_NORMALIZE} \\
		--reference={REFERENCE}
	"""

rule createAggrCSV:
	input:	ILLUMINA_FOLDER
	output: OUTPUT_PATH+"/libraryDescription.csv"
	run:
		with open(str(output),"w") as f:
			f.write("library_id,fragments,cells\n")
			for sample in SAMPLES:
				f.write(sample+","+ \
					OUTPUT_PATH+"/COUNT_"+sample+"/outs/fragments.tsv.gz,"+\
					OUTPUT_PATH+"/COUNT_"+sample+"/outs/singlecell.csv\n")



