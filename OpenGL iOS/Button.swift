//
//  Button.swift
//  OpenGL iOS
//
//  Created by Jordan Thomas on 8/1/19.
//  Copyright © 2019 Jordan Thomas. All rights reserved.
//

import Foundation
import GLKit

class Button {
	var screenWidth:Float, screenHeight:Float
	var joystickDriverWidth:Float, joystickDriverHeight:Float
	var joystickBackgroundWidth:Float, joystickBackgroundHeight:Float
	var joystickImage:CGImage, joystickBackgroundImage: CGImage
	var joystickXPosition: Float, joystickYPosition:Float
	var left: Float, right: Float, top: Float, bottom: Float
	var isPressed:Bool = false
	var joystickBackgroundVertices: [GLfloat] = [], joystickBackgroundUVCoords: [GLfloat] = [], joystickBackgroundIndex: [GLuint] = []
	var joystickDriverVertices: [GLfloat] = [],  joystickDriverUVCoords: [GLfloat] = [], joystickDriverIndex: [GLuint] = []
	
	
	
	var backgroundShader : BaseEffect!
	var driverShader : BaseEffect!
	var backgroundVertexArray : GLuint = 0
	var driverVertexArray : GLuint = 0
	var backgroundVertexBuffer : GLuint = 0
	var driverVertexBuffer : GLuint = 0
	var backgroundElementBuffer : GLuint = 0
	var driverElementBuffer : GLuint = 0
	var backgoundTexture : GLKTextureInfo!
	var driverTexture : GLKTextureInfo!
	
	init( joystickXPosition: Float, joystickYPosition:Float,  backgroundJoystickImage: CGImage, joystickBackgroundWidth:Float, joystickBackgroundHeight:Float, joystickImage:CGImage, joystickWidth:Float, joystickHeight:Float,screenWidth:Float, screenHeight:Float){
		
		self.backgroundShader = BaseEffect(vertexShader: "JoystickBackgroundShader.vsh", fragmentShader: "JoystickBackgroundShader.fsh")
		
		glGenVertexArrays(GLsizei(1), &backgroundVertexArray)
		glGenBuffers(GLsizei(1), &backgroundVertexBuffer)
		glGenBuffers(GLsizei(1), &backgroundElementBuffer)
		
		
		
		
		self.driverShader = BaseEffect(vertexShader: "JoystickDriverShader.vsh", fragmentShader: "JoystickDriverShader.fsh")
		
		glGenVertexArrays(GLsizei(1), &driverVertexArray)
		glGenBuffers(GLsizei(1), &driverVertexBuffer)
		glGenBuffers(GLsizei(1), &driverElementBuffer)
		
		//1. screen width and height
		self.screenWidth = screenWidth
		self.screenHeight = screenHeight
		
		//2. Joystick driver & background width and height
		self.joystickDriverWidth = joystickWidth
		self.joystickDriverHeight = joystickHeight
		
		self.joystickBackgroundWidth = joystickBackgroundWidth
		self.joystickBackgroundHeight = joystickBackgroundHeight
		
		//3. set the reference of both Joystick element images
		self.joystickImage = joystickImage
		self.joystickBackgroundImage = backgroundJoystickImage
		
		//4. Joystick x and y position. Because our ortho matrix is in the range of [-1,1]. We need to convert from screen coordinates to ortho coordinates.
		self.joystickXPosition = joystickXPosition * 2/self.screenWidth - 1
		self.joystickYPosition = joystickYPosition * (-2/self.screenHeight) + 1
		
		//5. calculate the boundaries of the Joystick
		left = self.joystickXPosition - self.joystickDriverWidth/self.screenWidth
		right = self.joystickXPosition + self.joystickDriverWidth/self.screenWidth
		
		top = self.joystickYPosition + self.joystickDriverHeight/self.screenHeight
		bottom = self.joystickYPosition - self.joystickDriverHeight/self.screenHeight
		
		//6. set the bool value to false
		
		//7. set the vertex and UV coordinates for both joystick elements
		//setJoystickBackgroundVertexAndUVCoords();
		//setJoystickDriverVertexAndUVCoords();
		
	}
	
}
