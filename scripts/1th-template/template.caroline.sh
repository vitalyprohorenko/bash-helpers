#!/bin/bash

# BASH-Source folder selector
[ ${#LINES} -gt 0 ] && cfgDir="$(pwd)" || cfgDir="$(dirname $0)"

# =============================== WORK HEADER ===============================
# Configuration
cfgActive=false						# Flag for "danger" functions
cfgFileConf="$cfgDir/settings.cfg"			# Override config file
cfgFileLog="$cfgDir/logfile.txt"			# Log-file for log() function
cfgFileLock="$cfgDir/$(basename $0).lock"		# Lock-file for run control
cfgDirLib="$cfgDir"					# Librarys path
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
for _file in $(find "$cfgDirLib" -regex ".*\.shlib" -type f -print); do
  _fileN="$(basename ${_file})"
  if [ -n "${_file}" ]; then _fileN="${_fileN}"; echo -n "[${_fileN}]	"
    if [ -s "${_file}" ] && [ -r "${_file}" ]
      then echo "Loading"; . "${_file}"; echo "[${_fileN}]	Loaded"
      else echo "Error"
    fi
  fi; unset _fileN
done

# === Framework functions ===
# Just show array on stdout
function showHelp() {
  for (( i=0; $i<${#h[@]}; i++ )); do log -out stdout -date "${h[$i]}"; done
}

# Log to file
_logFile=$cfgFileLog					# Filename for write logs
_logPrefix=" "						# Default log-prefix
_logDefault=file					# Default log-patch
function log() {
local _logMsg=""; local _logLine="\n"
local _logDate="$(date "+%Y-%m-%d %H:%M:%S")"
local _logStd="$_logDefault"
local _logOFilter='^(f|file|s|stdout)$'
local _logTPrefix="$_logPrefix"

if [ "$1" == "-c" ] || [ "$1" == "-clear" ]; then if $_logStd
  then clear; return
  else echo -n "" >$_logFile; return
fi;fi

while true; do
  case "$1" in
    "-d"|"-date") _logDate=""; shift;;
    "-n"|"-newline") _logLine=""; shift;;
    "-p"|"-prefix") _logTPrefix="$2"; shift 2;;
    "-o"|"-out")
      if [[ "$2" =~ $_logOFilter ]]
        then shift 2; _logStd="$2"
        else shift; _logStd="stdout"
      fi
    ;;
    *)
      case $_logStd in
        "f"|"file") echo -ne "${_logDate}${_logTPrefix}${*}${_logLine}" >>$_logFile;;
        "s"|"stdout"|*) echo -ne "${_logDate}${_logTPrefix}${*}${_logLine}";;
      esac
      break
    ;;
  esac
done
}

#*UPDATE
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

#*UPDATE
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
  log -out "$testMessage"
}
# ============================ END USER FUNCTION=============================

# BASH-Source loader stopper
if [ ${#LINES} -gt 0 ]; then log -out "Functions loaded!"; return; fi

# Processing cli-arguments
while true; do
  case "$1" in
    "-h"|"--help") shift; showHelp; lock exit;;
    *) break;;
  esac
done

# Test for 2-nd instance
if $(lock tstproc); then log -out "Second instance detected"; lock exit; fi
if $(lock tstfile); then log -out "Previous launch was unsuccessful"; lock unlock; fi

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
log -out "Shuting down in 1.5 sec"; sleep 1.5
# ============================== END WORK BODY ==============================
$cfgActive && lock unlock || lock exit