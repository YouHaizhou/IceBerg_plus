#!/bin/bash
# 学习清单 5.2：换 backbone，固定其他条件，比较收敛与指标
# 固定：dataset=Cora, loss_type=bs, imb_ratio=10, 开 DB（不加 --no_pseudo）, patience=500, runs=10
# 变量：--net GCN | GAT | SAGE | Diff（Diff 需额外 T/alpha/lr/feat_dim 等，与 run_iceberg 一致）

echo "=== 5.2 Backbone 对比 (Cora, BS, IR=10, DB) ==="

echo "[1/4] GCN"
python main.py --net GCN --dataset Cora --patience 500 --loss_type bs --imb_ratio 10

echo "[2/4] GAT"
python main.py --net GAT --dataset Cora --patience 500 --loss_type bs --imb_ratio 10

echo "[3/4] SAGE"
python main.py --net SAGE --dataset Cora --patience 500 --loss_type bs --imb_ratio 10

echo "[4/4] Diff"
python main.py --net Diff --dataset Cora --patience 500 --epochs 2000 --loss_type bs --imb_ratio 10 --T 20 --alpha 0.1 --lr 0.1 --feat_dim 128 --no_feat_norm --weight_decay 0.005

echo "=== 结果写在 result/：<Net>_Cora_True.txt，比较 Test BAcc、F1 ==="
