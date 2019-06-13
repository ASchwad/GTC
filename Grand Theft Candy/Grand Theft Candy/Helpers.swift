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

// Generates a random number between -0.44 and 0.44 (adjusted for plane with size of 1,1 and borders)
public func GenerateRandomCoordinateInPlane() -> Double {
    let randomNumber = Double.random(in: -0.44...0.44)
    return randomNumber
}

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

public func placeNodeOnHit(node: SCNNode, atHit hit: ARHitTestResult, sceneView: ARSCNView)
{
    let rotate = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
    let rotateTransform = simd_mul(hit.worldTransform, rotate)
    
    node.transform =  SCNMatrix4(m11: rotateTransform.columns.0.x, m12: rotateTransform.columns.0.y, m13: rotateTransform.columns.0.z, m14: rotateTransform.columns.0.w, m21: rotateTransform.columns.1.x, m22: rotateTransform.columns.1.y, m23: rotateTransform.columns.1.z, m24: rotateTransform.columns.1.w, m31: rotateTransform.columns.2.x, m32: rotateTransform.columns.2.y, m33: rotateTransform.columns.2.z, m34: rotateTransform.columns.2.w, m41: rotateTransform.columns.3.x, m42: rotateTransform.columns.3.y, m43: rotateTransform.columns.3.z, m44: rotateTransform.columns.3.w)
   
  
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
    
    public func maximizeView()
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



