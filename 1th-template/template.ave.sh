#!/bin/bash

# BASH-Source folder selector
[ ${#PROMPT_COMMAND} -gt 0 ] && cfgDir="$(dirname $BASH_ARGV)" || cfgDir="$(dirname $0)"

# === CONFIGURATION ===
cfgActive=true
cfgFileConf="$cfgDir/settings.cfg"
cfgFileLog="$cfgDir/logfile.txt"
cfgFileLock="$cfgDir/$0.lock"
cfgDirLib="$cfgDir"
cfgKillSleep=5

# === HELP SECTION  ===
unset h
h[${#h[@]}]="This is help strings"
h[${#h[@]}]="for echo with -h arg"
h[${#h[@]}]=""
h[${#h[@]}]="Just add lines as you need"
h[${#h[@]}]="with h[\${#h[@]}]= prefix"
h[${#h[@]}]=""

# =====================

# Override config
if [ -r "$cfgFileConf" ]; then source "$cfgFileConf"; fi

# Inner variables
_test_message="TEST MESSAGE"

# Load libraries
for _file in "$cfgDirLib/*.shlib"; do
  if [ -s "$_file" ] && [ -r "$_file" ]; then source "$_file"; fi
done

# Functions
function showHelp() {
for (( i=0; $i<${#h[@]}; i++ )); do
echo -e ${h[$i]}
done
}

function log() {
local _logDate="$(date "+%Y-%m-%d %H:%M:%S") "
local _logLine="\n"; local _logStd=false; _logMsg=""
while true; do
  case "$1" in
    "-f"|"-file") shift; _logStd=true;;
    "-d"|"-date") shift; _logDate="";;
    "-n"|"-newline") shift; _logLine="";;
    *) if $_logStd
          then echo -ne "${_logDate}${*}${_logLine}"
	  else echo -ne "${_logDate}${*}${_logLine}" >>$cfgFileLog
       fi; break;;
  esac
done
}

function lock() {
  local _lockPid
  case "$1" in
    "l"|"lock") echo "$$" >"$cfgFileLock";;
    "e"|"exit") exit 0;;
    "u"|"unlock") rm -f "$cfgFileLock"; lock exit;;
    "f"|"tstfile") if [ -s "$cfgFileLock" ]; then echo true; else echo false; fi;;
    "p"|"tstproc")
      if [ -r "$cfgFileLock" ]; then
        _lockPid=$(cat "$cfgFileLock")
        if [ $(ps ax | grep -cE "^[ ]*$_lockPid[ ]+") -ge 1 ]
	  then echo true; else echo false
        fi
        else echo false
      fi
    ;;
    "k"|"kill")
      if [ $(lock tstfile) ] && [ $(lock tstproc) ]; then
        _lockPid=$(if [ -r "$cfgFileLock" ]; then cat "$cfgFileLock"; fi)
        kill $_lockPid
	sleep $cfgKillSleep
	[ $(lock tstproc) ] && kill -9 $_lockPid
	lock unlock
      fi
    ;;
    *) lock lock;;
  esac
}

# BASH-Source loader stopper
if [ ${#PROMPT_COMMAND} -gt 0 ];  then log -file "Functions loaded!"; return; fi

# Processing cli-arguments
while true; do
  case "$1" in
    "-h"|"--help") shift; showHelp; lock exit;;
    *) break;;
  esac
done

# Test for 2-nd instance
if $(lock tstproc); then log -file "Second instance detected"; lock exit; fi
if $(lock tstfile); then log -file "Previous launch was unsuccessful"; lock unlock; fi

# Create traps
trap 'break' SIGINT	# Pressed CTRL+C
trap 'break' SIGTSTP	# Pressed CTRL+Z
trap 'break' SIGHUP	# Hands-up
#trap '' SIGQUIT	# QUIT Signal
trap 'break' SIGTERM	# Request for exit
#trap '' EXIT		# Before exit
#trap '' USR		# User signal (1 or 2)

# === BEGIN ===
$cfgActive && lock

# === Dummy cycle =========================================
while true; do
  read -n1 -t1 -s
  if [ "$REPLY" == "q" ] || [ "$REPLY" == "Q" ]
    then break; else log -file $_test_message; fi
done
# === Dummy cycle =========================================

# === END ===
log -file "Shuting down in 1.5 sec"; sleep 1.5
$cfgActive && lock unlock || lock exit
