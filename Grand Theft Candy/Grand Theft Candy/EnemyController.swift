//
//  EnemyController.swift
//  Grand Theft Candy
//
//  Created by Bao on 12.06.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//

import SceneKit
import Foundation
import QuartzCore
import ARKit

var shouldContinueToMove = true
var explodingPolice: SCNNode!

var isCycleCompleted = false

final class EnemyController {
    
    init() {
        
    }
    
    func MoveToFirstPoint(enemy: SCNNode) {
        //let currentLocation = enemy.position
        let forwardX = 0.5
        if(isCycleCompleted == true)
        {
            let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 90)), around: SCNVector3(0,1,0), duration: 0.3)
            enemy.runAction(rotateAction)
            isCycleCompleted = false
         
        }
        let moveAction = SCNAction.moveBy(x: CGFloat(forwardX), y: 0, z: 0, duration: 2)
        enemy.runAction(moveAction, completionHandler: {
            if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                self.MoveToSecondPoint(enemy: enemy)
            }
        }) }
        
        func MoveToSecondPoint(enemy: SCNNode) {
            //let currentLocation = enemy.position
            let pointZ
                = -0.5
            let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 90)), around: SCNVector3(0,1,0), duration: 0.3)
            enemy.runAction(rotateAction)
            let moveAction = SCNAction.moveBy(x: 0, y: 0, z: CGFloat(pointZ), duration: 2)
            enemy.runAction(moveAction, completionHandler: {
                if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                    self.MoveToThirdPoint(enemy: enemy)
                }
            })
            
        }
        
        func MoveToThirdPoint(enemy: SCNNode) {
            //let currentLocation = enemy.position
            let backX = -0.5
            let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 90)), around: SCNVector3(0,1,0), duration: 0.3)
            enemy.runAction(rotateAction)
            let moveAction = SCNAction.moveBy(x: CGFloat(backX), y: 0, z: 0, duration: 2)
            enemy.runAction(moveAction, completionHandler: {
                if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                   self.MoveToFourthPoint(enemy: enemy)
                }
            })
        }
        
        func MoveToFourthPoint(enemy: SCNNode) {
            let backZ = 0.5
            let moveAction = SCNAction.moveBy(x: 0, y: 0, z: CGFloat(backZ), duration: 2)
            let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 90)), around: SCNVector3(0,1,0), duration: 0.3)
            enemy.runAction(rotateAction)
            enemy.runAction(moveAction, completionHandler: {
                if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                    isCycleCompleted = true
                    self.MoveToFirstPoint(enemy: enemy)
                    
                }
            })
        }
        
    @objc func DestroyPoliceNode(){
        
        explodingPolice.removeFromParentNode()
        
    }
        
        func DestroyPolice (police: SCNNode!)
        {
            let move = SCNAction.moveBy(x: 0.1, y: 1, z: 0.1, duration: 0.5)
            let rotation = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 360)), around: SCNVector3(1,0,0), duration: 0.2)
            let rotationTwo = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 360)), around: SCNVector3(0,1,0), duration: 0.2)
            
            police.runAction(move)
            police.runAction(rotation)
            police.runAction(rotationTwo)
            explodingPolice = police
            let timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(DestroyPoliceNode), userInfo: nil, repeats: false)
        }
        
   
}

