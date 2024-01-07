from pathlib import Path


# PROJECT_ROOT = Path(__file__).absolute().parent
def absolute_project_root() -> Path:
    return Path(__file__).absolute().parent


def relative_project_root() -> Path:
    return Path(__file__).relative_to(Path(__file__).parent.parent).parent


PROJECT_ROOT = Path(__file__).relative_to(Path(__file__).parent.parent).parent
