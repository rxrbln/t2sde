#!/bin/sh

for x in sendmail mailq newaliases; do
	echo "$0: Re-creating /usr/bin/$x -> ${x}_@mailer@ ..."
	echo -e "#!/bin/sh\nexec -a $x ${x}_@mailer@ \"\$@\"" > /usr/bin/$x
	chmod +x /usr/bin/$x
done
exit 0

