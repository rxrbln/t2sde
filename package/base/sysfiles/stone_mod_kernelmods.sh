## [MAIN] 30 kernelmods Kernel Module loader

# The function is used to call modprobe only so we can catch any error
# and display it in a neat way.  Otherwise calling modprobe directly works.
loadmod()
{
# $1 is the module to load, any errors go into result for display.
	result=`modprobe $1 2>&1`
	if [ ! -z "$result" ]; then
		gui_message "Error loading module $1: \n$result"
	fi
}

# This is the heart of things, it builds the menues and for sub directories
# calles it self recursively via the menu. main() also calles it.
selectmod()
{
# This is how to call gui_menu
# gui_menu "ID" "Title" "Text" "Action" [ "Text" "Action" [ .. ] ]

	while
		# Set 'ID' and 'Title' for this menu.
		cmd="gui_menu selectmod_${1//\//_} 'Select module you want to load or subdir you want to enter:
Current directory is [$1/$2].'"
		# Build the menu, pull a directory listing to get the data.
		for mod in `ls -1 $1 | sort`; do
			if [ -d $1/$mod -a "$mod" != "build" ]; then
				# It is a sub-directory, use recursion.
				cmd="$cmd '[dir]  $mod/' 'selectmod $1/$mod'"
			elif [ "$mod" != "${mod%.o}" ] ; then
				# It's a module (name.o)
				cmd="$cmd '[mod]  $mod' 'loadmod ${mod%.o}'"
			fi
		done

		# run gui_menu ...
		eval "$cmd"
    do : ; done
}

main() {
	# Call selectmod to build the menues.
	selectmod "/lib/modules/`uname -r`"
}

