#!/usr/bin/awk -f

# Format the output of "ip address list" to:
# <iface name> <MAC-address> <CIDR-1,CIDR2,...>

/^[0-9]+: / {
	gsub(":","",$2)
        iface = $2
	ifaces[iface]["ip"] = ""
	ifaces[iface]["mac"] = "00:00:00:00:00:00"
}

/inet/ {
	ifaces[iface]["ip"] = ifaces[iface]["ip"]","$2
}

/link\/ether/ { ifaces[iface]["mac"] = toupper($2) }

END {
	for (ifc in ifaces) {
		a = ifc
		for (key in ifaces[ifc]) {
			{ a = a" "ifaces[ifc][key] }
		}
		gsub(" ,", " ", a)
		print a
	}
}
