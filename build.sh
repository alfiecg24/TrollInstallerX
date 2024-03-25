#!/usr/bin/env bash

set -e

xcodebuild -configuration Release -derivedDataPath DerivedData/TrollInstallerX -destination 'generic/platform=iOS' -scheme TrollInstallerX CODE_SIGNING_ALLOWED="NO" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_IDENTITY=""
cp Resources/ents.plist DerivedData/TrollInstallerX/Build/Products/Release-iphoneos/
pushd DerivedData/TrollInstallerX/Build/Products/Release-iphoneos
rm -rf Payload TrollInstallerX.ipa
mkdir Payload
cp -r TrollInstallerX.app Payload
ldid -Sents.plist Payload/TrollInstallerX.app
zip -qry TrollInstallerX.ipa Payload
popd
cp DerivedData/TrollInstallerX/Build/Products/Release-iphoneos/TrollInstallerX.ipa .
rm -rf Payload
open -R TrollInstallerX.ipa
