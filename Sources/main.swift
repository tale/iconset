//
//  main.swift
//  Iconset
//
//  Created by Aarnav Tale on 6/19/21.
//

import Foundation

Iconset.main()

public func purgeCache() throws {
    let iterator = FileManager.default.enumerator(atPath: "/private/var/folders")
    while let object = iterator!.nextObject() {
        if let file = object as? String, file.contains("com.apple.iconservices") || file.contains("com.apple.dock.iconcache") {
            try FileManager.default.removeItem(atPath: "/private/var/folders/\(file)")
        }
    }
    
    try FileManager.default.removeItem(atPath: "/Library/Caches/com.apple.iconservices.store")
    
    let task = Process()
    task.launchPath = "/usr/bin/killall"
    task.arguments = ["Dock"]
    task.launch()
    task.waitUntilExit()
}
