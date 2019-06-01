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
import ARKit

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

  public func placeNodeOnHit(node: SCNNode, atHit hit: ARHitTestResult)
  {
    node.transform = SCNMatrix4(hit.anchor!.transform)
 
    
    let position = SCNVector3Make(hit.worldTransform.columns.3.x + node.geometry!.boundingBox.min.z, hit.worldTransform.columns.3.y, hit.worldTransform.columns.3.z)
        node.position = position
}

// Creates a circle (as SKSShapeNode) for overlays with given properties
public func CreateCircleShape(radius: CGFloat, color: UIColor, lineWidth: CGFloat) -> SKShapeNode
{
    let circle = SKShapeNode(circleOfRadius: radius)
    
    circle.strokeColor = color
    circle.lineWidth = lineWidth
    
    return circle
}

extension UIView {
    
    public func fillSuperview()
    {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
    }
}


