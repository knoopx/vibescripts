#!/usr/bin/env bash

# Show help if requested
if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    echo "Usage: $0 [FILE|-] [-- COMMAND...]"
    echo ""
    echo "Interactive search through file content using fzf."
    echo ""
    echo "Options:"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Arguments:"
    echo "  FILE                  File to search through (use '-' or omit for stdin)"
    echo "  -- COMMAND...         Command to run (default: egrep -i)"
    echo ""
    echo "Placeholders in COMMAND:"
    echo "  {input}               Input file path"
    echo "  {q}                   Current search query"
    echo ""
    echo "Examples:"
    echo "  $0 myfile.txt"
    echo "  echo 'hello world' | $0"
    echo "  echo 'hello world' | $0 -- egrep -i"
    echo "  $0 myfile.txt -- grep -n"
    echo "  $0 myfile.txt -- rg --color=always"
    exit 0
fi

# Parse arguments
input=""
command_args=()

# Find the -- separator
separator_index=-1
for i in "${!@}"; do
    if [[ ${!i} == "--" ]]; then
        separator_index=$i
        break
    fi
done

if [[ $separator_index -gt 0 ]]; then
    # File argument before --
    input=${!1}
    # Command arguments after --
    for ((i = separator_index + 1; i <= $#; i++)); do
        command_args+=("${!i}")
    done
elif [[ $separator_index -eq 1 ]]; then
    # No file argument, starts with --
    input=""
    # Command arguments after --
    for ((i = separator_index + 1; i <= $#; i++)); do
        command_args+=("${!i}")
    done
else
    # No -- separator
    if [[ $# -gt 0 ]]; then
        input=$1
    fi
fi

# Set default command if none provided
if [[ ${#command_args[@]} -eq 0 ]]; then
    command_args=("egrep" "-i")
fi

# Handle input
if [[ -z $input ]] || [[ $input == "-" ]]; then
    input=$(mktemp)
    trap 'rm -f "$input"' EXIT
    cat /dev/stdin >"$input"
fi

# Build command with placeholders
command_with_placeholders=""
for arg in "${command_args[@]}"; do
    if [[ $arg == *"{q}"* ]] || [[ $arg == *"{input}"* ]]; then
        command_with_placeholders+="$arg "
    else
        command_with_placeholders+="$arg "
    fi
done

# Add {q} and {input} if not present
if [[ $command_with_placeholders != *"{q}"* ]]; then
    command_with_placeholders+="{q} "
fi
if [[ $command_with_placeholders != *"{input}"* ]]; then
    command_with_placeholders+="{input}"
fi

# Replace placeholders in command
preview_command="${command_with_placeholders//\{input\}/$input}"

echo '' |
    fzf --ansi --disabled \
        --preview-window='up:99%' \
        --preview "$preview_command"
