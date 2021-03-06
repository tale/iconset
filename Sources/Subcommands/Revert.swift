//
//  Revert.swift
//  Iconset
//
//  Created by Aarnav Tale on 11.12/21.
//  Copyright (c) 2021 Aerum LLC. All rights reserved.
//

import Chalk
import AppKit
import Foundation
import ArgumentParser

@available(macOS 10.15.4, *)
extension Iconset {
	struct Revert: ParsableCommand {
		static var configuration = CommandConfiguration(
			commandName: "revert",
			abstract: "Revert a custom icon by supplying a path to a '.app'"
		)
		
		@Argument(help: "A path to a '.app' file")
		var path: String
		
		mutating func run() throws {
			guard FileManager.default.fileExists(atPath: path) else {
				Log.error("The supplied path does not exist")
				throw ExitCode.failure
			}
			
			let url = URL(fileURLWithPath: path)
			
			guard url.hasDirectoryPath else {
				Log.error("Invalid path supplied")
				throw ExitCode.failure
			}
			
			// This extended attribute is used to override icons
			removexattr(url.path, "com.apple.FinderInfo", 0)
			try FileManager.default.removeItem(atPath: url.appendingPathComponent("Icon\r").path)
			try Iconset.purge()
		}
	}
}
