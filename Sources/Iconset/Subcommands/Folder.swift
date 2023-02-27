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
			var failed = [[String: String]]()
			var unmatched = [String]()
			var completed = [[String]]()

			for item in items {
				if item.contains(".icns") {
					let application = item.replacingOccurrences(of: ".icns", with: ".app")
					let iconPath = URL(fileURLWithPath: "\(iconsPath)/\(item)")

					guard let applicationPath = findApplicationPath(application) else {
						unmatched.append(item)
						continue
					}

					let setter = IconSetter(from: iconPath)

					do {
						try setter.generateResource()
						try setter.updateApplication(applicationPath)
					} catch {
						if !unmatched.contains(item) {
							failed.append([item: error.localizedDescription])
						}

						continue
					}

					completed.append([item, application])
				}
			}

			if completed.count > 0 {
				let mapped = completed.map { "\($0[0]) \(ck.dim.on($0[1]))" }
				let array = "\n  - \(mapped.joined(separator: "\n  - "))\n"
				Log.info("The following icons were successfully set: \(array)")
			}

			if unmatched.count > 0 {
				let array = "\n  - \(unmatched.joined(separator: "\n  - "))\n"
				Log.warn("The following icons lack a matching application: \(array)")
			}

			if failed.count > 0 {
				let array = "\n  - \(failed.map { "\($0.keys.first!) - \(ck.dim.on($0.values.first!))" }.joined(separator: "\n  - "))\n"
				Log.error("The following icons failed to set: \(array)")
			}

			let decacher = DeCacher()
			try decacher.nuke()
		}

		func findApplicationPath(_ application: String) -> URL? {
			for applicationPath in options.applicationPaths {
				// Replace the ~ with the user's home directory we found in iconsPath
				let realPath = applicationPath.replacingOccurrences(of: "~", with: getHomePath())
				guard let enumerator = FileManager.default.enumerator(atPath: realPath) else {
					continue
				}

				while let element = enumerator.nextObject() as? String {
					if element.contains(application) {
						return URL(fileURLWithPath: "\(realPath)/\(element)")
					}

					if element.contains(".app") {
						enumerator.skipDescendants()
					}
				}
			}

			return nil
		}

		func getHomePath() -> String {
			if getuid() == 0 {
				let user = iconsPath.components(separatedBy: "/")

				if user.count > 2 && user[1] == "Users" {
					return "/Users/\(user[2])"
				}
			}

			return NSHomeDirectory()
		}
	}
}
