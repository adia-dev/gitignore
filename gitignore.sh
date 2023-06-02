#!/bin/bash

# TODO: maybe add a -u or --update option to update the local list of languages/frameworks/libraries
# TODO: maybe use variables for the colors instead of hardcoding them eheheh...
# TODO: maybe add a -s or --silent option to hide the curl output and a verbose option to show more information
# TODO: maybe add a -f or --force option to force the overwriting of the template file (to overcome permission issues maybe idk eheheh...)
# FIXME: stop saying eheheh... people might think I'm a child or something eheheh...
# TODO: maybe add a -d or --debug option to show more information about the script execution
# TODO: I think there is some refactoring to do especially in the template part and the sorting/processing of the inputs
# TODO: The script works fine but still need more error handling and testing
# TODO: Maybe let the user choose the separator for the languages/frameworks/libraries (e.g. space, comma, semicolon, etc.)
# TODO: Using environment variables to set the default values for the options would be nice
# TODO: I would love to ping an API everytime the script is used to count the number of times it is used and the number of languages/frameworks/libraries used but I don't know if it's legal or not eheheh...
# TODO: Add a test suite to test the script, maybe make it available as a GitHub action, or even as a flag in the script itself eheheh...
# FIXME: column: line too long, maybe use a variable for the column width
# TODO: Add support to check if the script is up to date and if not, prompt the user to update it

# Define the script values
script_name="gitignore"
script_version="1.0"
script_description="A simple script to generate a .gitignore file for your project using the gitignore.io API."
script_author="adia-dev (on GitHub)"
script_website="https://github.com/adia-dev"
script_license="MIT License"
script_install_path="/usr/local/bin"

blue=$(tput setaf 4)
green=$(tput setaf 2)
red=$(tput setaf 1)
gray=$(tput setaf 8)
reset=$(tput sgr0)
error=1

# Feel free to edit the following values :)
gitignore_api_url="https://www.toptal.com/developers/gitignore/api"
gitignore_path="$TMPDIR.gitignore.io"
gitignore_man_path="./man.txt"
# gitignore_path="./.gitignore.io" # TODO: change this to the line above when the script is ready to be used
gitignore_template_path="$gitignore_path/templates"
gitignore_refresh_time=259200 # 3 days

# Define default values
output_file=".gitignore"
append=false  # if true, append to the existing gitignore file instead of overwriting it
languages=""  # comma-separated list of languages/frameworks/libraries
verbose=false # if true, show more information about the script execution

# Define default values for the template options
use_template=false
overrite_template=false
template_name="" # if no template name is specified, the default template will be used

function trim_spaces() {
  # Trim the spaces in the input string and remove possible empty values
  local str=$1
  str="$(echo "$str" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  str="$(echo "$str" | sed -e 's/,,/,/g')"
  str="$(echo "$str" | sed -e 's/,$//')"
  str="$(echo "$str" | sed -e 's/^,//')"
  echo "$str"
}

function make_unique() {
  # Make the list of values unique
  local str=$1
  str="$(echo "$str" | tr ',' '\n' | sort -u | tr '\n' ',')"
  str="$(echo "$str" | sed -e 's/,$//')"
  echo "$str"
}

function print_error() {
  # Print an error message in red
  echo "${red}$1${reset}"
}

function print_success() {
  # Print a success message in green
  echo "${green}$1${reset}"
}

function print_warning() {
  # Print a warning message in yellow
  echo "${gray}$1${reset}"
}

function print_info() {
  # Print an informational message in blue
  echo "${blue}$1${reset}"
}

function parse_arguments() {
  while [[ "$#" -gt 0 ]]; do
    case $1 in
    -o | --output)
      output_file="$2"
      shift
      ;;
    -a | --append)
      append=true
      generate
      ;;
    -h | --help)
      show_help
      return 1
      ;;
    -v | --version)
      show_version
      return 1
      ;;
    -l | --list)
      list_languages "$2"
      return 1
      ;;
    -t | --template)
      use_template=true
      template_name="$2"
      languages="$3"
      if [ "$4" = "-o" ] || [ "$4" = "--overwrite-template" ]; then
        overrite_template=true
      fi
      generate
      shift
      ;;
    -c | --clear-cache)
      clear_cache
      return 1
      ;;
    -i | --install)
      install_script
      return 1
      ;;
    -u | --uninstall)
      uninstall_script
      return 1
      ;;
    --reinstall)
      reinstall_script
      return 1
      ;;
    --verbose)
      verbose=true
      ;;
    *)
      collect_languages "$1"
      ;;
    esac
    shift
  done
}

