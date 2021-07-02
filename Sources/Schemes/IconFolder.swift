//
//  IconFolder.swift
//  Iconset
//
//  Created by Aarnav Tale on 6/19/21.
//

import Foundation
import AppKit
import ArgumentParser

extension Iconset {
    struct IconFolder: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "folder",
            abstract: "Set icons using a folder of '.icns' files with the same names as their '.app' counterparts"
        )
        
        @OptionGroup
        var options: Iconset.Options
        
        @Argument(help: "A path to a folder containing '.icns' files")
        var iconsPath: String
        
        mutating func run() throws {
            guard getuid() == 0 else {
                print("Please run this command as root")
                throw ExitCode.failure
            }
            
            let items = try FileManager.default.contentsOfDirectory(atPath: iconsPath)
            
            for item in items {
                if item.contains(".icns") {
                    let application = item.replacingOccurrences(of: ".icns", with: ".app")
                    let applicationPath = "\(options.applicationsPath)/\(application)"
                    
                    guard FileManager.default.fileExists(atPath: applicationPath) else {
                        return
                    }
                    
                    print("\(item) –> \(application)")
                    let image = NSImage(contentsOfFile: "\(iconsPath)/\(item)")
                    NSWorkspace.shared.setIcon(image, forFile: applicationPath, options: .excludeQuickDrawElementsIconCreationOption)
                }
            }
            
            try purgeCache()
        }
    }
}
