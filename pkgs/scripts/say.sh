#!/usr/bin/env bash

# Function to display help
usage() {
    echo "Usage: $0 [-v voice] [-m model] [-i input_file] \"input_string\""
    exit 1
}

# Default values
voice="af_heart"
model="tts-1"
input_file=""
input_string=""

# Parse command-line options
while getopts 'v:m:i:h' flag; do
  case "${flag}" in
    v) voice="${OPTARG}" ;;
    m) model="${OPTARG}" ;;
    i) input_file="${OPTARG}" ;;
    h) usage ;;
    *) usage ;;
  esac
}

# Check for remaining arguments
if [ -z "$input_file" ]; then
    if [ $OPTIND -gt $# ]; then
        echo "Error: Missing input string"
        usage
    else
        input_string="${@:$OPTIND:1}"
    fi
else
  if [ -f "$input_file" ]; then
        input_string=$(<"$input_file")
  else
        echo "Error: Input file does not exist"
        exit 1
    fi
fi

# Prepare parameters for OpenAI API call
PARAM=$(jq -n -c --arg model "$model" --arg voice "$voice" --arg input "$input_string" '$ARGS.named')

curl -s "$OPENAI_API_BASE/v1/audio/speech" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PARAM" | mpv --no-terminal --force-window=no -
