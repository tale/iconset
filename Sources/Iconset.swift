//
//  Iconset.swift
//  Iconset
//
//  Created by Aarnav Tale on 11/11/21.
//  Copyright (c) 2021 Aerum LLC. All rights reserved.
//

import Chalk
import Foundation
import ArgumentParser

@available(macOS 10.15.4, *)
struct Iconset: ParsableCommand {
	static var configuration = CommandConfiguration(
		abstract: "A nifty command line tool to manage macOS icons",
		subcommands: [Iconset.Folder.self, Iconset.Single.self, Iconset.Revert.self]
	)
	
	struct Options: ParsableArguments {
		@Option(name: .shortAndLong, help: "The path to the applications to theme")
		var applicationsPath = "/Applications"
	}
	
	public static func purge(passphrase: Data? = nil) throws {
		var password = passphrase
		
		if password == nil {
			// All of these operations require sudo so let's store the password first if it's not already passed in
			// We can't use getpass() because it doesn't support passwords longer than 128 chars
			
			var buffer = [CChar](repeating: 0, count: 8192) // This size is overkill but better safe than sorry
			guard let passphrase = readpassphrase(Log.prompt("Password (required to purge cache): "), &buffer, buffer.count, RPP_ECHO_OFF) else {
				print("No password supplied")
				throw ExitCode.failure
			}
			
			password = (String(cString: passphrase) + "\n").data(using: .utf8)
		}
		
		let sudo = Process()
		let input = Pipe()
		sudo.standardInput = input
		sudo.standardOutput = nil
		sudo.standardError = nil
		sudo.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
		sudo.arguments = [
			"-S",
			"/bin/rm", "-rf",
			"/Library/Caches/com.apple.iconservices.store"
		]
		
		sudo.launch() // This is deprecated, but the replacement run() doesn't wait for us to pass input
		try input.fileHandleForWriting.write(contentsOf: password!)
		try input.fileHandleForWriting.close()
		sudo.waitUntilExit()
		
		guard sudo.terminationStatus == 0 else {
			Log.error("Failed to purge icon cache")
			throw ExitCode.failure
		}
		
		let task = Process()
		task.standardOutput = nil
		task.launchPath = "/usr/bin/killall"
		task.arguments = ["Dock"]
		try task.run()
		task.waitUntilExit()
		
		guard task.terminationStatus == 0 else {
			Log.error("Failed to restart Dock")
			throw ExitCode.failure
		}
		
		Log.info("Cache purged successfully. \(ck.dim.on("Updated icons will show on Application relaunch"))")
	}
}
