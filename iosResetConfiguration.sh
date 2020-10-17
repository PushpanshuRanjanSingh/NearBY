#!/bin/sh

#   This files clean and refresh the ios project
#   sudo sh flutterrepair.sh

echo "Flutter Repair (by jeroen-meijer on GitHubGist)"
set -e
echo Cleaning project...
flutter clean 2>&1 >/dev/null

echo Updating Pod...
pod repo update

if ! ( "${PWD##*/}" == 'ios')
    then cd ios
fi

echo Removing pod files...
rm -rf Podfile.lock Pods/ 2>&1 >/dev/null

cd ..

echo Removing cached flutter dependency files...
rm -rf .packages .flutter-plugins 2>&1 >/dev/null

echo Getting all flutter packages...
flutter packages get

cd ios

echo Running pod install...
pod install

cd ..

echo DONE!
