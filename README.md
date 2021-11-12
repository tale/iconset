# iconset
A nifty command line tool to manage macOS icons<br/>

`iconset` is a new command line tool for macOS that allows you to change icons for macOS apps (excluding system ones of course).<br/>
It is still in its early stages and as time goes on, more customization schemes will be arriving with later releases.

## Installing
In the future, I plan to set this up on brew, but for now the following command should work:<br/>
`curl https://github.com/tale/iconset/releases/download/v0.2-beta/iconset -Lo /usr/local/bin/iconset`<br/>
`sudo chmod +x /usr/local/bin/iconset`<br/>

## Usage
Coming soon, for now just reference them by running `iconset --help`

## Current Options
- Specifying an icon and an application file to theme<br/>
- Specifying the directory where Applications are stored (defaults to `/Applications`)<br/>
- Specifying a folder of `.icns` files who's names match their respective icons<br/>
- Reverting an icon by supplying a folder of `.icns` or the path to a `.app`<br/>

## Coming Soon
- Advanced manifest file which lets you map `.icns` files to `.app` files directly<br/>
- Recursive directory search for applications and icons<br/>
- Accompanying status bar app for macOS with automation and easy config UI<br/>

## Building
The project is an SPM Package that requires Xcode 13 and Swift 5.5.<br/>
Run `swift build --disable-sandbox` in the project root to build a debug binary.<br/>
For release binaries, instead run `swift build -c release --arch arm64 --arch x86_64 --disable-sandbox` in the project root<br/>
Currently, the in-app Xcode builds are sandbox enforced, potentially breaking `iconset`'s access to certain files.<br/>
