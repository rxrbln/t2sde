#!/usr/bin/gawk -f

BEGIN {
	speedargidx=0;
	sizeargidx=0;
	isholy=0;
}

ARGIND == 1 {
	holylist[$4] = 1;
}

ARGIND == 2 {
	if ( gsub("^-SPEED", "") == 1 )
		speedarg[speedargidx++] = $0;
	else
	if ( gsub("^-SIZE", "") == 1 )
		sizearg[sizeargidx++] = $0;
	else {
		speedarg[speedargidx++] = $0;
		sizearg[sizeargidx++] = $0;
	}
	if ( holylist[$0] == 1 )
		isholy=1;
}

END {
	if ( isholy )
		for (i=0; i<speedargidx; i++)
			print speedarg[i];
	else
		for (i=0; i<sizeargidx; i++)
			print sizearg[i];
}

