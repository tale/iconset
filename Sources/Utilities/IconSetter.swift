//
//  IconSetter.swift
//  Iconset
//
//  Created by Aarnav Tale on 2/7/23.
//

import AppKit
import Foundation
import ArgumentParser

enum SetAttributeError: Error {
	case fileNotFound
	case noPermission
	case xattrGeneric
}

extension SetAttributeError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .fileNotFound:
			return "File not found"
		case .noPermission:
			return "Missing permissions to set attribute"
		case .xattrGeneric:
			return "Unknown xattr error"
		}
	}
}

extension Array {
	func chunked(into size: Int) -> [[Element]] {
		return stride(from: 0, to: count, by: size).map {
			Array(self[$0 ..< Swift.min($0 + size, count)])
		}
	}
}

class IconSetter {
	private let iconPath: URL
	private let userIconPath: URL
	private let resourcePath: URL

	init(from iconPath: URL) {
		let randomID = UUID().uuidString
		let tempDirectory = FileManager.default.temporaryDirectory

		var tempIconPath = tempDirectory.appendingPathComponent(randomID)
		tempIconPath.appendPathExtension("icns")

		var tempResourcePath = tempDirectory.appendingPathComponent(randomID)
		tempResourcePath.appendPathExtension("rsrc")

		self.iconPath = tempIconPath
		self.userIconPath = iconPath
		self.resourcePath = tempResourcePath
	}

	func generateResource() throws {
		try FileManager.default.copyItem(at: self.userIconPath, to: self.iconPath)
		Log.debug("Copied file to \(self.userIconPath)")

		let image = NSImage(contentsOf: self.iconPath)
		NSWorkspace.shared.setIcon(image, forFile: self.iconPath.path)
		Log.debug("Set icon for \(self.userIconPath) to \(self.iconPath) (via NSWorkspace)")

		// Create the resource file so we can get a valid file handle
		guard FileManager.default.createFile(atPath: self.resourcePath.path, contents: nil, attributes: nil) else {
			// Handle this soon
			throw NSError()
		}

		defer {
			try? FileManager.default.removeItem(at: self.iconPath)
			Log.debug("Removed temporary icon file at \(self.iconPath)")
		}

		Log.debug("Created resource file at \(self.resourcePath)")
		let fileHandle = try FileHandle(forWritingTo: self.resourcePath)

		// let data = try Data(contentsOf: self.userIconPath)
		// let hexdump = data.map { String(format: "%04lx", $0) }
		// 	.chunked(into: 8)
		// 	.map({ "\t$\"\($0.joined(separator: " "))\"" })
		// 	.joined(separator: "\n")

		// guard let resource = [
		// 	"data 'icns' (-16455) {",
		// 	hexdump,
		// 	"};"
		// ].joined(separator: "\n").data(using: .utf8) else {
		// 	throw NSError()
		// }

		// try resource.write(to: self.resourcePath)

		// Run the file through DeRez to generate the resource file
		let derezTask = Process()
		derezTask.standardOutput = fileHandle
		derezTask.launchPath = "/usr/bin/DeRez"
		derezTask.arguments = ["-only", "icns", self.iconPath.path]
		try derezTask.run()

		derezTask.waitUntilExit()
		Log.debug("DeRez exited with status \(derezTask.terminationStatus) for \(self.userIconPath)")
	}

	func updateApplication(_ applicationPath: URL) throws {
		// Set the FinderInfo attribute to 0x00000000000000040000000000000000
		// This enables the kHasCustomIcon bit on the com.apple.FinderInfo attribute
		let data: [CChar] = [
			00, 00, 00, 00, 00, 00, 00, 00, 04, 00, 00, 00, 00, 00, 00, 00,
			00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
		]

		// Set the extended attribute using xattr
		let status = setxattr(applicationPath.path, "com.apple.FinderInfo", data, 32, 0, 0)
		guard status == 0 else {
			switch errno {
			case EPERM, EACCES:
				throw SetAttributeError.noPermission
			case ENOENT:
				throw SetAttributeError.fileNotFound
			default:
				throw SetAttributeError.xattrGeneric
			}
		}

		defer {
			try? FileManager.default.removeItem(at: self.resourcePath)
			Log.debug("Removed temporary resource file at \(self.resourcePath)")
		}

		// Get the expected path of the icon file in the Application
		let iconPath = applicationPath.appendingPathComponent("Icon\r")

		let task = Process()
		task.standardOutput = nil
		task.launchPath = "/usr/bin/Rez"
		task.arguments = ["-append", resourcePath.path, "-o", iconPath.path]
		try task.run()

		task.waitUntilExit()
		Log.debug("Rez exited with status \(task.terminationStatus) for \(self.userIconPath)")
	}
}
