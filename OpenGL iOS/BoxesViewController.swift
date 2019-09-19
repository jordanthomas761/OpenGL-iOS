//
//  ViewController.swift
//  OpenGL iOS
//
//  Created by Jordan Thomas on 1/19/18.
//  Copyright © 2018 Jordan Thomas. All rights reserved.
//

import UIKit
import GLKit
import GameController


class BoxesViewController: GLKViewController, GLKViewControllerDelegate {
	
	
	
	var controllers:[GCController]!
    
    var glkView:GLKView!
    var glkUpdater: GLKViewControllerDelegate!
    
    var vertexArray : GLuint = 0
    var vertexBuffer : GLuint = 0
    var elementBuffer : GLuint = 0
    var shader : BaseEffect!
    var texture1 : GLKTextureInfo!
    var texture2 : GLKTextureInfo!
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
	var tri : Triangle!
	
	var currentXTouchPoint:Float = 0
	var currentYTouchPoint:Float = 0
	
    
    let vertices : [Vertex] = [
                // positions        // colors       //TextCoord
        Vertex( -0.5,   -0.5, -0.5,    1.0, 0.0, 0.0,   0.0, 0.0),
        Vertex( 0.5,    -0.5, -0.5,   0.0, 1.0, 0.0,   1.0, 0.0),
        Vertex( 0.5,    0.5, -0.5,  0.0, 0.0, 1.0,   1.0, 1.0),
        Vertex( 0.5,    0.5, -0.5,   1.0, 1.0, 0.0,   1.0, 1.0),
        Vertex( -0.5,   0.5, -0.5,   1.0, 1.0, 0.0,   0.0, 1.0),
        Vertex( -0.5,   -0.5, -0.5,   1.0, 1.0, 0.0,   0.0, 0.0),
        
        Vertex( -0.5, -0.5, 0.5,    1.0, 0.0, 0.0,   0.0, 0.0),
        Vertex( 0.5, -0.5, 0.5,   0.0, 1.0, 0.0,   1.0, 0.0),
        Vertex( 0.5, 0.5, 0.5,  0.0, 0.0, 1.0,   1.0, 1.0),
        Vertex( 0.5, 0.5, 0.5,   1.0, 1.0, 0.0,   1.0, 1.0),
        Vertex( -0.5, 0.5, 0.5,   1.0, 1.0, 0.0,   0.0, 1.0),
        Vertex( -0.5, -0.5, 0.5,   1.0, 1.0, 0.0,   0.0, 0.0),
        
        Vertex( -0.5, 0.5, 0.5,    1.0, 0.0, 0.0,   1.0, 0.0),
        Vertex( -0.5, 0.5, -0.5,   0.0, 1.0, 0.0,   1.0, 1.0),
        Vertex( -0.5, -0.5, -0.5,  0.0, 0.0, 1.0,   0.0, 1.0),
        Vertex( -0.5, -0.5, -0.5,   1.0, 1.0, 0.0,   0.0, 1.0),
        Vertex( -0.5, -0.5, 0.5,   1.0, 1.0, 0.0,   0.0, 0.0),
        Vertex( -0.5, 0.5, 0.5,   1.0, 1.0, 0.0,   1.0, 0.0),
    
        Vertex( 0.5, 0.5, 0.5,    1.0, 0.0, 0.0,   1.0, 0.0),
        Vertex( 0.5, 0.5, -0.5,   0.0, 1.0, 0.0,   1.0, 1.0),
        Vertex( 0.5, -0.5, -0.5,  0.0, 0.0, 1.0,   0.0, 1.0),
        Vertex( 0.5, -0.5, -0.5,   1.0, 1.0, 0.0,   0.0, 1.0),
        Vertex( 0.5, -0.5, 0.5,   1.0, 1.0, 0.0,   0.0, 0.0),
        Vertex( 0.5, 0.5, 0.5,   1.0, 1.0, 0.0,   1.0, 0.0),
        
        Vertex( -0.5, -0.5, -0.5,    1.0, 0.0, 0.0,   0.0, 1.0),
        Vertex( 0.5, -0.5, -0.5,   0.0, 1.0, 0.0,   1.0, 1.0),
        Vertex( 0.5, -0.5, 0.5,  0.0, 0.0, 1.0,   1.0, 0.0),
        Vertex( 0.5, -0.5, 0.5,   1.0, 1.0, 0.0,   1.0, 0.0),
        Vertex( -0.5, -0.5, 0.5,   1.0, 1.0, 0.0,   0.0, 0.0),
        Vertex( -0.5, -0.5, -0.5,   1.0, 1.0, 0.0,   0.0, 1.0),
        
        Vertex( -0.5, 0.5, -0.5,    1.0, 0.0, 0.0,   0.0, 1.0),
        Vertex( 0.5, 0.5, -0.5,   0.0, 1.0, 0.0,   1.0, 1.0),
        Vertex( 0.5, 0.5, 0.5,  0.0, 0.0, 1.0,   1.0, 0.0),
        Vertex( 0.5, 0.5, 0.5,   1.0, 1.0, 0.0,   1.0, 0.0),
        Vertex( -0.5, 0.5, 0.5,   1.0, 1.0, 0.0,   0.0, 0.0),
        Vertex( -0.5, 0.5, -0.5,   1.0, 1.0, 0.0,   0.0, 1.0),
    ]
    
    let cubePositions : [GLKVector3] = [
        GLKVector3Make( 0.0,  0.0,  0.0),
        GLKVector3Make( 2.0,  5.0, -15.0),
        GLKVector3Make(-1.5, -2.2, -2.5),
        GLKVector3Make(-3.8, -2.0, -12.3),
        GLKVector3Make( 2.4, -0.4, -3.5),
        GLKVector3Make(-1.7,  3.0, -7.5),
        GLKVector3Make( 1.3, -2.0, -2.5),
        GLKVector3Make( 1.5,  2.0, -2.5),
        GLKVector3Make( 1.5,  0.2, -1.5),
        GLKVector3Make(-1.3,  1.0, -1.5)
    ]
    
