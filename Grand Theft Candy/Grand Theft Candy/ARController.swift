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
    
    private var horizontalPlanes = [UUID: HorizontalPlane]()
    
    var sceneView: ARSCNView?
    
    let configuration = ARWorldTrackingConfiguration()
    
    func initializeARController(to sceneView: ARSCNView) {
        self.sceneView = sceneView
        self.sceneView!.delegate = self
        self.sceneView?.autoenablesDefaultLighting = true
        
        startPlaneDetection()
        configuration.isLightEstimationEnabled = true
    }
    
    func displayDegubInfo()
    {
        sceneView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func startPlaneDetection() {
        configuration.planeDetection = [.horizontal]
        sceneView?.session.run(configuration)
    }
}

extension ARController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // we only care about planes
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        let plane = HorizontalPlane(anchor: planeAnchor)
        
        // store a local reference to the plane
        horizontalPlanes[anchor.identifier] = plane
        
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if let plane = horizontalPlanes[planeAnchor.identifier] {
            plane.UpdatePlaneTransform(anchor: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor)
    {
        horizontalPlanes.removeValue(forKey: anchor.identifier)
    }
    
}
