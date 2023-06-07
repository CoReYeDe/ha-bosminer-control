#!/bin/bash

if [ -z $1 ]; then 
  echo "Missing IP-Adress for Miner: Usage control_miner.sh MINER_IP ACTION (TARGET_POWER)";
  exit 1 
fi

if [ -z $2 ]; then 
  echo "Missing Action for Miner: Usage control_miner.sh MINER_IP ACTION (TARGET_POWER)";
  exit 1 
fi

setPowerLimit () {

  echo "Set Miner $1 to $clean_psu_power_limit_input Watt PSU-Power"
#  exit 0

  min_psu_limit=$(/usr/bin/ssh -o StrictHostKeyChecking=no root@$1 "grep -o '^min_psu_power_limit\ =\ [0-9]\+' /etc/bosminer.toml | grep -o '[0-9]\+'")
  
  if [ -z $min_psu_limit ]; then
    	  
        echo "No PSU-Limit found - BOS higher than 22.05"
	min_power_target=$(/usr/bin/ssh -o StrictHostKeyChecking=no root@$1 "grep -o '^min_power_target\ =\ [0-9]\+' /etc/bosminer.toml | grep -o '[0-9]\+'")
          
	if [ -z $min_power_target ]; then
		echo "No PSU-Limit found - Cant set PowerLimit"
		exit 1  
        else
	  if (( $min_power_target > $clean_psu_power_limit_input )); then
            echo "MIN_PSU_LIMIT ($min_power_target) higher then TARGET-POWER ($clean_psu_power_limit_input) - New Power-Limit not set"; exit 1
          else
            /usr/bin/ssh -o StrictHostKeyChecking=no root@$1 "sed -i -E 's/^power_target\ =\ [0-9]*/power_target\ =\ $clean_psu_power_limit_input/' /etc/bosminer.toml && /etc/init.d/bosminer restart"
	    new_power_target=$(/usr/bin/ssh -o StrictHostKeyChecking=no root@$1 "grep -o '^power_target\ =\ [0-9]\+' /etc/bosminer.toml | grep -o '[0-9]\+'")
            if (( $new_power_target == $clean_psu_power_limit_input )); then
              echo "OK - New PSU-Power-Target ($clean_psu_power_limit_input)"
              exit 0
            else
              echo "ERROR - New PSU-Power-Target ($clean_psu_power_limit_input)"
              exit 1
            fi
          fi
	fi
  else

	  if (( $min_psu_limit > $clean_psu_power_limit_input )); then
	    echo "MIN_PSU_LIMIT ($min_psu_limit) higher then TARGET-POWER ($clean_psu_power_limit_input) - New Power-Limit not set"; exit 1
	  else
	    /usr/bin/ssh -o StrictHostKeyChecking=no root@$1 "sed -i -E 's/^psu_power_limit\ =\ [0-9]*/psu_power_limit\ =\ $clean_psu_power_limit_input/' /etc/bosminer.toml && /etc/init.d/bosminer restart"
	    new_psu_power_limit=$(/usr/bin/ssh -o StrictHostKeyChecking=no root@$1 "grep -o '^psu_power_limit\ =\ [0-9]\+' /etc/bosminer.toml | grep -o '[0-9]\+'")
	    if (( $new_psu_power_limit == $clean_psu_power_limit_input )); then
	      echo "OK - New PSU-Power-Limit ($clean_psu_power_limit_input)"
	      exit 0
	    else
	      echo "ERROR - New PSU-Power-Limit ($clean_psu_power_limit_input)"
	      exit 1
	    fi
	  fi
  fi
}

setFanMode () {

echo "SetFanMode $1 $2"
#[temp_control]
#mode = 'manual'

#[fan_control]
#speed = 90

}

case $2 in

  pause)

    echo '{"command":"pause"}' | nc $1 4028
    echo "PAUSE $1"
    ;;

  resume)

    echo '{"command":"resume"}' | nc $1 4028
    ;;

  setfanmode)
    
    setFanMode $1 'auto'
    ;;

  setpowerlimit)

    if [ -z $3 ]; then 
      echo "Missing Target-Power for Miner: Usage control_miner.sh MINER_IP ACTION TARGET_POWER";
      exit 1 
    fi 

    clean_psu_power_limit_input=$(echo $3 | grep -o '^[0-9]\+')

    testint='^[0-9]*$'

    if [[ $clean_psu_power_limit_input =~ $testint ]]; then

      setPowerLimit $1 $clean_psu_power_limit_input

    fi

    ;;

  *)

    echo "ERROR - No valid Action"
    exit 1  
    ;;

esac

