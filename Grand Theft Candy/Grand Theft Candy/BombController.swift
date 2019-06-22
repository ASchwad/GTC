//
//  BombController.swift
//  Grand Theft Candy
//
//  Created by admin on 23.06.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//

import Foundation
import ARKit

class BombController {
    
    var explosionNode: SCNNode!
    
    
    func PerformExplosion(contactNode: SCNNode!, playArea: SCNNode!) {
        let explosion =
            SCNParticleSystem(named: "explosionParticles.scnp", inDirectory:
                nil)!
        
        explosionNode = SCNNode()
        explosionNode.transform = contactNode.transform
        explosionNode.scale = SCNVector3(0.01, 0.01, 0.01)
        explosion.particleSize = 0.004
        
        playArea.addChildNode(explosionNode)
        explosionNode.addParticleSystem(explosion)
        
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(DestroyParticleSystem), userInfo: nil, repeats: false)
    }
    
    @objc func DestroyParticleSystem()
    {
        explosionNode.removeFromParentNode()
}

}
