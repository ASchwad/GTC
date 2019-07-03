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

final class EnemyController {
    var _enemiesWithCirclePattern: Int = 0
    var _enemiesWithDiagonalPattern: Int = 0
    var _enemiesWithZigZagPattern: Int = 0
    
    var _multiplicatorForCircle = 1.0
    var _multiplicatorForDiagonal = 1.0
    var _multiplicatorForZigZag = 1.0
    
    var firstEnemyWithCirclePattern = true
    var firstEnemyWithDiagonalPattern = true
    var firstEnemyWithZigZagPattern = true
    
    var enemiesWithCirclePattern: Int {
        get {
            return self._enemiesWithCirclePattern
        }
        set(newValue) {
            self._enemiesWithCirclePattern = newValue
        }
    }
    
    var enemiesWithDiagonalPattern: Int {
        get {
            return self._enemiesWithDiagonalPattern
        }
        set(newValue) {
            self._enemiesWithDiagonalPattern = newValue
        }
    }
    
    var enemiesWithZigZagPattern: Int {
        get {
            return self._enemiesWithZigZagPattern
        }
        set(newValue) {
            self._enemiesWithZigZagPattern = newValue
        }
    }
    
    //circle pattern
    @objc func MoveInCircle(enemy: SCNNode, duration: Double) {
        
        func MoveToFirstPoint() {
            let forwardX = 0.5
            if(isCycleCompleted == true)
            {
                let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 90)), around: SCNVector3(0,1,0), duration: 0.3)
                enemy.runAction(rotateAction)
                isCycleCompleted = false
                
            }
            let moveAction = SCNAction.moveBy(x: CGFloat(forwardX), y: 0, z: 0, duration: duration)
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
            let moveAction = SCNAction.moveBy(x: 0, y: 0, z: CGFloat(pointZ), duration: duration)
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
            let moveAction = SCNAction.moveBy(x: CGFloat(backX), y: 0, z: 0, duration: duration)
            enemy.runAction(moveAction, completionHandler: {
                if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                    MoveToFourthPoint()
                }
            })
        }
        
        func MoveToFourthPoint() {
            let backZ = 0.5
            let moveAction = SCNAction.moveBy(x: 0, y: 0, z: CGFloat(backZ), duration: duration)
            let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 90)), around: SCNVector3(0,1,0), duration: 0.3)
            enemy.runAction(rotateAction)
            enemy.runAction(moveAction, completionHandler: {
                if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                    isCycleCompleted = true
                    MoveToFirstPoint()
                    
                }
            })
        }
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (nil) in
            MoveToFirstPoint()
        }
        
        
    }
    
    //diagonal-pattern
    func MoveDiagonal(enemy: SCNNode, duration: Double) {
        
        func MoveToFirstCorner() {
            let forwardZ = -0.7
            let forwardX = 0.7
            if(firstLineCompleted == true) {
                let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 180)), around: SCNVector3(0,1,0), duration: 0.3)
                enemy.runAction(rotateAction)
                firstLineCompleted = false
            }
            let moveAction = SCNAction.moveBy(x: CGFloat(forwardX), y: 0, z: CGFloat(forwardZ), duration: duration)
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
            let moveAction = SCNAction.moveBy(x: CGFloat(forwardX), y: 0, z: CGFloat(forwardZ), duration: duration)
            enemy.runAction(moveAction, completionHandler: {
                if shouldContinueToMove { // Configure your `Bool` to check whether to continue to move your node or not.
                    firstLineCompleted = true
                    MoveToFirstCorner()
                    
                }
            }) }
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (nil) in
            MoveToFirstCorner()
        }
        
    }
    
    //zigZag-pattern
    func MoveZigZag(enemy: SCNNode, duration: Double) {
        timerForZag = 0
        timerForZig = 0
        isZigCompleted = false
        isZagCompleted = false
        
        func MoveZig() {
            let forwardX = 0.2
            if(isZigCompleted){
                let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: 90)), around: SCNVector3(0,1,0), duration: 0.3)
                enemy.runAction(rotateAction)
                isZigCompleted = false
            }
            let moveAction = SCNAction.moveBy(x: CGFloat(forwardX), y: 0, z: 0, duration: duration)
            enemy.runAction(moveAction, completionHandler: {
                MoveDown()
            })
            
            func MoveDown() {
                let pointZ = 0.2
                let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: -90)), around: SCNVector3(0,1,0), duration: 0.3)
                enemy.runAction(rotateAction)
                let moveAction = SCNAction.moveBy(x: 0, y: 0, z: CGFloat(pointZ), duration: duration)
                enemy.runAction(moveAction, completionHandler: {
                        isZigCompleted = true
                        if(timerForZig <= 2) {
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
            let moveAction = SCNAction.moveBy(x: CGFloat(backX), y: 0, z: 0, duration: duration)
            enemy.runAction(moveAction, completionHandler: {
                MoveUp()
            })
            
            func MoveUp() {
                let pointZ = -0.27
                let rotateAction = SCNAction.rotate(by: CGFloat(DegreeToRad(degree: -90)), around: SCNVector3(0,1,0), duration: 0.3)
                enemy.runAction(rotateAction)
                
                let moveAction = SCNAction.moveBy(x: 0, y: 0, z: CGFloat(pointZ), duration: duration)
                enemy.runAction(moveAction, completionHandler: {
                        isZagCompleted = true
                        if(timerForZag <= 1) {
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
                )
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (nil) in
            MoveZig()
        }
        
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
        
        MoveInCircle(enemy: police, duration: 2 * self._multiplicatorForCircle)
        
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
        
        MoveDiagonal(enemy: police, duration: 9 * self._multiplicatorForDiagonal)
        
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
        
        MoveZigZag(enemy: police, duration: 2 * self._multiplicatorForZigZag)
        
        
    }
    
    @objc func CreateEnemies(playArea: SCNNode, score: Int) {
       if(score >= 5 && self.enemiesWithCirclePattern < 1 && firstEnemyWithCirclePattern) {
            CreatePoliceWithCirclePattern(playArea: playArea)
            if(self._multiplicatorForCircle >= 0.1) {
                self._multiplicatorForCircle = self._multiplicatorForCircle - 0.1
            }
            self.enemiesWithCirclePattern = self.enemiesWithCirclePattern + 1
            firstEnemyWithCirclePattern = false
        }
        else if(score >= 10 && self.enemiesWithDiagonalPattern < 1) {
            CreatePoliceWithDiagonalPattern(playArea: playArea)
            if(self._multiplicatorForDiagonal >= 0.1) {
                self._multiplicatorForDiagonal = self._multiplicatorForDiagonal - 0.1
            }
            self.enemiesWithDiagonalPattern = self.enemiesWithDiagonalPattern + 1
        } 
        else if(score >= 25 && self.enemiesWithZigZagPattern < 1) {
            CreatePoliceWithZigZagPattern(playArea: playArea)
            if(self._multiplicatorForZigZag >= 0.1) {
                self._multiplicatorForZigZag = self._multiplicatorForZigZag - 0.1
            }
            self.enemiesWithZigZagPattern = self.enemiesWithZigZagPattern + 1
        }
        else if(score >= 5 && self.enemiesWithCirclePattern < 1 && !firstEnemyWithCirclePattern) {
            Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { (nil) in
                self.CreatePoliceWithCirclePattern(playArea: playArea)
            }
            if(self._multiplicatorForCircle >= 0.1) {
                self._multiplicatorForCircle = self._multiplicatorForCircle - 0.1
            }
            self.enemiesWithCirclePattern = self.enemiesWithCirclePattern + 1
        }
        
        else if(score >= 10 && self.enemiesWithDiagonalPattern < 1 && !firstEnemyWithDiagonalPattern) {
            Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { (nil) in
                self.CreatePoliceWithDiagonalPattern(playArea: playArea)
            }
            if(self._multiplicatorForDiagonal >= 0.1) {
                self._multiplicatorForDiagonal = self._multiplicatorForDiagonal - 0.1
            }
            self.enemiesWithDiagonalPattern = self.enemiesWithDiagonalPattern + 1
        }
        
        else if(score >= 25 && self.enemiesWithZigZagPattern < 1 && !firstEnemyWithZigZagPattern) {
            Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { (nil) in
                self.CreatePoliceWithZigZagPattern(playArea: playArea)
            }
            if(self._multiplicatorForZigZag >= 0.1) {
                self._multiplicatorForZigZag = self._multiplicatorForZigZag - 0.1
            }
            self.enemiesWithZigZagPattern = self.enemiesWithZigZagPattern + 1
        }

       
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

