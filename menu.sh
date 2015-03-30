#!/bin/ksh
export PATH=/usr/sbin:$PATH

typeset -r SLEEPTIME=2

REVON=$(tput smso)  # Reverse on.
REVOFF=$(tput rmso) # Reverse off.


################################################################################################################
#       Checking users existence 
################################################################################################################

check_users(){
clear
echo "Please enter a file name for users to check\n"
read FS_FILE
echo ""
echo "Full PATH is: $PWD/$FS_FILE"
echo ""
	if [[ -s "$FS_FILE" ]]; then
		for i in `cat $FS_FILE`
		do
			USER_CHECK=`grep -w $i /etc/passwd`
			if [[ $? -eq 0 ]]
				then
					USER_SHELL=`grep -w $i /etc/passwd | awk -F: '{print $7}'`
					USER_GRP_NUM=`grep -w $i /etc/passwd | awk -F: '{print $4}'`
					GRP_NAME=`grep -w $USER_GRP_NUM /etc/group | awk -F: '{print $1}'`
					printf "User \033[32m%-10s Exist - Group Number:%-3s - Group Name:%-6s\033[00m\n" $i $USER_GRP_NUM $GRP_NAME
				else
					printf "User \033[31m%s Does NOT Exist\033[00m\n" $i
				fi
		done
	else
		printf "Error: \033[31m%s NO FILE WAS ENTERED\033[00m\n" 
	fi

echo "\n"
echo "Hit Enter to Continue..."
read a
}


kernel_parameters(){
################################################################################################################
#       Checking kernel parameters
################################################################################################################
clear
#checking if /stand/current is sufficient.
if [[ -r "/stand/current" ]];then
	echo "Please enter a file name for kernel parameters to check\n"
	read FS_FILE
	echo ""
	echo "Full PATH is: $PWD/$FS_FILE"
	echo ""
	if [[ -s "$FS_FILE" ]]; then
	FILE="$PWD/$FS_FILE"
			while read PARAM VALUE; do
			#TEMP2=`cat $kctune_pam | grep -w $PARAM | cut -f 3 -d " "`
			TEMP_NO_USE=`/usr/sbin/kctune 2> /tmp/ek.temp $PARAM `
			if [[ `cat /tmp/ek.temp | grep -q ERROR;echo $?` -eq 0 ]]
				then
					printf "%-20s \033[01;31mDoes not EXIST on the SYSTEM \033[00m \n" $PARAM 
				else	
					TEMP2=`/usr/sbin/kctune $PARAM 2> /dev/null| grep -v Tunable | awk '{print $2}'`
					if [[ $TEMP2 != $VALUE ]]
						then
							printf "\033[01;32m%-20s \033[00mis configured to be %s should be %s \n" $PARAM $VALUE $TEMP2 
						fi
			fi
			done<"$FILE"
	else 
		printf "Error: \033[31m%s NO FILE WAS ENTERED\033[00m\n" 
	fi
else
  	    printf "Error: \033[31m%s Not able to run kctune to get kernel parameters, please enter the list of kernel parameters to check.\033[00m\n"
        read FS_FILE
        echo ""
        printf "Error: \033[31m%s Enter the kctune output to compare with.\033[00m\n"
        read KC_FILE
        echo ""

        if [[ -s "$FS_FILE" && -s "$KC_FILE" ]]; then
                FILE="$PWD/$FS_FILE"
                KC_FILE=$PWD/$KC_FILE"
                $FIX_KC_FILE=`cat $KC_FILE | awk '{print $1,"           ",$2}'`
                echo $FIX_KC_FILE
        fi

fi
echo "\n"
echo "Hit Enter to Continue..."
read a

}



network_speed(){
################################################################################################################
#       Checking network cards and the speed on them
################################################################################################################

`netstat -rn | awk '{print $5}' | grep -v : | grep -v Interface | grep -v lo0 > /tmp/a`
`sed '/^$/d' /tmp/a > /tmp/b`
`sed s/lan//g /tmp/b > /tmp/a`
`cat /tmp/a | sort -n | uniq > /tmp/b`

clear
echo "Checking lan speeds\n"
sleep 1
for i in `cat /tmp/b`
do

TEMP=`lanadmin -x $i | grep Speed|awk '{print $3}'`
echo "lan$i speed is: $TEMP MB, network address is:`ifconfig lan$i | grep inet | awk '{print $2}'` "
done

echo "\n"
echo "Hit Enter to Continue..."
read a
}

