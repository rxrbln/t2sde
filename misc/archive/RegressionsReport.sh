#!/bin/sh
config=default
TARGET=regressions

if [ "$1" == "-cfg" ]; then
	config="$2"; shift 2
fi
mkdir -p $TARGET

sh misc/archive/AuditBuild.sh -w $TARGET -cfg $config --no-enabled-too -repository package/* \
	| grep '\(CHANGED\|UPDATED\|ADDED\|FAILED\|PENDING\|NOQUEUED\)' > $TARGET/regressions.$config.$$


cat <<EOT > $TARGET/regressions.$config.html
<html>
	<head><title>T2 r$( svn info | sed -n 's,^Revision: \(.*\),\1,p' ) - $( date )</title></head>
<body><pre>
$( ./scripts/Create-ErrList -cfg $config )
</pre><hr><table>
<tr><th>Package</th><th>SVN Status</th><th>Version</th><th>Audit</th><th>Status</th></tr>
EOT
grep -v NOQUEUED $TARGET/regressions.$config.$$ >> $TARGET/regressions.$config.html

cat <<EOT >> $TARGET/regressions.$config.html
</table><hr><table>
<tr><th>Package</th><th>SVN Status</th><th>Version</th><th>Audit</th><th>Status</th></tr>
EOT
grep NOQUEUED $TARGET/regressions.$config.$$ >> $TARGET/regressions.$config.html
cat <<EOT >> $TARGET/regressions.$config.html
</table></body>
</html>
EOT

rm -f $TARGET/regressions.$config.$$
mv -f $TARGET/regressions.$config.html $TARGET/$config/regressions.html

