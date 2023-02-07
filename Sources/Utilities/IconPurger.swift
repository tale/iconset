//
//  IconPurger.swift
//  Iconset
//
//  Created by Aarnav Tale on 2/7/23.
//

import Foundation
import ArgumentParser

class IconPurger {
	private let applicationPath: URL

	init(from applicationPath: URL) {
		self.applicationPath = applicationPath
	}

	func deleteCustomIcon() throws {
		// Remove the com.apple.FinderInfo attribute (Maybe in the future instead of destroying we can modify)
		let status = removexattr(self.applicationPath.path, "com.apple.FinderInfo", 0)
		guard status == 0 else {

			// get errno
			print(errno)
			print(status)
			// Handle this soon
			throw NSError()
		}

		// Get the expected path of the icon file in the Application
		let iconPath = applicationPath.appendingPathComponent("Icon\r")
		try FileManager.default.removeItem(at: iconPath)
		Log.debug("Removed icon file at \(iconPath)")
	}
}
