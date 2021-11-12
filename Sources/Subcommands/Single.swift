//
//  Single.swift
//  Iconset
//
//  Created by Aarnav Tale on 6/20/21.
//  Copyright (c) 2021 Aerum LLC. All rights reserved.
//

import Chalk
import AppKit
import Foundation
import ArgumentParser

@available(macOS 10.15.4, *)
extension Iconset {
	struct SingleIcon: ParsableCommand {
		static var configuration = CommandConfiguration(
			commandName: "single",
			abstract: "Set the icon of a '.app' file using a '.icns' file"
		)
		
		@OptionGroup
		var options: Iconset.Options
		
		@Argument(help: "A path to a '.icns' file")
		var iconPath: String
		
		@Argument(help: "A path to a '.app' file")
		var appPath: String
		
		mutating func run() throws {
			guard FileManager.default.fileExists(atPath: iconPath) else {
				Log.error("Specified icon does not exist")
				throw ExitCode.failure
			}
			
			guard FileManager.default.fileExists(atPath: appPath) else {
				Log.error("Specified application does not exist")
				throw ExitCode.failure
			}
			
			let image = NSImage(contentsOfFile: iconPath)
			NSWorkspace.shared.setIcon(image, forFile: appPath, options: .excludeQuickDrawElementsIconCreationOption)
			Log.info("\(URL(fileURLWithPath: iconPath).lastPathComponent) \(ck.dim.on(URL(fileURLWithPath: appPath).lastPathComponent))")
			try Iconset.purge()
		}
	}
}
