
                          Building ROCK Linux
                          ~~~~~~~~~~~~~~~~~~~


	1. Requirements
	===============

For building ROCK Linux you need a good internet connection for downloading the
sources, a lot of disk space, a fast computer and some time. Depending on the
configuration you are going to choose and your hardware, a build of ROCK Linux
can take some days to complete. You also need root permissions to build ROCK
Linux.

The distribution you are building ROCK Linux on should also be ROCK Linux.
It is also possible to build ROCK Linux on other distributions, but don't expect
it to work without some hacking ...

If you are building on older ROCK Linux versions (1.4/1.6) you should at least
make sure to upgrade/install the packages "Curl" "mktemp" and "coreutils".


	2. Extracting the sources
	=========================

Download the ROCK Linux sources (a tar.bz2 file of a few MB) from
www.rocklinux.org and extract it somewhere as root. The resulting directory
is the ROCK Linux 'base' directory.


	3. Configure the build
	======================

Type './scripts/Config' and a configuration menu comes up. Choose
your configuration (or simply leave the default values untouched). You need to
start the Config tool - even if you don't want to change anything.

It's also possible to have multiple configurations. Use the command
'./scripts/Config -cfg config-name' (where config-name can be any text not
containing whitespaces or any special characters). If you have choosen a name
for your configuration, you need to pass the '-cfg config-name' option as
first parameter to all the other scripts too - so they know which
configuration to read.

The default configuration name (when no -cfg option is passed) is 'default'.
The configuration is stored in the 'config/config-name' directory.


	4. Downloading the package sources
	==================================

Now you need to download the sources for the packages which are build in the
configuration you have choosen. Simply type: 
'./scripts/Download -cfg config-name -required'
If you want to download the sources for all packages (regardless if they are
required for your configuration), type './scripts/Download -all'.


	5. Building the distribution
	============================

Type './scripts/Build-Target -cfg config-name'. As mentioned already, it may 
take multiple days for the build to complete.

The resulting distribution is stored in the build/ directory.


	6. Creating CD Images
	=====================

To create a CD-Image to install from you can use './scripts/Create-ISO'.
Create-ISO takes at least two arguments: a name used as prefix for the
filename of the ISO images and the name of the configuration you
just built (usually 'default' or whatever you choose after -cfg).

Optionally you can use -size <MB> to specify the size of your CD-Rs.
Another optional parameter is -mkdebug which will create a VMWare-Config
to be used with your newly created iso.

The iso will, however, not be bootable, unless you configured and built
a 'bootdisk'-Target. This configuraton has to be the first configuration to
be passed to './scripts/Create-ISO'.

So, a complete call might look like this:

# ./scripts/Create-ISO -size 700 -mkdebug rock-cd bootdisk athlon pentium4 generic

This would create a CD-Set of iso images which are at most 700 MB big, the
first CD would be bootable and the set would contain the builds 'athlon',
'pentium4' and 'generic'.

You see, it's perfectly possible to have several optimised or just different
builds on one CD-Set. So you would only need one set to install different
machines.

If you have a DVD-Writer, you could also pass '-size 4300' and write that iso
on a DVD. That would make approx. 5 to 6 builds on one DVD.


	7. Cleaning up the source tree
	==============================

Simply type './scripts/Cleanup' to remove the src* directories. DO NOT REMOVE
THEM BY HAND! These directories may contain bind mounts to the rest of the
source tree and it is possible that you are going to remove everything in the
ROCK Linux base directory if you execute a simple 'rm -rf' to remove them ..

If you also want to remove the build/ directory type './scripts/Cleanup -full'.
