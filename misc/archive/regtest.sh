#!/bin/bash

# Tiny regression testsuite driver used by some core developers to track
# breakage, sometimes even automated on a nightly basis.
#   - Rene Rebe

set -e

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
	echo "Processing $x ..."
	build $x
done
