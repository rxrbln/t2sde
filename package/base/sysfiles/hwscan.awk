#!/bin/gawk -f
#
# Usually I'd write this in perl. But this should also work on a system
# with no perl installed, so it's in awk ...

function debug(text) {
	if ( print_debug )
		print text > "/dev/stderr";
}

function autocomplete(mod, id) {
	driver_initrd[id] = 1;

	if ( mod ~ /^snd-/ ) {
		driver_mod[id] = driver_mod[id] \
			" snd-pcm-oss snd-seq-oss snd-mixer-oss";
		driver_initrd[id] = 0;
	}

	if ( modidx[mod] ~ "/video/" ) {
		driver_cmd[id] = driver_cmd[id] \
			"\n: touch /dev/vc/{1,2,3,4,5,6}" \
			"\n: fbset -a 800x600-60" \
			"\nchvt 2; sleep 1; chvt 1";
		driver_initrd[id] = 0;
	}
}

function get_pci_drivers() {
	debug("Reading /lib/modules/" kernel "/modules.pcimap.");
	while ( (getline < ("/lib/modules/" kernel "/modules.pcimap")) > 0 ) {
		id = sprintf( "%04x%04x", and(strtonum($2),0xffff),
			and(strtonum($3),0xffff));
		# always prefer ALSA drivers if available
		if ( id in pci_driver && pci_driver[id] ~ /^snd-/ ) continue;
		pci_driver[id] = $1;
	}

	while ( (getline < "/usr/share/pci.ids") > 0 ) {
		if ( /^\t\t/ ) {
			id = $1 $2;
			sub("^\t+[0-9a-f]+[ \t]+[0-9a-f]+[ \t]+", "");
			pci_descs[id] = vendor_name " " $0;
		} else
		if ( /^\t/ ) {
			id = vendor_id $1;
			sub("^\t+[0-9a-f]+[ \t]+", "");
			pci_descs[id] = vendor_name " " $0;
		} else {
			vendor_id = $1;
			sub("^[0-9a-f]+[ \t]+", "");
			vendor_name = $0;
		}
	}
	
	while ( (getline < "/proc/bus/pci/devices") > 0 ) {
		id = "pci" $1 " (Device " $2 ")";
		driver_mod[id] = pci_driver[$2];
		driver_dsc[id] = pci_descs[$2];
		driver_cmd[id] = "";
		drivers[id] = id;
		autocomplete(pci_driver[$2], id);
	}
}

function get_isapnp_drivers() {
	debug("Reading /lib/modules/" kernel "/modules.isapnpmap.");
	while ( (getline < ("/lib/modules/" kernel "/modules.isapnpmap")) > 0 ) {
		vendor = strtonum($2);
		device = strtonum($3);

		# ugly mangling performed in the kernel ...
		id = sprintf ("%c%c%c%x%x%x%x",
		65 + and (vendor / 4, 0x3f) - 1,
		65 + or (and (vendor, 3) * 8, and (vendor / 8192, 7) ) - 1,
		65 + and (vendor / 256, 0x1f) - 1,
		and (device / 16,  0x0f),
		and (device, 0x0f),
		and (device / 4096, 0x0f),
		and (device / 256, 0x0f) );

		isapnp_driver[id] = $1;
	}

	while ( (getline < "/proc/bus/isapnp/devices") > 0 ) {
		id = substr ($2,0,7);
		iid = "isapnp" id;
		driver_mod[iid] = isapnp_driver[id];
		driver_dsc[iid] = "ISA PnP (" id ")"; #isapnp_descs[id];
		driver_cmd[iid] = "";
		drivers[iid] = iid;
		autocomplete(isapnp_driver[id], iid);
	}
}

function match_usb_dev() {
	if ( usb_device[ "Vendor" ] == 0 && usb_device[ "ProdID" ] == 0 ) return;
	usbmap_idx[ "Vendor"  ] = 1;
	usbmap_idx[ "ProdID"  ] = 2;
	usbmap_idx[ "DevLo"   ] = 4;
	usbmap_idx[ "DevHi"   ] = 8;
	usbmap_idx[ "DevCls"  ] = 16;
	usbmap_idx[ "DevSub"  ] = 32;
	usbmap_idx[ "DevProt" ] = 64;
	usbmap_idx[ "IfCls"   ] = 128;
	usbmap_idx[ "IfSub"   ] = 256;
	usbmap_idx[ "IfProt"  ] = 512;
	usbmap_idx[ "DrvInfo" ] = 1024;
	usb_modlist="";

	for ( usb_driver_id=0; usb_driver_id < usb_driver_c; usb_driver_id++ ) {
	  found=1;
	  for ( usbmap_idx_id in usbmap_idx ) {
		if ( and(usb_driver[usb_driver_id, "match"], usbmap_idx[usbmap_idx_id]) ) {
			if ( (usb_driver[usb_driver_id, usbmap_idx_id] != \
				usb_device[usbmap_idx_id]) ) found=0;
		}
	  }
	  if (found) {
		if ( usb_modlist != "" ) usb_modlist = usb_modlist " ";
		usb_modlist = usb_modlist usb_driver[usb_driver_id, "mod"];
	  }
	}
	if ( usb_modlist != "" ) {
		id = "usb-device " usb_device[ "Vendor" ] ":" usb_device[ "ProdID" ] " (" usb_modlist ")";
		driver_mod[id] = usb_modlist;
		driver_dsc[id] = usb_device[ "Desc" ] " (" usb_modlist ")";
		gsub(" +", " ", driver_dsc[id]);
		driver_cmd[id] = "";
		drivers[id] = id;
		autocomplete(pci_driver[$2], id);
	}
}

