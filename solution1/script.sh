#!/bin/bash
user_agent=""
display_methods=false

display_usage() {
    echo "Usage: $0 [--user-agent <value>] [--method] [-h]"
    echo "Options:"
    echo "  --user-agent <value>    Allows restricting parsing of logs only to provided user agent."
    echo "  --method                Prints in output number of request per method/address instead of just per address."
    echo "  -h                      Display this help message"
}

show_output_with_methods(){
    printf "%-20s %-10s %5s\n" "ADDRESS" "METHOD" "REQUESTS"
    for ip in "${!ip_count[@]}"; do
        printf "%-34s %5s\n" "$ip" "${ip_count[$ip]}"
    done
}

show_output_without_methods(){
    printf "%-20s %5s\n" "ADDRESS" "REQUESTS"
    for ip in "${!ip_count[@]}"; do
        printf "%-20s %5s\n" "$ip" "${ip_count[$ip]}"
    done
}

show_output(){
    if ${display_methods} ; then
        show_output_with_methods
    else
        show_output_without_methods
    fi
}



parse_options() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --user-agent)
                user_agent="$2"
                shift
                ;;
            --method)
                display_methods=true
                ;;
            -h|--help)
                display_usage
                exit 0
                ;;
            *)
                echo "Invalid option: $1" >&2
                display_usage >&2
                exit 1
                ;;
        esac
        shift
    done
}

check_file(){
    if [ ! -f "logs.tar.bz2" ]; then
    echo "file 'logs.tar.bz2' not found"
    exit 1
fi
}


parse_options "$@"

check_file

tar -xf logs.tar.bz2


declare -A ip_count

ip_pattern='(?<=client_ip:\s")([0-9]{1,3}\.){3}[0-9]{1,3}'
method_pattern='(?<=method: ")[^"]+'

for log_file in $(find logs -name "*.log"); do
    while IFS= read -r log; do
        if [ -n "$log" ]; then            
            if [ -z "$user_agent" ] || grep -q "$user_agent" <<< "$log" ; then
                ip_address=$(grep -oP "$ip_pattern" <<< "$log")
                if $display_methods ; then
                    request_method=$(grep -oP "$method_pattern" <<< "$log")
                    ((ip_count["$(printf '%-20s' "$ip_address") $request_method"]++))
                else 
                    ((ip_count["$ip_address"]++)) 
                fi
            fi
        fi
    done < "$log_file"
done


show_output

rm -rf logs

