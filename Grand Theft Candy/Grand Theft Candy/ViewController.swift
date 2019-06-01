//
//  ViewController.swift
//  Grand Theft Candy
//
//  Created by admin on 22.05.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import SpriteKit

class ViewController: UIViewController {
   
    @IBOutlet weak var sceneView: ARSCNView!
    
      lazy var skView: SKView = {
        let view = SKView()
        view.isMultipleTouchEnabled = true
        view.backgroundColor = .clear
        view.isHidden = true
        return view
      }()
    
    
    var playAreaNode: SCNNode!
    var playArea: SCNNode!
    var playerNode: SCNNode!
    var player: SCNNode!
    var skScene: SKScene!
    var isGameWorldCreated : Bool!
    
    let arController = ARController()
    let joystickController = JoystickController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arController.initializeARController(to: sceneView)
        arController.displayDegubInfo()
        
        InitializeModels()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScene(_:)))
        view.addGestureRecognizer(tapGesture)
        sceneView.fillSuperview()
       
    }
    
    @objc func didTapScene(_ gesture: UITapGestureRecognizer)
    {
            let location = gesture.location(ofTouch: 0,
                                            in: sceneView)
            let hit = sceneView.hitTest(location,
                                        types: .existingPlaneUsingGeometry)
            
            if let hit = hit.first
            {
                CreateGame(hit: hit)
            }
    }
    
    func InitializeModels()
    {
        let floorScene = SCNScene(named: "playarea.scn")!
        playAreaNode = floorScene.rootNode.childNode(withName: "floor", recursively: false)!
        
        let heroScene = SCNScene(named: "gangster.scn")!
        playerNode = heroScene.rootNode.childNode(withName: "The_limited_1", recursively: false)!
        
    }
    
    func CreateGame(hit: ARHitTestResult)
    {
        CreatePlayArea(to: sceneView.scene.rootNode, hit: hit)
        CreatePlayer()
        joystickController.CreateJoysick(view: sceneView)
     
    }
    
    func CreatePlayArea(to rootNode: SCNNode, hit: ARHitTestResult)
    {
        playArea = playAreaNode.clone()
        playArea.name = "Floor"
        placeNodeOnHit(node: playArea, atHit: hit)
        playArea.position.x = playArea.position.x + 0.3
        playArea.geometry?.firstMaterial?.diffuse.contents  = UIColor.green
        rootNode.addChildNode(playArea)
    }
    
    func CreatePlayer() {
        player = playerNode.clone()
        player.name = "Gangster"
        player.position = SCNVector3(0.0, 0.09, 0.0)
        player.eulerAngles = SCNVector3(0, DegreeToRad(degree: 180),0)
        player.scale = SCNVector3(0.00004, 0.00004, 0.00004)
        playArea.addChildNode(player)
        playArea.eulerAngles = SCNVector3(DegreeToRad(degree: 360), 0 , 0)
        playArea.eulerAngles = SCNVector3(0, DegreeToRad(degree: 360) , 0)
        
        isGameWorldCreated = true
    }
}


