#!/bin/sh

config=default
repositories=
VERBOSE=

show_usage() {
	cat<<-EOT
	usage: $0 [-v] [-cfg <config>] [-repository <repositories>]
	EOT
}

while [ $# -gt 0 ]; do
	case "$1" in
		-cfg)	config="$2"; shift	;;
		-v)	VERBOSE=1		;;
		--help)	show_usage; exit 1	;;
		-repository)
			shift; repositories="$*"
			break ;;
		*)	show_usage; exit 2	;;
	esac
	shift
done

if [ ! -f config/$config/packages ]; then
	echo "ERROR: '$config' is not a valid config"
	exit 1
fi

eval `grep 'ROCKCFG_ID=' config/$config/config 2> /dev/null`
LOGSDIR=build/$ROCKCFG_ID/var/adm/logs
if [ -z "$ROCKCFG_ID" -o ! -d $LOGSDIR ]; then
	echo "ERROR: 'build/$ROCKCFG_ID/' is not a valid build root (sandbox)"
	exit 1
fi

expand_stages() {
	local array="$1" stage=
	while [ "$array" ]; do
		stage=${array:0:1}
		array=${array:1}
		if [ "$stage" != "-" ]; then
			echo -n "$stage "
		fi
	done
}

audit_package() {
	local pkg="$1" repo="$2" ver="$3"
	local stages= svndiff= oldver= lchanges= stage=
	local lstatus= lbuild= file=
	shift 3; stages="$*"

	svndiff=`svn diff package/$repo/$pkg`
	if [ "$svndiff" ]; then
		lchanges="CHANGED"
		oldver=`echo "$svndiff" | grep '^-\[V\]' | cut -d' ' -f2`

		if [ "$oldver" ]; then
			ver="$oldver -> $ver"
			lchanges="UPDATED"
		fi
	fi

	for stage in $stages; do
		file=`ls -1 $LOGSDIR/$stage-$pkg.{err,log,out} 2> /dev/null`
		if [ "$file" ]; then
			case "$file" in
				*.log)	[ "$lstatus" == 2 ] || lstatus=1
					lbuild="$lbuild OK($stage)"	;;
				*.out)	lbuild="$lbuild NO($stage)"	;;
				*)	lstatus=2
					lbuild="$lbuild ERR($stage)"	;;
			esac
		else
			lbuild="$lbuild NO($stage)"
		fi
	done
	case "$lstatus" in
		2)	lstatus=FAILED		;;
		1)	lstatus=SUCCESSFUL	;;
		*)	lstatus=PENDING		;;
	esac
	echo -e "$repo/$pkg\t$lchanges\t($ver)\t$lbuild\t$lstatus"
}

if [ "$repositories" ]; then
	for repo in $repositories; do
		repo=${repo#./package/}; repo=${repo#package/}; repo=${repo%/}
		if [ -d package/$repo/ ]; then
			grep -e "^X.* $repo " config/$config/packages | while \
				read x stages x repo pkg ver x; do
					audit_package $pkg $repo $ver `expand_stages $stages`
			done
		fi
	done
else
	grep -e "^X" config/$config/packages | while \
		read x stages x repo pkg ver x; do
			audit_package $pkg $repo $ver `expand_stages $stages`
	done
fi
