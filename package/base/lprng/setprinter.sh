#!/bin/sh

for x in cancel lp lpq lpr lprm lpstat; do
	echo "$0: Re-creating /usr/bin/$x -> ${x}_@printer@ ..."
	echo -e "#!/bin/sh\nexec -a $x ${x}_@printer@ \"\$@\"" > /usr/bin/$x
	chmod +x /usr/bin/$x
done
for x in lpc; do
	echo "$0: Re-creating /usr/sbin/$x -> ${x}_@printer@ ..."
	echo -e "#!/bin/sh\nexec -a $x ${x}_@printer@ \"\$@\"" > /usr/sbin/$x
	chmod +x /usr/sbin/$x
done
exit 0

