#
# Example login script
#

# Add the current directory to the path
#
PATH="$PATH:."

# We want to get write(1) and talk(1) messages
#
# mesg y

# Let's use the gnome desktop per default (overwrite system default)
#
# export WINDOWMANAGER=gnome

# Set personal timezone and language
#
# export TZ=Europe/Vienna  # Austrian time - list at /usr/share/zoneinfo
# export LANG=de_AT        # German (AT) - see 'locale -a' output

# Write the hostname in the window title
# (interactive shells in xterm terminals only)
#
# if [ "$PS1" ] ; then
#   case "$TERM" in xterm*)
#	echo -ne "\033]0;`hostname --fqdn`\007" ;;
#   esac
# fi

