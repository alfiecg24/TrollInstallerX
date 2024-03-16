#!/usr/bin/env bash

set -e

xcodebuild -configuration Release -derivedDataPath DerivedData/TrollInstallerX -destination 'generic/platform=iOS' -scheme TrollInstallerX CODE_SIGNING_ALLOWED="NO" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_IDENTITY=""
pushd DerivedData/TrollInstallerX/Build/Products/Release-iphoneos
rm -rf Payload TrollInstallerX.ipa
mkdir Payload
cp -r TrollInstallerX.app Payload
zip -qry TrollInstallerX.ipa Payload
popd
cp DerivedData/TrollInstallerX/Build/Products/Release-iphoneos/TrollInstallerX.ipa .
open -R TrollInstallerX.ipa
