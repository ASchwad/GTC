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

class ViewController: UIViewController ,ARSCNViewDelegate{
    
    enum ViewState {
        case readyToStartGame
        case playing
    }
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var hintView: UIView!
    @IBOutlet weak var hintLabel: UILabel!
   
    
    
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
    var isTouched: Bool!
    var currentTouchLocation: CGPoint!
    
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
        
    }
    
    func CreateGame(hit: ARHitTestResult)
    {
        //changed state to playing (CreateGame should only be called once)
        state = .playing
        
        //remove all planes and stop plane detection and debug mode
        arController.removePlaneNodes()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        sceneView.debugOptions = []
        sceneView.session.run(configuration)
        
        CreatePlayArea(to: sceneView.scene.rootNode, hit: hit)
        CreatePlayer()
        skScene = joystickController.CreateJoysick(view: sceneView)
        self.sceneView!.delegate = self
        
        //diese Reihenfolge lässt wenigstens nicht mehrere Playareas spawnen
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

