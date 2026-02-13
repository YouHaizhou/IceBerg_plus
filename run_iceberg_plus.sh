#!/usr/bin/env bash
######################################################################
# IceBerg_plus α–λ 联动实验脚本
# - 目标 α (ALPHA)   : 0.10
# - λ ramp-up 长度   : 100
# - lamda_schedule  : none / linear / cosine / exp / step / grid
######################################################################

set -e  # 任一命令出错即退出

# 实验配置
NET="Diff"
DATASET="Cora"
ALPHA="0.10"    # 目标 α
RAMPUP="100"    # lamda_rampup & alpha_rampup
RESULT_FILE="result/${NET}_${DATASET}_True.txt"

SCHED=${1:-cosine}   # 默认 cosine；传 grid 跑 5 种调度

run_one() {
  local schedule=$1
  echo "===== 运行: alpha=${ALPHA}, lamda_schedule=${schedule}, rampup=${RAMPUP} ====="

  python main.py \
    --net ${NET} --dataset ${DATASET} \
    --patience 500 --epochs 2000 \
    --loss_type bs --imb_ratio 10 \
    --T 20 --alpha ${ALPHA} \
    --alpha_schedule sync --alpha_min 0.0 --alpha_rampup ${RAMPUP} \
    --lr 0.1 --feat_dim 128 --no_feat_norm --weight_decay 0.005 \
    --lamda 1 --lamda_schedule ${schedule} --lamda_rampup ${RAMPUP}
}

if [ "$SCHED" = "grid" ]; then
  for sc in none linear cosine exp step; do
    run_one $sc
  done
else
  run_one $SCHED
fi