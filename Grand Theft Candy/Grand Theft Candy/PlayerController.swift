//
//  PlayerController.swift
//  Grand Theft Candy
//
//  Created by Niklas on 24.05.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//

import SceneKit
import SpriteKit

final class PlayerController {
    
    let defaultSpeed: float3 = float3 (0.005)
    let fastSpeed: float3 = float3 (0.008)
    let slowSpeed = float3 (0.002)

    init()
    {

    }
    func RotatePlayer(rotationAngle: Float, player: SCNNode)
    {
        let action = SCNAction.rotateTo(
            x: 0.0,
            y: CGFloat(rotationAngle),
            z: 0.0,
            duration: 0.1, usesShortestUnitArc: true
        )
        player.runAction(action)
    }
    
    public func MovePlayer(moveDirection: float2, player: SCNNode, speed: float3)
    {
        let normalizedDirection = normalize(moveDirection)
        let lookAngle = atan2(normalizedDirection.x, -normalizedDirection.y)
        
        RotatePlayer(rotationAngle: lookAngle, player: player)
        
        let finalDirection = float3(x: normalizedDirection.x, y: 0, z: -normalizedDirection.y)
        
        let currentPosition = float3(player.position)
        player.position = SCNVector3(currentPosition + finalDirection * speed)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
