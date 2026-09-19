#!/usr/bin/env bash
# Stage 1: targeted variant filtering for BUB1B / CEP57 / TRIP13 (MVA1-3)
# Usage: ./run_stage1_mva_filter.sh <path_to_vcf.gz> <output_dir>
#
# Prereqs (install via: mamba activate mva-hackathon):
#   bcftools, tabix, ensembl-vep (with GRCh38 cache downloaded)

set -euo pipefail

VCF="${1:?Usage: $0 <input.vcf.gz> <output_dir>}"
OUTDIR="${2:?Usage: $0 <input.vcf.gz> <output_dir>}"
# Default assumes project layout: scripts/<this file>, data/reference/<bed file>
# Override with a 3rd argument if your BED file lives elsewhere.
BED="${3:-$(dirname "$0")/../data/reference/mva_genes_grch38.bed}"

mkdir -p "$OUTDIR"

echo "== Step 1: Restrict to BUB1B / CEP57 / TRIP13 regions =="
bcftools view \
  --regions-file "$BED" \
  --output-type z \
  --output "$OUTDIR/mva_genes.vcf.gz" \
  "$VCF"
tabix -p vcf "$OUTDIR/mva_genes.vcf.gz"

echo "== Step 2: Keep only PASS variants =="
bcftools view -f PASS \
  --output-type z \
  --output "$OUTDIR/mva_genes.pass.vcf.gz" \
  "$OUTDIR/mva_genes.vcf.gz"
tabix -p vcf "$OUTDIR/mva_genes.pass.vcf.gz"

echo "== Step 3: Annotate with VEP (ClinVar, gnomAD, SIFT/PolyPhen/CADD) =="
# --custom / --plugin flags require the corresponding VEP cache + plugin data.
# Add --custom for ClinVar and --plugin CADD if you've downloaded those resources
# separately; the base call below works with just the standard VEP cache.
vep \
  --input_file "$OUTDIR/mva_genes.pass.vcf.gz" \
  --output_file "$OUTDIR/mva_genes.annotated.vcf" \
  --vcf \
  --cache \
  --offline \
  --assembly GRCh38 \
  --sift b \
  --polyphen b \
  --af_gnomade \
  --force_overwrite

echo "== Step 4: Filter to rare (gnomAD AF < 0.001), damaging variants =="
bcftools view "$OUTDIR/mva_genes.annotated.vcf" \
  | filter_vep \
      --filter "gnomADe_AF < 0.001 or not gnomADe_AF" \
      --filter "SIFT is deleterious or PolyPhen is probably_damaging or Consequence match stop_gained or Consequence match frameshift" \
      --format vcf \
      -o "$OUTDIR/mva_genes.rare_damaging.vcf"

echo "== Done. Review: $OUTDIR/mva_genes.rare_damaging.vcf =="
echo "Next: manually inspect zygosity (het/hom) and check for compound-het pairs"
echo "within the same gene — MVA is autosomal recessive, so biallelic hits matter most."
