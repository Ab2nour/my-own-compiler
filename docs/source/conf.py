# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html
import os
import sys
from pathlib import Path

# add root folder to path
filepath = Path(__file__).resolve()
root_folder = str(filepath.parent.parent.parent)
src_folder = f"{root_folder}/src"
sys.path.append(root_folder)
sys.path.append(src_folder)
print(f"{sys.path = }")

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = "My Own Compiler"
copyright = "2023, Ab2nour"
author = "Ab2nour"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.viewcode",
    "sphinx.ext.napoleon",
    "myst_nb",
]


templates_path = ["_templates"]
exclude_patterns = []

# Autodoc options
autodoc_default_options = {"private-members": True}

# MyST NB options
nb_number_source_lines = True
os.environ["PYTHONPATH"] = root_folder  # MyST NB must have root folder in PYTHONPATH

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = "sphinx_book_theme"
html_static_path = ["_static"]
html_css_files = ["custom.css"]
