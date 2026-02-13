"""
在项目根目录运行: python scripts/check_load_citeseer_pubmed.py
用于检查 CiteSeer、PubMed 是否能被 Planetoid 正常加载（含首次 process）。
若报错，把完整报错贴出来便于排查。
"""
import os
import sys
import os.path as osp

# 保证能 import 项目模块
root = osp.dirname(osp.dirname(osp.abspath(__file__)))
sys.path.insert(0, root)
os.chdir(root)

from data_utils import get_dataset

def check(name):
    path = osp.join(root, 'data', name)
    print(f"Loading {name} from {path} ...")
    try:
        dataset = get_dataset(name, path, split_type='public', no_feat_norm=False)
        data = dataset[0]
        print(f"  {name}: OK  nodes={data.x.shape[0]}, edges={data.edge_index.shape[1]}, classes={data.y.max().item()+1}")
        return True
    except Exception as e:
        print(f"  {name}: FAIL  {e}")
        return False

if __name__ == '__main__':
    ok_c = check('CiteSeer')
    ok_p = check('PubMed')
    if ok_c and ok_p:
        print("CiteSeer and PubMed load OK. You can run run_iceberg.sh.")
    else:
        print("Fix the error above, then re-run run_iceberg.sh.")
