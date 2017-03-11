//
//  GameScene.swift
//  VirtualJoystick
//
//  Created by Richard Jiang on 11/03/17.
//  Copyright © 2017年 nus.cs3217.a0119401. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private let plate = SKSpriteNode(imageNamed: "plate")
    private let joystick = SKSpriteNode(imageNamed: "top")
    private let spaceship = SKSpriteNode(imageNamed: "Spaceship")
    private let fireButton = SKSpriteNode(imageNamed: "fire")
    
    private var xDestination: CGFloat = CGFloat(0)
    private var yDestination: CGFloat = CGFloat(0)
    private var unitOffset: CGVector = CGVector(dx: 0, dy: 1)
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = SKColor.white
        plate.position = CGPoint(x: self.size.width * 0.1, y: self.size.height * 0.1)
        plate.size = CGSize(width: self.size.width / 8, height: self.size.width / 8)
        addChild(plate)
        
        joystick.size = CGSize(width: plate.size.width / 2, height: plate.size.height / 2)
        // Note: position is given as center position already
        joystick.position = CGPoint(x: plate.position.x, y: plate.position.y)
        joystick.alpha = 0.8
        addChild(joystick)
        //joystick.bringToFront()
        joystick.zPosition = 2
        
        spaceship.size = CGSize(width: plate.size.width * 0.8, height: plate.size.height * 0.8)
//        spaceship.xScale = 1.2
//        spaceship.yScale = 1.2
        spaceship.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        addChild(spaceship)
        
        fireButton.size = CGSize(width: plate.size.width, height: plate.size.height)
        fireButton.position = CGPoint(x: self.size.width * 0.9, y: self.size.height * 0.1)
        addChild(fireButton)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches {
            if self.checkFireButtonActive(touch: t) {
                print ("Fire in the hole!")
                // add here for firing action
                self.fire()
            } else {
                self.rotateJoystickAndSpaceship(touch: t)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if !self.checkFireButtonActive(touch: t) {
                self.rotateJoystickAndSpaceship(touch: t)
            }
        }
    }
    
    private func rotateJoystickAndSpaceship(touch: UITouch) {
        let location = touch.location(in: self)
        let direction = CGVector(dx: location.x - plate.position.x, dy: location.y - plate.position.y)
        let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        let directionVector = CGVector(dx: direction.dx / length, dy: direction.dy / length)
        self.unitOffset = directionVector
        let rotationAngle = atan2(directionVector.dy, directionVector.dx) - CGFloat.pi / 2
        var radius = plate.size.width / 2
        if length < radius {
            radius = length
        }
        joystick.position = CGPoint(x: plate.position.x + directionVector.dx * radius, y: plate.position.y + directionVector.dy * radius)
        spaceship.zRotation = rotationAngle
    }
    
    private func checkFireButtonActive(touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        if fireButton.frame.contains(location) {
            return true
        } else {
            return false
        }
    }
    
    private func fire() {
        let currentFiringAngle = spaceship.zRotation
        let projectile = SKSpriteNode(imageNamed: "missile")
        //projectile.size = CGSize(width: )
        projectile.xScale = 0.3
        projectile.yScale = 0.3
        projectile.position = CGPoint(x: spaceship.position.x, y: spaceship.position.y)
        projectile.zRotation = currentFiringAngle
        projectile.zPosition = -1
        
        addChild(projectile)
        let travel = CGVector(dx: self.unitOffset.dx * 1200, dy: self.unitOffset.dy * 1200)
        let destination = CGPoint(x: spaceship.position.x + travel.dx, y: spaceship.position.y + travel.dy)
        
        projectile.run(SKAction.move(to: destination, duration: 3), completion: {
            projectile.removeFromParent()
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if !self.checkFireButtonActive(touch: t) {
                joystick.run(SKAction.move(to: CGPoint(x: plate.position.x, y: plate.position.y), duration: 0.2))
                spaceship.run(SKAction.rotate(toAngle: 0, duration: 0.2))
                self.unitOffset = CGVector(dx:0, dy: 1)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

extension SKNode {
    func bringToFront() {
        guard let parent = parent else {
            return
        }
        removeFromParent()
        parent.addChild(self)
    }
}
