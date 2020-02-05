#!/bin/bash

while getopts v:r:c:f:t:a:b:o: option
do
case "${option}"
in
v) VCF=${OPTARG};;
r) REF=${OPTARG};;
c) CHR=${OPTARG};;
f) FROM=${OPTARG};;
t) TO=${OPTARG};;
a) PARENTA=${OPTARG};;
b) PARENTB=${OPTARG};;
o) OUTFILE=${OPTARG};;
esac
done

LABELSTR="$PARENTA-$PARENTB.$CHR.$FROM-$TO"

echo $PARENTA > tmpkeep.txt
echo $PARENTB >> tmpkeep.txt

vcftools --vcf $VCF \
  --keep tmpkeep.txt \
  --chr $CHR --from-bp $FROM --to-bp $TO \
  --out $OUTFILE --maf 0.0001 --recode

sed -ie '/\.\/\./ d' $OUTFILE.recode.vcf
sed '/^#/ d' < $OUTFILE.recode.vcf |
  awk -v OFS='\t' '{ if(length($5) == 1 && ($2 - prev) > 30){print $1, $2 - 32, $2; prev=$2; next} prev=$2}' > tmpbed.bed

bedtools getfasta -fi $REF -fo $OUTFILE.fa -bed tmpbed.bed

sed '/^#/ d' < $OUTFILE.recode.vcf |
  awk -v OFS='\t' '{ if(length($5) == 1 && ($2 - prev) > 30){print $1, $2 - 250, $2 + 250; prev=$2; next} prev=$2}' > tmpbed2.bed

bedtools getfasta -fi $REF -fo $OUTFILE.501.fa -bed tmpbed2.bed

sed '/^#/ d' < $OUTFILE.recode.vcf |
  awk -v OFS='\t' '{ if(length($5) == 1 && ($2 - prev) > 30){print $1, $2, $4, $5; prev=$2; next} prev=$2}' > refallels.bed

rm tmpkeep.txt
rm tmpbed.bed
