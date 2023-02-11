//
//  DeCacher.swift
//  Iconset
//
//  Created by Aarnav Tale on 2/7/23.
//

import Foundation
import ArgumentParser
import Chalk

@available(macOS 10.15.4, *)
class DeCacher {
	private let sudo: Bool

	init() {
		getuid() == 0 ? (sudo = true) : (sudo = false)
	}

	func nuke() throws {
		if sudo {
			try nukeWithSudo()
		} else {
			try nukeWithoutSudo()
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

	private func nukeWithoutSudo() throws {
		var buffer = [CChar](repeating: 0, count: 8192) // This size is overkill but better safe than sorry
		guard let passphrase = readpassphrase(Log.prompt("Password (required to purge cache): "), &buffer, buffer.count, RPP_ECHO_OFF) else {
			print("No password supplied")
			throw ExitCode.failure
		}

		let password = (String(cString: passphrase) + "\n").data(using: .utf8)
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
		task.launchPath = "/usr/bin/sudo"
		task.arguments = ["-k"]
		try task.run()
		task.waitUntilExit()

		if task.terminationStatus != 0 {
			Log.warn("Failed to invalidate sudo credentials")
			Log.warn("Try running \(ck.dim.on("sudo -k"))")
		}
	}

	private func nukeWithSudo() throws {
		let task = Process()
		task.standardOutput = nil
		task.launchPath = "/bin/rm"
		task.arguments = ["-rf", "/Library/Caches/com.apple.iconservices.store"]
		try task.run()
		task.waitUntilExit()

		guard task.terminationStatus == 0 else {
			Log.error("Failed to purge icon cache")
			throw ExitCode.failure
		}
	}
}
