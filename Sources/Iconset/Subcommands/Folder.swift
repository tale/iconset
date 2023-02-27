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

			let applicationPaths = options.applicationPaths.split(separator: ",").map {
				String($0).trimmingCharacters(in: .whitespacesAndNewlines)
			}

			var applications = [String]()
			DispatchQueue.concurrentPerform(iterations: applicationPaths.count) {
				let path = applicationPaths[$0]
				let recurse = Recurse(directory: path).recurse()
				applications.append(contentsOf: recurse)
			}

			DispatchQueue.concurrentPerform(iterations: items.count) {
				let item = items[$0]
				if item.contains(".icns") {
					let application = item.replacingOccurrences(of: ".icns", with: ".app")
					let applicationPath = URL(fileURLWithPath: "\(applications.first { $0.contains(application) } ?? "")")
					let iconPath = URL(fileURLWithPath: "\(iconsPath)/\(item)")

					guard FileManager.default.fileExists(atPath: applicationPath.path) else {
						unmatched.append(item)
						return
					}

					let setter = IconSetter(from: iconPath)

					do {
						try setter.generateResource()
						try setter.updateApplication(applicationPath)
					} catch {
						if !unmatched.contains(item) {
							failed.append([item: error.localizedDescription])
						}
						return
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
	}
}
