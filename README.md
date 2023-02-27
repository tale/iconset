# iconset

A nifty command line tool to manage macOS icons<br/>

`iconset` is a new command line tool for macOS that allows you to change icons for macOS apps (excluding system ones of course).<br/>
It's considered generally stable and utilizes `NSWorkspace()` to change icons, so it should work on all macOS versions above 15.4.1.<br/>

## Installing

In the future, I plan to set this up on brew, but for now the following command should work:<br/>
`curl https://github.com/tale/iconset/releases/download/v1.0.0/iconset -Lo /usr/local/bin/iconset`<br/>
`sudo chmod +x /usr/local/bin/iconset`<br/>

## Usage

```
OVERVIEW: A nifty command line tool to manage macOS icons

USAGE: iconset <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  folder                  Set icons using a folder of '.icns' files with the same names as their '.app' counterparts
  single                  Set the icon of a '.app' file using a '.icns' file
  revert                  Revert a custom icon by supplying a path to a '.app' file or directory

  See 'iconset help <subcommand>' for detailed help.
```

## Current Options

- Specifying an icon and an application file to theme<br/>
- Specifying the directory where Applications are stored (defaults to `/Applications, ~/Applications`)<br/>
- Specifying a folder of `.icns` files who's names match their respective icons<br/>
- Reverting an icon by supplying a folder of `.icns` or the path to a `.app`<br/>
- Recursively searches through folders for `.app` files<br/>

## Possible Expansions

- Advanced manifest file which lets you map `.icns` files to `.app` files directly<br/>
- Accompanying status bar app for macOS with automation and easy config UI<br/>

## Building

The project is an SPM Package that requires Xcode 13 and Swift 5.5.<br/>
Run `swift build --disable-sandbox` in the project root to build a debug binary.<br/>
For release binaries, instead run `swift build -c release --arch arm64 --arch x86_64 --disable-sandbox` in the project root<br/>
Currently, the in-app Xcode builds are sandbox enforced, potentially breaking `iconset`'s access to certain files.<br/>
