#!/bin/sh

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Setup backup" \
        -m "Please enter the system password (root user)^\
in order to generate encryption keys." -c $0
fi

# PATH and co
. /etc/profile

export gpg="gpg --homedir /home/archivista/.gnupg"

if $gpg --list-keys ade > /dev/null; then
	Xdialog --default-no --yesno \
"Warning: A data exchange key pair does already exist! Overwriting this key
will make importing previously encrypted data, encrypted with the current key,
impossible.
Do you really like to create a new key pair?" 10 65 || exit
fi

# flush previous keys
rm -rf /home/archivista/.gnupg
($gpg --gen-key --batch <<-EOT
     %echo Generating a standard key
     Key-Type: DSA
     Key-Length: 1024
     Subkey-Type: ELG-E
     Subkey-Length: 1024
     Name-Real: ade
     Name-Comment: Archivista Data Exchange key
#     Name-Email: none
     Expire-Date: 0
#     Passphrase: 
#     %pubring foo.pub
#     %secring foo.sec
     # Do a commit here, so that we can later print "done" :-)
     %commit
     %echo done

EOT
)  2>&1 | Xdialog --no-cancel --title "Generating key ..." --logbox - 30 65
#       ^- fold -w 50 or so ?
#Xdialog --msgbox "The key was generated." 8 30

