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
    
    var isDestroyed: Bool = false
    var hotBombNode: SCNNode!
    
    init(placePosition: SCNVector3, playArea: SCNNode)
    {
        let hotBombScene = SCNScene(named: "hotBomb.scn")!
         hotBombNode = hotBombScene.rootNode.childNode(withName: "bonbon", recursively: false)!
        hotBombNode.name = "HotBomb"
        
        
        let incItemBodyShape = SCNPhysicsShape(geometry: SCNBox(width: 0.0008, height: 0.0008, length: 0.0008, chamferRadius: 0), options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
        hotBombNode.physicsBody = SCNPhysicsBody(type: .static, shape: incItemBodyShape)
        hotBombNode.physicsBody?.categoryBitMask = 256
         hotBombNode.physicsBody?.contactTestBitMask = 64
        
          let selfDestroyTimer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(Destroy), userInfo: nil, repeats: false)
        
        hotBombNode.position = placePosition
        hotBombNode.position.y = 0.03
        playArea.addChildNode(hotBombNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func Destroy(){
        
        if(isDestroyed == false){
            hotBombNode.removeFromParentNode()
            isDestroyed = true
        }
       
    }
    
    
    
    
}
