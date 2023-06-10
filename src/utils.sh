#!/bin/bash

# Usage message
usage() {
  echo "Usage: script.sh [options] <languages>"
  echo "Options:"
  echo "  -h, --help           Show help"
  echo "  -d, --delimiter      Specify delimiter character"
  echo "  -f, --force          Force cache update"
  echo "  ls, --list           List available languages"
}

# Help message
handle_help() {
  usage
  echo "Additional help information..."
}

# Handle delimiter option
handle_delimiter_option() {
  local delimiter=$2
  if [[ -z $delimiter || ! $delimiter =~ ^.$ ]]; then
    echo "Error: The -d|--delimiter option requires a single character argument enclosed in quotes."
    exit 1
  fi
  echo "Delimiter: $delimiter"
}

# Handle list option
handle_list_option() {
  local cache_dir=$1
  local expiration_days=$2
  local base_url=$3
  local force=$4

  local file_path="$cache_dir/available_languages.txt"
  local cache_miss=false

  if [ -e "$file_path" ]; then
    # Check the system type and use the appropriate format specifier
    # Calculate the expiration timestamp
    if [[ $(uname) == "Darwin" ]]; then
      local file_timestamp=$(stat -f "%m" "$file_path")
      local expiration_timestamp=$(date -v -"$expiration_days"d +%s)
      echo "expiration: $(date -r "$expiration_timestamp")"
      echo "creation: $(date -r "$file_timestamp")"
    else
      local expiration_timestamp=$(date -d "$expiration_days days ago" +%s)
      local file_timestamp=$(stat -c "%Y" "$file_path")
    fi

    # Compare file timestamp with expiration timestamp
    if [ "$file_timestamp" -lt "$expiration_timestamp" ]; then
        echo "The file is older than $expiration_days days."
        cache_miss=true
    else
        echo "Using the cached list of available languages"
        local available_languages=$(cat "$file_path")
      fi
    else
      cache_miss=true
    fi

    if [[ "$cache_miss" = true || "$force" = true ]]; then
      local available_languages=$(curl -s "$base_url/list")

      echo "Attempt to cache the list of available languages..."

      mkdir -p "$cache_dir/"
      if [[ $? -ne 0 ]]; then
        echo "Error: Could not create the CACHE_DIR: $cache_dir."
        exit 1
      else
        echo "$available_languages" > "$file_path"
        echo "Successfully created a cache version of the available languages at:"
      fi
    fi

    echo "$available_languages"
}

# Generate .gitignore for languages
generate_gitignore_for_languages() {
  local delimiter=$1
  local base_url=$2
  local languages=$3

  languages=$(echo "$languages" | sed "s/ //g" | sed "s/$delimiter/\\n/g" | sort | uniq)
  local comma_separated=$(echo "$languages" | paste -sd "," -)

  echo ""
  echo "Generating .gitignore for: $comma_separated..."
  echo ""

  if [[ -n "$comma_separated" && ${#comma_separated} -gt 1 ]]; then
    local output=$(curl -s "$base_url/$comma_separated")
    echo "$output" > .gitignore
  fi
}

