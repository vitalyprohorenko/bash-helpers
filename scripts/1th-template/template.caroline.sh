#!/bin/bash
# =============================== WORK HEADER ===============================
# Configuration
cfgDir="$PWD"
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
_logDefault=file					# Default log-patch
function log() {
local _logMsg=""; local _logLine="\n"
local _logDate="$(date "+%Y-%m-%d %H:%M:%S") "
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
    "-p"|"-prefix") _logTPrefix="$2 "; shift 2;;
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
${cfgActive} && _timerCallback=false || _timerCallback='log -o -p [TIMER] '
# Inner vars
_timerPid=0; unset _timerPExec; unset _timerPTimer; unset _timerPCount
declare -A _timerPExec; declare -A _timerPTimer; declare -A _timerPCount
function timer() {
case $1 in
  "bind")
    if ! [[ "$2" =~ ^[_a-zA-Z0-9-]+$ ]]
      then $_timerCallback "Bad id for bind"; return; fi
    if ! [[ "$3" =~ ^[0-9]+$ ]]
      then $_timerCallback "Bad timing for bind"; return; fi
    if ! [[ "$4" =~ ^[_a-zA-Z0-9-]+$ ]]
      then $_timerCallback "Bad function for bind"; return; fi
    $_timerCallback "Binding [$2/$3sec] $4"
    _timerPTimer[$2]="$3"; _timerPExec[$2]="$4"
  ;;
  "clear")
    if [[ "$2" =~ ^[_a-zA-Z0-9-]+$ ]]; then
      $_timerCallback "Unset $2"
      unset _timerPExec[$2]; unset _timerPCount[$2]; unset _timerPTimer[$2]
    else
      $_timerCallback "Unset all"
      _timerPExec=(); _timerPCount=(); _timerPTimer=()
    fi
  ;;
  "on")
    if [ 0$_timerPid -eq 0 ]; then shift
      $_timerCallback "Timer is ON"
      trap 'timer _worker' USR${_timerSig}
      timer _thread $$ &
      _timerPid=$!
    fi
  ;;
  "off")
    if [ 0$_timerPid -gt 0 ]; then
      $_timerCallback "Timer is OFF"
      kill $_timerPid >/dev/null 2>/dev/null
      trap - USR${_timerSig}
      _timerPid=0
    fi
  ;;
  "_worker")
    for current in ${!_timerPExec[*]}; do
      (( _timerPCount[$current]+=1 ))
      if [ 0${_timerPCount[$current]} -ge 0${_timerPTimer[$current]} ]; then
	[ "${_timerPExec[$current]}" != "" ] && ${_timerPExec[$current]}
	_timerPCount[$current]=0
      fi
    done
  ;;
  "_thread")
    $_timerCallback "Starting timer-thread"
    if [[ $2 =~ ^[0-9]+ ]]; then
      while [ $(ps ax | grep -cE "[ ]*$2[ ]+") -ge 1 ]; do
        kill -SIGUSR${_timerSig} $2 >/dev/null 2>/dev/null
	sleep $_timerSleep
      done
    fi
    $_timerCallback "Closing timer-thread"
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
timer bind test 2 testFunction
timer on
while $testRun; do
  read -n1 -t1 -s
  if [ "$REPLY" == "q" ] || [ "$REPLY" == "Q" ]
    then testRun=false; else sleep 0.25
  fi
done

timer off
log -out "Shuting down in 1.5 sec"; sleep 1.5
# ============================== END WORK BODY ==============================
$cfgActive && lock unlock || lock exit