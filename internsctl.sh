#!/bin/bash

# Function to display the list of interns
list_interns() {
  echo "List of Interns:"
  echo "================"
  cat interns.txt
}

# Function to add a new intern
add_intern() {
  local name="$1"
  local role="$2"
  local start_date="$3"

  echo "$name | $role | $start_date" >> interns.txt
  echo "Intern added successfully:"
  echo "=========================="
  echo "Name: $name"
  echo "Role: $role"
  echo "Start Date: $start_date"
}

# Function to display help information
display_help() {
  # Use 'man' to display the manual page we created earlier
  man ./internsctl.1
}

# Function to display the version of internsctl
display_version() {
  echo "internsctl v0.1.0"
}

# Function to create a new user
create_user() {
  local username="$1"
  # Add the user and set the password interactively
  sudo adduser "$username"
}

# Function to list all regular users or users with sudo permissions
list_users() {
  local sudo_only="$1"
  local users_list

  if [ "$sudo_only" == "--sudo-only" ]; then
    # List users with sudo permissions
    users_list=$(getent group sudo | cut -d: -f4)
  else
    # List all regular users
    users_list=$(getent passwd | cut -d: -f1)
  fi

  echo "List of Users:"
  echo "=============="
  echo "$users_list"
}

# Function to get file information and contents
get_file_info() {
  local file="$1"
  local show_content=true
  local show_permissions=false
  local show_owner=false
  local size_option=false
  local last_modified_option=false

  # Check if the file exists
  if [ ! -f "$file" ]; then
    echo "Error: File not found: $file"
    exit 1
  fi

  # Process options
  while [[ "$#" -gt 1 ]]; do
    case $2 in
      --size | -s)
        size_option=true
        show_content=false
        ;;
      --owner | -o)
        show_owner=true
        show_content=false
        ;;
      --last-modified | -m)
        last_modified_option=true
        show_content=false
        ;;
      --permissions | -p)
        show_permissions=true
        show_content=false
        ;;
      *)
        echo "Error: Invalid option: $2"
        exit 1
        ;;
    esac
    shift
  done

  # Display file contents by default
  if [ "$show_content" = true ]; then
    echo "File: $file"
    echo "File Content:"
    echo "============="
    cat "$file"
    echo
  fi

  # Display file owner when using the --owner option
  if [ "$show_owner" = true ]; then
    echo "File Owner:"
    echo "==========="
     ls -l "$file" | awk '{print $3}'
    echo
  fi

  # Display file permissions when using the --permissions option
  if [ "$show_permissions" = true ]; then
    echo "File Permissions:"
    echo "================="
    ls -l "$file" | awk '{print $1}'
    echo
  fi

  # Display file information when options are provided
  if [ "$size_option" = true ]; then
    echo "Size(B): $(stat -c "%s" "$file")"
  fi
  if [ "$last_modified_option" = true ]; then
    echo "Modify: $(stat -c "%y" "$file")"
  fi
}

get_memory_info() {
  echo "Memory Information:"
  echo "==================="
  free -h
}

get_cpu_info() {
  echo "CPU Information:"
  echo "================"
  lscpu
}

# Main script
main() {
  local action="$1"
  shift

  case "$action" in
    "--help")
      display_help
      ;;
    "--version")
      display_version
      ;;
    "list")
      list_interns
      ;;
    "add")
      local name="$1"
      local role="$2"
      local start_date="$3"
      add_intern "$name" "$role" "$start_date"
      ;;
    "cpu")
      local cpu_action="$1"
      case "$cpu_action" in
        "getinfo")
          get_cpu_info
          ;;
        *)
          echo "Error: Invalid CPU action. Usage: internsctl cpu [getinfo]"
          exit 1
          ;;
      esac
      ;;
    "memory")
      local memory_action="$1"
      case "$memory_action" in
        "getinfo")
          get_memory_info
          ;;
        *)
          echo "Error: Invalid memory action. Usage: internsctl memory [getinfo]"
          exit 1
          ;;
      esac
      ;;
    "user")
      local user_action="$1"
      shift
      case "$user_action" in
        "create")
          create_user "$1"
          ;;
        "list")
          list_users "$1"
          ;;
        *)
          echo "Error: Invalid user action. Usage: internsctl user [create|list]"
          exit 1
          ;;
      esac
      ;;
    "file")
      local file_action="$1"
      shift
      case "$file_action" in
        "getinfo")
          get_file_info "$@"
          ;;
        *)
          echo "Error: Invalid file action. Usage: internsctl file [getinfo]"
          exit 1
          ;;
      esac
      ;;
    "")
      # No action provided, show usage message
      echo "Usage: internsctl [list|add|cpu|memory|user|file]"
      exit 1
      ;;
    *)
      echo "Error: Invalid command. Usage: internsctl [list|add|cpu|memory|user|file]"
       exit 1
      ;;
  esac
}

main "$@"
