//
//  ItemController.swift
//  Grand Theft Candy
//
//  Created by Egeler Lea on 25.06.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//

import SceneKit

class ItemController {
    var fastItemNode: SCNNode!
    var fastItem: SCNNode!
    var slowItemNode: SCNNode!
    var slowItem: SCNNode!
    var incItemNode: SCNNode!
    var incItem: SCNNode!
    var decItemNode: SCNNode!
    var decItem: SCNNode!
    var bombItemNode: SCNNode!
    var bombItem: SCNNode!
    var starItemNode : SCNNode!
    var starItem : SCNNode!
    
    func InitializeItems()
    {
        let incItemScene = SCNScene(named: "candyCane.scn")!
        incItemNode = incItemScene.rootNode.childNode(withName: "candyCane", recursively: false)!
        let decItemScene = SCNScene(named: "broccoli.scn")!
        decItemNode = decItemScene.rootNode.childNode(withName: "broccoli", recursively: false)!
        
        let fastItemScene = SCNScene(named: "lightningBolt.scn")!
        fastItemNode = fastItemScene.rootNode.childNode(withName: "lightningBolt", recursively: false)!
        let slowItemScene = SCNScene(named: "snowFlake.scn")!
        slowItemNode = slowItemScene.rootNode.childNode(withName: "snowFlake", recursively: false)!
        
        let bombItemScene = SCNScene(named: "bombItemScene.scn")!
        bombItemNode = bombItemScene.rootNode.childNode(withName: "Bomb", recursively: false)!
        
        let starItemScene = SCNScene(named: "facestar.scn")!
        starItemNode = starItemScene.rootNode.childNode(withName: "Mesh", recursively: false)!
    }
    
    @objc func RandomItem(playArea: SCNNode!){
        let number = Int.random(in: 1 ..< 100)
        
        if(number <= 20){
            //bombe
            CreateBombItem(playArea: playArea)
            // stern, 20% W'keit?
            CreateStarItem(playArea: playArea)
        }else if(number<=50){
            //speed
            CreateFastItem(playArea: playArea)
        }else if(number<=75){
            //slow
            CreateSlowItem(playArea: playArea)
        }else if(number<=100){
            //Dec Item
            CreateDecItem(playArea: playArea)
        }else{
            
        }
    }
    
