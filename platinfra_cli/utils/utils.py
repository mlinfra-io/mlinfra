import os
import shutil
from .constants import TF_PATH


def clean_tf_directory():
    if os.path.isdir(TF_PATH):
        shutil.rmtree(TF_PATH)
