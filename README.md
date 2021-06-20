# iconset
A nifty command line tool to manage macOS icons<br/>

`iconset` is a new command line tool for macOS that allows you to change icons for macOS apps (excluding system ones of course).<br/>
It is still in its early stages and as time goes on, more customization schemes will be arriving with later releases.

## Installing
In the future, I plan to set this up on brew, but for now the following command should work:<br/>
`curl https://github.com/tale/iconset/releases/download/v0.1-alpha.1/iconset -o /usr/local/bin/iconset`<br/>
`sudo chmod +x /usr/local/bin/iconset`<br/>

## Usage
Coming soon, for now just reference them by running `iconset --help`

## Current Options
- Specifying an icon and an application file to theme<br/>
- Specifying the directory where Applications are stored (defaults to `/Applications`)<br/>
- Specifying a folder of `.icns` files who's names match their respective icons<br/>

## Coming Soon
- Advanced manifest file which lets you map `.icns` files to `.app` files directly<br/>
- Recursive directory search for applications and icons<br/>
- Better permission handling for root<br/>
- Accompanying status bar app for macOS with automation and easy config UI<br/>

## Building
Building is simple when using Xcode (however this requires Swift 5.5 and Xcode 13 beta).<br/>
If you encounter issues with Xcode, run `swift build` in the project root to build a debug binary.<br/>
For release binaries, instead run `swift build -c release --arch arm64 --arch x86_64` in the project root<br/>
