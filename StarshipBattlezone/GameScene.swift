//
//  GameScene.swift
//  StarshipBattlezone
//
//  Created by Mason Black on 2015-03-10.
//  Copyright (c) 2015 Mason Black. All rights reserved.
//

import SpriteKit

protocol gameSceneDelegate {
    func starship1Move()
    func starship2Move()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var viewController: GameViewController? // This pointer is needed to create segue back to PPVC after gameOver
    
    // Set up labels to display scores
    let myLabel = SKLabelNode(fontNamed:"Chalkduster")
    let starship1Score = SKLabelNode(fontNamed: "Chalkduster")
    let starship2Score = SKLabelNode(fontNamed: "Chalkduster")
    
    // An array of SKTextures for animating the explosions
    var explosionAnimation = [SKTexture]()
    
    // These delegates are needed in order to be able to call each student's 
    //      StarshipMove() functions within different classes
    var player1Delegate:gameSceneDelegate?
    var player2Delegate:gameSceneDelegate?
    
    var updatesCalled = 0 // variable needed to prevent multiple collisions from happening
    var gameOver = false
    var gameStarted = false
    
    override func didMove(to view: SKView) {
        self.scene?.isPaused = true   // Pause the game when we first get to the GameScene
        
        // Creating a connection with the labels that are displayed in the GameScene.sks file
        //      These are used to display each player's name
        let p1Node = childNode(withName: "lblPlayer1Name") as! SKLabelNode
        let p2Node = childNode(withName: "lblPlayer2Name") as! SKLabelNode
        p1Node.text = Game.🚀1.name + ":"
        p2Node.text = Game.🚀2.name + ":"
        
        // This function sets the correct StarshipMove() functions depending on which
        //      students are playing the game.
        setPlayerClasses()
        
        // Create the background of the GameScene.
        self.view?.backgroundColor = UIColor(patternImage: UIImage(named: "SpaceBackground.png")!)
        let bgLayer = SKNode();
        self.addChild(bgLayer)
        
        // The following code allows the background to move behind the Starships
        let bgTexture = SKTexture(imageNamed: "SpaceBackground")
        let doubleBg = CGFloat(-bgTexture.size().width*2)
        let bgDuration = TimeInterval(0.1 * bgTexture.size().width)
        let bgMove = SKAction.moveBy(x: doubleBg, y: 0, duration: bgDuration)
        let bgReset = SKAction.moveBy(x: -doubleBg, y: 0, duration: 0)
        let moveBgForever = SKAction.repeatForever(SKAction.sequence([bgMove, bgReset]))
        
        for i in 0..<Int(2 + self.frame.size.width / (bgTexture.size().width * 2)) {
            let sp = SKSpriteNode(texture: bgTexture)
            sp.setScale(1.0)
            sp.zPosition = -20
            sp.anchorPoint = CGPoint.zero
            sp.position = CGPoint(x: CGFloat(i) * CGFloat(sp.size.width), y: 0)
            sp.run(moveBgForever)
            bgLayer.addChild(sp)
        }

        // A property of a ViewController that allows user interaction
        //      This is needed to start the game.
        self.isUserInteractionEnabled = true
        
        // Display a label before the game begins
        myLabel.text = "Ready...Set...Battle!!!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY);
        self.addChild(myLabel)
        
        // Update the Starship1's score
        starship1Score.text = String(Game.🚀1.life)
        starship1Score.fontSize = 24
        //starship1Score.position = CGPoint(x: p1Node.frame.width/2 + p1Node.position.x + 5, y:CGRectGetMaxY(self.frame) - 40);
        starship1Score.position = CGPoint(x: self.frame.maxX - 35, y:self.frame.maxY - 40);
        self.addChild(starship1Score)
        
        // Update the Starship2's score
        starship2Score.text = String(Game.🚀2.life)
        starship2Score.fontSize = 24
        starship2Score.position = CGPoint(x: self.frame.maxX - 35, y:self.frame.maxY - 80);
        self.addChild(starship2Score)
        

        // Set the viewSize of the Starships so they understand when they go out of bounds and
        //      need to wrap to the other side of the screen
        let parentViewSize = CGPoint(x: self.frame.width, y: self.frame.height)
        Game.🚀1.viewSize = parentViewSize
        Game.🚀2.viewSize = parentViewSize
        
        // Use the setSprite function of a Starship class which sets all of the initial properties of the Starships
        Game.🚀1.setSprite(Game.🚀1.imageName)
        Game.🚀2.setSprite(Game.🚀2.imageName)
        
        // Add the Starships to the Scene
        self.addChild(Game.🚀1.sprite)
        self.addChild(Game.🚀2.sprite)
    

        // Add all of the Missiles as nodes to the Scene
        for i in 0 ..< Game.🚀1.TOTAL_MISSILES {
            
            Game.🚀1.missiles[i].viewSize = parentViewSize
            Game.🚀2.missiles[i].viewSize = parentViewSize
            
            Game.🚀1.missiles[i].starshipSize = Game.🚀1.sprite.size
            Game.🚀2.missiles[i].starshipSize = Game.🚀2.sprite.size
            
            Game.🚀1.missiles[i].setSprite(i)
            Game.🚀2.missiles[i].setSprite(i)
            
            self.addChild(Game.🚀1.missiles[i].sprite)
            self.addChild(Game.🚀2.missiles[i].sprite)

        }
        
        // Set up the explosion animation to use later when missiles collide with a starship
        let explosionAtlas = SKTextureAtlas(named: "explosions")
        for index in 0..<explosionAtlas.textureNames.count {
            let texture = "explosion\(index)"
            explosionAnimation += [explosionAtlas.textureNamed(texture)]
        }
        
        // Set some of the properties of the physicsWorld
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector.zero
    }
    
