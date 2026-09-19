# Methodology Notes — MVA Hackathon 2026, Track 1

This document describes the analysis pipeline used in this repository. For dataset access instructions, see the [official gated dataset page](https://huggingface.co/datasets/SageBio/mva-hackathon-2026-data) directly (not duplicated here, per Hackathon data-governance rules).

## Overview

Given proband-only whole-genome sequencing data (GRCh38) and a structured clinical phenotype (HPO terms) for a child with suspected Mosaic Variegated Aneuploidy (MVA), this pipeline narrows ~5 million genome-wide variants down to a ranked set of candidates in the three genes with established MVA causation.

## Candidate Genes

| Gene | Locus (GRCh38) | MVA subtype |
|---|---|---|
| BUB1B | chr15:40,161,022–40,221,136 | MVA1 |
| CEP57 | chr11:95,789,964–95,832,693 | MVA2 |
| TRIP13 | chr5:892,883–919,357 | MVA3 |

## Pipeline Steps

1. **Region restriction** — `bcftools view --regions-file data/reference/mva_genes_grch38.bed` narrows the genome-wide VCF to the three gene windows above. BED coordinates are 0-based (start shifted −1 from standard 1-based gene coordinates; end coordinates require no adjustment).
2. **Quality filter** — `bcftools view -f PASS` retains only caller-confident variants.
3. **Annotation** — Ensembl VEP (offline, GRCh38 cache) adds consequence type, SIFT, PolyPhen, gnomAD population frequency, and ClinVar status where catalogued.
4. **Rarity + damage filter** — `filter_vep`, requiring gnomAD AF < 0.001 (or absent) and (SIFT deleterious OR PolyPhen probably-damaging OR stop-gained OR frameshift).
5. **Manual review** — All PASS-quality variants across all three genes individually inspected, since the automated Step 4 filter has a known edge case around completely-missing (vs. merely low) gnomAD values.

## Environment

| Tool | Version | Environment |
|---|---|---|
| samtools | 1.24 | `genomics` |
| bcftools | 1.24 | `genomics` |
| htslib | 1.24 | `genomics` |
| ensembl-vep | 116.2 | `vep-env` (isolated separately due to dependency weight) |

Full setup steps in the repository's root `README.md`.

## Results Summary

Of 20 total PASS-quality variants across BUB1B/CEP57/TRIP13:

- **CEP57 and TRIP13:** all variants intronic (MODIFIER impact) — no coding or predicted-damaging candidates identified
- **BUB1B:** two heterozygous, damaging candidates identified — a ClinVar-catalogued pathogenic nonsense variant, and a novel missense variant with strong SIFT/PolyPhen agreement (full detail in submission report, not duplicated here per data-sensitivity scope of this public repo)

## Known Limitation

Proband-only sequencing does not permit read-based phasing between variants more than ~300bp apart. Compound-heterozygosity (trans configuration) versus same-copy variants (cis) cannot be resolved from this dataset alone.
