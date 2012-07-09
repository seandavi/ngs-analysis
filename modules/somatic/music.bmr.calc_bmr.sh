#!/bin/bash

genome music bmr calc-bmr                              \
  --roi-file=sureselect.bed                            \
  --reference-sequence=ref.fa                          \
  --bam-list=bamlist.txt                               \
  --output-dir=output                                  \
  --maf-file=?                                         \
  --skip-non-coding                                    \
  --skip-silent
