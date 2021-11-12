//
//  main.swift
//  Iconset
//
//  Created by Aarnav Tale on 11/11/21.
//  Copyright (c) 2021 Aerum LLC. All rights reserved.
//

import Foundation

if #available(macOS 10.15.4, *) {
	Iconset.main()
} else {
	Log.error("iconset is only supported on macOS Catalina (10.15.4) or greater")
	exit(1)
}
