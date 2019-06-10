//
//  HorizontalPlane.swift
//  Grand Theft Candy
//
//  Created by admin on 22.05.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//

import Foundation
import ARKit

class HorizontalPlane: SCNNode {
    
    let basicPlane: SCNPlane
    
    init(anchor: ARPlaneAnchor)
    {
        basicPlane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        super.init()

        let planeNode = SCNNode(geometry: basicPlane)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = "Surface.jpeg"
        planeNode.geometry!.materials = [planeMaterial]

        planeNode.eulerAngles.x = -.pi / 2
        
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UpdatePlaneTransform(anchor: ARPlaneAnchor) {
        basicPlane.width = CGFloat(anchor.extent.x)
        basicPlane.height = CGFloat(anchor.extent.z)
        
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
    
}
