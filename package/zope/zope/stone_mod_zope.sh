ZOPESYSCONFDIR=/etc/opt/zope
PRODUCTTAB=$ZOPESYSCONFDIR/producttab

declare -a zope_containers
declare -a zope_products

[ -f $PRODUCTTAB ] || touch $PRODUCTTAB

zope_update_containers() {
	local line=0 size=
	
	while read zope_containers[line++]; do :; done < $PRODUCTTAB

	size=$line; for line in ${!zope_containers[@]}; do
		[ $line -lt $size ] || unset zope_containers[$line]
	done
	}

zope_containers_menu() {
	local containers= line=
	
	for line in ${!zope_containers[@]}; do
		[ -n "${zope_containers[$line]}" ] && \
			containers="$containers '${zope_containers[$line]}' \
				'zope_containers_edit $line'"
	done

	[ -z "$containers" ] || containers="$containers '' ''"

	eval "gui_menu zope_container 'ZOPE Product Containers' \
		$containers \
		'Add new product container' zope_containers_add"
	}

zope_containers_edit() {
	local container= line="$1"

	gui_input "Please enter a directory which contains ZOPE products" "${zope_containers[$line]}" container
	
	if [ -z "$container" ]; then
		unset zope_containers[$line]
		zope_update_products
	elif [ "${zope_containers[$line]}" != "$container" ]; then
		zope_containers[$line]="$container"
		zope_update_products
	fi
}

zope_containers_add() {
	local container=

	gui_input "Please enter a directory which contains ZOPE products" '' container

	if [ -n "$container" ]; then
		zope_containers[${#zope_containers[@]}]="$container"
		zope_update_products
	fi
}

zope_containers_commit() {
	local container=
	for container in ${!zope_containers[@]}; do
		echo "${zope_containers[$container]}"
	done > $PRODUCTTAB
}

zope_update_products() {
	local container=0 productdir=
	local init= product= version=
	local entry=0 size=

	for container in ${!zope_containers[@]}; do
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
			zope_products[$entry*3+0]="$product"
			zope_products[$entry*3+1]="$version"
			zope_products[$entry*3+2]="$productdir"
			(( entry++ ))
		done < <( ls -1 ${zope_containers[$container]}/*/__init__.py 2> /dev/null )
	done

	(( size=$entry*3 )); for entry in ${!zope_products[@]}; do
		[ $entry -lt $size ] || unset zope_products[$entry]
	done
}

zope_products_list() {
	local entry=0 count=
	local product= version= productdir=

	(( count=${#zope_products[@]}/3 ))
	while [ $entry -lt $count ]; do
		product=${zope_products[ $entry * 3 + 0 ]}	
		version=${zope_products[ $entry * 3 + 1 ]}	
		productdir=${zope_products[ $entry * 3 + 2 ]}	
		echo "'$product - $version' 'gui_message \"$productdir\"'"
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

# populate caches
zope_update_containers
zope_update_products

main() {
	while gui_menu zope 'ZOPE Manager' \
		'Product Containers'	'while zope_containers_menu; do : ; done'	\
		'Available Products'	'while zope_products_menu; do : ; done'		\
		'ZOPE Instances'	zope_instances	
		do : ; done

	zope_containers_commit
	
}
