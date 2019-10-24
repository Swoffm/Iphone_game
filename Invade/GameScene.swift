//
//  GameScene.swift
//  Invasion
//
//  Created by gavin Swofford on 12/5/18.
//  Copyright © 2018 Nexus 2. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    
    var ground : SKSpriteNode?
    var castle : SKSpriteNode?
    var scoreLabel : SKLabelNode?
    var alienTimer : Timer?
    var plasmaTimer : Timer?
    var castleHealth = 500
    var score = 1
    var yourScoreLabel : SKLabelNode?
    var finalScoreLabel : SKLabelNode?
    var level : SKLabelNode?
    
    // side bar for spawning the alien
    var alienSide : SKSpriteNode?
    
    // alien picture on the sidebar
    let alienSideBarSpawn = SKSpriteNode(imageNamed: "Alien")
    let exit = SKSpriteNode(imageNamed: "exit")
    // side bar for spawning
    var sideBar : SKSpriteNode?
    
    
    // spawning the alien
    let spawnAlien = SKSpriteNode(imageNamed: "Alien")
    // inital resources
    var water = 100
    var steel = 100
    var food = 100
    
    
    let groundCategory : UInt32 = 0x1 << 1
    let castleCategory : UInt32 = 0x1 << 2
    let alienCategory : UInt32 = 0x1 << 3
    let plasmaCategory : UInt32 = 0x1 << 4
    
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        ground = childNode(withName: "ground") as? SKSpriteNode
        ground?.physicsBody?.categoryBitMask = groundCategory
        ground?.physicsBody?.collisionBitMask = groundCategory
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        
        castle = childNode(withName: "castle") as? SKSpriteNode
        castle?.physicsBody?.categoryBitMask = castleCategory
        castle?.physicsBody?.collisionBitMask = castleCategory
        castle?.physicsBody?.contactTestBitMask = alienCategory
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        
        
        
        
        
        gametext()
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        if let location = touch?.location(in: self){
            let theNodes = nodes(at: location)
            for node in theNodes {
                
                if node.name == "play"{
                    //restart the game
                    score = 1
                    castleHealth = 500
                    node.removeFromParent()
                    finalScoreLabel?.removeFromParent()
                    yourScoreLabel?.removeFromParent()
                    scene?.isPaused = false
                    scoreLabel?.text = "Wave: \(score)"
                    
                    // beginTimers()
                }
                
                if node.name == "alienSpawn" {
                    if water > 25 {
                        water -= 25
                        // spawns in an alien when touched
                        createAlien()
                    }
                    
                }
                
                
            }
            
        }
        
    }
    
    func createPlasma() {
        
        
        
        // let plasma = Plasma()
        // where the plasma is going to which is the castle's location
        let fire = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 1)
        let fireAlien = SKAction.sequence([fire])
        let alienFire = SKAction.repeatForever(fireAlien)
        
        let  alien = Alien()
        let plasma = Plasma()
        
        // let alienPostion = alien.alien.position
        // plasma
        
        plasma.plasma.physicsBody = SKPhysicsBody(rectangleOf: plasma.plasma.size)
        plasma.plasma.physicsBody?.categoryBitMask = plasmaCategory
        plasma.plasma.physicsBody?.contactTestBitMask = castleCategory
        plasma.plasma.physicsBody?.affectedByGravity = false
        plasma.plasma.physicsBody?.collisionBitMask = 0
        // this set postion of plasma to alien postion
        plasma.plasma.position = alien.alien.position
        plasma.plasma.zPosition = 2
        
        
        
        
        if alien.alienHealth > 0 {
            plasmaTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
                self.addChild(plasma.plasma)
            })
            plasma.plasma.run(alienFire)
        }
        
        
        
    }
    
    
    
    func createAlien() {
        
        
        let  alien = Alien()
        
        // these are constants that are defined as actions and sequences
        
        //  let alien = SKSpriteNode(imageNamed: "Alien")
        let moveLeft = SKAction.move(to: CGPoint(x: 600, y: 300 ),duration: 3)
        let moveRight = SKAction.move(to: CGPoint(x: -600, y: 300 ),duration: 3)
        let movement = SKAction.sequence([moveLeft, moveRight])
        let myMovement = SKAction.repeatForever(movement)
        
        
        // this calls the alien onto the screen and ends with its starting postion
        alien.alien.physicsBody = SKPhysicsBody(rectangleOf: alien.alien.size)
        alien.alien.physicsBody?.categoryBitMask = alienCategory
        alien.alien.physicsBody?.contactTestBitMask = castleCategory
        alien.alien.physicsBody?.affectedByGravity = false
        alien.alien.physicsBody?.collisionBitMask = 0
        alien.alien.position = CGPoint(x: 640, y: 300)
        
        addChild(alien.alien)
        
        
        if alien.alienHealth > 0 {
            alien.alien.run(myMovement)
            plasmaTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
                self.createPlasma()
            })
        }
        
        
        
        
        
        // this is the logic that keeps the alien going until it's health reaches zero
        if alien.alienHealth > 0 {
            alien.alien.run(myMovement)
        }
            
            // when the alien health reaches zero this deltes the alien
        else if alien.alienHealth == 0 {
            alien.alien.run(SKAction.removeFromParent())
        }
        
        
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        // this is how much damage the castle takes if plasma comes in contact with the castle
        if contact.bodyA.categoryBitMask == plasmaCategory {
            contact.bodyA.node?.removeFromParent()
            castleHealth -= 10
            
            
            
        }
        // this is how much damage the castle takes if plasma comes in contact with the castle
        if contact.bodyB.categoryBitMask == plasmaCategory {
            contact.bodyB.node?.removeFromParent()
            
            castleHealth -= 10
            
            
        }
        if castleHealth == 0 {
            gameOver()
        }
        
        
    }
    
    
    func gameOver() {
        
        scene?.isPaused = true
        
        level?.removeFromParent()
        let alien = Alien()
        let plasma = Plasma()
        alien.alien.removeFromParent()
        plasma.plasma.removeFromParent()
        alienTimer?.invalidate()
        //  alien.removeFromParent()
        
        yourScoreLabel = SKLabelNode(text: "You made it to wave: ")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.zPosition = 1
        yourScoreLabel?.fontSize = 100
        if yourScoreLabel != nil {
            addChild(yourScoreLabel!)}
        
        finalScoreLabel = SKLabelNode(text: "\(score)")
        finalScoreLabel?.position = CGPoint(x: 0, y: 0)
        finalScoreLabel?.zPosition = 1
        finalScoreLabel?.fontSize = 200
        if finalScoreLabel != nil {
            addChild(finalScoreLabel!)}
        
        let playButton = SKSpriteNode(imageNamed: "playbutton")
        playButton.position = CGPoint(x: 0, y: -200)
        playButton.zPosition = 1
        playButton.name = "play"
        addChild(playButton)
        
        
    }
    
    // this adds the text for level one
    func gametext() {
        if castleHealth != 0 {
            level = SKLabelNode(text: "Level One")
            level?.position = CGPoint(x: 0, y: 300)
            level?.zPosition = 1
            level?.fontSize = 100
            if level != nil {
                addChild(level!)}
            
            // this is a variable for the color of the sidebar
            let sideColor = UIColor(red: 221, green: 147, blue: 17, alpha: 0.5)
            // sets for screen size
            let sideBarSize = CGSize(width: 300, height: 875)
            // this sets the location of the sidebar, size, and color.
            //let  screenWidth = UIScreen.main.bounds
            sideBar = SKSpriteNode(color: sideColor, size: sideBarSize)
            sideBar?.position = CGPoint(x: 700, y: 0)
            sideBar?.zPosition = 1
            if sideBar != nil {
                addChild(sideBar!)}
            
            // box around alien
            let alienSideColor = UIColor(red: 244, green: 252, blue: 15, alpha: 1)
            // size of the background square
            let alienSideSize = CGSize(width: 190, height: 200)
            alienSide = SKSpriteNode(color: alienSideColor, size: alienSideSize)
            alienSide?.position = CGPoint(x: 650, y: 300)
            alienSide?.zPosition = 1.1
            if alienSide != nil {
                addChild(alienSide!)}
            
            // prints the image on the side bar
            alienSideBarSpawn.zPosition = 1.12
            alienSideBarSpawn.position = CGPoint(x: 640, y: 300)
            alienSideBarSpawn.name = "alienSpawn"
            addChild(alienSideBarSpawn)
            
            
            
            
        }
    }
    
}
class Alien {
    let alien = SKSpriteNode(imageNamed: "Alien")
    var alienHealth = 50
    
}

class Plasma {
    let plasma = SKSpriteNode(imageNamed: "plasma")
    
}




