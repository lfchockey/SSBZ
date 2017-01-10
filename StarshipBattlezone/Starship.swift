//
//  Starship.swift
//  StarshipBattlezone
//
//  Created by Mason Black on 2015-03-10.
//  Copyright (c) 2015 Mason Black. All rights reserved.
//


import Foundation
import UIKit
import SpriteKit
import Darwin


class Starship {
    // Declare properties of a Starship
    private var speed = CGPoint(x: 0, y: 0)
    var sprite = SKSpriteNode()
    var texture = SKTexture()
    var viewSize = CGPoint()    // width, height
    var gun = SKNode()
    var missiles: [Missile] = []
    var missileNumber = 0
    let TOTAL_MISSILES = 10
    var life: Int = 20
    var name = ""
    var imageName = ""
    var playerNumber = 0
    var angle: Float = 0.0
    

    
    // Constructor
    init(playerNum: Int) {
        
        // Set the player number of each Starship
        self.playerNumber = playerNum
        
        // Initialize all of the missile objects
        for i in 0..<TOTAL_MISSILES {
            let missile = Missile(playerNum: playerNum)
            missiles.append(missile)
        }
    }
    
    // This function sets up all of the characteristics of the sprite once the proper player has been selected
    func setSprite(_ filename: String) {

        
        sprite = SKSpriteNode(imageNamed: imageName)            
        
        // Set all of the properties of the physicsBody for the Starship (depending if it is Player1 or Player2).
        sprite.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: imageName), size: sprite.size) 
        if let physics = sprite.physicsBody {
            physics.affectedByGravity = false
            physics.allowsRotation = false
            physics.usesPreciseCollisionDetection = true
            if playerNumber == 1 {
                physics.categoryBitMask =  ColliderType.starship1.rawValue //Game.starship1Category
                physics.collisionBitMask = ColliderType.missile2.rawValue | ColliderType.starship2.rawValue //Game.missile2Category
                physics.contactTestBitMask = ColliderType.missile2.rawValue //Game.starship2Category //ColliderType.Starship2.rawValue
            }
            else {
                physics.categoryBitMask = ColliderType.starship2.rawValue //Game.starship2Category
                physics.collisionBitMask = ColliderType.missile1.rawValue | ColliderType.starship1.rawValue //Game.missile1Category
                physics.contactTestBitMask = ColliderType.missile1.rawValue //Game.starship1Category //ColliderType.Starship1.rawValue
            }
        }
        
        // Position the Starship at the top of the screen
        if self.playerNumber == 1 {
            self.sprite.position.x = self.viewSize.x/2
            self.sprite.position.y = self.viewSize.y - 100
            self.sprite.zRotation = CGFloat(M_PI)   // the Starship should face down
            self.sprite.name = "Starship1"
        }
        else {      // Position the Starship at the bottom of the screen
            self.sprite.position.x = self.viewSize.x/2
            self.sprite.position.y = 100
            self.sprite.name = "Starship2"
        }
        
        // Set the scale/size of the sprite
        self.sprite.xScale = 0.5
        self.sprite.yScale = 0.5
        
        // Set the position of the gun (where missiles will be fired from)
        self.gun.position.x = 0
        self.gun.position.y = self.sprite.size.height + 20
        self.gun.name = "gun"
        self.sprite.addChild(gun)

      
    }
    
    //~~~ 
    // returns how much life is remaining
    func getLife() -> Int {
        return self.life
    }
    
    //~~~
    // returns the values of the other Starship
    func radar() -> (starshipPosition: CGPoint, starshipSpeed: CGPoint, life: Int) {
        
        if self.playerNumber == 1 {
            return (Game.🚀2.sprite.position, Game.🚀2.speed, Game.🚀2.life)
        }
        else {
            return (Game.🚀1.sprite.position, Game.🚀1.speed, Game.🚀1.life)
        }
        
    }
    
    
    // A function that returns the speed of Starship
    func getSpeed() -> CGPoint {
        return self.speed
    }
    
    // A function that returns the speed of Starship
    func getPosition() -> CGPoint {
        return self.sprite.position
    }
    
    //~~~
    // A function that sets a new speed/direction of a Starship
    //  The max speed a Starship can travel is -25 or 25 (both vertically and horizontally)
    func setNewSpeed(x: Int, y: Int) {
        var newX: Int = x
        var newY: Int = y
        
        if newX > 25 {
            newX = 25
        }
        else if newX < -25 {
            newX = -25
        }
        
        if newY > 25 {
            newY = 25
        }
        else if newX < -25 {
            newY = -25
        }
        
        self.speed = CGPoint(x: newX, y: newY)
        
        
        // The following rotates the image so the Starships are always looking at one another
        let deltaX = Game.🚀2.sprite.position.x - Game.🚀1.sprite.position.x
        let deltaY = Game.🚀2.sprite.position.y - Game.🚀1.sprite.position.y
        
        // Set the angle/direction the Starship is facing.
        angle = atan2f(Float(deltaY), Float(deltaX))
        angle = angle - Float(M_PI/2)
        
        if playerNumber == 1 {
            self.sprite.zRotation = CGFloat(angle)
        }
        else {
            angle = angle - Float(M_PI)
            self.sprite.zRotation = CGFloat(angle)
        }

    }
    
    
    
    
    
    
    // A function that sets a new speed/direction of a Starship
    //  The max speed a Starship can travel is -25 or 25 (both vertically and horizontally)
    func setSpeed(_ newSpeed: CGPoint) {
        var spd = CGPoint(x: newSpeed.x, y: newSpeed.y)
        
        // Make sure that the newSpeed doesn't exceed 25
        if newSpeed.x > 25 {
            spd = CGPoint (x: 25, y: newSpeed.y)
        }
        else if newSpeed.x < -25 {
            spd = CGPoint (x: -25, y: newSpeed.y)
        }
        else {
            spd = CGPoint (x: spd.x, y: newSpeed.y)
        }
        
        // Make sure that the newSpeed doesn't exceed 25
        if newSpeed.y > 25 {
            spd = CGPoint (x: spd.x, y: 25)
        }
        else if newSpeed.x < -25 {
            spd = CGPoint (x: spd.x, y: -25)
        }
        else {
            spd = CGPoint (x: spd.x, y: newSpeed.y)
        }
        
        self.speed = spd
        
        let deltaX = Game.🚀2.sprite.position.x - Game.🚀1.sprite.position.x
        let deltaY = Game.🚀2.sprite.position.y - Game.🚀1.sprite.position.y

        // Set the angle/direction the Starship is facing.
        angle = atan2f(Float(deltaY), Float(deltaX))
        angle = angle - Float(M_PI/2)

        if playerNumber == 1 {
            self.sprite.zRotation = CGFloat(angle)
        }
        else {
            angle = angle - Float(M_PI)
            self.sprite.zRotation = CGFloat(angle)
        }

    }
    
    // This function is called inside the individual student Starship classes.
    func move (){
        self.sprite.physicsBody?.velocity = CGVector(dx: self.speed.x, dy: self.speed.y)
        
        // See if the Starship goes off the left of the screen.
        if sprite.position.x < 0 {
            let rightSideOfScreen = viewSize.x - sprite.size.width
            let moveStarship = SKAction.move(to: CGPoint(x: rightSideOfScreen, y: sprite.position.y), duration: 0.01)
            let moveAction = SKAction.repeat(moveStarship, count: 1)
            sprite.run(moveAction)
        } // See if the Starship goes off the right of the screen.
        else if sprite.position.x > viewSize.x {
            let leftSideOfScreen: CGFloat = 0.0
            let moveStarship = SKAction.move(to: CGPoint(x: leftSideOfScreen, y: sprite.position.y), duration: 0.01)
            let moveAction = SKAction.repeat(moveStarship, count: 1)
            sprite.run(moveAction)
        }
        
        // See if the Starship goes off the bottom of the screen.
        if sprite.position.y < 0 {
            let topOfScreen = viewSize.y - sprite.size.height
            let moveStarship = SKAction.move(to: CGPoint(x: sprite.position.x, y: topOfScreen), duration: 0.01)
            let moveAction = SKAction.repeat(moveStarship, count: 1)
            sprite.run(moveAction)
        }
            // See if the Starship goes off the top of the screen.
        else if sprite.position.y > viewSize.y {
            let bottomOfScreen: CGFloat = 0.0
            let moveStarship = SKAction.move(to: CGPoint(x: sprite.position.x, y: bottomOfScreen), duration: 0.01)
            let moveAction = SKAction.repeat(moveStarship, count: 1)
            sprite.run(moveAction)
        }
        
    }
    
    //~~~
    // This function fires the next missile that is available.
    func shoot (xSpeed: Double, ySpeed: Double) {
        
        // Loop through all of the missiles.
        for i in missileNumber ..< self.TOTAL_MISSILES {
            
            // If a missile isn't being fired.
            if !missiles[i].isBeingFired {
                let gunPosition =  sprite.childNode(withName: "gun")!.convert(CGPoint.zero, to: sprite.parent!)
                missiles[i].setSpeed(newSpeed: CGPoint(x: xSpeed, y: ySpeed), newPosition: gunPosition)
                missiles[i].isBeingFired = true
                break
            }
        }
        
        // Move on to the next missile
        missileNumber += 1
        if missileNumber >= TOTAL_MISSILES {
            missileNumber = 0   // Reset the missile back to the first one if they've reached the end.
        }
    }

    
    // This function fires the next missile that is available.
    func fire (_ missileSpeed: CGPoint) -> Void {
        
        // Loop through all of the missiles.
        for i in missileNumber ..< self.TOTAL_MISSILES {
            
            // If a missile isn't being fired.
            if !missiles[i].isBeingFired {
                let gunPosition =  sprite.childNode(withName: "gun")!.convert(CGPoint.zero, to: sprite.parent!)
                missiles[i].setSpeed(newSpeed: missileSpeed, newPosition: gunPosition)
                missiles[i].isBeingFired = true
                break
            }
        }
        
        // Move on to the next missile
        missileNumber += 1
        if missileNumber >= TOTAL_MISSILES {
            missileNumber = 0   // Reset the missile back to the first one if they've reached the end.
        }
    }
    
    // Get the width of the sprite.
    func getWidth() -> CGFloat {
        return sprite.size.width
    }
    
    // Get the height of the sprite.
    func getHeight() -> CGFloat {
        return sprite.size.height
    }
    
    func resetStarShip() {
        
        speed = CGPoint(x: 0, y: 0)
        missileNumber = 0
        life = 20
        name = ""
        imageName = ""
        angle = 0.0
        
        for i in 0 ..< TOTAL_MISSILES {
            missiles[i].isBeingFired = false
        }
    }
    
}
