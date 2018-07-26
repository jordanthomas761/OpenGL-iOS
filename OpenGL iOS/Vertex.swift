//
//  Vertex.swift
//  OpenGL iOS
//
//  Created by Jordan Thomas on 1/20/18.
//  Copyright © 2018 Jordan Thomas. All rights reserved.
//

import Foundation
import GLKit

enum VertexAttributes : GLuint {
    case Position = 0
    case Color = 1
    case TexCoord = 2
}

struct Vertex {
    var x : GLfloat = 0
    var y : GLfloat = 0
    var z : GLfloat = 0
    var r : GLfloat = 0
    var g : GLfloat = 0
    var b : GLfloat = 0
    var s : GLfloat = 0
    var t : GLfloat = 0
    
    
    
    init(_ x : GLfloat, _ y : GLfloat, _ z :GLfloat, _ r : GLfloat, _ g : GLfloat, _ b :GLfloat,
         _ s : GLfloat, _ t : GLfloat){
        self.x = x
        self.y = y
        self.z = z
        self.r = r
        self.g = g
        self.b = b
        self.s = s
        self.t = t
    }
    
}
