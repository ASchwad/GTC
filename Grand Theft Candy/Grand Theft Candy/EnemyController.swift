//
//  EnemyController.swift
//  Grand Theft Candy
//
//  Created by Bao on 12.06.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//

import SceneKit

var shouldContinueToMove = true

final class EnemyController {
    
    init() {
        
    }
    
    func enemyConstantMoveForward(enemy: SCNNode) {
        //let currentLocation = enemy.position
        let forwardX = 0.5
        let moveAction = SCNAction.moveBy(x: CGFloat(forwardX), y: 0, z: 0, duration: 1)
        enemy.runAction(moveAction, completionHandler: {
            if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                enemyConstantMoveBack(enemy: enemy)
            }
        })
        
        func enemyConstantMoveBack(enemy: SCNNode) {
            //let currentLocation = enemy.position
            let backX = -0.5
            let moveAction = SCNAction.moveBy(x: CGFloat(backX), y: 0, z: 0, duration: 1)
            enemy.runAction(moveAction, completionHandler: {
                if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                    self.enemyConstantMoveForward(enemy: enemy)
                }
            })
            
        }
    }
}

