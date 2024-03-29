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
    

    @IBOutlet weak var bombStackOne: UIButton!
    
    
    @IBOutlet weak var bombStackTwo: UIButton!
    
    
    @IBOutlet weak var bombStackThree: UIButton!
    
    
    @IBOutlet weak var policeStarLabel: UILabel!
    
    
    var bombStackRow = [UIButton]()
    @IBOutlet weak var placeBombButton: UIButton!
    var playAreaNode: SCNNode!
    var playArea: SCNNode!
    var decorationNode: SCNNode!
    var decoration: SCNNode!
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

    var animations = [String: CAAnimation]()
    var idle:Bool = true
    
    var score = 0
    
    var isSlow = false
    var isFast = false
    var playerIsInvincible = false
    
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
        InitializeBombStack()
        
        placeBombButton.isHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        view.addGestureRecognizer(tapGesture)
        sceneView.maximizeView()
        
        //sceneView.debugOptions = ARSCNDebugOptions.showPhysicsShapes
        scoreLabel.isHidden = true
        policeStarLabel.isHidden = true
        speed = playerController.defaultSpeed
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.isMultipleTouchEnabled = true
    }
    
    @objc func createPoliceStarLabel() {
        
        let font = UIFont.systemFont(ofSize: 17)
        
        var policeStarString = NSMutableAttributedString(string: "")
        
        let imageAttachment = NSTextAttachment()
        let image = UIImage(named: "policeStar.png")
        
        imageAttachment.bounds = CGRect(x: 0, y: (font.capHeight - image!.size.height).rounded() / 2, width: image!.size.width, height: image!.size.height)
        imageAttachment.image = image
        
        let imageString = NSAttributedString(attachment: imageAttachment)
        
        
        DispatchQueue.main.async {
            if(self.score >= 6 && self.score < 16) {
                policeStarString.append(imageString)
            }
            if(self.score >= 16 && self.score < 26) {
                policeStarString.append(imageString)
                policeStarString.append(imageString)
            }
            if(self.score >= 26) {
                policeStarString.append(imageString)
                policeStarString.append(imageString)
                policeStarString.append(imageString)
            }
            
            if(self.score < 6) {
                policeStarString = NSMutableAttributedString(string: "")
            }
            
            self.policeStarLabel.attributedText = policeStarString
        }
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
                DispatchQueue.main.async {
                    self.scoreLabel.text = "Score: \(self.score)"
                }
                itemController.CreateIncItem(playArea: playArea)
                
                createPoliceStarLabel()
                
            } else if contactNode.physicsBody?.categoryBitMask == 4 {
                contactNode.removeFromParentNode()
                score -= 10
                DispatchQueue.main.async {
                    self.scoreLabel.text = "Score: \(self.score)"
                }
                createPoliceStarLabel()
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
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "GameOver", sender: Any?.self)
                    }
                    enemyController.enemiesWithZigZagPattern = 0
                    enemyController.enemiesWithDiagonalPattern = 0
                    enemyController.enemiesWithCirclePattern = 0
                    state = .gameOver
                    
                }
            }
            else if contactNode.physicsBody?.categoryBitMask == 64 {
                if(state != .gameOver && !playerIsInvincible){
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "GameOver", sender: Any?.self)
                    }
                    enemyController.enemiesWithZigZagPattern = 0
                    enemyController.enemiesWithDiagonalPattern = 0
                    enemyController.enemiesWithCirclePattern = 0
                    state = .gameOver
                }
                if(playerIsInvincible) {
                    // zerstöre polizei
                    bombController.PerformExplosion(contactNode: contactNode, playArea: playArea)
                    enemyController.DestroyPolice(police: contactNode)
                    
                    contactNode.removeFromParentNode()
                        
                        if(contactNode.name == "PoliceWithCirclePattern") {
                            enemyController.enemiesWithCirclePattern = enemyController.enemiesWithCirclePattern - 1
                        }
                        if(contactNode.name == "PoliceWithDiagonalPattern") {
                            enemyController.enemiesWithDiagonalPattern = enemyController.enemiesWithDiagonalPattern - 1
                        }
                        if(contactNode.name == "PoliceWithZigZagPattern") {
                            enemyController.enemiesWithZigZagPattern = enemyController.enemiesWithZigZagPattern - 1
                        }
                    }

            }//Bombe
            else if contactNode.physicsBody?.categoryBitMask == 128 && bombCount <= 2{
                PickUpBomb()
                contactNode.removeFromParentNode()
            }//Stern
            else if contactNode.physicsBody?.categoryBitMask == 256 {
                contactNode.physicsBody = nil // seperat removed, weil sonst die Funktion mehrmals aufgerufen wird
                contactNode.removeFromParentNode()
                
                playerIsInvincible = true
                
                // material heißt Mat.3 (Head und Body benutzen das selbe, deswegen ändert sich auch Farbe der beiden)
                // Spieler wird blau^^
                let oldContents = player.childNode(withName: "rdmobj00-001", recursively: false)?.geometry?.firstMaterial?.diffuse.contents
                player.childNode(withName: "rdmobj00-001", recursively: false)?.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
                
                let delay = 3// seconds of invincibilty
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(delay)) {
                    self.playerIsInvincible = false
                    self.player.childNode(withName: "rdmobj00-001", recursively: false)?.geometry?.firstMaterial?.diffuse.contents = oldContents
                }
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
            DispatchQueue.main.async {
                self.scoreLabel.text = "Score: \(self.score)"
            }
            bombController.PerformExplosion(contactNode: contactNode, playArea: playArea)
            enemyController.DestroyPolice(police: policeNode)
            
            contactNode.removeFromParentNode()
            
        }
        
    }
    
    func InitializeModels(){
        let floorScene = SCNScene(named: "playarea.scn")!
        playAreaNode = floorScene.rootNode.childNode(withName: "floor", recursively: false)!
        
        let decorationScene = SCNScene(named: "playarea.scn")!
        decorationNode = floorScene.rootNode.childNode(withName: "decoration", recursively: false)!
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
    
    fileprivate func InitializeBombStack() {
        bombStackRow.append(bombStackOne)
        bombStackRow.append(bombStackTwo)
        bombStackRow.append(bombStackThree)
        
        for button in bombStackRow{
            button.isHidden = true
            button.layer.cornerRadius = 20
        }
    }
    
    func InitializePlaceBombButton()
    {
        let color = UIColor.clear
        placeBombButton.backgroundColor = color
        placeBombButton.layer.cornerRadius = 50
        placeBombButton.isHidden = false
        
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
        let timerForEnemy = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(CreateEnemySpawner), userInfo: nil, repeats: true)
        
        InitializePlaceBombButton()
        
        scoreLabel.isHidden = false
        policeStarLabel.isHidden = false
        createPoliceStarLabel()

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
        playArea.scale = SCNVector3(0.5,0.5,0.5)
        
        CreateDecoration()
        
        rootNode.addChildNode(playArea)
    }
    
    func CreateDecoration()
    {
        decoration = decorationNode.clone()
        decoration.name = "Decoration"
        
        playArea.addChildNode(decoration)
    }
    
    func CreatePlayer() {
        
        let heroScene = SCNScene(named: "ip_obeseMan_running.dae")!
        let playerNode = SCNNode()
        
        // Add all the child nodes to the parent node
        for child in heroScene.rootNode.childNodes {
            playerNode.addChildNode(child)
        }
        player = playerNode
        player.scale = SCNVector3(0.025,0.025,0.025)
        player.name = "Gangster"
        player.geometry = SCNBox(width: 0.0003, height: 0.0003, length: 0.0003, chamferRadius: 0)
        player.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: player.geometry!, options: nil))
        player.physicsBody?.categoryBitMask = 1
        
        playArea.addChildNode(player)
        
        loadAnimation(withKey: "dancing", sceneName: "twist_danceFixed", animationIdentifier: "twist_danceFixed-1")
        
        loadAnimation(withKey: "idle", sceneName: "idleFixed", animationIdentifier: "idleFixed-1")
        
        playAnimation(key: "dancing")
    }
    
    func loadAnimation(withKey: String, sceneName:String, animationIdentifier:String) {
        let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
        let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        
        if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
            // The animation will only play once
            animationObject.repeatCount = .infinity
            // To create smooth transitions between animations
            animationObject.fadeInDuration = CGFloat(1)
            animationObject.fadeOutDuration = CGFloat(0.7)
            
            // Store the animation for later use
            animations[withKey] = animationObject
        }
    }
    
    func playAnimation(key: String) {
        // Add the animation to start playing it right away
        sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
    }
    
    func stopAnimation(key: String) {
        // Stop the animation with a smooth transition
        sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
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
        if (bombCount <= 2){
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
        }else{
            
        }
    }

    func BombUIUpdate()
    {
        var iterator = 1
        for button in bombStackRow{
            
            if(iterator > bombCount)
            {
                if(button.isHidden == false){
                    button.isHidden = true
                }
            }
            else
            {
                if(button.isHidden == true){
                    button.isHidden = false
                }
            }
            
            iterator+=1
        }

        if(bombCount <= 0 && placeBombButton.alpha >= 0.5){
            placeBombButton.alpha = 0.5
        }
        else{
            placeBombButton.alpha = 1.0
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
        if(animations.count>0){
            stopAnimation(key: "idle")
            stopAnimation(key: "dancing")
            print("Touch recognized")
        }
        
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
        if(animations.count>0){
            playAnimation(key: "idle")
        }
    }
    
}

