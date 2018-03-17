#!/bin/sh

repo='';
release='empty';
meta=false;
force=false;

while getopts "fmsr:" opt; do
	case "$opt" in
	f)
		force=true;
		;;
	m)
		meta=true;
		;;
	s)
		repo="staging";
		;;
	r)
		repo="release";
		release=$OPTARG;
		;;
	esac
done

if [ "$repo" != '' ]
then
	cd ecom-oneapp-data-${repo};
else
	echo "Please chose repo (-s for staging or -r for release)";
	exit 1;
fi

if ! "$force"; then
	rm site_template.zip;
	git reset --hard;

	if [ "$repo" == 'release' ]
	then
		if [ "$release" == 'empty' ]
		then
			echo "Please provide the release branch";
			exit 1;
		else
			git checkout release/${release};
		fi
	fi

	git pull;

	if [ "$repo" == 'staging' ]
	then
		cd site_template;
		if "$meta"; then
			find -maxdepth 1 ! -name meta ! -name . -exec rm -r {} \;
			cd ..;
		else
			rm -r catalogs custom-objects inventory-lists pricebooks;
			cd sites;
			rm -r spiewak bdbaggies;
			cd ../..;
		fi
	fi

	/c/Program\ Files\ \(x86\)/GnuWin32/bin/zip -r site_template.zip site_template;
fi

rm -r /d/TLGSource/build-suite/output/TLG/site_import/*.*;
cp site_template.zip /d/TLGSource/build-suite/output/TLG/site_import/;
cd /d/TLGSource/build-suite;
grunt importSite;