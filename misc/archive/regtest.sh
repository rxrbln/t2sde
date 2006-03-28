#!/bin/bash

# Tiny regression testsuite driver used by some core developers to track
# breakage, sometimes even automated on a nightly basis.
#   - Rene Rebe

set -e

embedded=0

while [ "$1" ]; do
	case $1 in
		-embedded)
			embedded=1
			;;
		*)	echo "Unknown option $1"
			exit
			;;
	esac
	shift
done

mkdir -p regtest

build()
{
  if [ ! -e regtest/$x.finished ]; then

	mkdir -p config/regtest-$x
	cat > config/regtest-$x/config <<-EOT
		SDECFG_ARCH=$x
		SDECFG_CROSSBUILD=1
		SDECFG_PKG_CCACHE_USEIT=1
		SDECFG_ABORT_ON_ERROR_AFTER=0
		SDECFG_ALWAYS_CLEAN=1
		SDECFG_XTRACE=1
		SDECFG_EXPERT=1
		SDECFG_OPT="lazy" # slightly speed up the test builds
EOT
	if [ $embedded -eq 1 ]; then
		cat >> config/regtest-$x/config <<-EOT
			SDECFG_TARGET='embedded'
			SDECFG_TARGET_EMBEDDED_STYLE='dietlibc'
			SDECFG_PKGSEL='1'
EOT

		cat > config/regtest-$x/pkgsel <<-EOT
			O linux2*
EOT
	fi

	./scripts/Config -cfg regtest-$x -oldconfig
	./scripts/Download -cfg regtest-$x -required >> regtest/$x.log 2>&1
	echo "Running build ..."
	./scripts/Build-Target -cfg regtest-$x 2>&1 | tee regtest/$x.log |
	grep '> Building\|> Finished'
#	id=`grep SDECFG_ID config/regtest-$x/config`
#	eval $id

	touch regtest/$x.finished

  fi

  ./scripts/Create-ErrList -cfg regtest-$x | grep " builds "
}

for x in architecture/*/ ; do
	[[ $x = *share* ]] && continue
	x=${x#*/}; x=${x%/*}

	if [ $embedded -eq 1 ]; then
	  case $x in
		cris|hppa*|m68k|mips64|sh*) # no diet support
			echo "Skipping $x (for now)"
			continue
			;;
	  esac
	fi

	echo "Processing $x ..."
	build $x
done
