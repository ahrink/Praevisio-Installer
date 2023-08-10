#!/bin/sh

B_size=40
BC_RT2N="#"
BC_todo="-"
P_scale=2
iT=37
cT=""
bN="x: "

show_progress() {
    local current="$1"
    local total="$2"

    local percent=$(echo "scale=$P_scale; 100 * $current / $total" | bc)
    local RT2N=$(echo "scale=0; $B_size * $percent / 100" | bc)
    local todo=$(echo "scale=0; $B_size - $RT2N" | bc)

    # build the RT2N and todo sub-Bs
    local RT2N_sub_B=$(printf "%${RT2N}s" | tr " " "${BC_RT2N}")
    local todo_sub_B=$(printf "%${todo}s" | tr " " "${BC_todo}")

    # output the B
    printf "%b \r" "\r$bN[${RT2N_sub_B}${todo_sub_B}] ${percent}%";

    if [ "$total" -eq "$current" ]; then
        printf "%b \n" "\nDONE\n"
    fi
}

# SIM part
clear
for cT in $(seq "$iT"); do
    #simulate the task running
    sleep 0.1
    show_progress "$cT" "$iT"
done

