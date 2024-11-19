#!/bin/bash

# Default options for asciidoctor
DEFAULT_OPTIONS=(
	-r asciidoctor-diagram
	-a revealjs_theme=white
	-a revealjs_history=true
	-a revealjs_fragmentInURL=true
	-a experimental
	-a stem
	-a icons=font
	-a data-uri
	-a allow-uri-read
	-a stylesdir="$HOME/.local/src/simple-asciidoctor-template/stylesheets"
	-a stylesheet="simple.css"
	-a source-highlighter="pygments"
	-a source-highlighter="trac"
	-a customcss="https://cdn.rawgit.com/majamin/simple-asciidoctor-template/refs/heads/master/stylesheets/simple-reveal.css"
	-a revealjs_theme="white"
	-a revealjs_history="true"
	-a revealjs_fragmentInURL="true"
)

REVEALJS_DIR="https://cdn.jsdelivr.net/npm/reveal.js@5.1.0"

# Build a single file with optional output directory and postfix
build_with_mode() {
	local file="$1"
	local mode="$2"
	local output_dir="$3"
	local postfix="$4"
	local options=("${@:5}")

	# Determine output file
	local base_name="${file%.adoc}"
	local output_file="${output_dir}/${base_name##*/}${postfix}.html"

	case "$mode" in
	normal)
		asciidoctor "${options[@]}" -o "$output_file" "$file"
		;;
	handout)
		asciidoctor "${options[@]}" -a handout -o "$output_file" "$file"
		;;
	revealjs)
		asciidoctor-revealjs "${options[@]}" -a revealjsdir="$REVEALJS_DIR" -o "$output_file" "$file"
		;;
	*)
		echo "Unknown build mode: $mode"
		exit 1
		;;
	esac
}

# Process a directory of files
process_directory() {
	local src_dir="$1"
	local build_dir="$2"
	local mode="$3"
	local postfix="$4"
	local options=("${@:5}")

	find "$src_dir" -name "*.adoc" | while read -r file; do
		local relative_path="${file#"$src_dir"/}"
		local output_dir="${build_dir}/$(dirname "$relative_path")"
		mkdir -p "$output_dir"
		build_with_mode "$file" "$mode" "$output_dir" "$postfix" "${options[@]}"
	done
}

# Main script logic
if [[ $# -lt 1 ]]; then
	echo "Usage: $0 [--handout|--reveal] <path> [options]"
	echo "Modes:"
	echo "  --handout   Build with -a handout and -handout postfix"
	echo "  --reveal    Build a reveal.js presentation with -reveal postfix"
	echo "  (default)   Standard build"
	echo "Path can be a single file or a directory"
	exit 1
fi

# Parse mode switches
MODE="normal"
POSTFIX=""
OPTIONS=("${DEFAULT_OPTIONS[@]}")

if [[ "$1" == "--handout" ]]; then
	MODE="handout"
	POSTFIX="-handout"
	shift
elif [[ "$1" == "--reveal" ]]; then
	MODE="revealjs"
	POSTFIX="-reveal"
	shift
fi

# Determine input path
PATH_INPUT="$1"
shift
OPTIONS+=("$@")

if [[ -f "$PATH_INPUT" ]]; then
	# Single file build
	build_with_mode "$PATH_INPUT" "$MODE" "$(dirname "$PATH_INPUT")" "$POSTFIX" "${OPTIONS[@]}"
elif [[ -d "$PATH_INPUT" ]]; then
	# Directory build
	BUILD_DIR="build"
	process_directory "$PATH_INPUT" "$BUILD_DIR" "$MODE" "$POSTFIX" "${OPTIONS[@]}"
else
	echo "Error: Invalid path: $PATH_INPUT"
	exit 1
fi
