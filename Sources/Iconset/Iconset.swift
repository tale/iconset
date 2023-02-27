//
//  Iconset.swift
//  Iconset
//
//  Created by Aarnav Tale on 11/11/21.
//  Copyright (c) 2021 Aerum LLC. All rights reserved.
//

import Chalk
import Foundation
import ArgumentParser

@available(macOS 10.15.4, *)
struct Iconset: ParsableCommand {
	static var configuration = CommandConfiguration(
		abstract: "A nifty command line tool to manage macOS icons",
		version: "iconset v1.0.0 (https://github.com/tale/iconset)",
		subcommands: [Iconset.Folder.self, Iconset.Single.self, Iconset.Revert.self]
	)

	struct Options: ParsableArguments {
		@Option(name: .shortAndLong, help: "The path to the applications to theme")
		var applicationPaths = "/Applications,~/Applications"
	}
}
