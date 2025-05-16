# shell_exec macro for Klipper

This is a basic Klipper extension that allows you to run shell code within Klipper macros and even gcode (probably not the best idea).
I made it so I can make my Anycubic Kobra S1 🎶 *beep* 🎶 using `M300` gcode, which is not supported by default.
While this may work on any Klipper based printer, it is designed for Anycubic printers running [Rinkhals](https://github.com/jbatonnet/Rinkhals), like the Anycubic Kobra S1.

> [!CAUTION]
> This is not for beginners! Executing arbitrary code on your printer may result in damaged firmware!

## Installation on Anycubic printers with Rinkhals

### Via *.swu

- download the *.swu file for your printer from [Releases](https://github.com/xsrf/klipper-shell_exec/releases)
- rename it to `update.swu` and place it on a USB stick into the folder `aGVscF9zb3Nf`
- plug the USB stick into your powered printer - it will beep when it sees the install and beep again when it finished installing
- enable "shell_exec" in the Rinhals menu on your printer (Settings - General - Rinkhals)
- don't forget to rename/remove the `update.swu` again

### Manually

For now, push `/apps/shell_exec/*` to `/useremain/home/rinkhals/apps/shell_exec/*` using SSH, SCP or e.g. ADB:
```
adb push apps/shell_exec /useremain/home/rinkhals/apps
adb shell chmod +x /useremain/home/rinkhals/apps/shell_exec/app.sh
```
Afterwards enable "shell_exec" in the rinkhals interface.

See https://github.com/jbatonnet/Rinkhals.apps/ for details on how to run and deploy apps.

## Installation on other Klipper based printers

Just somehow run `shell_exec.sh` on the device running Klipper. Make sure to also change the Klipper Unix Domain Socket within `shell_exec.sh` if you Klipper installation is not running on the default `/tmp/unix_uds1`.

## Usage

Use the `action_call_remote_method("shell_exec",cmd)` method in your `printer.cfg` to execute shell commands within your printer macros. 
`cmd` can either be a string or an object. If it is a string, it's directly executed as shell command.
If it's an object, it's assumed the `params` object was passed, which contains the parsed gcode. It will then look for a `Mxxx.sh` script either in `shell_exec_scripts` on your USB stick or in `/useremain/home/shell_exec_scripts` with the corresponding M-code filename. e.g. `M300` will execute `M300.sh` and pass all the parameters to the script in the first argument.
The following examples are written for GoKlipper on Anycubic printers.
On a printer with rinkhals, consider putting this into `/useremain/home/rinkhals/printer_data/config/printer.custom.cfg` (see [here](https://jbatonnet.github.io/Rinkhals/Rinkhals/printer-configuration/)) or in `printer.custom.cfg` on the USB stick.

### Execute command from macro
```
[gcode_macro BEEP_ON]
description: Beeper ON
gcode:
    {% set cmd = "echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable" %}
    {{action_call_remote_method("shell_exec", cmd)}}

[gcode_macro BEEP_OFF]
description: Beeper OFF
gcode:
    {% set cmd = "echo 0 > /sys/class/pwm/pwmchip0/pwm0/enable" %}
    {{action_call_remote_method("shell_exec", cmd)}}
```
### Execute command via gcode (really not recommended!)
```
[gcode_macro M1337]
description: Execute shell command, e.g. M1337 echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable
gcode:
    {{action_call_remote_method("shell_exec", rawparams)}}
```
### Execute code specific script
```
[gcode_macro M300]
description: Beep! S:Frequency[Hz] P:Duration[ms] e.g. M300 S1000 P200
gcode:
    {{action_call_remote_method("shell_exec", params)}}
```
This will look for `M300.sh` on the USB stick in `shell_exec_scripts` or `/useremain/home/shell_exec_scripts` and execute it, also passing all the parameters.

`{{action_call_remote_method("shell_exec", "echo 42")}}` causes a syntax error, the 2nd argumant must always be a variable. That's why `cmd` is used above. `params` and `rawparams` are predefined variables set by klipper.

You may refer to the provided `printer.custom.cfg` and `M300.sh` for further examples.

# Debugging

All received actions and executed commands are logged to `/tmp/shell_exec.log`. Errors may show up in GoKlippers log in `/tmp/gklib.log`.
With ADB installed and connected (`adb connect $IP`), view live via `adb shell tail -f /tmp/shell_exec.log -f /tmp/gklib.log`.