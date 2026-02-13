#!/bin/bash
# 学习清单 5.3：调关键超参（Diff + Cora + BS + DB），单变量对比
# 基线：T=20, alpha=0.1, warmup=0, lamda=1

BASE="python main.py --net Diff --dataset Cora --patience 500 --epochs 2000 --loss_type bs --imb_ratio 10 --lr 0.1 --feat_dim 128 --no_feat_norm --weight_decay 0.005"

echo "=== 5.3 超参对比 (Diff, Cora, BS, DB) ==="

echo "[0] 基线 T=20 alpha=0.1 warmup=0 lamda=1"
$BASE --T 20 --alpha 0.1

echo "[1] warmup=50"
$BASE --T 20 --alpha 0.1 --warmup 50

echo "[2] warmup=100"
$BASE --T 20 --alpha 0.1 --warmup 100

echo "[3] lamda=0.5"
$BASE --T 20 --alpha 0.1 --lamda 0.5

echo "[4] lamda=1.5"
$BASE --T 20 --alpha 0.1 --lamda 1.5

echo "[5] T=10"
$BASE --T 10 --alpha 0.1

echo "[6] T=30"
$BASE --T 30 --alpha 0.1

echo "[7] alpha=0.05"
$BASE --T 20 --alpha 0.05

echo "[8] alpha=0.15"
$BASE --T 20 --alpha 0.15

echo "=== 结果见 result/Diff_Cora_True.txt（按运行顺序对应）；记录到 docs/exp-5-3-hyperparams.md 表 4 ==="
