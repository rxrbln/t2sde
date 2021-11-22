#compdef mine

_arguments -s \
	'(-i)'-i'[install package]:package:->packages' \
	'(-r)'-r'[remove package]:package:->packages' \
	'(-q)'-q'[show package version]:package:->packages' \
	'(-p)'-p'[display package description]:package:->packages' \
	'(-l)'-l'[display all files owned by a package]:package:->packages' \
	'(-d)'-d'[show package dependecies]:package:->packages' \
	'(-m)'-m'[view checksums for each files owned by a package]:package:->packages' \
	'(-v)'-v'[verbose: output information while processing packages]' \
	'(-t)'-t'[run in test mode aka dry-run]' \
	'(-f)'-f'[force (skip checksum tests)]' \
	'(-s)'-s'[also remove sub-packages]' \
	'(-x)'-x'[skip files based on PATTERN]' \
	'(-R)'-R'[specify root directory]:root:_files' \
	'(-T)'-T'[create .tar.bz2 package files from installed packages]'

case ${state} in
	packages)
		_values 'package list' /var/adm/packages/*(.:t)
		;;
esac
