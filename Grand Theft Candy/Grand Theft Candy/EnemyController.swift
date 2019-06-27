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
var firstLineCompleted = false
var isZigCompleted = false
var isZagCompleted = false
var timerForZig = 0
var timerForZag = 0

var police: SCNNode!
var policeNode: SCNNode!

var enemiesOnPlayArea = 0
var enemiesWithCirclePattern = 0
var enemiesWithDiagonalPattern = 0
var enemiesWithZigZagPattern = 0

final class EnemyController {
    
    //circle pattern
    func MoveInCircle(enemy: SCNNode) {
        
        func MoveToFirstPoint() {
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
                    MoveToSecondPoint()
                }
            }) }
        
        func MoveToSecondPoint() {
            let pointZ
                = -0.5
            let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 90)), around: SCNVector3(0,1,0), duration: 0.3)
            enemy.runAction(rotateAction)
            let moveAction = SCNAction.moveBy(x: 0, y: 0, z: CGFloat(pointZ), duration: 2)
            enemy.runAction(moveAction, completionHandler: {
                if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                    MoveToThirdPoint()
                }
            })
            
        }
        
        func MoveToThirdPoint() {
            //let currentLocation = enemy.position
            let backX = -0.5
            let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 90)), around: SCNVector3(0,1,0), duration: 0.3)
            enemy.runAction(rotateAction)
            let moveAction = SCNAction.moveBy(x: CGFloat(backX), y: 0, z: 0, duration: 2)
            enemy.runAction(moveAction, completionHandler: {
                if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                    MoveToFourthPoint()
                }
            })
        }
        
        func MoveToFourthPoint() {
            let backZ = 0.5
            let moveAction = SCNAction.moveBy(x: 0, y: 0, z: CGFloat(backZ), duration: 2)
            let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 90)), around: SCNVector3(0,1,0), duration: 0.3)
            enemy.runAction(rotateAction)
            enemy.runAction(moveAction, completionHandler: {
                if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                    isCycleCompleted = true
                    MoveToFirstPoint()
                    
                }
            })
        }
        
        MoveToFirstPoint()
        
        
    }
    
    //diagonal-pattern
    func MoveDiagonal(enemy: SCNNode) {
        
        func MoveToFirstCorner() {
            let forwardZ = -0.7
            let forwardX = 0.7
            if(firstLineCompleted == true) {
                let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 180)), around: SCNVector3(0,1,0), duration: 0.3)
                enemy.runAction(rotateAction)
                firstLineCompleted = false
            }
            let moveAction = SCNAction.moveBy(x: CGFloat(forwardX), y: 0, z: CGFloat(forwardZ), duration: 9)
            enemy.runAction(moveAction, completionHandler: {
                if shouldContinueToMove { // Configure your `Bool` to check whether to
                    MoveToSecondCorner()
                }
            }) }
        
        func MoveToSecondCorner() {
            let forwardZ = 0.7
            let forwardX = -0.7
            let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 180)), around: SCNVector3(0,1,0), duration: 0.3)
            enemy.runAction(rotateAction)
            let moveAction = SCNAction.moveBy(x: CGFloat(forwardX), y: 0, z: CGFloat(forwardZ), duration: 9)
            enemy.runAction(moveAction, completionHandler: {
                if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                    firstLineCompleted = true
                    MoveToFirstCorner()
                    
                }
            }) }
        
        MoveToFirstCorner()
        
    }
    
    //zigZag-pattern
    func MoveZigZag(enemy: SCNNode) {
        
        func MoveZig() {
            let forwardX = 0.2
            if(isZigCompleted){
                let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 90)), around: SCNVector3(0,1,0), duration: 0.3)
                enemy.runAction(rotateAction)
                isZigCompleted = false
            }
            let moveAction = SCNAction.moveBy(x: CGFloat(forwardX), y: 0, z: 0, duration: 2)
            enemy.runAction(moveAction, completionHandler: {
                MoveDown()
            })
            
            func MoveDown() {
                let pointZ = 0.2
                let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: -90)), around: SCNVector3(0,1,0), duration: 0.3)
                enemy.runAction(rotateAction)
                let moveAction = SCNAction.moveBy(x: 0, y: 0, z: CGFloat(pointZ), duration: 2)
                enemy.runAction(moveAction, completionHandler: {
                    if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                        isZigCompleted = true
                        if(timerForZig < 3) {
                            MoveZig()
                        }
                        else {
                            timerForZag = 0
                            isZagCompleted = false
                            let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: -90)), around: SCNVector3(0,1,0), duration: 0.3)
                            enemy.runAction(rotateAction)
                            MoveZag()
                        }
                        timerForZig = timerForZig + 1
                    }
                })
            }
        }
        func MoveZag() {
            let backX = -0.27
            
            if(isZagCompleted) {
                let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 90)), around: SCNVector3(0,1,0), duration: 0.3)
                enemy.runAction(rotateAction)
                isZagCompleted = false
            }
            let moveAction = SCNAction.moveBy(x: CGFloat(backX), y: 0, z: 0, duration: 2)
            enemy.runAction(moveAction, completionHandler: {
                MoveUp()
            })
            func MoveUp() {
                let pointZ = -0.27
                let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: -90)), around: SCNVector3(0,1,0), duration: 0.3)
                enemy.runAction(rotateAction)
                
                let moveAction = SCNAction.moveBy(x: 0, y: 0, z: CGFloat(pointZ), duration: 2)
                enemy.runAction(moveAction, completionHandler: {
                    if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                        isZagCompleted = true
                        if(timerForZag < 2) {
                            MoveZag()
                        }
                        else {
                            timerForZig = 0
                            isZigCompleted = false
                            let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: -90)), around: SCNVector3(0,1,0), duration: 0.3)
                            enemy.runAction(rotateAction)
                            MoveZig()
                        }
                        timerForZag = timerForZag + 1
                    }
                })
            }
        }
        
        MoveZig()
        
    }
    
    func InitializeEnemy() {
        let policeScene = SCNScene(named: "police.scn")!
        policeNode = policeScene.rootNode.childNode(withName: "police", recursively: false)!
    }
    
    func CreatePoliceWithCirclePattern(playArea: SCNNode!) {
        police = policeNode.clone()
        police.name = "PoliceWithCirclePattern"
        
        let box = SCNBox(width: 0.06, height: 0.06, length: 0.06, chamferRadius: 0)
        police.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: box, options: nil))
        police.physicsBody?.categoryBitMask = 64
        police.physicsBody?.contactTestBitMask = 1
        police.position = SCNVector3(-0.3, 0.04, 0.4)
        
        playArea.addChildNode(police)
        
        MoveInCircle(enemy: police)
        enemiesOnPlayArea = enemiesOnPlayArea + 1
        enemiesWithCirclePattern = enemiesWithCirclePattern + 1
        
    }
    
    func CreatePoliceWithDiagonalPattern(playArea: SCNNode!) {
        police = policeNode.clone()
        police.name = "PoliceWithDiagonalPattern"
        
        let box = SCNBox(width: 0.06, height: 0.06, length: 0.06, chamferRadius: 0)
        police.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: box, options: nil))
        police.physicsBody?.categoryBitMask = 64
        police.physicsBody?.contactTestBitMask = 1
        police.position = SCNVector3(-0.4, 0.04, 0.4)
        police.eulerAngles = SCNVector3(0,0.78,0)
        
        playArea.addChildNode(police)
        
        MoveDiagonal(enemy: police)
        enemiesOnPlayArea = enemiesOnPlayArea + 1
        enemiesWithDiagonalPattern = enemiesWithDiagonalPattern + 1
        
    }
    
    func CreatePoliceWithZigZagPattern(playArea: SCNNode!) {
        police = policeNode.clone()
        police.name = "PoliceWithZigZagPattern"
        
        let box = SCNBox(width: 0.06, height: 0.06, length: 0.06, chamferRadius: 0)
        police.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: box, options: nil))
        police.physicsBody?.categoryBitMask = 64
        police.physicsBody?.contactTestBitMask = 1
        police.position = SCNVector3(-0.4, 0.04, -0.4)
        
        playArea.addChildNode(police)
        
        MoveZigZag(enemy: police)
        enemiesOnPlayArea = enemiesOnPlayArea + 1
        enemiesWithZigZagPattern = enemiesWithZigZagPattern + 1
        
    }
    
    @objc func CreateEnemies(playArea: SCNNode, score: Int) {
        if(score >= 5 && enemiesWithCirclePattern < 1) {
            CreatePoliceWithCirclePattern(playArea: playArea)
        }
        if(score >= 10 && enemiesWithDiagonalPattern < 1) {
            CreatePoliceWithDiagonalPattern(playArea: playArea)
        }
        if(score >= 15 && enemiesWithZigZagPattern < 1) {
            CreatePoliceWithZigZagPattern(playArea: playArea)
        }
    }
    
    func getEnemiesWithCirclePattern() -> Int {
        return enemiesWithCirclePattern
    }
    
    func getEnemiesWithDiagonalPattern() -> Int {
        return enemiesWithDiagonalPattern
    }
    
    func getEnemiesWithZigZagPattern() -> Int {
        return enemiesWithZigZagPattern
    }
    
    func setEnemiesWithCirclePattern(number: Int) {
        enemiesWithCirclePattern += number
    }
    
    func setEnemiesWithDiagonalPattern(number: Int) {
        enemiesWithDiagonalPattern += number
    }
    
    func setEnemiesWithZigZagPattern(number: Int) {
        enemiesWithZigZagPattern += number
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

