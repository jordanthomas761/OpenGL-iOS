//
//  LightingViewController.swift
//  OpenGL iOS
//
//  Created by Jordan Thomas on 7/30/19.
//  Copyright © 2019 Jordan Thomas. All rights reserved.
//

import UIKit
import GLKit
import GameController

class LightingViewController: GLKViewController, GLKViewControllerDelegate {


	var controllers:[GCController]!
	
	var glkView:GLKView!
	var glkUpdater: GLKViewControllerDelegate!
	
	var cubeVAO : GLuint = 0
	var lampVAO : GLuint = 0
	var vertexBuffer : GLuint = 0
	var elementBuffer : GLuint = 0
	var lightingShader : BaseEffect!
	var lampShader : BaseEffect!
	var texture1 : GLKTextureInfo!
	var specularMap : GLKTextureInfo!
	var mixture : GLfloat = 0.5
	var model: GLKMatrix4 = GLKMatrix4Identity
	var viewGL: GLKMatrix4 = GLKMatrix4Identity
	var projection: GLKMatrix4 = GLKMatrix4Identity
	
	var cameraPos: GLKVector3 = GLKVector3Make(0.0, 0.0, 3.0)
	var cameraFront: GLKVector3 = GLKVector3Make(0.0, 0.0, -1.0)
	var cameraUp: GLKVector3 = GLKVector3Make(0.0, 1.0, 0.0)
	
	var lastX:Float = 0, lastY:Float = 0
	var pitch:Float = 0, yaw:Float = -90 // yaw is initialized to -90.0 degrees since a yaw of 0.0 results in a direction vector pointing to the right so we initially rotate a bit to the left.
	var fov:Float = 45
	var deltaTime:Float = 0, lastFrame:Float = 0
	
	var leftJoystick : JoyStick!
	var rightJoystick : JoyStick!
	var lightPos : GLKVector3 = GLKVector3Make(1.2, 0.3, 2.0)
	
	var currentXTouchPoint:Float = 0
	var currentYTouchPoint:Float = 0
	
	let vertices : [Vertex] = [
				// positions        // colors       //TextCoord
		Vertex( -0.5, -0.5, -0.5,    0.0,  0.0, -1.0,   0.0, 0.0),
		Vertex( 0.5, -0.5, -0.5,  0.0,  0.0, -1.0,   1.0, 0.0),
		Vertex( 0.5, 0.5, -0.5,  0.0, 0.0, -1.0,   1.0, 1.0),
		Vertex( 0.5, 0.5, -0.5,   0.0,  0.0, -1.0,   1.0, 1.0),
		Vertex( -0.5, 0.5, -0.5,   0.0,  0.0, -1.0,   0.0, 1.0),
		Vertex( -0.5, -0.5, -0.5,   0.0,  0.0, -1.0,   0.0, 0.0),
		
		Vertex( -0.5, -0.5, 0.5,    0.0, 0.0, 1.0,   0.0, 0.0),
		Vertex( 0.5, -0.5, 0.5,   0.0, 0.0, 1.0,   1.0, 0.0),
		Vertex( 0.5, 0.5, 0.5,  0.0, 0.0, 1.0,   1.0, 1.0),
		Vertex( 0.5, 0.5, 0.5,   0.0, 0.0, 1.0,   1.0, 1.0),
		Vertex( -0.5, 0.5, 0.5,   0.0, 0.0, 1.0,   0.0, 1.0),
		Vertex( -0.5, -0.5, 0.5,   0.0, 0.0, 1.0,   0.0, 0.0),
		
		Vertex( -0.5, 0.5, 0.5,    -1.0, 0.0, 0.0,   1.0, 0.0),
		Vertex( -0.5, 0.5, -0.5,   -1.0, 0.0, 0.0,   1.0, 1.0),
		Vertex( -0.5, -0.5, -0.5,  -1.0, 0.0, 0.0,   0.0, 1.0),
		Vertex( -0.5, -0.5, -0.5,   -1.0, 0.0, 0.0,   0.0, 1.0),
		Vertex( -0.5, -0.5, 0.5,   -1.0, 0.0, 0.0,   0.0, 0.0),
		Vertex( -0.5, 0.5, 0.5,   -1.0, 0.0, 0.0,   1.0, 0.0),
		
		Vertex( 0.5, 0.5, 0.5,    1.0, 0.0, 0.0,   1.0, 0.0),
		Vertex( 0.5, 0.5, -0.5,   1.0, 0.0, 0.0,   1.0, 1.0),
		Vertex( 0.5, -0.5, -0.5,  1.0, 0.0, 0.0,   0.0, 1.0),
		Vertex( 0.5, -0.5, -0.5,   1.0, 0.0, 0.0,   0.0, 1.0),
		Vertex( 0.5, -0.5, 0.5,   1.0, 0.0, 0.0,   0.0, 0.0),
		Vertex( 0.5, 0.5, 0.5,   1.0, 0.0, 0.0,   1.0, 0.0),
		
		Vertex( -0.5, -0.5, -0.5,    0.0, -1.0, 0.0,   0.0, 1.0),
		Vertex( 0.5, -0.5, -0.5,   0.0, -1.0, 0.0,   1.0, 1.0),
		Vertex( 0.5, -0.5, 0.5,  0.0, -1.0, 0.0,   1.0, 0.0),
		Vertex( 0.5, -0.5, 0.5,   0.0, -1.0, 0.0,   1.0, 0.0),
		Vertex( -0.5, -0.5, 0.5,   0.0, -1.0, 0.0,   0.0, 0.0),
		Vertex( -0.5, -0.5, -0.5,   0.0, -1.0, 0.0,   0.0, 1.0),
		
		Vertex( -0.5, 0.5, -0.5,    0.0, 1.0, 0.0,   0.0, 1.0),
		Vertex( 0.5, 0.5, -0.5,   0.0, 1.0, 0.0,   1.0, 1.0),
		Vertex( 0.5, 0.5, 0.5,  0.0, 1.0, 0.0,   1.0, 0.0),
		Vertex( 0.5, 0.5, 0.5,   0.0, 1.0, 0.0,   1.0, 0.0),
		Vertex( -0.5, 0.5, 0.5,   0.0, 1.0, 0.0,   0.0, 0.0),
		Vertex( -0.5, 0.5, -0.5,   0.0, 1.0, 0.0,   0.0, 1.0),
	]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.isMultipleTouchEnabled = true