function show_help() {
  cat $gitignore_man_path
}

function show_version() {
  echo "gitignore version 1.0"
}

function use_template() {
  echo "Use template"
}

function clear_cache() {
  echo "Clear cache"
}

function install_script() {
  echo "Install script"
}

function uninstall_script() {
  echo "Uninstall script"
}

function reinstall_script() {
  uninstall_script
  install_script
}

function collect_languages() {
  languages="$languages,$1"
}

function generate() {
  # trim the spaces in the languages and remove possible empty values
  languages="$(echo "$languages" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  languages="$(echo "$languages" | sed -e 's/,,/,/g')"
  languages="$(echo "$languages" | sed -e 's/,$//')"
  languages="$(echo "$languages" | sed -e 's/^,//')"
  # make the list of languages unique, need to refactor this eventually eheeeeeehee...
  languages="$(echo "$languages" | tr ',' '\n' | sort -u | tr '\n' ',')"
  languages="$(echo "$languages" | sed -e 's/,$//')"

  # check if the user want to use a custom template, if so, check if the template exists, if not, create it
  if [ "$use_template" = true ]; then
    if [ "$template_name" = "" ]; then
      template_name="default"
    fi
    if [ -f "$gitignore_template_path/$template_name" ] && [ "$overrite_template" = false ]; then
      print_info "Using the template \"$template_name\"..."
      languages="$(cat "$gitignore_template_path/$template_name")"
    elif [ "$overrite_template" = true ]; then
      print_warning "Overwriting the template \"$template_name\"..."
      echo "$languages" >"$gitignore_template_path/$template_name"
    else
      print_info "Creating the template \"$template_name\"..."
      mkdir -p "$gitignore_template_path"
      echo "$languages" >"$gitignore_template_path/$template_name"
    fi
  fi

  # if on verbose mode, print the gitignore file path
  if [ "$verbose" = true ]; then
    print_info "* The gitignore file will be saved at $output_file"
    echo ""
    print_info "* The list of languages/frameworks/libraries to be used is:"
    echo "$languages"
    echo ""
    print_info "* Looking for a local list of languages/frameworks/libraries at:"
    echo "$gitignore_path/available_gitignores"
    echo ""
  fi

  # fetch the list of available languages from the gitignore.io website or use the cached version if it exists and check if the last modified date is less than 3 days ago else refetch the list
  # verbose: print the content of the condition in a way human can understand
  if [ "$verbose" = true ]; then
    print_info "* Checking if the local list of languages/frameworks/libraries exists and is less than 3 days old..."
    echo "Path: $gitignore_path/available_gitignores"
    echo "Last modified: $(date -r "$gitignore_path/available_gitignores")"
    echo "Current date: $(date)"
    echo "Difference: $(($(date +%s) - $(date -r "$gitignore_path/available_gitignores" +%s)))s"
    echo ""
  fi

  if [ ! -f "$gitignore_path/available_gitignores" ] || [ $(($(date +%s) - $(date -r "$gitignore_path/available_gitignores" +%s))) -gt 259200 ]; then
    print_error "No local list of languages/frameworks/libraries found or the list is older than 3 days. Fetching the latest list..."
    # curl -sSL $gitignore_api_url/list >"$gitignore_path/available_gitignores"
    curl -sSL $gitignore_api_url/list >"$gitignore_path/available_gitignores"

    if [ $? -ne 0 ]; then

      print_error "An error occurred while fetching the list of languages/frameworks/libraries."
      print_error "It might be a temporary issue, please try again later."
      print_error "You can always create a github issue at $script_website/issues"
      echo ""
    fi
  else
    print_info "Using cached list of languages/frameworks/libraries..."
  fi

  list=$(cat "$gitignore_path/available_gitignores")

  # if verbose mode is enabled, print the list of languages/frameworks/libraries, truncated to 100 characters and add ...
  if [ "$verbose" = true ]; then
    print_info "* The list of languages/frameworks/libraries available is:"
    echo "${list:0:100}...(truncated)"
    echo ""
  fi

  # error handling
  if [ $? -ne 0 ]; then
    print_error "An error occurred while fetching the list of languages/frameworks/libraries."
    print_error "It might be a temporary issue, please try again later."
    print_error "You can always create a github issue at $script_website/issues"
    echo ""
  fi

  local to_exclude=""

  # Check if the provided languages are valid and print an error message if not
  if [[ "$languages" != "" ]]; then
    # Check if the list is not empty before checking the languages
    if [ "$list" = "" ]; then
      print_error "Could not fetch the list, thus we cannot affirm that the provided languages are valid." | sed -e 's/^/[90m/' -e 's/$/[0m/'
    else
      for language in $(echo "$languages" | sed "s/,/ /g"); do
        if [[ "$list" != *"$language"* ]]; then
          print_error "$language is not a valid language/framework/library. Please check the list of available languages/frameworks/libraries using the -h or --help option."
          # if to_exclude is empty, add the language to it, else add a comma and the language to it
          if [ "$to_exclude" = "" ]; then
            to_exclude="$language"
          else
            to_exclude="$to_exclude,$language"
          fi
        fi
      done
    fi
  fi

  content=""

  if [ "$use_template" = true ]; then
    # check if the template exists on the local machine
    # TODO: add a message to warn about possible missing permissions
    if [ -f "$gitignore_template_path/$template_name" ]; then
      # add the languages from the template to the list of languages, remove the first comma and trim the spaces, remove possible empty values, make sure the list is unique
      languages="$(echo "$languages,$(cat "$gitignore_template_path/$template_name")" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      languages="$(echo "$languages" | sed -e 's/,,/,/g')"
      languages="$(echo "$languages" | sed -e 's/^[,]*//' -e 's/[,]*$//')"
      languages="$(echo "$languages" | tr ',' '\n' | sort -u | tr '\n' ',')"

      # write back the languages to the template if overwrite is true
      # TODO: add a message to tell the user that the template has been updated
      if [ "$overrite_template" = true ]; then
        echo "$languages" >"$gitignore_template_path/$template_name"
      fi
    else
      print_error "The template \"$template_name\" does not exist."
      print_error "Please check that the template exists."
      print_error "If you are on a Windows machine you could use dir $gitignore_template_path to see the list of templates."
      print_error "If you are on a UNIX machine you could use ls -a $gitignore_template_path to see the list of templates."
    fi
  fi

  # Generate the gitignore file
  if [[ "$languages" == "" ]]; then
    print_info "Generating a default gitignore file..."
    content=$(curl -sSL $gitignore_api_url)
    if [[ "$verbose" == true ]]; then
      echo "Requested URL: $gitignore_api_url"
    fi
  else
    print_info "Generating a gitignore file for the following: $languages"
    if [[ "$verbose" == true ]]; then
      print_info "Requested URL: $gitignore_api_url/$languages"
    fi
    content=$(curl -sSL "$gitignore_api_url/$languages")
  fi

  # Echo an overview of the selected languages and if they are found in the gitignore file
  if [[ "$languages" != "" ]]; then
    echo ""
    print_info "Selected languages:"
    echo "-------------------"
    # echo the excluded languages in red
    print_error "$to_exclude"
    # echo the included languages in green (remove the excluded languages from the list of languages)
    if [[ "$to_exclude" != "" ]]; then
      print_success "$(echo "$languages" | sed "s/$to_exclude//g")"
    else
      print_success "$(echo "$languages")"
    fi
    echo ""
  fi

  # Append to the existing file if requested
  if [[ "$append" == true ]]; then
    print_info "Appending to the existing gitignore file..."
    echo "$content" >>"$output_file"
  else
    print_info "Writing to the gitignore file..."
    echo "$content" >"$output_file"
  fi
}