check_filesystems(){
################################################################################################################
#       Checking Filesystems from an input file
################################################################################################################
clear
echo "Please enter a file name for files systems to check\n"
read FS_FILE
echo ""
echo "Full PATH is: $PWD/$FS_FILE"
echo ""

if [[ -s "$FS_FILE" ]]; then

for i in `cat $FS_FILE | awk '{print $1}'`
do
	TEMP=`mount | grep -w $i`
	if [[ $? -ne "0" ]]
		then
			printf "\033[31mFS ---> %-10s Not created on the system\033[0m\n" $i 
		else
		SIZE_TEMP=`mount | grep -w $i | grep -v /$i/ | awk '{print "df -k "$1}' | sh | grep 'total allocated Kb' | sed 's/.*: *\([0-9]*\) .*/\1/g'`
		SIZE=`echo "${SIZE_TEMP}/1024/1024" | bc`	
		MOUNT_PATH=`mount | grep -w $i | grep -v /$i/ | awk '{print $3}'`
		printf 'FS ---> %-10s ------\033[32m OK\033[0m--->> %-30s FS-SIZE=%sG\n' $i $MOUNT_PATH $SIZE

		fi
done
fi
echo ""
echo "Hit Enter to Continue..."
read a
}


network_parameters(){
################################################################################################################
#       Checking network parameters (NDD)
################################################################################################################
>/tmp/tmp.ndd #Control file to check if 
echo "Please enter a file name for ndd params to check\n"
read NDD_FILE
#FILE="$PWD/$NDD_FILE"
if [[ -s "$FILE" ]]; then
	echo "Checking the Network parameters\n"
	sleep 1
	while read PARAM VALUE; do
	if [[ $PARAM = udp* ]]
	then
		if [[ $VALUE -ne `ndd -get /dev/udp $PARAM` ]]
			then
				 echo "value for $PARAM is not good, should be $VALUE but we get `ndd -get /dev/udp $PARAM` \n" >> /tmp/tmp.ndd
			 fi
		 else
			if [[ $VALUE -ne `ndd -get /dev/tcp $PARAM` ]]
		 		then
		  			echo "value for $PARAM is not good should be $VALUE but we get `ndd -get /dev/tcp $PARAM` \n"  >> /tmp/tmp.ndd
		  	fi
		fi
	done<"$FILE"
	if [[ ! -z /tmp/tmp.ndd ]]
		then
			clear
			echo "All network parameters are configured right, Yataa !!!\n"
		else
			cat /tmp/tmp.ndd
		fi
	echo "Hit Enter to Continue...\n"
	read a
else
	printf "Error: \033[31m%s NO INPUT FILE WAS ENTERED\033[00m\n"
	printf "Error: \033[31m%s Please enter input files. in the ndd value parameter use only numbers without commas or other characters.\033[00m\n"
fi
}


while :
do
    clear
    print "\t    $REVON Check Menu by Alex Aizenberg  $REVOFF"
    print
    print
    print "\t\033[01;32mOptions: Check for...?\033[00m"
    print "\t---------------------------------------------"
    print "\t1) Kernel Parameters"
    print "\t2) NDD Parameters"
    print "\t3) Users existence"
    print "\t4) File Systems"
    print "\t5) Networks"
    print "\t6) Under Construction"
    print
    print "\n\tOther Options:"
    print "\t----------------"
    print "\tr) Refresh screen"
    print "\tq) Quit"
    print
    print "\tEnter your selection: r\b\c"
    read selection
    if [[ -z "$selection" ]]
        then selection=r
    fi

    case $selection in
        1)  print "\nYou selected option 1"
	    kernel_parameters
            sleep 1
            ;;
        2)  print "You selected option 2 - NDD Parameters..."
            #sleep $SLEEPTIME
	    network_parameters
	    sleep 1
            ;;
        3)  print "You selected option 3"
	    check_users
            sleep 1
            ;;
        4)  print "You selected option 4"
	    check_filesystems
            ;;
        5)  print "You selected option 5 - Networks speed..."
	    network_speed	
            sleep 1
            ;;
        6)  print "You selected option 6"
        		printf "\033[31m%s Under Construction\033[00m\n"
            sleep $SLEEPTIME
            ;;
      r|R)  continue
            ;;
      q|Q)  print
            exit
            ;;
        *)  print "\n$REVON Invalid selection $REVOFF"
            sleep 1
            ;;
    esac
done
