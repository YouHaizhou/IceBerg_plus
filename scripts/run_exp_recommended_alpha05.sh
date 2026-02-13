#!/usr/bin/env bash
set -e

# IceBerg_plus 推荐配置批量实验脚本
# 推荐配置（来自 docs/alpha_lambda_schedule.md）：
# - net=Diff
# - alpha=0.05
# - lamda=1
# - lamda_schedule=none
# - 其它保持 Diff 常用设置

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

NET="Diff"
ALPHA="0.05"
LAMDA="1"
LAMDA_SCHEDULE="none"
LOSS_TYPE="bs"
IMB_RATIO="10"
T="20"
LR="0.1"
FEAT_DIM="128"
WD="0.005"
EPOCHS="2000"
PATIENCE="500"
RUNS="10"

# 根据 data/ 目录下实际存在的数据集（目录名需与 --dataset 参数一致）
DATASETS=("Cora" "CiteSeer" "PubMed" "cs")

# 统一汇总 stdout 到一个文件（不修改 main.py）。
# main.py 仍会各自写 result/Diff_<DATASET>_True.txt；这个文件只是额外的汇总日志。
OUT_FILE="result/Diff_Cora_True_plus.txt"
mkdir -p result

echo "===== IceBerg_plus recommended config batch run ====="
echo "net=$NET alpha=$ALPHA lamda=$LAMDA lamda_schedule=$LAMDA_SCHEDULE loss_type=$LOSS_TYPE IR=$IMB_RATIO T=$T"
echo "datasets: ${DATASETS[*]}"
echo "==============================================="

for dataset in "${DATASETS[@]}"; do
  echo "" | tee -a "$OUT_FILE"
  echo "===== Running dataset: ${dataset} =====" | tee -a "$OUT_FILE"

  python main.py \
    --net ${NET} --dataset ${dataset} \
    --patience ${PATIENCE} --epochs ${EPOCHS} \
    --loss_type ${LOSS_TYPE} --imb_ratio ${IMB_RATIO} \
    --T ${T} --alpha ${ALPHA} \
    --lr ${LR} --feat_dim ${FEAT_DIM} --no_feat_norm --weight_decay ${WD} \
    --lamda ${LAMDA} --lamda_schedule ${LAMDA_SCHEDULE} \
    --out_file "$OUT_FILE" \
    --runs ${RUNS}
done

echo "" | tee -a "$OUT_FILE"
echo "Done. Per-dataset logs: result/${NET}_<DATASET>_True.txt ; merged stdout: ${OUT_FILE}" | tee -a "$OUT_FILE"
