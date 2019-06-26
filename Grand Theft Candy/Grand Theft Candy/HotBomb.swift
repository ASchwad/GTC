//
//  HotBomb.swift
//  Grand Theft Candy
//
//  Created by admin on 21.06.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//

import Foundation
import ARKit

class HotBomb {
    var explosionNode: SCNNode!
    var isDestroyed: Bool = false
    var hotBombNode: SCNNode!
     var playAreaNode: SCNNode!

    
    init(placePosition: SCNVector3, playArea: SCNNode)
    {
        let hotBombScene = SCNScene(named: "hotBombScene.scn")!
         hotBombNode = hotBombScene.rootNode.childNode(withName: "Bomb", recursively: false)!
        hotBombNode.name = "HotBomb"
        hotBombNode.scale = SCNVector3(0.25, 0.25, 0.25)
        hotBombNode.eulerAngles = SCNVector3(DegreeToRad(degree: -90), 0, 0)
        
        let incItemBodyShape = SCNPhysicsShape(geometry: SCNBox(width: 0.0008, height: 0.0008, length: 0.0008, chamferRadius: 0), options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
        hotBombNode.physicsBody = SCNPhysicsBody(type: .static, shape: incItemBodyShape)
        hotBombNode.physicsBody?.categoryBitMask = 256
         hotBombNode.physicsBody?.contactTestBitMask = 64
        
          let selfDestroyTimer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(Destroy), userInfo: nil, repeats: false)
        
        hotBombNode.position = placePosition
        hotBombNode.position.y = 0.03
        hotBombNode.highlightNodeWithFrequence(1, materialIndex: 1)
        playAreaNode = playArea
        playArea.addChildNode(hotBombNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func Destroy(){
            if(hotBombNode.parent != nil)
            {
                hotBombNode.removeFromParentNode()
                SelfExplosion()
            }
        }
    
        
        func SelfExplosion() {
            let explosion =
                SCNParticleSystem(named: "explosionParticles.scnp", inDirectory:
                    nil)!
            
            explosionNode = SCNNode()
            explosionNode.transform = hotBombNode.transform
            explosionNode.scale = SCNVector3(0.01, 0.01, 0.01)
            explosion.particleSize = 0.004
            
            playAreaNode.addChildNode(explosionNode)
            explosionNode.addParticleSystem(explosion)
            
            let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(DestroyParticleSystem), userInfo: nil, repeats: false)
        }
       
        @objc func DestroyParticleSystem()
        {
            explosionNode.removeFromParentNode()
        }
}
