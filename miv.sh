#!/bin/bash

directory=
file=
line=
action=
content=
end_f=
temp_file_name=

function show_help(){
    echo "Usage: miv [options]"
    echo "miv performs operations on text files."
    echo "Is mandatory to set the file using -f [name_of_file]"
    echo
    echo "Options:"
    echo "  -h, --help              Display this help message."
    echo "  -f, --file FILE         Specify the file on which operations will be performed."
    echo "  -l, --line LINE_NUMBER  Specify the line number for insertion, update, or deletion operations."
    echo "  -r, --read              Read the content of the specified file."
    echo "  -i, --insert TEXT       Insert new text at the specified line."
    echo "  -u, --update TEXT       Update the text at the specified line."
    echo "  -d, --delete            Delete the specified line."
    echo "  -e                      Make the changes at the end of the file"
    echo
    echo "Examples:"
    echo "  script_name -f file.txt -r"
    echo "  script_name -f file.txt -l 5 -i 'New text'"
    echo "  script_name -f file.txt -l 3 -u 'Updated text'"
    echo "  script_name -f file.txt -l 7 -d"
    echo "  script_name -f file.txt -e -i 'New text'"
    echo "  script_name -f file.txt -e -d"
    echo
    echo "For more details, consult the documentation."
}

function find_tmp(){
    local tmp_nmb=1
    local temp_file="mivtmp$tmp_nmb.txt"
    while true; do
        local temp_file="mivtmp$tmp_nmb.txt"
        if [[ ! -e "$directory/$temp_file" ]];then
            temp_file_name="$directory/$temp_file"
            break
        fi
        ((tmp_nmb++))
    done
}

function print_file(){
    local total_char_lines=$(echo $(wc -l < $file | wc -m))
    local counter=0
    while IFS= read -r line; do
        local spaces=$(echo $(($total_char_lines - $(echo $counter | wc -m))))
        new_line="$counter$(printf '%*s' "$spaces" '')| $line"
        echo $new_line >> $temp_file_name
        ((counter++))
    done < $file
    cat $temp_file_name
    if [[ ! $(tail -c1 $temp_file_name | wc -l) -gt 0 ]]; then
        echo
    fi
    rm $temp_file_name
}

function insert_line(){
    local counter=0
    while IFS= read -r line; do
        if [[ ! $1 -eq $counter ]];then
            echo $line >> $temp_file_name
        else
            echo $2 >> $temp_file_name
            echo $line >> $temp_file_name
        fi
        ((counter++))
    done < $file
    mv -f $temp_file_name $file
}

function update_line(){
    local counter=0
    while IFS= read -r line; do
        if [[ ! $1 -eq $counter ]];then
            echo $line >> $temp_file_name
        else
            echo $2 >> $temp_file_name
        fi
        ((counter++))
    done < $file
    mv -f $temp_file_name $file
}

function delete_line(){
    local counter=0
    while IFS= read -r line; do
        if [[ ! $1 -eq $counter ]];then
            echo $line >> $temp_file_name
        fi
        ((counter++))
    done < $file
    mv -f $temp_file_name $file
}

function set_env(){
    directory=$(pwd)
    # Organize the options to be analyzed
    options=$(getopt -o hf:l:i:ru:de -l help,file:,line:,insert,read,update,delete -- "$@")
    eval set -- "$options"
    # Analyze the options
    while true;do
        case "$1" in
            -h | --help)
                show_help
                exit 0
            ;;
            -f | --file)
                file="$directory/$2"
                shift 2
            ;;
            -l | --line)
                line=$2
                shift 2
            ;;
            -r | --read)
                action=0
                shift
            ;;
            -i | --insert)
                action=1
                content="$2"
                shift 2
            ;;
            -u | --update)
                action=2
                content="$2"
                shift 2
            ;;
            -d | --delete)
                action=3
                shift
            ;;
            -e)
                end_f=true
                shift
            ;;
            --)
                shift
                break
                ;;
            *)
                echo "$1 is not a valid option, use --help"
                exit 1
            ;;
        esac
    done
    find_tmp
    case "$action" in
        0)
            print_file
        ;;
        1)
            insert_line "$line" "$content"
            print_file
        ;;
        2)
            update_line "$line" "$content"
            print_file
        ;;
        3)
            delete_line "$line"
            print_file
        ;;
        *)
        ;;
    esac
}

function run_exec() {
    set_env "$@"
}

run_exec "$@"