//
//  Log.swift
//  Iconset
//
//  Created by Aarnav Tale on 11/11/21.
//  Copyright (c) 2021 Aerum LLC. All rights reserved.
//

import Chalk
import Foundation

class Log {
	public class func warn(_ message: String) {
		let prefix = ck.bold.on(ck.dim.on("[") + ck.yellowBright.on("!") + ck.dim.on("]"))
		print("\(prefix) \(message)")
	}
	
	public class func info(_ message: String) {
		let prefix = ck.bold.on(ck.dim.on("[") + ck.blueBright.on("i") + ck.dim.on("]"))
		print("\(prefix) \(message)")
	}
	
	public class func error(_ message: String) {
		let prefix = ck.bold.on(ck.dim.on("[") + ck.redBright.on("x") + ck.dim.on("]"))
		print("\(prefix) \(message)")
	}
	
	public class func prompt(_ message: String) -> String {
		let prefix = ck.bold.on(ck.dim.on("[") + ck.cyanBright.on("?") + ck.dim.on("]"))
		return "\(prefix) \(message)"
	}
}