function gitignore() {
  # Welcome message if there is no argument
  if [ $# -eq 0 ]; then
    welcome_message
    return 1
  fi
  # check if the directory for the local list of languages/frameworks/libraries exists if not create it
  if [ ! -d "$gitignore_path" ]; then
    check_if_directory_exists
  fi

  parse_arguments "$@"


  # Parse arguments
  # while [[ "$#" -gt 0 ]]; do
  #   case $1 in
  #   -o | --output)
  #     output_file="$2"
  #     shift
  #     ;;
  #   -a | --append) append=true ;;
  #   -h | --help)
  #     cat $gitignore_man_path
  #     return 1
  #     ;;
  #   -v | --version)
  #     echo "gitignore version 1.0"
  #     return 1
  #     ;;
  #   -l | --list)
  #     list_languages "$2"
  #     return 1
  #     ;;
  #   -t | --template)
  #     use_template=true
  #     template_name="$2"
  #     languages="$3"
  #     if [ "$4" = "-o" ] || [ "$4" = "--overwrite-template" ]; then
  #       overrite_template=true
  #     fi
  #     shift
  #     ;;
  #   -c | --clear-cache)
  #     rm -rf "$gitignore_path/*"
  #     echo "The local list of languages/frameworks/libraries has been deleted."
  #     return 1
  #     ;;
  #   -i | --install)
  #     # check if the script is already installed
  #     if [ -f "$script_install_path/$script_name" ]; then
  #       echo "The script is already installed."
  #       return 1
  #     fi
  #     # check if the user is root
  #     if [ "$EUID" -ne 0 ]; then
  #       echo "Please run this script as root."
  #       return 1
  #     fi
  #     # check if the script is in the current directory
  #     if [ ! -f "$script_name" ]; then
  #       echo "The script is not in the current directory."
  #       return 1
  #     fi

  #     if [ ! -d "$script_install_path" ]; then
  #       mkdir -p "$script_install_path"
  #     fi

  #     # copy the script to the /usr/local/bin directory
  #     cp "$script_name" "$script_install_path/$script_name"
  #     # check if the script was copied successfully
  #     if [ $? -eq 0 ]; then
  #       echo "The script has been installed successfully at $script_install_path/$script_name"
  #       # make the script executable and hide it from the Finder, new cool trick I learned eheh
  #       chmod +x "$script_install_path/$script_name"
  #       chflags hidden "$script_install_path/$script_name"
  #       echo "You can now use the gitignore command from anywhere."
  #     else
  #       echo "An error occurred while installing the script."
  #       echo "Please try again later."
  #     fi

  #     #TODO: add support for other shells if needed
  #     # check if the user is using bash
  #     if [ -f "$HOME/.bashrc" ]; then
  #       echo "export PATH=\"\$PATH:$script_install_path\"" >>"$HOME/.bashrc"
  #     fi
  #     # check if the user is using zsh
  #     if [ -f "$HOME/.zshrc" ]; then
  #       echo "export PATH=\"\$PATH:$script_install_path\"" >>"$HOME/.zshrc"
  #     fi
  #     # check if the user is using fish
  #     if [ -f "$HOME/.config/fish/config.fish" ]; then
  #       echo "set PATH \$PATH $script_install_path" >>"$HOME/.config/fish/config.fish"
  #     fi
  #     # check if the user is using csh
  #     if [ -f "$HOME/.cshrc" ]; then
  #       echo "set path = ( \$path $script_install_path )" >>"$HOME/.cshrc"
  #     fi
  #     return 1
  #     ;;
  #   -u | --uninstall)
  #     # check if the script is installed
  #     if [ ! -f "$script_install_path/$script_name" ]; then
  #       echo "The script is not installed."
  #       return 1
  #     fi
  #     # check if the user is root
  #     if [ "$EUID" -ne 0 ]; then
  #       echo "Please run this script as root."
  #       return 1
  #     fi
  #     # remove the script from the /usr/local/bin directory
  #     rm -f "$script_install_path/$script_name"
  #     # check if the script was removed successfully
  #     if [ $? -eq 0 ]; then
  #       echo "The script has been uninstalled successfully."
  #     else
  #       echo "An error occurred while uninstalling the script."
  #       echo "Please try again later."
  #     fi

  #     return 1
  #     ;;
  #   --reinstall)
  #     # try running the uninstall script first and then the install script
  #     "$script_install_path/$script_name" --uninstall
  #     "$script_install_path/$script_name" --install
  #     return 1
  #     ;;
  #   --verbose)
  #     verbose=true
  #     ;;
  #   *)
  #     # Collect the languages
  #     languages="$languages,$1"
  #     ;;
  #   esac
  #   shift
  # done

}

function welcome_message() {
  echo "Welcome to the $script_name script!"
  echo "$script_description"
  echo "Author: $script_author"
  echo "Website: $script_website"
  echo "License: $script_license"
  echo ""
  echo "Usage: $script_name [options] [languages]"
  echo ""
  echo "You can find the list of available languages/frameworks/libraries at $gitignore_api_url/list"
  echo ""
}

function check_if_directory_exists() {
  echo "Warning: The directory for the local list of languages/frameworks/libraries does not exist."
  echo "We will create it now, you can delete it later if you want with the -c or --clear-cache option. :)"

  echo ""
  echo "RUNNING: mkdir -p \"$gitignore_path\""
  echo ""
  mkdir -p "$gitignore_path"
  if [ $? -ne 0 ]; then
    echo "Error: Could not create the directory for the local list of languages/frameworks/libraries."
    echo "This is probably due to a permission issue."
    return 1
  fi

  echo ""
  echo "Success: The directory for the local list of languages/frameworks/libraries has been created."
}

function list_languages() {
  local search_term="$1"

  # check the local list of languages/frameworks/libraries or fetch the latest list from the gitignore.io website
  if [[ ! -f "$gitignore_path/available_gitignores" || $(($(date +%s) - $(date -r "$gitignore_path/available_gitignores" +%s))) -gt "$gitignore_refresh_time" ]]; then
    echo -e "${gray}No local list of languages/frameworks/libraries found or the list is older than 3 days. Fetching the latest list...${reset}"
    # check if the directory for the local list of languages/frameworks/libraries exists if not create it
    if [[ ! -d "$gitignore_path" ]]; then
      echo -e "${gray}The directory for the local list of languages/frameworks/libraries does not exist.${reset}"
      echo -e "${gray}We will create it now, you can delete it later if you want with the -c or --clear-cache option. :).${reset}"
      mkdir -p "$gitignore_path" || {
        echo -e "${red}Error: Could not create the directory for the local list of languages/frameworks/libraries.${reset}"
        echo -e "${blue}This is probably due to a permission issue.${reset}"
        echo -e "${blue}Try running the script with as root or with sudo.${reset}"
        echo -e "${blue}If you don't want to use the local list of languages/frameworks/libraries, you can use the -c or --clear-cache option.${reset}"
        return $error
      }
    fi

    if ! curl -sSL $gitignore_api_url/list >"$gitignore_path/available_gitignores"; then
      echo -e "${red}An error occurred while fetching the list of languages/frameworks/libraries.${reset}"
      echo -e "${blue}It might be related to your internet connection or the gitignore.io website might be down.${reset}"
      echo -e "${blue}Or you could try running the script with as root or with sudo.${reset}"
      echo -e "${blue}Clear the local list of languages/frameworks/libraries with the -c or --clear-cache option first if you want to try again.${reset}"
      echo -e "${blue}Please try again later.${reset}"
      return $error
    fi
  else
    echo -e "${gray}Using the local list of languages/frameworks/libraries...${reset}"
  fi

  # if there is a search term, search the list of languages/frameworks/libraries
  if [[ "$search_term" != "" ]]; then
    echo -e "${green}Searching the list of languages/frameworks/libraries for \"$search_term\"...${reset}"
    echo ""

    local available_languages="$(cat "$gitignore_path/available_gitignores" | grep -i "$search_term" | sed -e 's/,/, /g' | sort)"
    if [[ "$available_languages" == "" ]]; then
      echo -e "${red}No languages/frameworks/libraries found for \"$search_term\".${reset}"
      echo -e "${blue}Try running the script without any arguments to see the list of available languages/frameworks/libraries.${reset}"
      return $error
    else
      echo -e "${blue}Available languages/frameworks/libraries for \"$search_term\":${reset}"
      # pretty print the list of languages/frameworks/libraries, separated by commas, print as a list of 4 columns sorted alphabetically
      local num_columns=4
      local num_lines=$((($(echo "$available_languages" | wc -l) - 1) / $num_columns + 1))
      local column_width=$(($(tput cols) / $num_columns))

      line=$(echo "$available_languages" | column -t -s, -c $column_width)

      # sed the line to add a blue color to the search term
      echo "$line" | sed -e "s/$search_term/${blue}$search_term${reset}/gi"

      if [ $? -ne 0 ]; then
        echo -e "${red}An error occurred while displaying the list of languages/frameworks/libraries.${reset}"
        echo -e "${blue}Please try again later.${reset}"
        return $error
      fi
    fi
  else
    # print the list of languages/frameworks/libraries and exit
    echo -e "${blue}Available languages/frameworks/libraries:${reset}"
    # pretty print the list of languages/frameworks/libraries, separated by commas, print as a list of 4 columns sorted alphabetically
    local available_languages="$(cat "$gitignore_path/available_gitignores" | sed -e 's/,/, /g' | sort)"
    local num_columns=4
    local num_lines=$((($(echo "$available_languages" | wc -l) - 1) / $num_columns + 1))
    local column_width=$(($(tput cols) / $num_columns))
    echo "$available_languages" | column -t -s, -c $column_width | pr -t -w $(tput cols) -l $num_lines
    if [ $? -ne 0 ]; then
      echo -e "${blue}An error occurred while displaying the list of languages/frameworks/libraries.${reset}"
      echo -e "${blue}Please try again later.${reset}"
      return $error
    fi
  fi
}

# call the function
gitignore "$@"