    let indices : [GLuint] = [
        0, 1, 3, // first triangle
        1, 2, 3  // second triangle
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
		
		
		//self.navigationItem.backBarButtonItem?.action = Selector("back")
        
        setupGLcontext()
        setupGLupdater()
		
		self.view.isMultipleTouchEnabled = true
		
		leftJoystick = JoyStick(joystickXPosition: Float(self.view.bounds.width/8), joystickYPosition: Float(self.view.bounds.height*3/4), backgroundJoystickImage: #imageLiteral(resourceName: "joystickBackground.png").cgImage!, joystickBackgroundWidth: 150, joystickBackgroundHeight: 150, joystickImage: #imageLiteral(resourceName: "joystickDriver.png").cgImage!, joystickWidth: 90, joystickHeight: 90, screenWidth: Float(self.view.bounds.width), screenHeight: Float(self.view.bounds.height))
		leftJoystick.setupOpenGL()
		
		rightJoystick = JoyStick(joystickXPosition: Float(self.view.bounds.width*7/8), joystickYPosition: Float(self.view.bounds.height*3/4), backgroundJoystickImage: #imageLiteral(resourceName: "joystickBackground.png").cgImage!, joystickBackgroundWidth: 150, joystickBackgroundHeight: 150, joystickImage: #imageLiteral(resourceName: "joystickDriver.png").cgImage!, joystickWidth: 90, joystickHeight: 90, screenWidth: Float(self.view.bounds.width), screenHeight: Float(self.view.bounds.height))
		rightJoystick.setupOpenGL()
		
		tri = Triangle()
		tri.prepareToDraw()
        setupShader()
		setupVertexArray()
        setupVertexBuffer()
		
				
		
        //setupElementBuffer()
        texture1 = GraphicsFunctions.setupTexture(file: #imageLiteral(resourceName: "awesomeface.png").cgImage!)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)
        texture2 = GraphicsFunctions.setupTexture(file: #imageLiteral(resourceName: "container.jpg").cgImage!)
		
        shader.prepareToDraw()
        glUniform1i(glGetUniformLocation(shader.programHandle, "texture1"), 0)
        glUniform1i(glGetUniformLocation(shader.programHandle, "texture2"), 1)
        glUniform1i(glGetUniformLocation(shader.programHandle, "mixture"), 2)
		

        
    }
	/*
	func back() {
		self.navigationController?.popViewController(animated: true)
		cameraPos = GLKVector3Make(0.0, 0.0, 3.0)
		cameraFront = GLKVector3Make(0.0, 0.0, -1.0)
		mixture = 0.5
	}
	*/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
	}
	
	//Draw function
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
		
		tri.draw()
		
		
		
        shader.prepareToDraw()
		
		
        shader.setFloat(name: "mixture", value: mixture)
		
		let currentFrame:Float = Float(CACurrentMediaTime())
        deltaTime = currentFrame - lastFrame
		lastFrame = currentFrame
        
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(texture1.target, texture1.name)
        glActiveTexture(GLenum(GL_TEXTURE1))
        glBindTexture(texture2.target, texture2.name)
        //let radius:Float = 10
		
		
		projection = GLKMatrix4Identity
		projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(fov), Float(self.view.bounds.size.width/self.view.bounds.size.height), 0.1, 100.0)
		shader.setMat4(name: "projection", value: projection)
		
		viewGL = GLKMatrix4MakeLookAt(cameraPos.x, cameraPos.y, cameraPos.z, cameraPos.x + cameraFront.x, cameraPos.y + cameraFront.y, cameraPos.z + cameraFront.z, cameraUp.x, cameraUp.y, cameraUp.z)
        //viewGL = GLKMatrix4MakeLookAt(sin(Float(CACurrentMediaTime())) * radius, 0, cos(Float(CACurrentMediaTime())) *  radius, 0, 0, 0, 0, 1, 0)
        shader.setMat4(name: "view", value: viewGL)
		
		
        for vec in cubePositions {
            model = GLKMatrix4Identity
            model = GLKMatrix4TranslateWithVector3(model, vec)
            model = GLKMatrix4Rotate(model, currentFrame * GLKMathDegreesToRadians(50.0), 0.5, 1, 0)
            shader.setMat4(name: "model", value: model)
            glBindVertexArray(vertexArray)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
        }
        //glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_INT), BUFFER_OFFSET(0))
		
		leftJoystick.draw()
		rightJoystick.draw()
		
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)

		glBindVertexArray(0)
        
    }

	
}

extension BoxesViewController {
    
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
        self.shader = BaseEffect(vertexShader: "Box.vsh", fragmentShader: "Box.fsh")
    }
    
    func setupVertexArray() {
        glGenVertexArrays(GLsizei(1), &vertexArray)
        glBindVertexArray(vertexArray)
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
    
    func setupElementBuffer() {
        glGenBuffers(GLsizei(1), &elementBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), elementBuffer)
        let count = indices.count
        let size =  MemoryLayout<[GLuint]>.size
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), count * size, indices, GLenum(GL_STATIC_DRAW))
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
		if (!leftJoystick.getJoystickIsPress() && !rightJoystick.getJoystickIsPress()){
			let y = (2 * touches.first!.location(in: self.view).y - self.view.bounds.size.height/2) / (self.view.bounds.size.height)
			if(y <= 0) {
				self.mixture = 0
			}else if ( y >= 1) {
				self.mixture = 1
			} else {
				self.mixture = Float(y)
			}
		}
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
