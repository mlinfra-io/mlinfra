from pathlib import Path


def absolute_project_root() -> Path:
    """
    Returns the absolute path to the project root.
    """
    return Path(__file__).absolute().parent


def relative_project_root() -> Path:
    """
    Returns the relative path to the project root.
    """
    return Path(__file__).relative_to(Path(__file__).parent.parent).parent
