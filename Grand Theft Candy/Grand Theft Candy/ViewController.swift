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
        case gameOver
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
    
    var isSlow = false
    var isFast = false
    
    // So the reset speed timer knows if it should actually reset the speed (sometimes it shouldnt reset because another speed item was activated meanwhile)
    var speedItemsCounter = 0
    var speedItemsReseted = 0

    var fastItemNode: SCNNode!
    var fastItem: SCNNode!
    var slowItemNode: SCNNode!
    var slowItem: SCNNode!
    
    var police: SCNNode!
    var policeNode: SCNNode!
    var enemyReady = true

     var speed: float3!
    
    let arController = ARController()
    let joystickController = JoystickController()
    let playerController = PlayerController()
    let enemyController = EnemyController()
    
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
        
        arController.InitializeARController(to: sceneView)
        arController.ShowDebugHints()
        
        InitializeModels()
        
        UIApplication.shared.isIdleTimerDisabled = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        view.addGestureRecognizer(tapGesture)
        sceneView.maximizeView()
        
        sceneView.debugOptions = ARSCNDebugOptions.showPhysicsShapes
        scoreLabel.isHidden = true
        speed = playerController.defaultSpeed
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
            contactNode.removeFromParentNode()
            
            //access label text from other thread
            // oder mit scene kit text overlay?
            scoreLabel.text = "Score: \(score)"
            CreateIncItem()
            
        } else if contactNode.physicsBody?.categoryBitMask == 4 {
            contactNode.removeFromParentNode()
            score -= 1
            scoreLabel.text = "Score: \(score)"
            CreateDecItem()
        }
        else if contactNode.physicsBody?.categoryBitMask == 8 {
            speedItemsCounter += 1
            contactNode.removeFromParentNode()
            SpeedFast()
            let timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ResetSpeed), userInfo: nil, repeats: false)
            CreateFastItem()
        }
        else if contactNode.physicsBody?.categoryBitMask == 16 {
            speedItemsCounter += 1
            contactNode.removeFromParentNode()
            SpeedSlow()
            let timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ResetSpeed), userInfo: nil, repeats: false)
            CreateSlowItem()
        }
        else if contactNode.physicsBody?.categoryBitMask == 32 {
            if(state != .gameOver){
                self.performSegue(withIdentifier: "GameOver", sender: Any?.self)
                state = .gameOver
            }
        }
        else if contactNode.physicsBody?.categoryBitMask == 64 {
            if(state != .gameOver){
                self.performSegue(withIdentifier: "GameOver", sender: Any?.self)
                state = .gameOver
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is GameOverController
        {
            let vc = segue.destination as? GameOverController
            vc?.score = score
        }
    }
    
    func CreateFastItem() {
        fastItem = fastItemNode.clone()
        fastItem.name = "FastItem"
        
        let x = GenerateRandomCoordinateInPlane()
        let z = GenerateRandomCoordinateInPlane()
        fastItem.position = SCNVector3(x, 0.09, z)
        
        
        playArea.addChildNode(fastItem)
    }
    func CreateSlowItem() {
        slowItem = slowItemNode.clone()
        slowItem.name = "SlowItem"
        
        let x = GenerateRandomCoordinateInPlane()
        let z = GenerateRandomCoordinateInPlane()
        slowItem.position = SCNVector3(x, 0.09, z)
        
        
        playArea.addChildNode(slowItem)
    }
    
    func CreatePolice() {
        police = policeNode.clone()
        police.name = "Police"
        
        police.position = SCNVector3(-0.3, 0.09, 0.4)
        let box = SCNBox(width: 0.06, height: 0.06, length: 0.06, chamferRadius: 0)
        police.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: box, options: nil))
        police.physicsBody?.categoryBitMask = 64
        police.physicsBody?.contactTestBitMask = 1
        police.position = SCNVector3(-0.3, 0.09, 0.4)
        
        playArea.addChildNode(police)
        
        if(enemyReady == true){
            enemyController.MoveToFirstPoint(enemy: police)
            enemyReady = false
        }

    }

    
    @objc func ResetSpeed(){
        speedItemsReseted += 1
        
        // so only the last called reset timer of a speed item actually resets the speed
        if(speedItemsReseted == speedItemsCounter){
            speed = playerController.defaultSpeed
            isSlow = false
        }
    }
    
    func SpeedFast(){
        speed = playerController.fastSpeed
        isFast = true
    }
    
    func SpeedSlow(){
        
        isSlow = true
        speed = playerController.slowSpeed
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
                print("readyToStarGame")
            case .playing:
                print("playing")
            case .gameOver:
                print("gameOver")
            }
        }
    }
    
    
    func InitializeModels()
    {
        let floorScene = SCNScene(named: "playarea.scn")!
        playAreaNode = floorScene.rootNode.childNode(withName: "floor", recursively: false)!
        
        let heroScene = SCNScene(named: "gangster.scn")!
        playerNode = heroScene.rootNode.childNode(withName: "The_limited_1", recursively: false)!
        let incItemScene = SCNScene(named: "candyCane.scn")!
        incItemNode = incItemScene.rootNode.childNode(withName: "candyCane", recursively: false)!
        let decItemScene = SCNScene(named: "decrementItem.scn")!
        decItemNode = decItemScene.rootNode.childNode(withName: "bonbon", recursively: false)!
        
        let fastItemScene = SCNScene(named: "fastItem.scn")!
        fastItemNode = fastItemScene.rootNode.childNode(withName: "bonbon", recursively: false)!
        let slowItemScene = SCNScene(named: "slowItem.scn")!
        slowItemNode = slowItemScene.rootNode.childNode(withName: "bonbon", recursively: false)!
        
        let policeScene = SCNScene(named: "police.scn")!
        policeNode = policeScene.rootNode.childNode(withName: "police", recursively: false)!

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
        //sceneView.debugOptions = []
        sceneView.session.run(configuration)
        sceneView!.delegate = self
        CreatePlayArea(to: sceneView.scene.rootNode, hit: hit)
        CreatePlayer()
        CreateIncItem()
        CreateDecItem()
        CreateFastItem()
        CreateSlowItem()
        CreatePolice()
        
        scoreLabel.isHidden = false

        view.removeGestureRecognizer(tapGesture)
        skScene = joystickController.CreateJoysick(view: sceneView)
        
        //diese Reihenfolge lässt wenigstens nicht mehrere Playareas spawnen
    }
    
    func CreatePlayArea(to rootNode: SCNNode, hit: ARHitTestResult)
    {
        playArea = playAreaNode.clone()
        playArea.name = "Floor"
        placeNodeOnHit(node: playArea, atHit: hit, sceneView: sceneView)
        
        let box = SCNNode()
        box.geometry = SCNBox(width: 0.01, height: 0.1, length: 1, chamferRadius: 0)
        //iterate through childnodes and give each border of playarea a box as physicsbody and properties for the collision detection
        playArea.enumerateChildNodes { (node, stop) in
            node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: box.geometry!, options: nil))
            node.physicsBody?.categoryBitMask = 32
            node.physicsBody?.contactTestBitMask = 1
        }
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
        
        player.geometry = SCNBox(width: 0.00004, height: 0.00004, length: 0.00004, chamferRadius: 0)
        player.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: player.geometry!, options: nil))
        player.physicsBody?.categoryBitMask = 1
        
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
        decItem.position = SCNVector3(x, 0.09, z)
        
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
                playerController.MovePlayer(moveDirection: direction, player: player, speed: speed)
                
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

