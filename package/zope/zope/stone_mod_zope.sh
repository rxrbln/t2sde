ZOPESYSCONFDIR=/etc/opt/zope
PRODUCTTAB=$ZOPESYSCONFDIR/producttab

[ -f $PRODUCTTAB ] || touch $PRODUCTTAB

zope_containers_menu() {
	local line=0 container= containers=

	while read container; do
		(( line++ ))
		containers="$containers '$container' 'zope_containers_edit $line'"
	done < $PRODUCTTAB

	[ -z "$containers" ] || containers="$containers ' ' true"

	eval "gui_menu zope_container 'ZOPE Product Containers' \
		$containers \
		'Add new product container' zope_containers_add"
	}

zope_containers_edit() {
	local line=$1 lines=`wc -l $PRODUCTTAB`
	# TODO: edit line $line
	true
}
zope_containers_add() {
	local container=

	gui_input "Please enter a directory which contains ZOPE products" '' container

	if [ -n "$container" ]; then
		echo "$container" >> $PRODUCTTAB
	fi
}

zope_products_list() {
	local container= productdir=
	local init= product= version=
	for container in $( cat $PRODUCTTAB ); do
		while read init; do
			productdir=${init%/__init__.py}
			product=${productdir##*/}
			if [ -f $productdir/version.txt ]; then
				version=$( cat $productdir/version.txt )
			elif [ "${product/-/}" != "$product" ]; then
				version="${product#*-}"
			else
				version=undefined
			fi
			product=${product%%-*}
			echo "'$product ($version)'	true"
		done < <( ls -1 $container/*/__init__.py 2> /dev/null )
	done
}
zope_products_menu() {
	eval "gui_menu zope_products 'ZOPE Products List' \
		$( zope_products_list | sort -t'	' | tr '\n' ' ' )"
}

zope_instances() {
	true
}

main() {
	while gui_menu zope 'ZOPE Manager' \
		'Product Containers'	'while zope_containers_menu; do : ; done'	\
		'Available Products'	'while zope_products_menu; do : ; done'		\
		'ZOPE Instances'	zope_instances	
		do : ; done
}
