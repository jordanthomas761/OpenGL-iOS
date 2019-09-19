//
//  Triangle.swift
//  OpenGL iOS
//
//  Created by Jordan Thomas on 8/8/18.
//  Copyright © 2018 Jordan Thomas. All rights reserved.
//

import Foundation
import GLKit

class Triangle {
	
	var vertices : [GLfloat] = [
		-0.5, -0.5, 0.0, 1.0, 0.0, 0.0,
		0.5, -0.5, 0.0, 0.0, 1.0, 0.0,
		0.0,  0.5, 0.0, 0.0 ,0.0, 1.0
	]
	
	var indecies : [GLuint] = [
		0, 1, 2
	]
	
	var tri:BaseEffect
	var VBO:GLuint = 0
	var VAO:GLuint = 0
	var EBO:GLuint = 0
	
	init(){
		tri = BaseEffect(vertexShader: "triangle.vsh", fragmentShader: "triangle.fsh")
		glGenBuffers(GLsizei(1), &VBO)
		glGenVertexArrays(GLsizei(1), &VAO)
		glGenBuffers(GLsizei(1), &EBO)
		
	}
	
	func prepareToDraw(){
		tri.prepareToDraw()
		glBindVertexArray(VAO)
		glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO)
		glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<[GLfloat]>.size * self.vertices.count, vertices, GLenum(GL_STATIC_DRAW))
		glEnableVertexAttribArray(0)
		glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(3 * MemoryLayout<[GLfloat]>.size), BUFFER_OFFSET(0))
		glEnableVertexAttribArray(1)
		glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(3 * MemoryLayout<[GLfloat]>.size), BUFFER_OFFSET(3 * MemoryLayout<GLfloat>.size))
		glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), EBO)
		glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<[GLuint]>.size * self.indecies.count, indecies, GLenum(GL_STATIC_DRAW))
		glUniform1i(glGetUniformLocation(tri.programHandle, "ourColor"), 0)
		
		
	}
	
	
	func draw() {
		glEnable(GLenum(GL_BLEND))
		glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
		glDisable(GLenum(GL_DEPTH_TEST))
		tri.prepareToDraw()
		glBindVertexArray(VAO)
		glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indecies.count), GLenum(GL_UNSIGNED_INT), BUFFER_OFFSET(0))
		glDisable(GLenum(GL_BLEND))
		glEnable(GLenum(GL_DEPTH_TEST))
	}
	
	func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
		return UnsafeRawPointer(bitPattern: n)
	}
}
