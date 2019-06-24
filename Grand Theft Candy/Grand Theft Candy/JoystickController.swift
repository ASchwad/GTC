//
//  JoystickController.swift
//  Grand Theft Candy
//
//  Created by Niklas on 31.05.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//

import Foundation
import SceneKit
import ARKit
import SpriteKit

class JoystickController
{
    var innerStick = SKShapeNode()
    var substrate = SKShapeNode()
    var innerStickX = 0
    var innerStickY = 0
    var initPositionX : CGFloat = 0
    var initPositionY : CGFloat = 0
    var maxXValue : CGFloat = 0
    var maxYValue : CGFloat = 0
    var minXValue : CGFloat = 0
    var minYValue : CGFloat = 0
    
    func CreateJoysick(view: ARSCNView) -> SKScene
    {
        let viewHeight = 100
        let viewWidth = 100
        let sceneSize = CGSize(width: viewWidth, height: viewHeight)
        let skScene = SKScene(size: sceneSize)
        skScene.scaleMode = .resizeFill
        substrate = CreateCircleShape(radius: 65, color: .black, lineWidth: 3.0 )
        
        initPositionX = substrate.frame.size.width / 2 + 20
        initPositionY = substrate.frame.size.height / 2 + 20
        
        maxXValue = initPositionX + 60
        maxYValue = initPositionY + 55
        
        minXValue = initPositionX - 60
        minYValue = initPositionY - 55
        
        substrate.position.x = initPositionX
        substrate.position.y = initPositionY
        
        innerStick = CreateCircleShape(radius: 30, color: .black, lineWidth: 3.0)
        innerStick.position.x = innerStick.frame.size.width / 2 + 55
    
        innerStick.position.y = innerStick.frame.size.height / 2 + 55
       
        innerStick.fillColor = .black
        
        skScene.addChild(substrate)
        skScene.addChild(innerStick)
        skScene.isUserInteractionEnabled = false
        view.overlaySKScene = skScene
        
        return skScene
    }
    
    func SnapBackJoystick ()
    {
        innerStick.position.x = initPositionX
        innerStick.position.y = initPositionY
    }
    
    func SetJoystickPosition (xPosition: CGFloat, yPosition: CGFloat)
    {
        innerStick.position.x  = xPosition
        innerStick.position.y  = yPosition
    }
}
