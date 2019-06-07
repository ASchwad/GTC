//
//  ARVController.swift
//  Grand Theft Candy
//
//  Created by admin on 22.05.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//

import Foundation
import ARKit

class ARController: NSObject {
    
    public var horizontalPlanes = [UUID: HorizontalPlane]()
    
    var planeAnchors: [ARPlaneAnchor] = []
    
    var sceneView: ARSCNView?
    
    let configuration = ARWorldTrackingConfiguration()
    
    func InitializeARController(to sceneView: ARSCNView) {
        self.sceneView = sceneView
        self.sceneView!.delegate = self
        self.sceneView?.autoenablesDefaultLighting = true
        
        StartPlaneDetection()
        configuration.isLightEstimationEnabled = true
    }
    
    func ShowDebugHints()
    {
        sceneView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func StartPlaneDetection() {
        configuration.planeDetection = [.horizontal]
        sceneView?.session.run(configuration)
    }
}

extension ARController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        planeAnchors.append(planeAnchor)

        let plane = HorizontalPlane(anchor: planeAnchor)
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if let plane = horizontalPlanes[planeAnchor.identifier] {
            plane.UpdatePlaneTransform(anchor: planeAnchor)
        }
    }
    
    func removePlaneNodes() {
        sceneView?.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
    }
    
}
