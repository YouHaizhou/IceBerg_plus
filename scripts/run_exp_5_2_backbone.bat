@echo off
REM 学习清单 5.2：换 backbone（Cora, BS, IR=10, DB）
cd /d "%~dp0.."

echo [1/4] GCN
python main.py --net GCN --dataset Cora --patience 500 --loss_type bs --imb_ratio 10

echo [2/4] GAT
python main.py --net GAT --dataset Cora --patience 500 --loss_type bs --imb_ratio 10

echo [3/4] SAGE
python main.py --net SAGE --dataset Cora --patience 500 --loss_type bs --imb_ratio 10

echo [4/4] Diff
python main.py --net Diff --dataset Cora --patience 500 --epochs 2000 --loss_type bs --imb_ratio 10 --T 20 --alpha 0.1 --lr 0.1 --feat_dim 128 --no_feat_norm --weight_decay 0.005

echo Done. See result/*_Cora_True.txt
pause
