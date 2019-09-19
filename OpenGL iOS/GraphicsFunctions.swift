//
//  File.swift
//  OpenGL iOS
//
//  Created by Jordan Thomas on 8/1/19.
//  Copyright © 2019 Jordan Thomas. All rights reserved.
//

import Foundation
import GLKit


class GraphicsFunctions {
	static func setupTexture(file: CGImage) -> GLKTextureInfo
	{
		var info: GLKTextureInfo!
		let option = [ GLKTextureLoaderOriginBottomLeft: true]
		do {
			info = try GLKTextureLoader.texture(with: file, options: option as [String : NSNumber]?)
			return info
		} catch let error {
			print(error)
		}
		
		return info
	}
	
	static func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
		return UnsafeRawPointer(bitPattern: n)
	}
}
