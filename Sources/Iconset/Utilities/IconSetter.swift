//
//  IconSetter.swift
//  Iconset
//
//  Created by Aarnav Tale on 2/7/23.
//

import AppKit
import Foundation
import ArgumentParser
import Carbon

enum SetterError: Error {
	case fileNotFound
	case noPermission
	case failedNSImage
	case xattrGeneric
}

extension SetterError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .fileNotFound:
			return "File not found"
		case .noPermission:
			return "Missing permissions to set attribute"
		case .failedNSImage:
			return "Failed to create image from file"
		case .xattrGeneric:
			return "Unknown xattr error"
		}
	}
}

// Converts the file Data to a "classic macOS resource"
// The format of a resource is something like this:
// data 'icns' (-16455) {
//	$"<8 bytes of hex data>"
//	...
//	$"<8 bytes of hex data>"
// };

extension Data {
	func asClassicResource() -> Data? {
		let hexFormatted = self.hexFormatted.wrapAdjacent(with: "$").joined(separator: "\n")
		return [ "data 'icns' (-16455) {", hexFormatted, "};" ].joined(separator: "\n").data(using: .utf8)
	}

	var hexFormatted: [String] {
		return self.map { String(format: "%02lx", $0).uppercased() }
	}
}

extension Array {
	func wrapAdjacent(with prefix: String) -> [String] {
		return stride(from: 0, to: count, by: 2).map {
			"\(self[$0])\(self[$0 + 1])"
		}.chunked(into: 8).map {
			"\(prefix)\"\($0.joined(separator: " "))\""
		}
	}

	func chunked(into size: Int) -> [[Element]] {
		return stride(from: 0, to: count, by: size).map {
			Array(self[$0 ..< Swift.min($0 + size, count)])
		}
	}
}

class IconSetter {
	private let iconPath: URL
	private let resourcePath: URL

	init(from iconPath: URL) {
		let randomID = UUID().uuidString
		let tempDirectory = FileManager.default.temporaryDirectory

		var resourcePath = tempDirectory.appendingPathComponent(randomID)
		resourcePath.appendPathExtension("rsrc")

		self.iconPath = iconPath
		self.resourcePath = resourcePath
	}

	func generateResource() throws {
		// let data = try Data(contentsOf: self.iconPath)
		// guard let resource = data.asClassicResource() else {
		// 	throw NSError()
		// }

		// try resource.write(to: self.resourcePath)
	}

	func updateApplication(_ applicationPath: URL) throws {
		// Set the FinderInfo attribute to 0x00000000000000040000000000000000
		// This enables the kHasCustomIcon bit on the com.apple.FinderInfo attribute
		// let data: [CChar] = [
		// 	00, 00, 00, 00, 00, 00, 00, 00, 04, 00, 00, 00, 00, 00, 00, 00,
		// 	00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
		// ]

		// // Set the extended attribute using xattr
		// let status = setxattr(applicationPath.path, "com.apple.FinderInfo", data, 32, 0, 0)
		// guard status == 0 else {
		// 	switch errno {
		// 	case EPERM, EACCES:
		// 		throw SetAttributeError.noPermission
		// 	case ENOENT:
		// 		throw SetAttributeError.fileNotFound
		// 	default:
		// 		throw SetAttributeError.xattrGeneric
		// 	}
		// }

		// defer {
		// 	try? FileManager.default.removeItem(at: self.resourcePath)
		// 	Log.debug("Removed temporary resource file at \(self.resourcePath)")
		// }

		// // Get the expected path of the icon file in the Application
		// let iconPath = applicationPath.appendingPathComponent("Icon\r")

		// let task = Process()
		// task.standardOutput = nil
		// task.launchPath = "/usr/bin/Rez"
		// task.arguments = ["-append", self.resourcePath.path, "-o", iconPath.path]
		// try task.run()

		// task.waitUntilExit()
		// Log.debug("Rez exited with status \(task.terminationStatus) for \(self.iconPath)")

		guard let image = NSImage(contentsOf: self.iconPath) else {
			throw SetterError.failedNSImage
		}

		// An option to suppress generation of the QuickDraw format icon representations that are used in macOS 10.0 through macOS 10.4.
		let status = NSWorkspace.shared.setIcon(image, forFile: applicationPath.path, options: .excludeQuickDrawElementsIconCreationOption)

		guard status else {
			throw SetterError.noPermission
		}
	}
}
