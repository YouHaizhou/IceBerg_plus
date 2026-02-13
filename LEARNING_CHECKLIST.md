# IceBerg → IceBerg_plus 顺序学习清单

你已有深度学习基础和标准 GCN 知识，本清单按「先复现、再理解、后改进」的顺序，帮助你从零上手项目并实现 IceBerg_plus。

---

## 一、前置：巩固与项目直接相关的概念（可选速览）

| 序号 | 内容 | 说明 |
|------|------|------|
| 0.1 | **图节点分类** | 给定图 \(G=(V,E)\) 和节点特征，对节点做多分类；半监督设定下只有部分节点有标签。 |
| 0.2 | **类别不平衡** | 训练集中各类样本数差异大（如 head / tail），常用指标：BAcc、Macro F1；本项目用 `imb_ratio` 控制。 |
| 0.3 | **自训练（Self-Training）** | 用当前模型对无标签节点打伪标签，再把这些伪标签当“监督”参与训练，需注意伪标签噪声。 |
| 0.4 | **Balanced Softmax** | 在 softmax 里用类别先验（样本数）做偏置修正，缓解长尾；论文与 `losses/balanced_softmax.py` 对应。 |

若已熟悉 GCN 和上述概念，可直接从「二、环境与复现」开始。

---

## 二、环境与复现（先跑通再深挖）

| 序号 | 任务 | 操作与验证 |
|------|------|------------|
| 2.1 | **配环境** | 按 README：`python>=3.9`, `torch==2.4.0`, `torch-geometric==2.6.1`, `ogb==1.3.6`, `scikit-learn==1.5.2`。创建虚拟环境并安装。 |
| 2.2 | **准备数据** | 运行 `python scripts/download_planetoid.py CiteSeer PubMed`（必要时设代理）。确认 `data/` 下 Cora、CiteSeer、PubMed 等可正常加载。 |
| 2.3 | **复现 IceBerg（含伪标签）** | 执行 `bash run_iceberg.sh` 或单条命令，例如：<br>`python main.py --net Diff --dataset Cora --patience 500 --epochs 2000 --loss_type bs --T 20 --alpha 0.1 --lr 0.1 --feat_dim 128 --no_feat_norm --weight_decay 0.005`<br>确认：不报错、有 Test Acc/BAcc/F1 输出，且 **未** 使用 `--no_pseudo`。 |
| 2.4 | **对比：关闭伪标签** | 同上命令加上 `--no_pseudo`，观察 BAcc/F1 是否明显低于 2.3，体会「Double Balancing」的收益。 |
| 2.5 | **复现 baseline** | 运行 `bash run_baselines.sh`，理解项目里集成了哪些 baseline（如 TAM、BAT、ENS、SHA）。 |

**阶段目标**：环境无报错、能复现 IceBerg 与 baseline，并看到伪标签带来的提升。

---

## 三、代码结构：按数据流与训练流阅读

建议按「数据 → 模型 → 损失 → 训练循环」顺序读，便于和论文对应。

| 序号 | 文件/模块 | 重点理解 |
|------|-----------|----------|
| 3.1 | **`main.py`** | 入口：解析参数、加载数据、多 run 训练、写 `result/`；理解 `args` 从哪里来。→ 详见 [docs/03-1-main-py.md](docs/03-1-main-py.md) |
| 3.2 | **`args.py`** | 所有超参：`dataset`、`net`、`loss_type`、`no_pseudo`、`warmup`、`lamda`、以及各 baseline 的开关（`tam`、`bat`、`ens`、`sha`）等。→ 详见 [docs/03-2-args-py.md](docs/03-2-args-py.md) |
| 3.3 | **`data_utils.py`** | `get_dataset()` 各数据集分支；`split_semi_dataset()`、`get_idx_info()`；**类别不平衡**与**少样本**划分在 `trainer` 里如何被调用。→ 详见 [docs/03-3-data-utils.md](docs/03-3-data-utils.md) |
| 3.4 | **`trainer.py`**（核心） | ① `init_data_imb()` / `init_data_few()`：如何构造 `data_train_mask` 和类别分布；② `get_pred_label()`：伪标签与 `pseudo_mask`、置信度阈值；③ `train_epoch()`：有标签损失 + **Double Balancing**（无标签 + RobustBalancedSoftmax）；④ 与 baseline 的衔接（ENS/SHA/TAM/BAT）。→ 详见 [docs/03-4-trainer-py.md](docs/03-4-trainer-py.md) |
| 3.5 | **`nets/gcn.py`** | 标准 GCN 的封装（1/2/多层），`reg_params` 与 `non_reg_params` 用于不同 weight decay；其他 backbone：`gat.py`、`sage.py`、`diff.py` 可对比看。 |
| 3.6 | **`losses/`** | `ce.py`、`balanced_softmax.py`（有标签平衡）、`robust_balanced.py`（无标签 + RCE 的 Robust Balanced Softmax）、`renode.py`（拓扑重权）。→ 详见 [docs/03-6-losses.md](docs/03-6-losses.md) |
| 3.7 | **`utils.py`** | `get_confidence()`（伪标签置信度）、`feature_propagation()`（Diff 用的特征传播）、邻接归一化等。→ 详见 [docs/03-7-utils-py.md](docs/03-7-utils-py.md) |



---

## 四、论文与实现一一对应（加深理解）

