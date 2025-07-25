# Vibescripts

A collection of utility scripts and Nix shell applications for automation, productivity, and system management.

## Overview

This repository contains a set of scripts and Nix expressions for various tasks, including audio processing, text-to-speech, markdown TODO management, and more. All scripts are packaged as Nix shell applications for easy installation and reproducibility.

## Directory Structure

- `pkgs/` — Nix expressions and script wrappers for each tool
- `pkgs/scripts/` — Source code for each script (Python, Bash, Node.js, etc.)
- `flake.nix` / `flake.lock` — Nix flake configuration for building and packaging

## Available Scripts

All scripts are available as Nix shell applications. Here is a summary:

| Name                  | Type    | Description                                                                          |
| --------------------- | ------- | ------------------------------------------------------------------------------------ |
| drum-practice         | Python  | Splits an input MP3 into stems using Demucs for drum practice.                       |
| importantize          | Node.js | PostCSS plugin that marks all CSS declarations as `!important`.                      |
| nixos-changelog       | Bash    | Compares NixOS generations and shows changelogs; supports an index argument.         |
| raise-or-open-url     | Bash    | Activates a browser tab with a given URL or opens it if not found.                   |
| repl                  | Bash    | Interactive search through file content using `fzf`, with flexible preview commands. |
| say                   | Bash    | Text-to-speech script with options for voice, model, speed, volume, and language.    |
| strip-python-comments | Python  | Removes docstrings and comments from Python code using AST.                          |
| todos                 | Bash    | Interactive TODO list manager for markdown checkboxes using `gum`.                   |

## Getting Started

To use these scripts, clone the repository and use Nix to build or run the desired tool. For example:

```sh
nix run .#drum-practice -- <args>
```

Or enter a development shell with all tools available:

```sh
nix develop
```

## Contributing

Contributions, bug reports, and suggestions are welcome! Please open an issue or submit a pull request.

---

For more details on each script, usage, and options, see the comments in the source files.
