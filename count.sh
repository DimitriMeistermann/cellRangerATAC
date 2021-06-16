#!/usr/bin/env bash

conda activate scATAC

/homes/dmeister/cellRangerATAC/bin/cellranger-atac-1.2.0/cellranger-atac count --id=scATAC_Kabuki \
	--reference=/homes/dmeister/GenomeRef/GRCh38/refdata-cellranger-atac-GRCh38-1.2.0 \
	--fastqs=/homes/dmeister/Dataset/scATAC_Kabuki/mkfastq_output/outs/fastq_path \
	--sample=A1-1,A1-2,A1-3,A1-4,A2-1,A2-2,A2-3,A2-4,A3-1,A3-2,A3-3,A3-4,A4-1,A4-2,A4-3,A4-4