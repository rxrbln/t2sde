ZOPESYSCONFDIR=/etc/opt/zope
PRODUCTTAB=$ZOPESYSCONFDIR/producttab

zope_containers=
zope_products=
zope_update=1

[ -f $PRODUCTTAB ] || touch $PRODUCTTAB

zope_update_cache() {
	zope_update_containers
	zope_update_products
	zope_update=0
}

zope_update_containers() {
	local line=0 container=
	
	zope_containers=
	while read container; do
		zope_containers[ $line ]="$container"
		(( line++ ))
	done < $PRODUCTTAB
	}

zope_containers_menu() {
	local line=0 containers= count=
	[ $zope_update -eq 0 ] || zope_update_cache
	
	count=${#zope_containers[@]}

	while [ $line -lt $count ]; do
		containers="$containers '${zope_containers[ $line ]}' 'zope_containers_edit $line'"
		(( line++ ))
	done

	[ -z "$containers" ] || containers="$containers '' ''"

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
		zope_containers[ ${#zope_containers[@]} ]="$container"
		echo "$container" >> $PRODUCTTAB
	fi
}

zope_update_products() {
	local container= productdir=
	local init= product= version=
	local entry=0 

	zope_products=

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
			zope_products[ $entry * 3 + 0 ]="$product"
			zope_products[ $entry * 3 + 1 ]="$version"
			zope_products[ $entry * 3 + 2 ]="$productdir"
			(( entry++ ))
		done < <( ls -1 $container/*/__init__.py 2> /dev/null )
	done
}

zope_products_list() {
	local entry=0 count=
	local product= version=
	[ $zope_update -eq 0 ] || zope_update_cache

	(( count=${#zope_products[@]}/3 ))
	while [ $entry -lt $count ]; do
		product=${zope_products[ $entry * 3 + 0 ]}	
		version=${zope_products[ $entry * 3 + 1 ]}	
		echo "'$product - $version' 'true'"
		(( entry++ ))
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