    // When the user touches the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameStarted = true  // the game has started
        myLabel.text = ""   // clear the label's text
        self.scene?.isPaused = false  // start the game.
        
//        for touch: AnyObject in touches {
//
//        }

    }
   
    // This function is called just prior to a frame being displayed
    override func update(_ currentTime: TimeInterval) {
        
        // If the game is currently in progress
        if !gameOver && gameStarted {
            
            // Call the StarshipMove() functions
            player1Delegate?.starship1Move()
            player2Delegate?.starship2Move()

            // Move all of the missiles that are currently on the screen
            for i in 0 ..< Game.🚀1.TOTAL_MISSILES {
                Game.🚀1.missiles[i].move()
            }
            for i in 0 ..< Game.🚀2.TOTAL_MISSILES {
                Game.🚀2.missiles[i].move()
            }
            
            updatesCalled += 1     // this variable is needed to prevent multiple collisions of the same missile
            updateScores()
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        // Set the Nodes which contacted each other
        let firstNode = contact.bodyA.node as! SKSpriteNode
        let secondNode = contact.bodyB.node as! SKSpriteNode
        
        //println("\(secondNode.name!) hits \(firstNode.name!)")
        
        // This is needed in order to prevent a single contact to be registered multiple times.
        if(updatesCalled == 0) {return} // No real change since last call
        updatesCalled = 0
        
        // Starship1 collides with Missiles from Starship2
        if ((contact.bodyA.categoryBitMask == ColliderType.starship1.rawValue ) && (contact.bodyB.categoryBitMask == ColliderType.missile2.rawValue)) {
            hitDetected(firstNode.name!, missileName: secondNode.name!)
        }
        else if ((contact.bodyA.categoryBitMask == ColliderType.missile2.rawValue ) && (contact.bodyB.categoryBitMask == ColliderType.starship1.rawValue)) {
            hitDetected(secondNode.name!, missileName: firstNode.name!)
        }
        
        // Starship2 collides with Missiles from Starship1
        if ((contact.bodyA.categoryBitMask == ColliderType.starship2.rawValue ) && (contact.bodyB.categoryBitMask == ColliderType.missile1.rawValue)) {
            hitDetected(firstNode.name!, missileName: secondNode.name!)
        }
        else if ((contact.bodyA.categoryBitMask == ColliderType.missile1.rawValue ) && (contact.bodyB.categoryBitMask == ColliderType.starship2.rawValue)) {
            hitDetected(secondNode.name!, missileName: firstNode.name!)
        }
        

    }
    
    // This function determines which missile hits the other StarShip
    func hitDetected(_ starshipName: String, missileName: String){
        
        // Starship1 was hit by a missile
        if starshipName == Game.🚀1.sprite.name {
            
            Game.🚀1.life -= 1  // Starship2 scores
            updateScores()
            // Check to see if Game is over
            gameOverCheck()
            
            // Remove proper missile from the screen
            for i in 0..<10 {
                if missileName == Game.🚀2.missiles[i].sprite.name {
                    // Set the velocity to zero
                    Game.🚀2.missiles[i].sprite.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    // Identify where the Starship was hit
                    let contactPoint = Game.🚀2.missiles[i].sprite.position
                    
                    // Move missile off the screen
                    let moveMissile = SKAction.move(to: CGPoint(x: -50, y: -50), duration: 0.01)
                    let moveAction = SKAction.repeat(moveMissile, count: 1)
                    Game.🚀2.missiles[i].sprite.run(moveAction)
                    Game.🚀2.missiles[i].isBeingFired = false
                    
                    // Play sound
                    playExplosionSound()
                    // Make exlposion
                    explodeMissile(contactPoint)
                }
            }
        }
        else if starshipName == Game.🚀2.sprite.name {
            // Starship1 scores
            Game.🚀2.life -= 1
            updateScores()
            // Check to see if Game is over
            gameOverCheck()
            
            // Remove proper missile from the screen
            for i in 0..<10 {
                if missileName == Game.🚀1.missiles[i].sprite.name {
                    // Set the velocity to zero
                    Game.🚀1.missiles[i].sprite.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    // Identify where the Starship was hit
                    let contactPoint = Game.🚀1.missiles[i].sprite.position
                    
                    // Move missile off the screen
                    let moveMissile = SKAction.move(to: CGPoint(x: -50, y: -50), duration: 0.01)
                    let moveAction = SKAction.repeat(moveMissile, count: 1)
                    Game.🚀1.missiles[i].sprite.run(moveAction)
                    Game.🚀1.missiles[i].isBeingFired = false
                    
                    // Play sound
                    playExplosionSound()
                    // Make exlposion
                    explodeMissile(contactPoint)
                }
            }

        }

    }
    
    // Function for progressing through the animation of a missile exploding
    func explodeMissile(_ whereToExplode: CGPoint) {
        let explosionSprite = SKSpriteNode(imageNamed:"explosion0")
        self.addChild(explosionSprite)
        explosionSprite.position = whereToExplode
        let animate = SKAction.animate(with: explosionAnimation, timePerFrame: 0.05)
        let explosionSequence = SKAction.sequence([animate, SKAction.removeFromParent()])
        explosionSprite.run(SKAction.repeat(explosionSequence, count: 1))
    }
    
    // Play the explosion sound when a missile hits a Starship
    func playExplosionSound() {
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: true))
    }
    
    // Play sound when a missile is fired
    func playFireMissileSound() {
        self.run(SKAction.playSoundFileNamed("missile.mp3", waitForCompletion: false))
    }
    
    // Function that is constantly called to see if the game is over
    func gameOverCheck(){
        var tie = false
        var gameOverMessage = ""
        
        // Starship2 wins
        if Game.🚀1.life <= 0 {
            gameOver = true
            gameOverMessage = "\(Game.🚀2.life) - \(Game.🚀2.name) (Winner) \(Game.🚀1.name) - \(Game.🚀1.life) (Loser)"
            if Game.🚀2.life <= 0 {
                tie = true
                gameOverMessage = "Tie game"
            }
        }
        else if Game.🚀2.life <= 0 { // Starship2 wins
            gameOver = true
            gameOverMessage = "\(Game.🚀1.life) - \(Game.🚀1.name) (Winner) \(Game.🚀2.name) - \(Game.🚀2.life) (Loser)"
            if Game.🚀1.life <= 0 {
                tie = true
                gameOverMessage = "Tie game"
            }
        }
        
        if gameOver {
            gameStarted = false
            let GVC = GameViewController()

            self.scene?.isPaused = true
            //Game.🚀1.sprite.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            //Game.🚀2.sprite.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            // Create an alert to display the final score
            let alertController = UIAlertController(title: "Game Over", message: gameOverMessage, preferredStyle: UIAlertControllerStyle.alert)
            
            // Add an 'action' to the alert so that when 'Main Menu' is clicked the ViewController segues back to the Menu screen
            let menuAction: UIAlertAction = UIAlertAction(title: "Main Menu", style: UIAlertActionStyle.default) {
                action -> Void in

                Game.🚀1.resetStarShip()
                Game.🚀2.resetStarShip()
                
                self.removeAllChildren()
                Game.🚀1.life = 20
                Game.🚀2.life = 20
                self.viewController?.moveToMenu()
            }
            
            // Add action to the alertController
            alertController.addAction(menuAction) //(UIAlertAction(title: "Main Menu", style: UIAlertActionStyle.Default, handler: nil))
            //self.view?.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
            
            // Present the alert
            self.viewController?.present(alertController, animated: true, completion: nil)
            
        }
        
    }

    
    // This function uses the player Delegates to determine which StarshipMove functions need to be called
    //      based on which students are playing each other.
    func setPlayerClasses() {

        if Game.🚀1.imageName == "Starship-Mr Black" {
            player1Delegate = MrBlack()
        }
        else if Game.🚀1.imageName == "Starship-Brynne" {
            //player1Delegate = BrynneAllan()
        }
        else if Game.🚀1.imageName == "Starship-Matthew" {
            //player1Delegate = MatthewBennett()
        }
        else if Game.🚀1.imageName == "Starship-Jacob" {
            //player1Delegate = JacobBland()
        }
        else if Game.🚀1.imageName == "Starship-Kaylee" {
            //player1Delegate = KayleeBogora()
        }
        else if Game.🚀1.imageName == "Starship-Eric" {
            //player1Delegate = EricDuberville()
        }
        else if Game.🚀1.imageName == "Starship-Daniel" {
            //player1Delegate = DanielGordon()
        }
        else if Game.🚀1.imageName == "Starship-David" {
            //player1Delegate = DavidHogan()
        }
        else if Game.🚀1.imageName == "Starship-Oksana" {
            //player1Delegate = OksanaJohnston()
        }
        else if Game.🚀1.imageName == "Starship-Jason" {
            //player1Delegate = JasonLittle()
        }
        else if Game.🚀1.imageName == "Starship-Jordan" {
            //player1Delegate = JordanMaloney()
        }
        else if Game.🚀1.imageName == "Starship-Greg" {
            //player1Delegate = GregMitchell()
        }
        else if Game.🚀1.imageName == "Starship-Owen" {
            //player1Delegate = OwenNichols()
        }
        else if Game.🚀1.imageName == "Starship-Ben" {
            //player1Delegate = BenSeward()
        }
        else if Game.🚀1.imageName == "Starship-Joey" {
            //player1Delegate = JoeyTripp()
        }
        else if Game.🚀1.imageName == "Starship-Dexter" {
            //player1Delegate = DexterVanZyllDeJong()
        }
        else if Game.🚀1.imageName == "Starship-Sherry" {
            //player1Delegate = SherryWang()
        }
        else if Game.🚀1.imageName == "Starship-Spencer" {
            //player1Delegate = SpencerWright()
        }
        else if Game.🚀1.imageName == "Starship-Justin" {
            //player1Delegate = JustinYanosik()
        }

        
        if Game.🚀2.imageName == "Starship-Mr Black" {
            player2Delegate = MrBlack()
        }
        else if Game.🚀2.imageName == "Starship-Brynne" {
            //player2Delegate = BrynneAllan()
        }
        else if Game.🚀2.imageName == "Starship-Matthew" {
            //player2Delegate = MatthewBennett()
        }
        else if Game.🚀2.imageName == "Starship-Jacob" {
            //player2Delegate = JacobBland()
        }
        else if Game.🚀2.imageName == "Starship-Kaylee" {
            //player2Delegate = KayleeBogora()
        }
        else if Game.🚀2.imageName == "Starship-Eric" {
            //player2Delegate = EricDuberville()
        }
        else if Game.🚀2.imageName == "Starship-Daniel" {
            //player2Delegate = DanielGordon()
        }
        else if Game.🚀2.imageName == "Starship-David" {
            //player2Delegate = DavidHogan()
        }
        else if Game.🚀2.imageName == "Starship-Oksana" {
            //player2Delegate = OksanaJohnston()
        }
        else if Game.🚀2.imageName == "Starship-Jason" {
            //player2Delegate = JasonLittle()
        }
        else if Game.🚀2.imageName == "Starship-Jordan" {
            //player2Delegate = JordanMaloney()
        }
        else if Game.🚀2.imageName == "Starship-Greg" {
            //player2Delegate = GregMitchell()
        }
        else if Game.🚀2.imageName == "Starship-Owen" {
            //player2Delegate = OwenNichols()
        }
        else if Game.🚀2.imageName == "Starship-Ben" {
            //player2Delegate = BenSeward()
        }
        else if Game.🚀2.imageName == "Starship-Joey" {
            //player2Delegate = JoeyTripp()
        }
        else if Game.🚀2.imageName == "Starship-Dexter" {
            //player2Delegate = DexterVanZyllDeJong()
        }
        else if Game.🚀2.imageName == "Starship-Sherry" {
            //player2Delegate = SherryWang()
        }
        else if Game.🚀2.imageName == "Starship-Spencer" {
            //player2Delegate = SpencerWright()
        }
        else if Game.🚀2.imageName == "Starship-Justin" {
            //player2Delegate = JustinYanosik()
        }
    }
    
    // Display the scores in the label
    func updateScores() {
        starship1Score.text = String(Game.🚀1.life)
        starship2Score.text = String(Game.🚀2.life)
    }
}
