#!/bin/bash

# Show the lag in the MySQL slave server and the queries executed into master
# and slave servers during the time specified.

function usage() {
    echo "Usage: $0 [-d HH:MM] [-h] [-m hostname] [-s hostname]"
    echo "Get the lag in the slave server and process running in master and slave servers"
    echo ""
    echo "Parameters:"
    echo "    -d <HH:NN>    Hour and minute to run the test"
    echo "                  Accepts regular expressions"
    echo "                  Useful to run the script in loop"
    echo "    -h            Show this message"
    echo "    -l <delay>    Run the check in loop each <delay> seconds (kill it manually)"
    echo "    -m <hostname> MySQL master server"
    echo "    -s <hostname> MySQL slave server"
    echo ""
    echo "Example:"
    echo "    # ${0} -l 1 -d '01:0[0-5]' -m master.mysql -s slave.mysql"
}

function check() {
    mysql_cmd="mysql -u root -p${password} -h"
    echo "$(date +'[%H:%M:%S]')"
    echo -e "Slave lag: $(${mysql_cmd} ${slave} -e 'show slave status\G' |
                          grep -i seconds | 
                          cut -d ':' -f 2)"

    for srv in ${master} ${slave}; do
        echo ""
        echo "*** ${srv}"
        ${mysql_cmd} ${srv} -t -e "show full processlist;" | 
            awk -F '|' '{
                if ($9 !~ /(^ +$|NULL)/ && $3 != "") {
                    gsub(/ /,"",$3)
                    gsub(/ /,"",$4)
                    gsub(/ /,"",$5)
                    user=$3"@"$4
                    printf "%-50s %-25s %s\n", user, $5, $9
                    if ($3 == "User") {
                        for (i = 0; i < 200; i++) { sep = sep"-" }
                        print sep
                    }
                }
            }'
    done
}

while getopts ":d:hl:m:s:" options; do
    case ${options} in
        "d")
            date=${OPTARG}
            ;;
        "h")
            usage
            exit 1
            ;;
        "l")
            loop=${OPTARG}
            ;;
        "m")
            master=${OPTARG}
            ;;
        "s")
            slave=${OPTARG}
            ;;
        "*")
            usage
            exit 2
            ;;    
    esac
done

if [ -z ${master} -o -z ${slave} ]; then
    usage
    exit 3
fi

echo -n "MySQL root password: "
read -s password
echo ""

if [ -z ${date} ]; then
    date=$(date +'%H:%M')
fi

while true; do
    if [[ $(date +'%H:%M') =~ ${date} ]]; then
        check
    fi
    if [ -v ${loop} ]; then
        exit
    else
        sleep ${loop}
    fi
done
