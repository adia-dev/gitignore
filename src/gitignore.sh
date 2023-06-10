#!/bin/bash

# Load configuration files
source "../config/gitignore_config.conf"
source "../config/custom_config.conf"
source "utils.sh"

# Access configuration values
echo "Version: $VERSION"
echo "Author: $AUTHOR"
echo "Contact: $CONTACT_EMAIL"

# Variables
delimiter=${DELIMITER:-","}
force=false

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      handle_help
      exit 1
      ;;
    -d|--delimiter)
      handle_delimiter_option "$@"
      shift
      ;;
    -f|--force)
      force=true
      echo "$force"
      ;;
    ls|--list)
      handle_list_option "$CACHE_DIR" "$AVAILABLE_LIST_EXPIRATION_IN_DAYS" "$BASE_URL" "$force"
      exit 1
      ;;
    *)
      generate_gitignore_for_languages "$delimiter" "$BASE_URL" "$1"
      exit 1
      ;;
  esac
  shift
done
