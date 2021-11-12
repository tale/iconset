//
//  Folder.swift
//  Iconset
//
//  Created by Aarnav Tale on 6/19/21.
//  Copyright (c) 2021 Aerum LLC. All rights reserved.
//

import Chalk
import AppKit
import Foundation
import ArgumentParser

@available(macOS 10.15.4, *)
extension Iconset {
	struct Folder: ParsableCommand {
		static var configuration = CommandConfiguration(
			commandName: "folder",
			abstract: "Set icons using a folder of '.icns' files with the same names as their '.app' counterparts"
		)
		
		@OptionGroup
		var options: Iconset.Options
		
		@Argument(help: "A path to a folder containing '.icns' files")
		var iconsPath: String
		
		mutating func run() throws {
			let items = try FileManager.default.contentsOfDirectory(atPath: iconsPath)
			var failed = [String]()
			var completed = [[String]]()

			for item in items {
				if item.contains(".icns") {
					let application = item.replacingOccurrences(of: ".icns", with: ".app")
					let applicationPath = "\(options.applicationsPath)/\(application)"
					
					guard FileManager.default.fileExists(atPath: applicationPath) else {
						failed.append(item)
						continue
					}
					
					completed.append([item, application])
					let image = NSImage(contentsOfFile: "\(iconsPath)/\(item)")
					NSWorkspace.shared.setIcon(image, forFile: applicationPath, options: .excludeQuickDrawElementsIconCreationOption)
				}
			}
			
			if completed.count > 0 {
				let mapped = completed.map { "\($0[0]) \(ck.dim.on($0[1]))" }
				let array = "\n  - \(mapped.joined(separator: "\n  - "))\n"
				Log.info("The following icons were successfully set: \(array)")
			}
			
			if failed.count > 0 {
				let array = "\n  - \(failed.joined(separator: "\n  - "))\n"
				Log.warn("The following icons lack a matching application: \(array)")
			}
			
			try Iconset.purge()
		}
	}
}
