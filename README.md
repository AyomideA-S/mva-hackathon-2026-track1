# MVA Hackathon 2026 — Track 1: Variant Prioritization

Submission for **Track 1 (Variant Identification)** of the [Rare Disease, Real Kid: MVA Hackathon 2026](https://sagebio-rare-disease-real-kid-mva-hackathon-2026.hf.space/), organized by Hugging Face, Sage Bionetworks, the MVA Society, and BEACON, with prize sponsorship from AWS and Anthropic.

## About This Project

This repository contains the variant filtering and annotation pipeline used to identify candidate causal variant(s) for a child living with Mosaic Variegated Aneuploidy (MVA), from whole-genome sequencing data shared under explicit parental consent (WCG IRB #20252010).

**Goal:** Given the proband's WGS data and clinical phenotype (HPO terms), identify the disease-causing genetic variant(s).

## Approach

1. Restrict genome-wide VCF to the three known MVA-associated genes (BUB1B/MVA1, CEP57/MVA2, TRIP13/MVA3), GRCh38
2. Filter to caller-confident (PASS) variants
3. Annotate with Ensembl VEP — consequence type, SIFT, PolyPhen, gnomAD population frequency, ClinVar status
4. Filter for rare (gnomAD AF < 0.001) and predicted-damaging variants
5. Manual review of all candidates in each gene region

See `docs/` for the full methods write-up and reproducibility notes.

## Repository Structure

```
.
├── data/
│   └── reference/       # Gene coordinate BED file (GRCh38) — no patient data
├── scripts/
│   └── run_stage1_mva_filter.sh
├── docs/
│   └── README.md        # Detailed methodology notes
└── README.md            # This file
```

**Note:** Raw genomic data (VCF, FASTQ) and the organizer-provided clinical phenotype document are intentionally excluded from this repository per the Hackathon's data governance rules (gated access, no redistribution). Access the dataset directly via the [official gated repository](https://huggingface.co/datasets/SageBio/mva-hackathon-2026-data) after agreeing to the Hackathon Rules.

## Reproducing This Pipeline

Requires `bcftools`/`samtools`/`tabix` (â‰¥1.17) and Ensembl VEP with a GRCh38 cache. See `docs/README.md` for full environment setup.

```bash
./scripts/run_stage1_mva_filter.sh <path_to_vcf.gz> <output_dir>
```

## Acknowledgement

This work was made possible through the Hackathon, organized by Sage Bionetworks in partnership with the MVA Society, Hugging Face, and BEACON (The Benchmarking, Evaluation, and Assessment Consortium for Science), with prize sponsorship from AWS and Anthropic. We are deeply grateful to the child and their family who generously contributed their data and their story to advance research into this rare disease. We acknowledge their trust in making this Hackathon possible.

## License

MVA Hackathon 2026 — Track 1: Variant Prioritization © 2026 by Ayomide Ayodele-Soyebo is licensed under CC BY 4.0 ![CC BY 4.0][cc-by-shield]

Shield: [![CC BY 4.0][cc-by-shield]][cc-by]

This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg

Released under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), per the Hackathon's submission licensing requirements. See [LICENSE](LICENSE).