    func CreateIncItem(playArea: SCNNode!) {
        incItem = incItemNode.clone()
        incItem.name = "IncItem"
        incItem.scale = SCNVector3(0.0008, 0.0008, 0.0008)
        
        let incItemBodyShape = SCNPhysicsShape(geometry: SCNBox(width: 0.0008, height: 0.0008, length: 0.0008, chamferRadius: 0), options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
        incItem.physicsBody = SCNPhysicsBody(type: .static, shape: incItemBodyShape)
        incItem.physicsBody?.categoryBitMask = 2
        incItem.physicsBody?.contactTestBitMask = 1
        
        giveNodeRandomCoordinatesInPlane(node: incItem)
        incItem.runAction(SCNAction.rotateBy(x: 0, y: 15, z: 0, duration: 20))
        
        playArea.addChildNode(incItem)
    }
    
    func CreateDecItem(playArea: SCNNode!) {
        decItem = decItemNode.clone()
        let uuid = UUID().uuidString
        decItem.name = uuid
        decItem.scale = SCNVector3(0.02, 0.02, 0.02)
        
        let decItemBodyShape = SCNPhysicsShape(geometry: SCNBox(width: 0.02, height: 0.02, length: 0.02, chamferRadius: 0), options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
        decItem.physicsBody = SCNPhysicsBody(type: .static, shape: decItemBodyShape)
        decItem.physicsBody?.categoryBitMask = 4
        decItem.physicsBody?.contactTestBitMask = 1
        
        giveNodeRandomCoordinatesInPlane(node: decItem)
        decItem.runAction(SCNAction.rotateBy(x: 0, y: 15, z: 0, duration: 20))
        
        playArea.addChildNode(decItem)
        removeNodeFromPlayArea(playArea: playArea, uuid: uuid)
    }
    
    func CreateFastItem(playArea: SCNNode!) {
        fastItem = fastItemNode.clone()
        let uuid = UUID().uuidString
        fastItem.name = uuid
        fastItem.scale = SCNVector3(0.0002, 0.0002, 0.0002)
        
        let fastItemBodyShape = SCNPhysicsShape(geometry: SCNBox(width: 0.0002, height: 0.0002, length: 0.0002, chamferRadius: 0), options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
        fastItem.physicsBody = SCNPhysicsBody(type: .static, shape: fastItemBodyShape)
        fastItem.physicsBody?.categoryBitMask = 8
        fastItem.physicsBody?.contactTestBitMask = 1
        
        giveNodeRandomCoordinatesInPlane(node: fastItem)
        
        fastItem.runAction(SCNAction.rotateBy(x: 0, y: 15, z: 0, duration: 20))
        playArea.addChildNode(fastItem)
        removeNodeFromPlayArea(playArea: playArea, uuid: uuid)
    }
    
    func CreateSlowItem(playArea: SCNNode!) {
        slowItem = slowItemNode.clone()
        let uuid = UUID().uuidString
        slowItem.name = uuid
        slowItem.scale = SCNVector3(0.02, 0.02, 0.02)
        
        let slowItemBodyShape = SCNPhysicsShape(geometry: SCNBox(width: 0.02, height: 0.02, length: 0.02, chamferRadius: 0), options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
        slowItem.physicsBody = SCNPhysicsBody(type: .static, shape: slowItemBodyShape)
        slowItem.physicsBody?.categoryBitMask = 16
        slowItem.physicsBody?.contactTestBitMask = 1
        
        giveNodeRandomCoordinatesInPlane(node: slowItem)
        slowItem.runAction(SCNAction.rotateBy(x: 0, y: 15, z: 0, duration: 20))
        
        playArea.addChildNode(slowItem)
        removeNodeFromPlayArea(playArea: playArea, uuid: uuid)
    }
    
    func CreateBombItem(playArea: SCNNode!) {
        bombItem = bombItemNode.clone()
        let uuid = UUID().uuidString
        bombItem.name = uuid
        
        
        let incItemBodyShape = SCNPhysicsShape(geometry: SCNBox(width: 0.0008, height: 0.0008, length: 0.0008, chamferRadius: 0), options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
        bombItem.physicsBody = SCNPhysicsBody(type: .static, shape: incItemBodyShape)
        bombItem.physicsBody?.categoryBitMask = 128
        bombItem.physicsBody?.contactTestBitMask = 1
        
        giveNodeRandomCoordinatesInPlane(node: bombItem)
        bombItem.scale = SCNVector3(0.2, 0.2, 0.2)
        bombItem.eulerAngles = SCNVector3(DegreeToRad(degree: -90), 0, 0)
        bombItem.runAction(SCNAction.rotateBy(x: 0, y: 15, z: 0, duration: 20))
        
        playArea.addChildNode(bombItem)
        removeNodeFromPlayArea(playArea: playArea, uuid: uuid)
    }
    
    func CreateStarItem(playArea: SCNNode!) {
        starItem = starItemNode.clone()
        let uuid = UUID().uuidString
        starItem.name = uuid
        
        starItem.scale = SCNVector3(0.02, 0.02, 0.02)
        
        let starItemBodyShape = SCNPhysicsShape(geometry: SCNBox(width: 0.02, height: 0.02, length: 0.02, chamferRadius: 0), options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
        starItem.physicsBody = SCNPhysicsBody(type: .static, shape: starItemBodyShape)
        
        starItem.physicsBody?.categoryBitMask = 256
        starItem.physicsBody?.contactTestBitMask = 1
        
        giveNodeRandomCoordinatesInPlane(node: starItem)
        
        starItem.runAction(SCNAction.rotateBy(x: 0, y: 15, z: 0, duration: 20))
        playArea.addChildNode(starItem)
        removeNodeFromPlayArea(playArea: playArea, uuid: uuid)
        
    }
    
    func giveNodeRandomCoordinatesInPlane(node: SCNNode){
        let x = GenerateRandomCoordinateInPlane()
        let z = GenerateRandomCoordinateInPlane()
        node.position = SCNVector3(x, 0.03, z)
    }
    
    func removeNodeFromPlayArea(playArea: SCNNode, uuid: String){
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                playArea.enumerateChildNodes{ (node, stop) in
                    if(node.name == uuid){
                        node.removeFromParentNode()
                    }
                }
            }
            playArea.enumerateChildNodes{ (node, stop) in
                if(node.name == uuid){
                    self.highlightNodeBeforeDeletion(0.15, node: node)
                }
            }
        }
    }
    
    func highlightNodeBeforeDeletion(_ duration: TimeInterval, node: SCNNode){
        let highlightAction = SCNAction.customAction(duration: duration) { (node, elapsedTime) in
            node.isHidden = true
        }
        
        let unHighlightAction = SCNAction.customAction(duration: duration) { (node, elapsedTime) in
            node.isHidden = false
        }
        
        let pulseSequence = SCNAction.sequence([highlightAction, unHighlightAction])
        let infiniteLoop = SCNAction.repeatForever(pulseSequence)
        
        node.runAction(infiniteLoop)
    }

}
