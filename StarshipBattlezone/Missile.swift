//
//  Missile.swift
//  TestGame
//
//  Created by SFDCI on 2015-03-03.
//  Copyright (c) 2015 SFDCI. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import Darwin
import AVFoundation

class Missile {
    // Declare properties of a Missile
    var speed = CGPoint(x: 0, y: 0)
    var sprite = SKSpriteNode()
    var texture = SKTexture()
    var viewSize = CGPoint()    // width, height
    var starshipSize = CGSize()
    var isBeingFired = false
    var angle: Float = 0.0
    var playerNumber = 0
    var missileAnimation = [SKTexture]()
    var audioPlayer = AVAudioPlayer()
    let missileSound = URL(fileURLWithPath: Bundle.main.path(forResource: "missile", ofType: "mp3")!)
    var error:NSError?
    
    // Constructor
    init (playerNum: Int) {
        sprite = SKSpriteNode(imageNamed:"Missile1")
        self.sprite.xScale = 0.5
        self.sprite.yScale = 0.5
       
        self.playerNumber = playerNum
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: missileSound)
        } catch let error1 as NSError {
            error = error1
            //audioPlayer = nil
        }
        audioPlayer.prepareToPlay()
        audioPlayer.volume = 0.4
        
    }
    
    func setSprite(_ num: Int) {
     
        //sprite.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "Missile1"), size: sprite.size)
        // Set all of the properties of the physicsBody for the Missile (depending if it is Player1 or Player2).
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.frame.size)
        if let physics = sprite.physicsBody {
            physics.affectedByGravity = false
            physics.allowsRotation = false
            physics.linearDamping = 0.0
            physics.angularDamping = 0.0
            physics.usesPreciseCollisionDetection = true
            if playerNumber == 1 {
                physics.categoryBitMask =  ColliderType.missile1.rawValue //Game.missile1Category
                physics.collisionBitMask = ColliderType.starship2.rawValue //Game.starship2Category //| Game.missile2Category //ColliderType.Starship2.rawValue | ColliderType.Missile2.rawValue
                physics.contactTestBitMask = ColliderType.starship2.rawValue //ColliderType.Missile1.rawValue
                sprite.zRotation = CGFloat(M_PI)
                sprite.name = String("Missile1-\(num)")
            }
            else {
                physics.categoryBitMask = ColliderType.missile2.rawValue //Game.missile2Category
                physics.collisionBitMask = ColliderType.starship1.rawValue  //Game.starship1Category | Game.missile1Category //ColliderType.Starship1.rawValue | ColliderType.Missile1.rawValue
                physics.contactTestBitMask = ColliderType.starship1.rawValue  //ColliderType.Missile2.rawValue
                sprite.zRotation = CGFloat(M_PI)
                sprite.name = String("Missile2-\(num)")
            }
        }

        // Position the missiles off the screen
        self.sprite.position = CGPoint(x: -50, y: -50)
        
        // Set the atlas of images that will be used to animate the missiles.
        let missileAtlas = SKTextureAtlas(named: "Missiles")
        for index in 1...missileAtlas.textureNames.count {
            let texture = "Missile\(index)"
            missileAnimation += [missileAtlas.textureNamed(texture)]
        }
        
        // Animate the missiles.
        for _ in 0..<10 {
            let animate = SKAction.animate(with: missileAnimation, timePerFrame: 0.05)
            sprite.run(SKAction.repeatForever(animate))
        }
    }

    // A function that sets the speed of a missile when it is first fired.
    //      The speed of a missile can never exceed -100 or 100.
    func setSpeed (newSpeed: CGPoint, newPosition: CGPoint) {
    
        
        var tempSpeedX = newSpeed.x
        var tempSpeedY = newSpeed.y
        
        if newSpeed.x > 100 {
            tempSpeedX = 100
        }
        else if newSpeed.x < -100 {
            tempSpeedX = -100
        }
        
        if newSpeed.y > 100 {
            tempSpeedY = 100
        }
        else if newSpeed.y < -100 {
            tempSpeedY = -100
        }
        
        // Set the speed of the missile.
        self.speed = CGPoint(x: tempSpeedX, y: tempSpeedY)
        
        // Make the missile face the correct direction.
        angle = atan2f(Float(tempSpeedY), Float(tempSpeedX))
        self.sprite.zRotation = CGFloat(angle)
        self.sprite.position = newPosition
        self.sprite.physicsBody?.velocity = CGVector(dx: self.speed.x, dy: self.speed.y)
        
        // Play the missile firing sound.
        audioPlayer.play()
    }
    
    
    func move() {

        if (self.isBeingFired) {
            //  Check to see if missile goes off the Scene
            if (self.sprite.position.x < 0 || self.sprite.position.x > self.viewSize.x || self.sprite.position.y < 0 || self.sprite.position.y > self.viewSize.y) {
                // Move the missile off the screen until it is ready to be fired again.
                self.isBeingFired = false
                self.sprite.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                self.sprite.position = CGPoint(x: -50, y: -50)
                let moveMissile = SKAction.move(to: self.sprite.position, duration: 0.01)
                let moveAction = SKAction.repeat(moveMissile, count: 1)
                sprite.run(moveAction)
            }
        }
    }
    
}
