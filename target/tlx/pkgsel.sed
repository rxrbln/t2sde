# only cross compiler, no single file in the target ...
/ automake /		{ s,^. [^ ]*,X 0---------,; p; d; }
/ autoconf /		{ s,^. [^ ]*,X 0---------,; p; d; }
/ libtool /		{ s,^. [^ ]*,X 0---------,; p; d; }
/ cache /		{ s,^. [^ ]*,X 0---------,; p; d; }
/ binutils /		{ s,^. [^ ]*,X 0---------,; p; d; }
/ gmp /			{ s,^. [^ ]*,X 0---------,; p; d; }
/ mpfr /		{ s,^. [^ ]*,X 0---------,; p; d; }
# if we would need C++ this would need to be build in 1 as well
/ gcc /			{ s,^. [^ ]*,X 0---------,; p; d; }
