# shell_exec Makro for Klipper

This is a basic Klipper extension that allows you to run shell code within Klipper Macros (probably not the best idea).
I made it so I can make my Anycubic Kobra S1 with [Rinkhals](https://github.com/jbatonnet/Rinkhals) 🎶 *beep* 🎶 using `M300` gcode.

## Installation on Anycubic printers with Rinkhals

For now, push the files of this repo to `/useremain/home/rinkhals/apps/shell_exec` using SSH, SFTP or e.g. ADB:
```
adb push app.sh /useremain/home/rinkhals/apps/shell_exec
adb push app.json /useremain/home/rinkhals/apps/shell_exec
adb push shell_exec.sh /useremain/home/rinkhals/apps/shell_exec
adb shell chmod +x /useremain/home/rinkhals/apps/shell_exec/shell_exec.sh
```
Afterwards enable "shell_exec" in the rinkhals interface.

See https://github.com/jbatonnet/Rinkhals.apps/ for details on how to run and deploy apps. I will provide an `update.swu` later.

## Installation on other Klipper based printers

Just somehow run `shell_exec.sh` on the device running Klipper. Make sure to also change the Klipper Unix Domain Socket within `shell_exec.sh` if you Klipper installation is not running on the default `/tmp/unix_uds1`.

## Usage
Use the `action_call_remote_method("shell_exec",cmd)` method in your `printer.cfg` to execute shell commands within your printer macros. The following examples are writte for GoKlipper on Anycubic printers.
On a printer with rinkhals, consider putting this into `/useremain/home/rinkhals/printer_data/config/printer.custom.cfg` (see [here](https://jbatonnet.github.io/Rinkhals/Rinkhals/printer-configuration/))

```
[gcode_macro BEEP_ON]
gcode:
    {% set cmd = "echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable" %}
    {{action_call_remote_method("shell_exec", cmd)}}

[gcode_macro BEEP_OFF]
gcode:
    {% set cmd = "echo 0 > /sys/class/pwm/pwmchip0/pwm0/enable" %}
    {{action_call_remote_method("shell_exec", cmd)}}

[gcode_macro BEEP]
gcode:
    BEEP_ON
    BEEP_OFF

[gcode_macro M300]
gcode:
    BEEP_ON
    G4 P{params.P}
    BEEP_OFF
```
For some reason the `G4 P{params.P}` is not working as pause inside the macro - so `M300` is still kinda broken. It's not because of the parameter, even `G4 P2000` won't cause a pause inside the macro. It works in gcode though 🤔