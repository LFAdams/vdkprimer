#PBS -S /bin/bash
#PBS -N vdkprimer9
#PBS -q batch
#PBS -l nodes=1:ppn=8:AMD
#PBS -l walltime=480:00:00
#PBS -l mem=25g


module load VCFtools/0.1.15-foss-2016b-Perl-5.24.1

module load BEDTools/2.26.0-foss-2016b
cd /scratch/lfa81121/primerchr9/

GITDIR=/home/lfa81121/vdkprimer



###########################################################
/usr/local/apps/eb/VCFtools/0.1.15-foss-2016b-Perl-5.24.1/bin/vcftools --gzvcf /home/lfa81121/primer/RS_raw_snps_and_indels.vcf --recode --recode-INFO-all --indv resistant_bulk --indv susceptible_bulk --chr Cla97Chr09 --from-bp 5957084 --to-bp 10328768 --out 788chr9.5mbto10mb

/usr/local/apps/eb/VCFtools/0.1.15-foss-2016b-Perl-5.24.1/bin/vcftools --gzvcf 788chr9.5mbto10mb.recode.vcf --remove-indels --min-alleles 2 --max-alleles 2 --minQ 50 --minDP 5 --recode --recode-INFO-all --out 788chr9.5mbto10mb_woindels

bash $GITDIR/primerHelper2.sh -v 788chr9.5mbto10mb_woindels.recode.vcf -r /work/cemlab/reference_genomes/97103_v2.fa -c Cla97Chr09 -f 5957084 -t 10328768 -a "resistant_bulk" -b "susceptible_bulk" -o 788chr9.5mbto10mb

module load BLAST+/2.7.1-foss-2016b-Python-2.7.14

blastn -query 788chr9.5mbto10mb.fa -db /work/cemlab/reference_genomes/97103_v2.fa -outfmt 7  -evalue 0.5 -out 788chr9.5mbto10mb_evalue.fa

grep "Query\|hits" 788chr9.5mbto10mb_evalue.fa > result_788chr9.5mbto10mb_evalue.fa

awk '{getline b;printf("%s %s\n",$0,b)}' result_788chr9.5mbto10mb_evalue.fa > resultcolumn_result_788chr9.5mbto10mb_evalue.fa

awk '{getline b;printf("%s %s\n",$0,b)}' 788chr9.5mbto10mb.fa > seq3_2.fa

awk '{getline b;printf("%s %s\n",$0,b)}' 788chr9.5mbto10mb.501.fa > seq501.fa

module load EMBOSS/6.6.0-foss-2016b

infoseq 788chr9.5mbto10mb.fa -only -desc -name -length -pgc > gc3_2.fa
