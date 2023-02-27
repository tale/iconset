//
//  Recurse.swift
//  Iconset
//
//  Created by Aarnav Tale on 2/26/23.
//

import Foundation

class Recurse {
	var directory: String
	var files: [String] = []

	init(directory: String) {
		self.directory = directory
	}

	func recurse() -> [String] {
		let fileManager = FileManager.default
		let enumerator = fileManager.enumerator(atPath: directory)

		while let element = enumerator?.nextObject() as? String {
			if element.contains(".app") {
				enumerator?.skipDescendants()
				files.append("\(directory)/\(element)")
			}
		}

		return files
	}
}
