#!/bin/bash
BASE_SCRIPT_SOURCE="https://raw.githubusercontent.com/mwildt/az-ops/main/cluster"

CURRENT="."
LOG_BASE="/var/logs"
SCRIPTS=()
ARGS=()
declare -A startargs
startargs=()
declare -A endargs
endargs=()
argc=0

while [[ $# -gt 0 ]]; do
  case $1 in
    ---scriptSourceBase)
      BASE_SCRIPT_SOURCE="$2"
      shift # past argument
      shift # past value
      ;;
    ---logBase)
      LOG_BASE="$2"
      shift # past argument
      shift # past value
      ;;
    --)
      endargs[$CURRENT]=$argc
      CURRENT=$2
      SCRIPTS+=($CURRENT)
      startargs[$CURRENT]=$argc
      shift # past argument
      shift # past value
      ;;
    *)
      ARGS+=($1)
      argc=$((argc+1))
      shift # past argument
      ;;
  esac
done

endargs[$CURRENT]=$argc

sudo mkdir -p /var/install
sudo mkdir -p $LOG_BASE/install

for script in "${SCRIPTS[@]}"
do
    echo "run $i"
    scriptfile="/var/install/$script"
    scriptSource="$BASE_SCRIPT_SOURCE/$script"
    echo "load script from source $scriptSource"
    sudo curl -o $scriptfile $scriptSource
    sudo cat $scriptfile
    sudo chmod +x $scriptfile
    start=${startargs[$script]}
    end=${endargs[$script]}
    
    read -ra scriptArgs <<< ${ARGS[*]:$start:$end}
    
    echo "run script file  $scriptfile with args ${scriptArgs[@]}, find logs @ $LOG_BASE/install/$script"
    echo "---------------------------------------------------------------------" >> $LOG_BASE/install/$script
    echo "|$(date) | RUN SCRIPT | $scriptfile ${scriptArgs[@]}" >> $LOG_BASE/install/$script
    echo "---------------------------------------------------------------------" >> $LOG_BASE/install/$script
    sudo $scriptfile "${scriptArgs[@]}" | sudo tee -a $LOG_BASE/install/$script
done
