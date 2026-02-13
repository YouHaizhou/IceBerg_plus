#!/usr/bin/env bash
set -e

echo "=== IceBerg default: alpha=0.1 across datasets (Diff, BS, IR=10, DB/self-training) ==="

# 统一参数（除 dataset 外一致）
BASE_ARGS="--net Diff --patience 500 --epochs 2000 \
           --loss_type bs --imb_ratio 10 --T 20 --alpha 0.1 \
           --lr 0.1 --feat_dim 128 --no_feat_norm --weight_decay 0.005 \
           --lamda 1 --lamda_schedule none --lamda_rampup 50 \
           --runs 10 \
           --out_file result/Diff_Cora_True_plus.txt"

DATASETS=(Cora CiteSeer PubMed cs)

for ds in "${DATASETS[@]}"; do
  echo "===== Running dataset: ${ds} (alpha=0.1) ====="
  python main.py --dataset "${ds}" ${BASE_ARGS}
done

echo "=== Done. Per-dataset files: result/Diff_<DATASET>_True.txt ; merged file: result/Diff_Cora_True_plus.txt ==="