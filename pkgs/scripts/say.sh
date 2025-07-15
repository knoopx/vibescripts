#!/usr/bin/env bash
#
# To use this script, you must set the OPENAI_API_KEY environment variable.
#
# For fish shell users, run:
#   set -Ux OPENAI_API_KEY "your-api-key-here"
#
# For bash/zsh users, run:
#   export OPENAI_API_KEY="your-api-key-here"

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

# Default OPENAI_API_KEY to empty string if not set
OPENAI_API_KEY="${OPENAI_API_KEY:-}"

# Parse command-line options
while getopts 'v:m:i:h' flag; do
	case "${flag}" in
	v) voice="${OPTARG}" ;;
	m) model="${OPTARG}" ;;
	i) input_file="${OPTARG}" ;;
	h) usage ;;
	*) usage ;;
	esac
done

# Check for remaining arguments
if [ -z "$input_file" ]; then
	if [ $OPTIND -gt $# ]; then
		echo "Error: Missing input string"
		usage
	else
		input_string="${*:$OPTIND}"
	fi
else
	if [ -f "$input_file" ]; then
		input_string=$(<"$input_file")
	else
		echo "Error: Input file does not exist"
		exit 1
	fi
fi

curl -s "$OPENAI_API_BASE/v1/audio/speech"
# Prepare parameters for OpenAI API call
PARAM=$(jq -n -c --arg model "$model" --arg voice "$voice" --arg input "$input_string" '$ARGS.named')

# Build curl arguments
CURL_ARGS=("-s" "$OPENAI_API_BASE/v1/audio/speech" "-H" "Content-Type: application/json" "-d" "$PARAM")
if [ -n "$OPENAI_API_KEY" ]; then
	CURL_ARGS+=("-H" "Authorization: Bearer $OPENAI_API_KEY")
fi

curl "${CURL_ARGS[@]}" | mpv --no-terminal --force-window=no -
