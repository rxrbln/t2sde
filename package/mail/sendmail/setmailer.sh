#!/bin/sh

for x in sendmail mailq newaliases; do
	echo "$0: Re-creating /usr/bin/$x -> ${x}_@mailer@ ..."
	echo -e "#!/bin/sh\nexec -a $x ${x}_@mailer@ \"\$@\"" > /usr/bin/$x
	chmod +x /usr/bin/$x
done

# add compatibility symlink
ln -sf /usr/bin/sendmail /usr/sbin/sendmail

exit 0