| 序号 | 论文概念 | 在代码中的位置 |
|------|----------|----------------|
| 4.1 | 利用无标签节点、自训练 | `trainer.get_pred_label()` + `train_epoch()` 里对 `pseudo_mask` 的损失。 |
| 4.2 | 伪标签选择（置信度） | `get_confidence()` → 阈值取 `confidence[self.data_unlabel_mask].mean()`，得到 `pseudo_mask`。 |
| 4.3 | Double Balancing（DB） | 有标签：`criterion(...)`（ce/bs/rn）；无标签：`criterion_u(..., class_num_list_u) * lamda`，其中 `class_num_list_u` 由伪标签类分布统计。 |
| 4.4 | BASE 平衡方法 | `loss_type`: ce / rw / bs / rn；可选 TAM、BAT、ENS、SHA 等，见 `args` 与 `trainer` 分支。 |
| 4.5 | 评估指标 | Acc、BAcc、Macro F1；`trainer.test_epoch()` 与 `main.py` 中统计。 |

**阶段目标**：能对着论文把「方法框图」和「代码片段」对应起来。

---

## 五、做小实验（巩固与排查）

| 序号 | 实验 | 目的 |
|------|------|------|
| 5.1 | 换数据集 | 用 CiteSeer、PubMed、cs 等跑同一组参数，看不同 `imb_ratio` 下 BAcc/F1 变化。 |
| 5.2 | 换 backbone | `--net GCN` / `GAT` / `SAGE` / `Diff`，固定其他条件，比较收敛与指标。→ 运行 `bash scripts/run_exp_5_2_backbone.sh` 或见 [docs/exp-5-2-backbone.md](docs/exp-5-2-backbone.md) |
| 5.3 | 调关键超参 | `warmup`、`lamda`、`T`、`alpha`（Diff）等，观察对 BAcc 的影响，便于之后设计 IceBerg_plus。→ 运行 `bash scripts/run_exp_5_3_hyperparams.sh` 或见 [docs/exp-5-3-hyperparams.md](docs/exp-5-3-hyperparams.md) |
| 5.4 | 单 run 调试 | `--runs 1`，在 `get_pred_label()` 后打印 `pseudo_mask.sum()`、`class_num_list_u`，确认伪标签规模与分布合理。→ 已加打印逻辑（仅 runs=1 时），见 [docs/exp-5-4-debug.md](docs/exp-5-4-debug.md) |

**阶段目标**：熟悉实验流程和超参敏感性，为改进打基础。

---

## 六、从复现到 IceBerg_plus：改进方向建议

在完全复现并理解 IceBerg 后，可从以下方向选 1～2 个做 **IceBerg_plus**。**已实现**：① alpha=0.05 配置（5.3 最优）；② lamda 线性爬坡（`--lamda_schedule linear --lamda_rampup 50`）。→ 计划与用法见 [docs/ICEBERG_PLUS_PLAN.md](docs/ICEBERG_PLUS_PLAN.md)，运行 `bash run_iceberg_plus.sh`。

| 方向 | 思路（简述） | 可能涉及代码 |
|------|--------------|--------------|
| **伪标签质量** | 更稳的阈值或置信度校准（如温度缩放、基于验证集的阈值）；或只对高置信子集做 DB。 | `get_confidence()`、`get_pred_label()`、`train_epoch()` |
| **无标签损失形式** | 除 RobustBalancedSoftmax 外，尝试 Focal、一致性正则等，或对伪标签加权重（按置信度）。 | `losses/robust_balanced.py`、`criterion_u`、`train_epoch()` |
| **warmup 与调度** | 自适应 warmup、或随 epoch 调整 `lamda`（如先小后大）。→ **已实现** lamda 线性爬坡（args + trainer）。 | `args.py`、`train_epoch()` |
| **图结构利用** | 在伪标签选择时考虑邻居一致性（如多数投票）、或对边/传播步数做小改动。 | `utils.py`、`get_pred_label()`、`nets/diff.py` |
| **backbone 与传播** | 更深的 GCN、残差/跳跃连接、或改进 Diff 的传播（T/alpha 调度）。→ **已采用** alpha=0.05（5.3）。 | `nets/`、`get_prop_feature()` |
| **长尾与少样本** | 与现有 baseline（TAM、BAT、ENS、SHA）做更多组合或消融，或设计新的类别/拓扑平衡策略。 | `trainer.py`、`losses/`、`baselines/` |

**实施建议**：  
1. 先定一个具体改进点（如「伪标签阈值」或「lamda 调度」）。  
2. 在现有代码上做最小改动，保留 `--no_pseudo` 与原有配置，便于对比。  
3. 用相同 `dataset`、`imb_ratio`、`runs` 做公平对比，记录 BAcc、F1。

---

## 七、推荐学习顺序小结（时间线可压缩）

1. **第 1 天**：环境 + 数据 + 跑通 `run_iceberg.sh`，对比 `--no_pseudo`（二）。  
2. **第 2 天**：按 3.1→3.4→3.6 读代码，画出「数据→模型→损失→epoch」流程图（三）。  
3. **第 3 天**：对照论文把 DB、伪标签、BASE 方法在代码里标出来（四）；做 5.1–5.3 小实验（五）。  
4. **第 4 天及以后**：选定 IceBerg_plus 的一个方向，实现最小可行版本并做消融（六）。

按此顺序，你可以从「能跑」到「能讲」再到「能改」，最后自然过渡到 IceBerg_plus 的实现与实验。
