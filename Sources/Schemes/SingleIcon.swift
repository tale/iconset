//
//  SingleIcon.swift
//  Iconset
//
//  Created by Aarnav Tale on 6/20/21.
//

import Foundation
import AppKit
import ArgumentParser

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
            guard getuid() == 0 else {
                print("Please run this command as root")
                throw ExitCode.failure
            }
            
            guard FileManager.default.fileExists(atPath: iconPath) else {
                print("Specified icon does not exist")
                throw ExitCode.failure
            }
            
            guard FileManager.default.fileExists(atPath: appPath) else {
                print("Specified application does not exist")
                throw ExitCode.failure
            }
            
            let image = NSImage(contentsOfFile: iconPath)
            NSWorkspace.shared.setIcon(image, forFile: appPath, options: .excludeQuickDrawElementsIconCreationOption)
            try purgeCache()
        }
    }
}
