//
//  GLKMatrix+Array.swift
//  OpenGL iOS
//
//  Created by Jordan Thomas on 2/19/18.
//  Copyright © 2018 Jordan Thomas. All rights reserved.
//

import GLKit

extension GLKMatrix2 {
    var array: [Float] {
        return (0..<4).map { i in
            self[i]
        }
    }
}


extension GLKMatrix3 {
    var array: [Float] {
        return (0..<9).map { i in
            self[i]
        }
    }
}

extension GLKMatrix4 {
    var array: [Float] {
        return (0..<16).map { i in
            self[i]
        }
    }
}
