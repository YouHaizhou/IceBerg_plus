#!/usr/bin/env bash
set -e

# Alpha sweep on Cora (IR=10) for Diff backbone under IceBerg/IceBerg_plus setting.
# This script runs a fixed protocol while sweeping diffusion restart probability alpha.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

DATASET="Cora"
NET="Diff"
LOSS_TYPE="bs"
IMB_RATIO="10"
T="20"
LR="0.1"
FEAT_DIM="128"
WD="0.005"
EPOCHS="2000"
PATIENCE="500"
RUNS="10"

LAMDA="1"
LAMDA_SCHEDULE="none"
LAMDA_RAMPUP="50"

# Alpha grid (feel free to adjust)
ALPHAS=("0.01" "0.03" "0.05" "0.07" "0.10" "0.15" "0.20")

mkdir -p result
OUT_FILE="result/Diff_Cora_alpha_sweep_IR10_True.txt"

{
  echo "===== Alpha sweep (dataset=${DATASET}) ====="
  echo "IR=${IMB_RATIO} net=${NET} loss_type=${LOSS_TYPE} T=${T} lamda=${LAMDA} lamda_schedule=${LAMDA_SCHEDULE} lamda_rampup=${LAMDA_RAMPUP}"
  echo "lr=${LR} feat_dim=${FEAT_DIM} wd=${WD} dropout=0.5 epochs=${EPOCHS} patience=${PATIENCE} runs=${RUNS}"
  echo "alphas: ${ALPHAS[*]}"
  echo "timestamp: $(date)"
  echo "==========================================="
} | tee "$OUT_FILE"

for alpha in "${ALPHAS[@]}"; do
  echo "" | tee -a "$OUT_FILE"
  echo "===== Running alpha: ${alpha} =====" | tee -a "$OUT_FILE"

  python main.py \
    --net ${NET} --dataset ${DATASET} \
    --patience ${PATIENCE} --epochs ${EPOCHS} \
    --loss_type ${LOSS_TYPE} --imb_ratio ${IMB_RATIO} \
    --T ${T} --alpha ${alpha} \
    --lr ${LR} --feat_dim ${FEAT_DIM} --no_feat_norm --weight_decay ${WD} \
    --lamda ${LAMDA} --lamda_schedule ${LAMDA_SCHEDULE} --lamda_rampup ${LAMDA_RAMPUP} \
    --out_file "$OUT_FILE" \
    --runs ${RUNS}
done

echo "" | tee -a "$OUT_FILE"
echo "Done. Merged stdout: ${OUT_FILE}" | tee -a "$OUT_FILE"
