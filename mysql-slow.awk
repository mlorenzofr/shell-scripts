#!/usr/bin/awk -f

# This script shows queries registered in mysql-slow.log
# with query time > 1 sec

BEGIN { host="" }

/^# User@Host/ { 
    block = 0
    host=$0
}

/^# Query_time: ([1-9]{1,}|[0-9]{2,})\./ {
    print host
    print $0
    block = 1
    next
}

/^SET timestamp/ {
    split($0, line, "=")
    if (block) {
        print strftime("# Date: %Y-%m-%d %H:%M:%S", line[2])
        next
    }
}

block