function get_usb_flag(name) {
	split($0, usb_flags, " +");
	for ( usb_flag_id in usb_flags ) {
		split(usb_flags[usb_flag_id], usb_flag, "[=(]");
		if ( usb_flag[1] == name ) return strtonum("0x" usb_flag[2]);
	}
	return 0;
}

function get_usb_drivers() {
	while ( ("lspci -v" | getline) > 0 ) {
		if ( / USB Controller: / ) {
			usb_ctrl_desc="";
			if ( /prog-if.*OHCI/ ) 
				{ usb_ctrl_driver="usb-ohci"; usb_ctrl_desc="OHCI"; }
			if ( /prog-if.*UHCI/ )
				{ usb_ctrl_driver="usb-uhci"; usb_ctrl_desc="UHCI"; }
			if ( usb_ctrl_desc != "" ) {
				sub("^[^ ]*", ""); sub("\\(rev .*$", "");
				usb_ctrl_desc = usb_ctrl_desc $0;
				break;
			}
		}
	}
	if ( usb_ctrl_driver && modidx[usb_ctrl_driver] ) {
		debug("Found USB " usb_ctrl_driver " device in lspci output.");
		id = "usb-controller (PCI " usb_ctrl_driver ")";
		driver_mod[id] = usb_ctrl_driver;
		driver_dsc[id] = usb_ctrl_desc;
		driver_cmd[id] = "\nmount -t usbfs none /proc/bus/usb";
		drivers[id] = id;
		autocomplete(usb_ctrl_driver, id);
	}

	debug("Reading /lib/modules/" kernel "/modules.usbmap.");
	for ( usb_driver_c=0;
	      (getline < ("/lib/modules/" kernel "/modules.usbmap")) > 0;
	      usb_driver_c++ ) {
		if ( $1 == "#" ) { usb_driver_c--; continue; }
		usb_driver[usb_driver_c, "mod"     ] = $1;
		usb_driver[usb_driver_c, "match"   ] = strtonum($2);
		usb_driver[usb_driver_c, "Vendor"  ] = strtonum($3);
		usb_driver[usb_driver_c, "ProdID"  ] = strtonum($4);
		usb_driver[usb_driver_c, "DevLo"   ] = strtonum($5);
		usb_driver[usb_driver_c, "DevHi"   ] = strtonum($6);
		usb_driver[usb_driver_c, "DevCls"  ] = strtonum($7);
		usb_driver[usb_driver_c, "DevSub"  ] = strtonum($8);
		usb_driver[usb_driver_c, "DevProt" ] = strtonum($9);
		usb_driver[usb_driver_c, "IfCls"   ] = strtonum($10);
		usb_driver[usb_driver_c, "IfSub"   ] = strtonum($11);
		usb_driver[usb_driver_c, "IfProt"  ] = strtonum($12);
		usb_driver[usb_driver_c, "DrvInfo" ] = strtonum($13);
	}

	while ( (getline < "/proc/bus/usb/devices") > 0 ) {
		if ( $1 == "T:" ) {
			if ( usb_device["Vendor"] != "" ) match_usb_dev();
			usb_device[ "Vendor"  ] = 0;
			usb_device[ "ProdID"  ] = 0;
			usb_device[ "DevLo"   ] = 0;	# FIXME: Where is this value in bus/usb/devices?
			usb_device[ "DevHi"   ] = 0;	# FIXME: Where is this value in bus/usb/devices?
			usb_device[ "DevCls"  ] = 0;
			usb_device[ "DevSub"  ] = 0;
			usb_device[ "DevProt" ] = 0;
			usb_device[ "IfCls"   ] = 0;
			usb_device[ "IfSub"   ] = 0;
			usb_device[ "IfProt"  ] = 0;
			usb_device[ "DrvInfo" ] = 0;	# FIXME: Where is this value in bus/usb/devices?
			usb_device[ "Desc"    ] = "USB:";
		}
		if ( $1 == "P:" ) {
			usb_device[ "Vendor"  ] = get_usb_flag("Vendor");
			usb_device[ "ProdID"  ] = get_usb_flag("ProdID");
		}
		if ( $1 == "D:" ) {
			usb_device[ "DevCls"  ] = get_usb_flag("Cls");
			usb_device[ "DevSub"  ] = get_usb_flag("Sub");
			usb_device[ "DevProt" ] = get_usb_flag("Sub");
		}
		if ( $1 == "I:" ) {
			usb_device[ "IfCls"   ] = get_usb_flag("Cls");
			usb_device[ "IfSub"   ] = get_usb_flag("Sub");
			usb_device[ "IfProt"  ] = get_usb_flag("Prot");
		}
		if ( $1 == "S:" ) {
			if ( ! match($0, "SerialNumber") ) {
				sub(".*=", "");
				usb_device[ "Desc" ] = usb_device[ "Desc" ] " " $0;
			}
		}
	}
	if ( usb_device["Vendor"] != "" ) match_usb_dev();
}

