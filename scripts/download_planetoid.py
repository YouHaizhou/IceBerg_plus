#!/usr/bin/env python3
"""
下载 Planetoid 原始数据（CiteSeer / PubMed），用于网络无法直接访问 GitHub 时。
用法：
  python scripts/download_planetoid.py CiteSeer PubMed
  # 使用代理（如可用）：
  set HTTPS_PROXY=http://127.0.0.1:7890
  python scripts/download_planetoid.py CiteSeer PubMed
"""
import os
import sys
import urllib.request
import urllib.error
import ssl

# Planetoid 需要的 8 个 raw 文件名（不含 ind.xxx. 前缀的后缀）
RAW_SUFFIXES = ['x', 'tx', 'allx', 'y', 'ty', 'ally', 'graph', 'test.index']
BASE_URL = "https://github.com/kimiyoung/planetoid/raw/master/data/"


def get_project_root():
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def download_file(url, save_path, timeout=60):
    """带重试的下载，支持代理（从环境变量 HTTP_PROXY/HTTPS_PROXY 读取）。"""
    proxy = os.environ.get('HTTPS_PROXY') or os.environ.get('https_proxy') or os.environ.get('HTTP_PROXY') or os.environ.get('http_proxy')
    if proxy:
        proxy_handler = urllib.request.ProxyHandler({'http': proxy, 'https': proxy})
        opener = urllib.request.build_opener(proxy_handler, urllib.request.HTTPSHandler(context=ssl.create_default_context()))
        urllib.request.install_opener(opener)
    for attempt in range(3):
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                data = resp.read()
            with open(save_path, 'wb') as f:
                f.write(data)
            return True
        except (urllib.error.URLError, OSError) as e:
            print(f"  尝试 {attempt + 1}/3 失败: {e}")
    return False


def download_planetoid(name):
    """下载单个数据集（CiteSeer 或 PubMed）的 8 个 raw 文件到 data/<Name>/<Name>/raw/。"""
    root = get_project_root()
    raw_dir = os.path.join(root, 'data', name, name, 'raw')
    os.makedirs(raw_dir, exist_ok=True)
    prefix = f"ind.{name.lower()}."
    all_ok = True
    for suf in RAW_SUFFIXES:
        fname = prefix + suf
        path = os.path.join(raw_dir, fname)
        if os.path.isfile(path):
            print(f"  已有: {fname}")
            continue
        url = BASE_URL + fname
        print(f"  下载: {fname} ...")
        if not download_file(url, path):
            print(f"  失败: {fname}")
            all_ok = False
    return all_ok


def main():
    names = [a for a in sys.argv[1:] if a in ('CiteSeer', 'PubMed', 'Cora')]
    if not names:
        print("用法: python scripts/download_planetoid.py CiteSeer PubMed")
        print("  可选: 设置环境变量 HTTPS_PROXY 或 HTTP_PROXY 使用代理")
        sys.exit(1)
    ok_all = True
    for name in names:
        print(f"[{name}]")
        ok = download_planetoid(name)
        ok_all = ok_all and ok
        print(f"  -> {'完成' if ok else '存在失败，请检查网络或代理'}\n")
    sys.exit(0 if ok_all else 1)


if __name__ == '__main__':
    main()