		setupGLcontext()
		setupGLupdater()
		
		leftJoystick = JoyStick(joystickXPosition: Float(self.view.bounds.width/8), joystickYPosition: Float(self.view.bounds.height*3/4), backgroundJoystickImage: #imageLiteral(resourceName: "joystickBackground.png").cgImage!, joystickBackgroundWidth: 150, joystickBackgroundHeight: 150, joystickImage: #imageLiteral(resourceName: "joystickDriver.png").cgImage!, joystickWidth: 90, joystickHeight: 90, screenWidth: Float(self.view.bounds.width), screenHeight: Float(self.view.bounds.height))
		leftJoystick.setupOpenGL()
		
		rightJoystick = JoyStick(joystickXPosition: Float(self.view.bounds.width*7/8), joystickYPosition: Float(self.view.bounds.height*3/4), backgroundJoystickImage: #imageLiteral(resourceName: "joystickBackground.png").cgImage!, joystickBackgroundWidth: 150, joystickBackgroundHeight: 150, joystickImage: #imageLiteral(resourceName: "joystickDriver.png").cgImage!, joystickWidth: 90, joystickHeight: 90, screenWidth: Float(self.view.bounds.width), screenHeight: Float(self.view.bounds.height))
		rightJoystick.setupOpenGL()
		
		
		setupShader()
		setupVertexArray()
		setupVertexBuffer()
		setupLamp()
		
		texture1 = GraphicsFunctions.setupTexture(file: #imageLiteral(resourceName: "container2.png").cgImage!)
		specularMap = GraphicsFunctions.setupTexture(file:#imageLiteral(resourceName: "container2_specular.png").cgImage!)
		
		
		lightingShader.prepareToDraw()
		glUniform1i(glGetUniformLocation(lightingShader.programHandle, "material.diffuse"), 0)
		glUniform1i(glGetUniformLocation(lightingShader.programHandle, "material.specular"), 1)
    }
	
	func glkViewControllerUpdate(_ controller: GLKViewController) {
		controllers = GCController.controllers()
		for controller in controllers {
			readControllerInput(controller: controller)
		}
		
		let cameraSpeed:Float = 100 * deltaTime
		var front:GLKVector3
		cameraPos = GLKVector3Add(cameraPos, GLKVector3MultiplyScalar(cameraFront, cameraSpeed * leftJoystick.getDisplacementInYDirection()))
		cameraPos = GLKVector3Add(cameraPos, GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3CrossProduct(cameraFront, cameraUp)), cameraSpeed * leftJoystick.getDisplacementInXDirection()))
		pitch += rightJoystick.getDisplacementInYDirection() * cameraSpeed*10
		if pitch > 89{
			pitch = 89
		}
		if pitch < -89{
			pitch = -89
		}
		yaw += rightJoystick.getDisplacementInXDirection() * cameraSpeed*10
		front = GLKVector3Make(cos(GLKMathDegreesToRadians(yaw))*cos(GLKMathDegreesToRadians(pitch)), sin(GLKMathDegreesToRadians(pitch)), sin(GLKMathDegreesToRadians(yaw)) * cos(GLKMathDegreesToRadians(pitch)))
		cameraFront = GLKVector3Normalize(front)
		lightPos.x = Float(sin(CACurrentMediaTime()) * 2)
		lightPos.z = Float(cos(CACurrentMediaTime()) * 2)
	}
	
	//Draw function
	override func glkView(_ view: GLKView, drawIn rect: CGRect) {
		glClearColor(0.2, 0.3, 0.3, 1.0);
		glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
		
		
		
		lightingShader.prepareToDraw()
		
		
		
		let currentFrame:Float = Float(CACurrentMediaTime())
		deltaTime = currentFrame - lastFrame
		lastFrame = currentFrame
		
		lightingShader.setVec3(name: "objectColor", x: 1.0, y: 1.0, z: 1.0)
		
		lightingShader.setVec3(name: "lightPos", x: lightPos.x, y: lightPos.y, z: lightPos.z)
		
		lightingShader.setVec3(name: "light.ambient", x: 0.1, y: 0.1, z: 0.1)
		lightingShader.setVec3(name: "light.diffuse", x: 0.5, y: 0.5, z: 0.5)
		lightingShader.setVec3(name: "light.specular", x: 1.0, y: 1.0, z: 1.0)
		
		lightingShader.setInt(name: "material.diffuse", value: 0)
		glActiveTexture(GLenum(GL_TEXTURE0))
		glBindTexture(texture1.target, texture1.name)
		lightingShader.setInt(name: "material.specular", value: 1)
		glActiveTexture(GLenum(GL_TEXTURE1))
		glBindTexture(specularMap.target, specularMap.name)
		lightingShader.setFloat(name: "material.shininess", value: 64.0)
		
		projection = GLKMatrix4Identity
		projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(fov), Float(self.view.bounds.size.width/self.view.bounds.size.height), 0.1, 100.0)
		lightingShader.setMat4(name: "projection", value: projection)
		
		viewGL = GLKMatrix4Identity
		viewGL = GLKMatrix4MakeLookAt(cameraPos.x, cameraPos.y, cameraPos.z, cameraPos.x + cameraFront.x, cameraPos.y + cameraFront.y, cameraPos.z + cameraFront.z, cameraUp.x, cameraUp.y, cameraUp.z)
		lightingShader.setMat4(name: "view", value: viewGL)
		
		model = GLKMatrix4Identity
		lightingShader.setMat4(name: "model", value: model)
		glBindVertexArray(cubeVAO)
		glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
		
		lampShader.prepareToDraw()
		model = GLKMatrix4Identity
		model = GLKMatrix4TranslateWithVector3(model, lightPos)
		model = GLKMatrix4ScaleWithVector3(model, GLKVector3Make(0.2, 0.2, 0.2))
		lampShader.setMat4(name: "projection", value: projection)
		lampShader.setMat4(name: "view", value: viewGL)
		lampShader.setMat4(name: "model", value: model)
		
		glBindVertexArray(lampVAO)
		glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
		
		leftJoystick.draw()
		rightJoystick.draw()
		
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LightingViewController {
	func setupGLcontext() {
		glkView = (self.view as! GLKView)
		glkView.context = EAGLContext(api: .openGLES3)!
		EAGLContext.setCurrent(glkView.context)
		//Enable Depth Buffer
		glEnable(GLenum(GL_DEPTH_TEST))
		glkView.drawableDepthFormat = GLKViewDrawableDepthFormat.format24
	}
	
	func setupGLupdater() {
		self.glkUpdater = self as GLKViewControllerDelegate
		self.delegate = self.glkUpdater
		self.preferredFramesPerSecond = 60
	}
	
	func setupShader() {
		self.lightingShader = BaseEffect(vertexShader: "Lighting.vsh", fragmentShader: "Lighting.fsh")
		self.lampShader = BaseEffect(vertexShader: "Lighting.vsh", fragmentShader: "Lamp.fsh")
	}
	
	func setupVertexArray() {
		glGenVertexArrays(GLsizei(1), &cubeVAO)
		glBindVertexArray(cubeVAO)
	}
	
	func setupVertexBuffer() {
		glGenBuffers(GLsizei(1), &vertexBuffer)
		glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
		let count = self.vertices.count
		let size =  MemoryLayout<Vertex>.size
		glBufferData(GLenum(GL_ARRAY_BUFFER), count * size, self.vertices, GLenum(GL_STATIC_DRAW))
		glEnableVertexAttribArray(VertexAttributes.Position.rawValue)
		glVertexAttribPointer(VertexAttributes.Position.rawValue, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), GraphicsFunctions.BUFFER_OFFSET(0)) // or BUFFER_OFFSET(0)
		
		glEnableVertexAttribArray(VertexAttributes.Color.rawValue)
		glVertexAttribPointer(VertexAttributes.Color.rawValue, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), GraphicsFunctions.BUFFER_OFFSET(3 * MemoryLayout<GLfloat>.size))
		
		glEnableVertexAttribArray(VertexAttributes.TexCoord.rawValue)
		glVertexAttribPointer(VertexAttributes.TexCoord.rawValue, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), GraphicsFunctions.BUFFER_OFFSET(6 * MemoryLayout<GLfloat>.size))
	}
	
	func setupLamp() {
		glGenVertexArrays(1, &lampVAO)
		glBindVertexArray(lampVAO)
		glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
		glEnableVertexAttribArray(VertexAttributes.Position.rawValue)
		glVertexAttribPointer(VertexAttributes.Position.rawValue, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), GraphicsFunctions.BUFFER_OFFSET(0))
		
		
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches{
			currentXTouchPoint = GLfloat((touch.location(in: self.view).x-self.view.bounds.size.width/2)/(self.view.bounds.size.width/2))
			currentYTouchPoint = GLfloat((self.view.bounds.size.height/2-touch.location(in:self.view).y)/(self.view.bounds.size.height/2))
			leftJoystick.update(touchX: currentXTouchPoint, touchY: currentYTouchPoint)
			rightJoystick.update(touchX: currentXTouchPoint, touchY: currentYTouchPoint)
			
		}
	}
	
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches{
			currentXTouchPoint = GLfloat((touch.location(in: self.view).x-self.view.bounds.size.width/2)/(self.view.bounds.size.width/2))
			currentYTouchPoint = GLfloat((self.view.bounds.size.height/2-touch.location(in:self.view).y)/(self.view.bounds.size.height/2))
			leftJoystick.update(touchX: currentXTouchPoint, touchY: currentYTouchPoint)
			rightJoystick.update(touchX: currentXTouchPoint, touchY: currentYTouchPoint)
			
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		currentXTouchPoint = 0
		currentYTouchPoint = 0
		leftJoystick.resetPosition()
		rightJoystick.resetPosition()
	}
	
	func readControllerInput(controller: GCController) {
		if let profile = controller.extendedGamepad {
			let cameraSpeed:Float = 5.5 * deltaTime
			var front:GLKVector3
			if profile.dpad.up.isPressed {
				cameraPos = GLKVector3Add(cameraPos, GLKVector3MultiplyScalar(cameraFront, cameraSpeed))
			}
			if profile.dpad.down.isPressed {
				cameraPos = GLKVector3Subtract(cameraPos, GLKVector3MultiplyScalar(cameraFront, cameraSpeed))
			}
			if profile.dpad.right.isPressed {
				cameraPos = GLKVector3Add(cameraPos, GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3CrossProduct(cameraFront, cameraUp)), cameraSpeed))
			}
			if profile.dpad.left.isPressed {
				cameraPos = GLKVector3Subtract(cameraPos, GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3CrossProduct(cameraFront, cameraUp)), cameraSpeed))
			}
			if profile.leftThumbstick.yAxis.value != 0{
				cameraPos = GLKVector3Add(cameraPos, GLKVector3MultiplyScalar(cameraFront, cameraSpeed*profile.leftThumbstick.yAxis.value))
			}
			if profile.leftThumbstick.xAxis.value != 0{
				cameraPos = GLKVector3Add(cameraPos, GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3CrossProduct(cameraFront, cameraUp)), cameraSpeed * profile.leftThumbstick.xAxis.value))
			}
			if profile.rightThumbstick.yAxis.value != 0{
				pitch = pitch + profile.rightThumbstick.yAxis.value
				if pitch > 89{
					pitch = 89
				}
				if pitch < -89{
					pitch = -89
				}
			}
			if profile.rightThumbstick.xAxis.value != 0{
				yaw = yaw  + profile.rightThumbstick.xAxis.value
			}
			front = GLKVector3Make(cos(GLKMathDegreesToRadians(yaw))*cos(GLKMathDegreesToRadians(pitch)), sin(GLKMathDegreesToRadians(pitch)), sin(GLKMathDegreesToRadians(yaw)) * cos(GLKMathDegreesToRadians(pitch)))
			cameraFront=GLKVector3Normalize(front)
		}
	}
	/*
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}
	*/
}
