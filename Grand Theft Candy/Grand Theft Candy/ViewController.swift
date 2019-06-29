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
    
    @IBOutlet weak var placeBombButton: UIButton!
    var playAreaNode: SCNNode!
    var playArea: SCNNode!
    var playerNode: SCNNode!
    var player: SCNNode!
    var skScene: SKScene!
    var isTouched: Bool!
    var isValidTouch = false
    var currentTouchLocation: CGPoint!
    var tapGesture: UIGestureRecognizer!
    
    var hotBombNode: SCNNode!
    var hotBomb: SCNNode!
    var bombCount = 0

    
    var score = 0
    
    var isSlow = false
    var isFast = false
    
    // So the reset speed timer knows if it should actually reset the speed (sometimes it shouldnt reset because another speed item was activated meanwhile)
    var speedItemsCounter = 0
    var speedItemsReseted = 0

    var speed: float3!
    
    let arController = ARController()
    let joystickController = JoystickController()
    let playerController = PlayerController()
    let enemyController = EnemyController()
    let bombController = BombController()
    let itemController = ItemController()
    
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
        
        enemyController.InitializeEnemy()
    
        itemController.InitializeItems()
        InitializeModels()
        placeBombButton.isHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        view.addGestureRecognizer(tapGesture)
        sceneView.maximizeView()
        
        sceneView.debugOptions = ARSCNDebugOptions.showPhysicsShapes
        scoreLabel.isHidden = true
        speed = playerController.defaultSpeed
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.isMultipleTouchEnabled = true
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print (contact.nodeA.name! + "   " + contact.nodeB.name!)
        if (contact.nodeA.name == "Gangster" || contact.nodeB.name == "Gangster" )
        {
            var contactNode:SCNNode!
            
            //Check which of the returned Nodes A and B is the Gangster
            if contact.nodeA.name == "Gangster"{
                contactNode = contact.nodeB
            }else{
                contactNode = contact.nodeA
            }
            
            //Check Itemtype with predefined categoryBitMask
            if contactNode.physicsBody?.categoryBitMask == 2{
                score += 2
                contactNode.removeFromParentNode()
                
                //access label text from other thread
                // oder mit scene kit text overlay?
                scoreLabel.text = "Score: \(score)"
                itemController.CreateIncItem(playArea: playArea)
                
            } else if contactNode.physicsBody?.categoryBitMask == 4 {
                contactNode.removeFromParentNode()
                score -= 10
                scoreLabel.text = "Score: \(score)"
            }
            else if contactNode.physicsBody?.categoryBitMask == 8 {
                speedItemsCounter += 1
                contactNode.removeFromParentNode()
                SpeedFast()
                let timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ResetSpeed), userInfo: nil, repeats: false)
            }
            else if contactNode.physicsBody?.categoryBitMask == 16 {
                speedItemsCounter += 1
                contactNode.removeFromParentNode()
                SpeedSlow()
                let timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ResetSpeed), userInfo: nil, repeats: false)
            }
            else if contactNode.physicsBody?.categoryBitMask == 32 {
                if(state != .gameOver){
                    self.performSegue(withIdentifier: "GameOver", sender: Any?.self)
                    enemyController.enemiesWithZigZagPattern = 0
                    enemyController.enemiesWithDiagonalPattern = 0
                    enemyController.enemiesWithCirclePattern = 0
                    state = .gameOver
                    
                }
            }
            else if contactNode.physicsBody?.categoryBitMask == 64 {
                if(state != .gameOver){
                    self.performSegue(withIdentifier: "GameOver", sender: Any?.self)
                    enemyController.enemiesWithZigZagPattern = 0
                    enemyController.enemiesWithDiagonalPattern = 0
                    enemyController.enemiesWithCirclePattern = 0
                    state = .gameOver
                }
            }
            else if contactNode.physicsBody?.categoryBitMask == 128 {
                PickUpBomb()
                contactNode.removeFromParentNode()
            }
        }
        
         if ((contact.nodeA.name == "PoliceWithCirclePattern" || contact.nodeA.name == "PoliceWithDiagonalPattern" || contact.nodeA.name == "PoliceWithZigZagPattern") && contact.nodeB.name == "HotBomb" || contact.nodeA.name == "HotBomb" && (contact.nodeA.name == "PoliceWithCirclePattern" || contact.nodeA.name == "PoliceWithDiagonalPattern" || contact.nodeA.name == "PoliceWithZigZagPattern"))
        {
            var contactNode:SCNNode!
            var policeNode:SCNNode!
            //Check which of the returned Nodes A and B is the Gangster
            if contact.nodeA.name == "PoliceWithCirclePattern"{
                contactNode = contact.nodeB
                policeNode = contact.nodeA
                enemyController.enemiesWithCirclePattern = enemyController.enemiesWithCirclePattern-1
            }
            else if(contact.nodeA.name == "PoliceWithDiagonalPattern") {
                contactNode = contact.nodeB
                policeNode = contact.nodeA
                enemyController.enemiesWithDiagonalPattern = enemyController.enemiesWithDiagonalPattern-1
            }
            else if(contact.nodeA.name == "PoliceWithZigZagPattern") {
                contactNode = contact.nodeB
                policeNode = contact.nodeA
                enemyController.enemiesWithZigZagPattern = enemyController.enemiesWithZigZagPattern-1
            }
            else{
                contactNode = contact.nodeA
                policeNode = contact.nodeB
            }
            score += 5
            scoreLabel.text = "Score: \(score)"
            
            bombController.PerformExplosion(contactNode: contactNode, playArea: playArea)
            enemyController.DestroyPolice(police: policeNode)
            
            contactNode.removeFromParentNode()
            
        }
        
    }
    
    func InitializeModels(){
        let floorScene = SCNScene(named: "playarea.scn")!
        playAreaNode = floorScene.rootNode.childNode(withName: "floor", recursively: false)!
        
        let heroScene = SCNScene(named: "gangster.scn")!
        playerNode = heroScene.rootNode.childNode(withName: "The_limited_1", recursively: false)!
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is GameOverController
        {
            let vc = segue.destination as? GameOverController
            vc?.score = score
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
    
    func InitializePlaceBombButton()
    {
        let color = UIColor.black
        placeBombButton.isHidden = false
        placeBombButton.backgroundColor = color
        placeBombButton.alpha = 0.5
    
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
        //Spawn continously increment items
        itemController.CreateIncItem(playArea: playArea)
        //Timer to spawn Items
        let timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(CreateItemSpawner), userInfo: nil, repeats: true)
        let timerForEnemy = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(CreateEnemySpawner), userInfo: nil, repeats: true)
        
        InitializePlaceBombButton()
        
        scoreLabel.isHidden = false

        view.removeGestureRecognizer(tapGesture)
        skScene = joystickController.CreateJoysick(view: sceneView)
    }
    
    @objc func CreateItemSpawner(){
        itemController.RandomItem(playArea: playArea)
    }
    
    @objc func CreateEnemySpawner(){
        enemyController.CreateEnemies(playArea: playArea, score: score)
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
    
    public func updateJoystick() {
        
        if(isTouched == true)
        {
            var touchXPoint = currentTouchLocation.x
            var touchYPoint = sceneView.bounds.size.height - currentTouchLocation.y
            
            let middleOfCircleX = joystickController.initPositionX
            let middleOfCircleY = joystickController.initPositionY
            let lengthOfX = Float(touchXPoint - middleOfCircleX)
            let lengthOfY = Float(touchYPoint - middleOfCircleY)
            let direction = float2(x: lengthOfX, y: lengthOfY)
            
            let touchPoint = CGPoint(x: touchXPoint, y: touchYPoint)
            
            playerController.MovePlayer(moveDirection: direction, player: player, speed: speed)
                
            touchXPoint = ClampNumber(value: touchXPoint, lowerBound: joystickController.minXValue, upperBound: joystickController.maxXValue)
                
            touchYPoint = ClampNumber(value: touchYPoint, lowerBound: joystickController.minYValue, upperBound: joystickController.maxYValue)
                
            joystickController.SetJoystickPosition(xPosition: touchXPoint, yPosition: touchYPoint)
        }
    }
    
    // bomb logic
    
    func PickUpBomb ()
    {
        if (bombCount <= 5){
            bombCount+=1
            BombUIUpdate()
        }
    }
    
    func PlaceBomb()
    {
        HotBomb(placePosition: player.position, playArea: playArea)
        bombCount-=1
        BombUIUpdate()
    }
    
    @IBAction func OnPlaceBombPressed(_ sender: Any) {
        if(bombCount > 0){
            PlaceBomb()
        }
    }

    func BombUIUpdate()
    {
        if(bombCount <= 0 && placeBombButton.alpha >= 0.5){
            placeBombButton.alpha = 0.5
            placeBombButton.setTitle(String(0), for: .normal)
        }
        else{
            placeBombButton.alpha = 1.0
            placeBombButton.setTitle(String(bombCount), for: .normal)
        }
        
    }
}
extension ViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        if(isValidTouch)
        {
             updateJoystick()
        }
       
    }
    // store touch in global scope
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let touch = touches.first!
            currentTouchLocation = touch.location(in: self.sceneView)
        
        var touchXPoint = currentTouchLocation.x
        var touchYPoint = sceneView.bounds.size.height - currentTouchLocation.y
        
        let touchPoint = CGPoint(x: touchXPoint, y: touchYPoint)
       
        if joystickController.substrate.contains(touchPoint)
        {
            isValidTouch = true
        }
        
        else
        {
            isValidTouch = false
        }
            isTouched = true
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        currentTouchLocation = touch.location(in: self.sceneView)
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
            joystickController.SnapBackJoystick()
            isTouched = false
            isValidTouch = false
    }
    
    
}

