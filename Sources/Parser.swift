//
//  Parser.swift
//  Iconset
//
//  Created by Aarnav Tale on 6/19/21.
//

import Foundation
import ArgumentParser

struct Iconset: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A nifty command line tool to manage macOS icons",
        subcommands: [Iconset.IconFolder.self, Iconset.SingleIcon.self],
        defaultSubcommand: Iconset.SingleIcon.self
    )
    
    struct Options: ParsableArguments {
        @Option(name: .shortAndLong, help: "The path to the applications to theme")
        var applicationsPath = "/Applications"
    }
}
