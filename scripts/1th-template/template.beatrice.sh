#!/bin/bash

# BASH-Source folder selector
[ ${#LINES} -gt 0 ] && cfgDir="$(pwd)" || cfgDir="$(dirname $0)"

# =============================== WORK HEADER ===============================
# Configuration
cfgActive=false						# Flag for "danger" functions
cfgFileConf="$cfgDir/settings.cfg"			# Override config file
cfgFileLog="$cfgDir/logfile.txt"			# Log-file for log() function
cfgFileLock="$cfgDir/$(basename $0).lock"		# Lock-file for run control
cfgDirLib="$cfgDir/lib"					# Librarys path
cfgSecondSig=false					# Use USR2 instead of USR1 for timer

# Help message
unset h
h+=("This is help strings")
h+=("for echo with -h arg")
h+=("")
h+=("Just add lines as you need")
h+=("with h+=(\"STRING\") syntax")
h+=("")
# ============================= END WORK HEADER =============================

# Override config
if [ -r "$cfgFileConf" ]; then source "$cfgFileConf"; fi

# Load libraries
for _file in "$(ls "$cfgDirLib" --color=never --file-type --hide-control-chars --escape -1)"
  do if [ -s "${cfgDirLib}/${_file}" ] && [ -r "${cfgDirLib}/${_file}" ]
    then source "${cfgDirLib}/${_file}"; fi; done

# === Framework functions ===
# Just show array on stdout
function showHelp() {
  for (( i=0; $i<${#h[@]}; i++ )); do log -file -date "${h[$i]}"; done
}

# Log to file
_logFile=$cfgFileLog					# Filename for write logs
_logPrefix=""						# Log-prefix
function log() {
if [ "$1" == "-c" ] || [ "$1" == "-clear" ]; then echo -n "" >$_logFile; return; fi
local _logDate="$(date "+%Y-%m-%d %H:%M:%S") "
local _logLine="\n"; local _logStd=false; _logMsg=""
local _logTPrefix="${_logPrefix} "
while true; do
  case "$1" in
    "-f"|"-file") shift; _logStd=true;;
    "-d"|"-date") shift; _logDate="";;
    "-n"|"-newline") shift; _logLine="";;
    "-p"|"-prefix") shift; _logTPrefix="";;
    *) if $_logStd
          then echo -ne "${_logDate}${_logTPrefix}${*}${_logLine}"
          else echo -ne "${_logDate}${_logTPrefix}${*}${_logLine}" >>$_logFile
       fi; break;;
  esac
done
}

# Lock-file controller
_lockKillSleep=5					# Sleep before 'kill -9' (sec)
_lockFile="$cfgFileLock"				# Lock-file name
function lock() {
  local _lockPid
  case "$1" in
    "l"|"lock") echo "$$" >"$_lockFile";;
    "u"|"unlock") rm -f "$_lockFile"; lock exit;;
    "e"|"exit") [ ${#LINES} -gt 0 ] && return || exit;;
    "f"|"tstfile") if [ -s "$_lockFile" ]; then echo true; else echo false; fi;;
    "p"|"tstproc")
      if [ -r "$_lockFile" ]; then
        _lockPid=$(cat -- "$_lockFile")
        if [ $(ps ax | grep -cE "^[ ]*$_lockPid[ ]+") -ge 1 ]
          then echo true; else echo false
        fi
        else echo false
      fi
    ;;
    "k"|"kill")
      if [ $(lock tstfile) ] && [ $(lock tstproc) ]; then
        _lockPid=$(if [ -r "$_lockFile" ]; then cat "$_lockFile"; fi)
        kill $_lockPid
        sleep $_lockKillSleep
        [ $(lock tstproc) ] && kill -9 $_lockPid
        lock unlock
      fi
    ;;
    *) lock lock;;
  esac
}

# Async timer
_timerSleep=1						# Send signal interval (sec)
_timerSig=$(${cfgSecondSig} && echo 2 || echo 1)	# SIGUSR1 or SIGUSR2 select
_timerPid=0
function timer() {
case $1 in
  "on")
    if [ "$*" != "" ]; then
      if [ 0$_timerPid -eq 0 ]; then shift
        eval trap '$*' USR${_timerSig}
        timer _thread $$ &
        _timerPid=$!
      fi
    fi
  ;;
  "off") if [ 0$_timerPid -gt 0 ]; then kill -9 $_timerPid; fi;;
  "_thread")
    if [[ $2 =~ ^[0-9]+ ]]; then
      while [ $(ps ax | grep -cE "[ ]*$2[ ]+") -ge 1 ]; do
        kill -SIGUSR${_timerSig} $2; sleep $_timerSleep
      done
    fi
  ;;
esac  
}

# ============================== USER FUNCTIONS =============================
function testFunction() {
  log -file "$testMessage"
}
# ============================ END USER FUNCTION=============================

# BASH-Source loader stopper
if [ ${#LINES} -gt 0 ]; then log -file "Functions loaded!"; return; fi

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
trap 'testRun=false' SIGINT				# Pressed CTRL+C
trap 'testRun=false' SIGTSTP				# Pressed CTRL+Z
trap 'testRun=false' SIGHUP				# Hands-up
#trap '' SIGQUIT					# QUIT Signal
trap 'testRun=false' SIGTERM				# Request for exit
#trap '' EXIT						# Before exit

$cfgActive && lock
# ================================ WORK BODY ================================
$cfgActive && testMessage="Run in active mode" || testMessage="Run in debug mode"
testRun=true
timer on testFunction
while $testRun; do
  read -n1 -t1 -s
  if [ "$REPLY" == "q" ] || [ "$REPLY" == "Q" ]
    then timer off; testRun=false
    else sleep 0.25
  fi
done
log -file "Shuting down in 1.5 sec"; sleep 1.5
# ============================== END WORK BODY ==============================
$cfgActive && lock unlock || lock exit