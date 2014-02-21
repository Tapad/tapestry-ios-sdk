#!/bin/bash

#
# Generates documentation for this project and moves it into the ./doc directory.
#

# appledoc executable is required.
which appledoc &> /dev/null
if [ $? -ne 0 ]; then
  echo "appledoc is not installed. Exiting."
  exit 1
fi

# Move to the correct base directory.
srcBaseDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $srcBaseDir

# appledoc --project-name "Tapestry iOS SDK" --project-company "Tapad" --company-id com.tapad.tapestry --create-html --keep-undocumented-objects --output . .
appledoc --project-name "Tapestry iOS SDK" --project-company "Tapad" --company-id com.tapad.tapestry --create-html --output . Tapestry

rm -rf ./doc

docBaseDir=$(cat docset-installed.txt | awk '/Path/ { print $2 }')

htmlDocDir="$docBaseDir/Contents/Resources/Documents"

cp -R $htmlDocDir doc
