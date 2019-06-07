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

class ViewController: UIViewController ,ARSCNViewDelegate, SCNPhysicsContactDelegate{
    
    enum ViewState {
        case readyToStartGame
        case playing
    }
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var playAreaNode: SCNNode!
    var playArea: SCNNode!
    var playerNode: SCNNode!
    var player: SCNNode!
    var skScene: SKScene!
    var isTouched: Bool!
    var currentTouchLocation: CGPoint!
    var tapGesture: UIGestureRecognizer!
    
    var incItemNode: SCNNode!
    var incItem: SCNNode!
    var decItemNode: SCNNode!
    var decItem: SCNNode!
    var score = 0
    
    let arController = ARController()
    let joystickController = JoystickController()
    let playerController = PlayerController()
    
    var allowToStartGame = true
    
    var planes: [ARAnchor: HorizontalPlane] = [:]
    var selectedPlane: HorizontalPlane?
    
    //setup for initial state
    var state: ViewState = .readyToStartGame {
        didSet {
            updateStates()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arController.initializeARController(to: sceneView)
        arController.displayDegubInfo()
        
        InitializeModels()
        
        UIApplication.shared.isIdleTimerDisabled = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        view.addGestureRecognizer(tapGesture)
        sceneView.maximizeView()
        
        sceneView.debugOptions = ARSCNDebugOptions.showPhysicsShapes
        
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var contactNode:SCNNode!
        //Check which of the returned Nodes A and B is the Gangster
        if contact.nodeA.name == "Gangster"{
            contactNode = contact.nodeB
        }else{
            contactNode = contact.nodeA
        }
        //Check Itemtype with predefined categoryBitMask
        if contactNode.physicsBody?.categoryBitMask == 2{
            score += 1
            contactNode.isHidden = true
            
            //access label text from other thread
            // oder mit scene kit text overlay?
            scoreLabel.text = "Score: \(score)"
            CreateIncItem()
            
        } else if contactNode.physicsBody?.categoryBitMask == 4 {
            contactNode.isHidden = true
            score -= 1
            scoreLabel.text = "Score: \(score)"
            CreateDecItem()
        }
    }
    
    @objc func onTap(_ gesture: UITapGestureRecognizer){
        let location = gesture.location(ofTouch: 0,
                                        in: sceneView)
        let hit = sceneView.hitTest(location,
                                    types: .existingPlaneUsingGeometry)
        
        if let hit = hit.first{
            if state == .readyToStartGame {
                CreateGame(hit: hit)
            }
            
        }
        
    }
    
    //wird wahrscheinlich später interessant, wenn man in den bestimmten states was machen will
    func updateStates() {
        DispatchQueue.main.async {
            switch self.state {
                
            case .readyToStartGame:
                print("readyToStarGame");
            case .playing:
                print("playing");
            }
        }
    }
    
    
    func InitializeModels()
    {
        let floorScene = SCNScene(named: "playarea.scn")!
        playAreaNode = floorScene.rootNode.childNode(withName: "floor", recursively: false)!
        
        let heroScene = SCNScene(named: "gangster.scn")!
        playerNode = heroScene.rootNode.childNode(withName: "The_limited_1", recursively: false)!
        let incItemScene = SCNScene(named: "incrementItem.scn")!
        incItemNode = incItemScene.rootNode.childNode(withName: "bonbon", recursively: false)!
        let decItemScene = SCNScene(named: "decrementItem.scn")!
        decItemNode = decItemScene.rootNode.childNode(withName: "bonbon", recursively: false)!
    }
    
    func CreateGame(hit: ARHitTestResult)
    {
        //changed state to playing (CreateGame should only be called once)
        state = .playing
        
        //remove all planes and stop plane detection and debug mode
        arController.removePlaneNodes()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        //evtl. auslagern?
        sceneView.debugOptions = []
        sceneView.session.run(configuration)
        sceneView!.delegate = self
        CreatePlayArea(to: sceneView.scene.rootNode, hit: hit)
        CreatePlayer()
        CreateIncItem()
        CreateDecItem()
        view.removeGestureRecognizer(tapGesture)
        skScene = joystickController.CreateJoysick(view: sceneView)
        
        //diese Reihenfolge lässt wenigstens nicht mehrere Playareas spawnen
    }
    
    func CreatePlayArea(to rootNode: SCNNode, hit: ARHitTestResult)
    {
        playArea = playAreaNode.clone()
        playArea.name = "Floor"
        placeNodeOnHit(node: playArea, atHit: hit)
        playArea.position.x = playArea.position.x + 0.3
        playArea.geometry?.firstMaterial?.diffuse.contents  = UIColor.green
        playArea.scale = SCNVector3(0.5,0.5,0.5)
        rootNode.addChildNode(playArea)
    }
    
    func CreatePlayer() {
        player = playerNode.clone()
        player.name = "Gangster"
        player.position = SCNVector3(0.0, 0.09, 0.0)
        player.eulerAngles = SCNVector3(0, DegreeToRad(degree: 180),0)
        player.scale = SCNVector3(0.00004, 0.00004, 0.00004)
        
        //doesnt work
        //player.geometry = playerNode.geometry?.copy() as? SCNGeometry
        
        player.geometry = SCNBox(width: 0.00004, height: 0.00004, length: 0.00004, chamferRadius: 0)
        
        player.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: player.geometry!, options: nil))
        
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.contactTestBitMask = 2
        
        playArea.addChildNode(player)
    }
    
    func CreateIncItem() {
        incItem = incItemNode.clone()
        incItem.name = "IncItem"
        
        let x = GenerateRandomCoordinateInPlane()
        let z = GenerateRandomCoordinateInPlane()
        incItem.position = SCNVector3(x, 0.09, z)
        
        
        playArea.addChildNode(incItem)
    }
    
    func CreateDecItem() {
        decItem = decItemNode.clone()
        decItem.name = "DecItem"
        
        let x = GenerateRandomCoordinateInPlane()
        let z = GenerateRandomCoordinateInPlane()
        decItem.position = SCNVector3(x, 0.04, z)
        
        playArea.addChildNode(decItem)
    }
    
    public func updateJoystick() {
        
        if(isTouched == true)
        {
            let touchXPoint = currentTouchLocation.x
            let touchYPoint = sceneView.bounds.size.height - currentTouchLocation.y
            
            let middleOfCircleX = joystickController.initPositionX
            let middleOfCircleY = joystickController.initPositionY
            let lengthOfX = Float(touchXPoint - middleOfCircleX)
            let lengthOfY = Float(touchYPoint - middleOfCircleY)
            let direction = float2(x: lengthOfX, y: lengthOfY)
            
            let touchPoint = CGPoint(x: touchXPoint, y: touchYPoint)
            
            if joystickController.substrate.contains(touchPoint)
            {
                playerController.MovePlayer(moveDirection: direction, player: player)
                
                joystickController.innerStick.position.x = touchXPoint
                joystickController.innerStick.position.y = touchYPoint
            }
            else
            {
                joystickController.innerStick.position.x = joystickController.initPositionX
                joystickController.innerStick.position.y = joystickController.initPositionY
            }
        }
        
    }
}
extension ViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        updateJoystick()
    }
    // store touch in global scope
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        currentTouchLocation = touch.location(in: self.sceneView)
        isTouched = true
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        currentTouchLocation = touch.location(in: self.sceneView)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        joystickController.innerStick.position.x = joystickController.initPositionX
        joystickController.innerStick.position.y = joystickController.initPositionY
        isTouched = false
    }
    
    
}

