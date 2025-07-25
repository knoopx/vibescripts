#!/usr/bin/env bash

# Step 1: Gather TODOs from files
todos="$(grep -Einr "\- \[(x|\s)\]" "$1")"

# Step 2: Build choices and selected arrays
choices_arr=()
selected_arr=()
while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    todo=$(echo "$line" | cut -d: -f3- | sed -E 's/^\s*- \[[x ]\]\s*//')
    option="${todo}|||${file}:${lineno}"
    choices_arr+=("$option")
    if echo "$line" | grep -q '\[x\]'; then
        selected_arr+=("$todo")
    fi
done <<<"$todos"
choices=$(printf "%s\n" "${choices_arr[@]}")
selected=$(
    IFS=,
    echo "${selected_arr[*]}"
)

# Step 3: Present choices to user and capture selection
chosen=$(echo "$choices" | gum choose --no-limit --header "TODOs" --label-delimiter="|||" --selected="$selected" --selected-prefix="☑ " --unselected-prefix="☐ " --cursor-prefix="☐ ")

# Step 4: Build mappings of TODOs and their states
declare -A todo_map
declare -A state_map
while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    todo=$(echo "$line" | cut -d: -f3- | sed -E 's/^\s*- \[[x ]\]\s*//')
    key="${file}:${lineno}"
    todo_map["$key"]="$todo"
    if echo "$line" | grep -q '\[x\]'; then
        state_map["$key"]=1
    else
        state_map["$key"]=0
    fi
done <<<"$todos"

# Step 5: Build a set of selected TODOs from user selection
declare -A new_state_map
if [[ -n "$chosen" ]]; then
    # Initialize all todos as unselected
    for key in "${!todo_map[@]}"; do
        new_state_map["$key"]=0
    done

    # Mark selected todos as checked
    while IFS= read -r chosen_line; do
        if [[ -n "$chosen_line" ]]; then
            # Extract todo text (before |||) and file:line info (after |||)
            # todo_text was unused and removed to fix ShellCheck SC2034
            file_line=$(echo "$chosen_line" | cut -d'|' -f4)
            # Use the file:line as the key directly
            if [[ -n "$file_line" ]]; then
                new_state_map["$file_line"]=1
            fi
        fi
    done <<<"$chosen"
else
    # If nothing chosen, mark all as unselected
    for key in "${!todo_map[@]}"; do
        new_state_map["$key"]=0
    done
fi

# Step 6: Update the checkbox at the exact file and line number using sed
for key in "${!todo_map[@]}"; do
    file="$(echo "$key" | cut -d: -f1)"
    lineno="$(echo "$key" | cut -d: -f2)"
    orig_state="${state_map["$key"]}"
    new_state="${new_state_map["$key"]}"

    if [[ "$orig_state" != "$new_state" ]]; then
        printf "Updating %s:%s from %d to %d\n" "$file" "$lineno" "$orig_state" "$new_state"
        if [[ "$new_state" == "1" ]]; then
            # Mark as checked
            sed -i "${lineno}s/- \[[x ]\]/- [ ]/" "$file"
        else
            # Mark as unchecked
            sed -i "${lineno}s/- \[[x ]\]/- [ ]/" "$file"
        fi
    fi
done
