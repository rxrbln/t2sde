#!/bin/bash

tmp=`mktemp`

cd ~/.wine/drive_c/Program\ Files/Av5e

# run wine in the background, to display a dialog if the fonts are processed
wine avocr $* 2> $tmp &

sleep 1

if grep -q "Font metrics" $tmp; then
	Xdialog --no-cancel --infobox \
"The OCR is analyzing the system fonts. It may take up to
30 seconds until the OCR dialog appears." 8 48 10000
fi

rm $tmp

