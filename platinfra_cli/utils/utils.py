import os
import json
import shutil
from .constants import TF_PATH


def clean_tf_directory():
    if os.path.isdir(TF_PATH):
        shutil.rmtree(TF_PATH)


def generate_tf_json(module_name: str, json_module: json):
    with open(f"./{TF_PATH}/{module_name}.tf.json", "w", encoding="utf-8") as tf_json:
        json.dump(json_module, tf_json, ensure_ascii=False, indent=2)