function print_driver(id) {
	if ( driver_initrd[id] ) {
		tmp = driver_mod[id];
		gsub(" +", "\nmodprobe ", tmp);
		tmp = "modprobe " tmp driver_cmd[id];
	} else {
		tmp = driver_mod[id] "\t#no-initrd";
		gsub(" +", "\t#no-initrd\nmodprobe ", tmp);
		tmp = "modprobe " tmp driver_cmd[id];
	}

	if ( disable_default ) {
		gsub("\n", "\n#", tmp);
		tmp = "#" tmp;
	}

	if ( driver_dsc[id] == "" ) {
		tmp2 = driver_mod[id]; gsub(" .*", "", tmp2);
		driver_dsc[id] = "Unkown device for driver " tmp2;
	}

	if ( file ) {
		print "New Device: " id;
		print "\n### " id " ###"  >> file;
		print "# " driver_dsc[id] >> file;
		if ( print_echos )
			print "echo '" driver_dsc[id] "'" >> file;
		print tmp >> file;
	} else {
		print "\n### " id " ###";
		print "# " driver_dsc[id];
		if ( print_echos )
			print "echo '" driver_dsc[id] "'";
		print tmp;
	}
}

BEGIN {
	for (i=1; i<ARGC; i++) {
		if ( ARGV[i] == "-k" )
			kernel = ARGV[++i];
		else if ( ARGV[i] == "-s" )
			file = ARGV[++i];
		else if ( ARGV[i] == "-d" )
			disable_default = 1;
		else if ( ARGV[i] == "-D" )
			print_debug = 1;
		else if ( ARGV[i] == "-V" )
			print_echos = 1;
		else {
print 									"\n" \
"HWScan - ROCK Linux (www.rocklinux.org)"				"\n" \
"Copyright 2003 Clifford Wolf <clifford@clifford.at>"			"\n" \
"This is free software with ABSOLUTELY NO WARRANTY."			"\n" \
									"\n" \
"Usage: hwscan [ [--] options ]"					"\n" \
									"\n" \
" -k <kernel-version>  .........  use /lib/modules/<thisvalue>/"	"\n" \
" -s <hw-init-script>  .........  e.g. /etc/conf/kernel"		"\n" \
" -d  ..........................  disable new driver on default"	"\n" \
" -D  ..........................  debug (print auto-detected values)"	"\n" \
" -V  ..........................  verbose (add echo's)"			"\n";
exit 1;
		}
	}

	if ( ! kernel ) {
		if ( ("cat /proc/version" | getline) > 0 ) {
			kernel = $3;
		} else {
			kernel = "*";
		}
		debug("Auto-detected kernel version: " kernel);
	}

	for ( c=0; (("find /lib/modules/" kernel \
			"/. -name '*.o' -printf '%P %f\n'") | getline) > 0; c++ ) {
		sub("\\.o$", "");
		modidx[$2] = $1;
	}
	debug("Found " c " modules in /lib/modules/" kernel ".");

	while ( file && (getline < file) > 0 ) {
		if ( /^### .* ###$/ ) {
			sub("^### ", "");
			sub(" ###$", "");
			skip[$0] = 1;
			debug("Mark existing driver " $0 " to be skipped.");
		}
	}

	get_pci_drivers();
	get_isapnp_drivers();
	get_usb_drivers();

	asort(drivers);
	for (i in drivers) {
		id = drivers[i];
		if ( driver_mod[id] && ! skip[id] ) {
			print_driver(id);
		}
	}
}

