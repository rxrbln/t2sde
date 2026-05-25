# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/openssh/stone_mod_sshd.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
# [MAIN] 50 sshd SSH Daemon configuration
# [SETUP] 99 sshd

ssh_create_hostpair(){
	gui_cmd "Creating ssh host keypair" \
		"/usr/bin/ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''; \
		 /usr/bin/ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''; \
		 /usr/bin/ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''"
}

main() {
    while
	gui_menu alsa 'SSH Daemon Configuration.' \
		'Create a ssh host keypair' \
			'ssh_create_hostpair' \
		'Configure runlevels for sshd service' \
			'$STONE runlevel edit_srv sshd' \
		'(Re-)Start sshd init script' \
			'$STONE runlevel restart sshd'
    do : ; done
}
