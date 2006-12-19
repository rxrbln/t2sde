
# Sort the kernel images so that a defined default kernel is on-top.
#
# Copyright (C) 2006 Archivista GmbH
# Copyright (C) 2006 Rene Rebe

BEGIN {
	default_kernel="2.6.17.14-dist"

	global=1
	n=0
}

# do we arrived at the kernel images?
/title/ {
	global=0
	n=n+1
}

{	# copy global config
	if (global)
		print
}

# save the image config
/title/		{titles[n]=$0}
/kernel/	{kernels[n]=$0}
/initrd/	{initrds[n]=$0}

function print_kernel (i) {
	print titles[i]
	print kernels[i]
	if (initrds[i] != "")
		print initrds[i]
	print ""
}

END {
	# output images

	# first the default one
	for (i = 1; i <= n; ++i) {
		#if (kernels[i] ~ $dk)
		if (match (kernels[i], default_kernel))
			print_kernel(i)
	}

	# then the others
	for (i = 1; i <= n; ++i) {
		if (! match (kernels[i], default_kernel))
			print_kernel(i)
	}
}
