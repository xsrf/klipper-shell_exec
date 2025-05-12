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
# Read the Socket
while IFS= read -r -d $'\x03' json <&"${KLIPPY[0]}"; do
    echo "Received raw JSON: $json"
    cmd=$(echo "$json" | jq -r '.params|strings')
    if [[ -n "$cmd" ]]; then
        echo "$cmd" >> /tmp/shell_exec.log
        echo "Received CMD: $cmd"
        output=$(bash -c "$cmd" 2>&1)
    fi
done