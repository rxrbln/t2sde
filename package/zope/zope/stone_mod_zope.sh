ZOPESYSCONFDIR=/etc/opt/zope
PRODUCTTAB=$ZOPESYSCONFDIR/producttab
INSTANCETAB=$ZOPESYSCONFDIR/instancetab

declare -a zope_containers
declare -a zope_instances
declare -a zope_products

[ -f $PRODUCTTAB ] || touch $PRODUCTTAB
[ -f $INSTANCETAB ] || touch $INSTANCETAB

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

zope_update_instances() {
	local line=0 size=
	
	while read zope_instances[line++]; do :; done < $INSTANCETAB

	size=$line; for line in ${!zope_instances[@]}; do
		[ $line -lt $size ] || unset zope_instances[$line]
	done
	}

zope_instances_menu() {
	local instances= line=
	
	for line in ${!zope_instances[@]}; do
		[ -n "${zope_instances[$line]}" ] && \
			instances="$instances '${zope_instances[$line]}' \
				'while zope_instances_products $line; do :; done'"
	done

	[ -z "$instances" ] || instances="$instances '' ''"

	eval "gui_menu zope_instance 'ZOPE Instances' \
		$instances \
		'Add new instance' zope_instances_add"
}

zope_instances_products() {
	local instance=$1 instancedir=${zope_instances[$1]}
	local installed= available=
	local productdir= product=
	local entry= count=
	local productname= version=
	local installedlist= code=

	count=${#zope_products[@]}; (( count=count/3 ))

	if [ -d $instancedir/Products ]; then
		installed="'Installed products:' ''"

		for product in $instancedir/Products/*; do
			if [ -d $product/ -a -L $product ]; then
				productdir="`readlink -f $product`"

				for (( entry=0; entry<count; entry++ )); do
					[ "${zope_products[$entry*3+2]}" != "$productdir" ] || break
				done

				if [ "${zope_products[$entry*3+2]}" == "$productdir" ]; then
					productname="${zope_products[$entry*3+0]}"
					version="${zope_products[$entry*3+1]}"

					installedlist="$installedlist $productname"

					code="zope_instances_update \"${productname}\" \"${product}\" \"${version}\""
					installed="$installed '$productname - $version' '$code'"
				else
					installed="$installed '[$productdir] unknown' ''"
				fi
			elif [ -d $product/ ]; then
				installed="$installed '[${product##*/}] static' ''"
			fi
		done

		available="'Other available products:' ''"

		for (( entry=0; entry<count; entry++ )); do
			set -- $installedlist
			while [ $# -gt 0 ]; do
				[ "$1" != "${zope_products[$entry*3+0]}" ] || continue 2
				shift
			done
			productname="${zope_products[$entry*3+0]}"
			product="$instancedir/Products/$productname"

			installedlist="$installedlist $productname"

			if [ -e "$product" ]; then
				code=
			else
				code="zope_instances_install ${productname} \"$product\""
			fi

			available="$available '$productname' '$code'"
		done
	else
		installed="'* NOT A VALID INSTANCE DIR*' ''"
	fi

	eval "gui_menu zope_instance_product 'Zope Instance Products' \
		'location: $instancedir' 'zope_instances_edit $instance' \
		'' '' \
		$installed \
		'' '' \
		$available"
}

zope_instances_install() {
	local productname="$1" product="$2"
	local productdir= version=

	if gui_yesno "Are you sure you want to install $productname?"; then
		count=${#zope_products[@]}; (( count=count/3 ))
		for (( entry=0; entry<count; entry++ )); do
			[ "${zope_products[$entry*3+0]}" == "$productname" ] || continue
			version="${zope_products[$entry*3+1]}"
			productdir="${zope_products[$entry*3+2]}"
			break
		done

		if [ ! -e "$product" -a "${zope_products[$entry*3+0]}" == "$productname" ]; then
			if ln -s "$productdir" "$product"; then
				gui_message "$productname - $version was succesfully installed"
		
				zope_instances_update "${productname}" "${product}" "${version}"
			else
				gui_message "Failed to install $productname - $version"
			fi
		else
			gui_message "Failed to install $productname, garbage on the road."
		fi
	fi
}
zope_instances_uninstall() {
	rm "$1"
}
zope_instances_set() {
	rm "$1"
	ln -s "$2" "$1"
}

zope_instances_update() {
	local productname="$1" product="$2" version="$3"
	local versions= entry= count=

	count=${#zope_products[@]}; (( count=count/3 ))
	for (( entry=0; entry<count; entry++ )); do
		[ "${zope_products[$entry*3+0]}" == "$productname" ] || continue
		if [ "${zope_products[$entry*3+1]}" == "$version" ]; then
			versions="$versions '(X) ${zope_products[$entry*3+1]}' 'true'"
		else
			versions="$versions '( ) ${zope_products[$entry*3+1]}' \
				'zope_instances_set \"$product\" \"${zope_products[$entry*3+2]}\"'"
		fi
	done

	eval "gui_menu zope_instance_update 'Update Zope Instance Product - $productname' \
		$versions \
		'' '' \
		'Uninstall $productname - $version' 'zope_instances_uninstall \"$product\"'"
	true
}

zope_instances_edit() {
	local instance= line="$1"

	gui_input "Please enter a directory which contains the ZOPE instance" "${zope_instances[$line]}" instance
	
	if [ -z "$instance" ]; then
		unset zope_instances[$line]
	elif [ "${zope_instances[$line]}" != "$instance" ]; then
		zope_instances[$line]="$instance"
	fi
}

zope_instances_add() {
	local instance=

	gui_input "Please enter a directory which contains the ZOPE instance" '' instance

	if [ -n "$instance" ]; then
		zope_instances[${#zope_instances[@]}]="$instance"
	fi
}

zope_instances_commit() {
	local instance=
	for instance in ${!zope_instances[@]}; do
		echo "${zope_instances[$instance]}"
	done > $INSTANCETAB
}

# populate caches
zope_update_containers
zope_update_products
zope_update_instances

main() {
	while gui_menu zope 'ZOPE Manager' \
		'Product Containers'	'while zope_containers_menu; do :; done'	\
		'Available Products'	'while zope_products_menu; do :; done'		\
		'ZOPE Instances'	'while zope_instances_menu; do :; done'
		do :; done

	zope_containers_commit
	zope_instances_commit
}
