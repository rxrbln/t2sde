#!/bin/sh
# --test-runner for cross builds: compile-time probes instead of running $1
probe() {
	{ sed '/^int main/,$d' "$1.c"; echo "int ngx_probe[($2) ? 1 : -1];"; } |
		$CC -I"${1%/*}" -x c -c -o /dev/null - 2>/dev/null
}

case "$2" in
feature)
	exit 0 ;;
sizeof)
	for n in 1 2 4 8 16; do
		probe "$1" "sizeof($3) == $n" && echo $n && exit 0
	done
	exit 1 ;;
endianness)
	probe "$1" "__BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__" ;;
*)
	exit 1 ;;
esac
