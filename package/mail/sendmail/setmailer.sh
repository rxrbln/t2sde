#!/bin/sh
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/sendmail/setmailer.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

prefix=$( cd ${0%/*}/..; pwd -P )
for x in sendmail mailq newaliases; do
	echo "$0: Re-creating /usr/bin/$x -> ${x}_@mailer@ ..."
	echo -e "#!/bin/sh\nexec -a $x ${x}_@mailer@ \"\$@\"" > $prefix/bin/$x
	chmod +x $prefix/bin/$x
done

# add compatibility symlink
ln -sf ../bin/sendmail $prefix/sbin/sendmail

exit 0
