//
//  JoyStick.swift
//  OpenGL iOS
//
//  Created by Jordan Thomas on 5/8/18.
//  Copyright © 2018 Jordan Thomas. All rights reserved.
//
/*
import Foundation
import UIKit

class JoyStick {
	var screenWidth:Float, screenHeight:Float
	var joystickDriverWidth:Float, joystickDriverHeight:Float
	
	
	init( joystickXPosition: Float, joystickYPosition:Float,  backgroundJoystickImage: CGImage, joystickBackgroundWidth:Float, joystickBackgroundHeight:Float, joystickImage:CGImage, joystickWidth:Float, joystickHeight:Float,screenWidth:Float, screenHeight:Float){
			
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
			joystickBackgroundImage = backgroundJoystickImage
			
			//4. Joystick x and y position. Because our ortho matrix is in the range of [-1,1]. We need to convert from screen coordinates to ortho coordinates.
			self.joystickXPosition=uJoystickXPosition*2/screenWidth-1;
			self.joystickYPosition=uJoystickYPosition*(-2/screenHeight)+1;
			
			//5. calculate the boundaries of the Joystick
			left=joystickXPosition-joystickDriverWidth/screenWidth;
			right=joystickXPosition+joystickDriverWidth/screenWidth;
			
			top=joystickYPosition+joystickDriverHeight/screenHeight;
			bottom=joystickYPosition-joystickDriverHeight/screenHeight;
			
			//6. set the bool value to false
			isPressed=false;
			
			//7. set the vertex and UV coordinates for both joystick elements
			setJoystickBackgroundVertexAndUVCoords();
			setJoystickDriverVertexAndUVCoords();

	}
}
*/
