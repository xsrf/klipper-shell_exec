#!/bin/bash

# Connect to Klipper Unix Socket
SOCKET="/tmp/unix_uds1"
coproc KLIPPY {
    socat - "UNIX-CONNECT:$SOCKET"
}

# Register remote method
json='{"method":"register_remote_method","params": {"remote_method":"shell_exec","response_template": {"action": "shell_exec"}},"id":1}'$'\x03'
echo -ne "$json" >&"${KLIPPY[1]}"

# {"action":"shell_exec","params":"echo 1 \u003e /sys/class/pwm/pwmchip0/pwm0/enable"}
# {"action":"shell_exec","params":{"M":"1338","P":"77","S":"1"}}
# Read the Socket
while IFS= read -r -d $'\x03' json <&"${KLIPPY[0]}"; do
    echo "JSON: $json" >> /tmp/shell_exec.log
    echo "Received raw JSON: $json"
    cmd=$(echo "$json" | jq -r '.params|strings')
    if [[ -n "$cmd" ]]; then
        # Parameter was just a String, execute it!
        cmd=$(echo "$json" | jq -r '.params|strings')
        echo "EXEC: $cmd" >> /tmp/shell_exec.log
        echo "Received CMD: $cmd"
        output=$(bash -c "$cmd" 2>&1)
        echo "Result: $output"
    fi
    cmd=$(echo "$json" | jq -r '.params?.M?|strings')
    if [[ -n "$cmd" ]]; then
        # Parameter was an Object containing Mxxx codes, execute Mxxx.sh!
        script="/useremain/home/shell_exec_scripts/M${cmd}.sh"
        script_usb="/mnt/udisk/shell_exec_scripts/M${cmd}.sh"
        [[ -f "$script_usb" ]] && script="$script_usb"
        if [[ -f $script ]]; then
            echo "Executing Script ${script}!"
            echo "EXEC: $script" >> /tmp/shell_exec.log
            chmod +x $script
            output=$(bash "${script}" "$json" 2>&1)
            echo "Result: $output"
        else
            echo "Script ${script} not found!"
        fi
    fi
done