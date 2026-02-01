# BASE balancing method: BalancedSoftmax; Imbalance Ratio: 10
# patience 1000: 早停更快，若效果接近 2000 可长期使用；要更稳可改回 2000 或试 1200/1500
python main.py --net Diff --dataset Cora --patience 500 --epochs 2000 --loss_type bs --T 20 --alpha 0.1 --lr 0.1 --feat_dim 128 --no_feat_norm --weight_decay 0.005

python main.py --net Diff --dataset CiteSeer --patience 500 --epochs 2000 --loss_type bs --T 20 --alpha 0.1 --lr 0.1 --feat_dim 128 --no_feat_norm --weight_decay 0.005

python main.py --net Diff --dataset PubMed --patience 500 --epochs 2000 --loss_type bs --T 20 --alpha 0.1 --lr 0.05 --feat_dim 128 --no_feat_norm --weight_decay 0.005

python main.py --net Diff --dataset cs --patience 500 --epochs 2000 --loss_type bs --T 5 --alpha 0.1 --lr 0.01 --feat_dim 256 --no_feat_norm --weight_decay 0.005
