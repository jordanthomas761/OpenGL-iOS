//
//  JoyStick.swift
//  OpenGL iOS
//
//  Created by Jordan Thomas on 5/8/18.
//  Copyright © 2018 Jordan Thomas. All rights reserved.
//
import Foundation
import GLKit

class JoyStick {
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
	
	var displacementInXDirection : Float = 0.0
	var displacementInYDirection : Float = 0.0
	
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
		setJoystickBackgroundVertexAndUVCoords();
		setJoystickDriverVertexAndUVCoords();

	}
	
	func setJoystickBackgroundVertexAndUVCoords(){
		//1. set the width, height and depth for the joystick background image rectangle
		let width=joystickBackgroundWidth/screenWidth
		let height=joystickBackgroundHeight/screenHeight
		let depth: Float = 1.0
		
		//2. Set the value for each vertex into an array
		
		//Upper-Right Corner vertex of rectangle
		joystickBackgroundVertices += [width, height, depth]
		
		//Lower-Right corner vertex of rectangle
		joystickBackgroundVertices += [width, -height, depth]
		
		//Lower-Left corner vertex of rectangle
		joystickBackgroundVertices += [-width, -height, depth]
		
		//Upper-Left corner vertex of rectangle
		joystickBackgroundVertices += [-width, height, depth]
		
		
		//3. Set the value for each uv coordinate into an array
		
		joystickBackgroundUVCoords += [
			1.0, 0.0,
			1.0, 1.0,
			0.0, 1.0,
			0.0, 0.0]
		
		//4. set the value for each index into an array
		
		joystickBackgroundIndex += [0, 1, 2, 2, 3, 0]

	}
	
	func setJoystickDriverVertexAndUVCoords() {
		//1. set the width, height and depth for the joystick background image rectangle
		let width=joystickDriverWidth/screenWidth
		let height=joystickDriverHeight/screenHeight
		let depth: Float = 0.0
		
		//2. Set the value for each vertex into an array
		
		//Upper-Right Corner vertex of rectangle
		joystickDriverVertices += [width, height, depth]
		
		//Lower-Right corner vertex of rectangle
		joystickDriverVertices += [width, -height, depth]
		
		//Lower-Left corner vertex of rectangle
		joystickDriverVertices += [-width, -height, depth]
		
		//Upper-Left corner vertex of rectangle
		joystickDriverVertices  += [-width, height, depth]
		
		
		//3. Set the value for each uv coordinate into an array
		
		joystickDriverUVCoords += [1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0]
		
		//4. set the value for each index into an array
		
		joystickDriverIndex += [0, 1, 2, 2, 3, 0]
	}
	
	func setupJoyStickBackgroundOpenGL(){
		
		backgroundShader.prepareToDraw()
		
		glBindVertexArray(backgroundVertexArray)
		glBindBuffer(GLenum(GL_ARRAY_BUFFER), backgroundVertexBuffer)
		
		glBufferData(GLenum(GL_ARRAY_BUFFER), (MemoryLayout<[GLfloat]>.size * joystickBackgroundUVCoords.count) + (MemoryLayout<[GLfloat]>.size * joystickBackgroundVertices.count), nil, GLenum(GL_STATIC_DRAW))
		
		glBufferSubData(GLenum(GL_ARRAY_BUFFER), 0, MemoryLayout<[GLfloat]>.size * joystickBackgroundVertices.count, joystickBackgroundVertices)
		
		glBufferSubData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<[GLfloat]>.size * joystickBackgroundVertices.count, MemoryLayout<[GLfloat]>.size * joystickBackgroundUVCoords.count, joystickBackgroundUVCoords)
		
		
		
		glEnableVertexAttribArray(0)
		glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, GraphicsFunctions.BUFFER_OFFSET(0))
		glEnableVertexAttribArray(1)
		glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, GraphicsFunctions.BUFFER_OFFSET(joystickBackgroundVertices.count*MemoryLayout<[GLfloat]>.size))
		
		glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), backgroundElementBuffer)
		glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<[GLuint]>.size * joystickBackgroundIndex.count, joystickBackgroundIndex, GLenum(GL_STATIC_DRAW))
		
		backgoundTexture = GraphicsFunctions.setupTexture(file: joystickBackgroundImage)
		
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
		
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
		
		glUniform1i(glGetUniformLocation(backgroundShader.programHandle, "texture1"), 0)
		
	}
	
	func setupJoyStickDriverOpenGL(){
		
		driverShader.prepareToDraw()
		glBindVertexArray(driverVertexArray)
		glBindBuffer(GLenum(GL_ARRAY_BUFFER), driverVertexBuffer)
		
		glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<[GLfloat]>.size * joystickDriverUVCoords.count + MemoryLayout<[GLfloat]>.size * joystickDriverVertices.count, nil, GLenum(GL_STATIC_DRAW))
		
		glBufferSubData(GLenum(GL_ARRAY_BUFFER), 0, MemoryLayout<[GLfloat]>.size * joystickDriverVertices.count, joystickDriverVertices)
		
		glBufferSubData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<[GLfloat]>.size * joystickDriverVertices.count, MemoryLayout<[GLfloat]>.size * joystickDriverUVCoords.count, joystickDriverUVCoords)
		
		
		
		glEnableVertexAttribArray(0)
		glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, GraphicsFunctions.BUFFER_OFFSET(0))
		glEnableVertexAttribArray(1)
		glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, GraphicsFunctions.BUFFER_OFFSET(joystickDriverVertices.count*MemoryLayout<[GLfloat]>.size))
		
		glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), driverElementBuffer)
		glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<[GLuint]>.size * joystickDriverIndex.count, joystickDriverIndex, GLenum(GL_STATIC_DRAW))
		
		driverTexture = GraphicsFunctions.setupTexture(file: joystickImage)
		
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
		
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
		
		glUniform1i(glGetUniformLocation(driverShader.programHandle, "texture1"), 0)
		
	}
	
	func setJoyStickBackgroundTransformation(){
		var model = GLKMatrix4Identity
		
		model = GLKMatrix4Translate(model, joystickXPosition, joystickYPosition, 0.0)
		
		let projection = GLKMatrix4MakeOrtho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0)
		
		backgroundShader.setMat4(name: "model", value: model)
		backgroundShader.setMat4(name: "view", value: GLKMatrix4Identity)
		backgroundShader.setMat4(name: "projection", value: projection)
		
	}
	
	func setJoyStickDriverTransformation() {
		var model = GLKMatrix4Identity
		
		model = GLKMatrix4Translate(model, joystickXPosition, joystickYPosition, 0.0)
		
		let projection = GLKMatrix4MakeOrtho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0)
		
		driverShader.setMat4(name: "model", value: model)
		driverShader.setMat4(name: "view", value: GLKMatrix4Identity)
		driverShader.setMat4(name: "projection", value: projection)
	}
	
	func draw(){
		glEnable(GLenum(GL_BLEND))
		glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
		glDisable(GLenum(GL_DEPTH_TEST))
		
		backgroundShader.prepareToDraw()
		
		glBindVertexArray(backgroundVertexArray)
		
		glActiveTexture(GLenum(GL_TEXTURE0))
		glBindTexture(backgoundTexture.target, backgoundTexture.name)
		glDrawElements(GLenum(GL_TRIANGLES), GLsizei(joystickBackgroundIndex.count), GLenum(GL_UNSIGNED_INT), GraphicsFunctions.BUFFER_OFFSET(0))
		
		driverShader.prepareToDraw()
		
		
		glBindVertexArray(driverVertexArray)
		glActiveTexture(GLenum(GL_TEXTURE0))
		glBindTexture(driverTexture.target, driverTexture.name)
		glDrawElements(GLenum(GL_TRIANGLES), GLsizei(joystickDriverIndex.count), GLenum(GL_UNSIGNED_INT), GraphicsFunctions.BUFFER_OFFSET(0))
		
		glDisable(GLenum(GL_BLEND))
		glEnable(GLenum(GL_DEPTH_TEST))
		
	}
	
	func setupOpenGL(){
		setupJoyStickBackgroundOpenGL()
		setJoyStickBackgroundTransformation()
		setupJoyStickDriverOpenGL()
		setJoyStickDriverTransformation()
	}
	
	func update(touchX: GLfloat, touchY: GLfloat){
		driverShader.prepareToDraw()
		glBindVertexArray(driverVertexArray)
		if (touchX >= left && touchX <= right){
			if (touchY >= bottom && touchY <= top){
				isPressed = true
				var model = GLKMatrix4Identity
				
				model = GLKMatrix4Translate(model, touchX, touchY, 0.0)
				
				let projection = GLKMatrix4MakeOrtho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0)
				
				driverShader.setMat4(name: "model", value: model)
				driverShader.setMat4(name: "view", value: GLKMatrix4Identity)
				driverShader.setMat4(name: "projection", value: projection)
				displacementInXDirection = touchX - joystickXPosition
				displacementInYDirection = touchY - joystickYPosition
			}
		}
		else
		{
			isPressed = false
		}
		glBindVertexArray(0)
	}
	
	func getDisplacementInXDirection() -> Float{
	
		//get displacement of joystick driver in x direction
		return displacementInXDirection
	}
	
	func getDisplacementInYDirection() -> Float{
	
		//get displacement of joystick driver in x direction
		return displacementInYDirection
	}
	
	func resetPosition(){
	
		//reset the position of the joystick driver to initial position
		update(touchX: joystickXPosition, touchY: joystickYPosition)
	}
	
	func getJoystickIsPress() -> Bool {
		return isPressed
	}
	

}
