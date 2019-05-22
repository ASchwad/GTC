//
//  Helpers.swift
//  Grand Theft Candy
//
//  Created by Niklas on 22.05.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

// Collection of useful methods which have a good chance to be reused

    // Gets the root node for a given scn (useful for imported models)
    public func GetRootNodeOfScn (scnname: String) -> SCNNode
    {
        let scene = SCNScene(named: scnname)!
        return scene.rootNode.childNodes[0]
    }
    
    // Calculates the radian for a given degree (Scenekit use rads for rotation)
    public func DegreeToRad (degree: Float) -> Float
    {
        return Float(Double.pi/180) * degree
    }

