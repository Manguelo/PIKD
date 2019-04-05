//
//  GameScene.swift
//  Pop The Lock
//
//  Created by Mantelot on 4/6/17.
//  Copyright © 2017 Mantelot. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
import GameKit

class GameScene: SKScene {
    var mainCamera = SKCameraNode()
    var cuff = SKSpriteNode()
    var Circle = SKSpriteNode()
    var Person = SKSpriteNode()
    var Dot = SKSpriteNode()
    var badDot = SKSpriteNode()
    var box = SKSpriteNode()
    var Path = UIBezierPath()
    
    var box1 = SKSpriteNode()
    var joint2 = SKPhysicsJointLimit()
    var joint4 = SKPhysicsJointLimit()
    
    var coolDown = true
    
    var lockEmitter = SKEmitterNode(fileNamed: "lock")
    
    var homeButton = SKSpriteNode(imageNamed: "home")
    var shareButton = SKSpriteNode(imageNamed: "share")
    var leaderButton = SKSpriteNode(imageNamed: "leaderBoard")
    
    var gameStarted = Bool()
    
    var movingClockwise = Bool()
    var intersected = false
    
    
    var LevelLabel = SKLabelNode()
    var LevelLabel2 = SKLabelNode()
    var LevelLabel3 = SKLabelNode()
    let doubleLabel = SKLabelNode()
    
    var attemptsTillAd = 10;
    var currentLevel = Int()
    var currentScore = Int()
    var highLevel = Int()
    var deviceHeightOffset = CGFloat()
    //var currentColor = UIColor(red: CGFloat(1.0), green: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), blue: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), alpha: CGFloat(1))
  let Defaults = UserDefaults.standard as UserDefaults?
    let fadeIn = SKAction.fadeIn(withDuration: 1.5)
    let fadeOut = SKAction.fadeOut(withDuration: 0.5)
    
    override func didMove(to view: SKView) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.size = CGSize(width: 1433, height: 1912)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAdBanners"), object: nil)

        
      /* START - Temp fix to format app for iPhone X */
      if UIDevice().userInterfaceIdiom == .phone {
        switch UIScreen.main.nativeBounds.height {
        case 2436:
          print("iPhone X, XS")
          self.size = CGSize(width: 1125, height: 2436)
          deviceHeightOffset = 175
        case 2688:
          print("iPhone XS Max")
          self.size = CGSize(width: 1125, height: 2436)
          deviceHeightOffset = 200
        case 1792:
          print("iPhone XR")
          self.size = CGSize(width: 1125, height: 2436)
          deviceHeightOffset = 175
        default:
          deviceHeightOffset = 0
          print("Unknown")
        }
      }
      
      /* END - Temp fix to format app for iPhone X */
        
        // print(scene?.backgroundColor)
        if Defaults?.integer(forKey: "HighLevel") != 0{
            highLevel = Defaults?.integer(forKey: "HighLevel") as! Int
            Defaults?.set(highLevel, forKey: "HighLevel")
            currentLevel = highLevel
            currentScore = currentLevel
            LevelLabel.text = "\(currentScore)"
        }
        else{
            
            Defaults?.set(1, forKey: "HighLevel")
        }
        
        if modeLabel.text == "Level Mode"{
            loadLevelMode()
            lockEmitter?.position = CGPoint(x: 0, y: -450)
            
            run(SKAction.wait(forDuration: 0.4), completion: {
                self.createChain()
                self.addChild(self.lockEmitter!)
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                self.run(SKAction.wait(forDuration: 0.7))
            })
        }
        
    }
    func loadLevelMode(){
        coolDown = true
        
        homeButton.name = "homeButton"
        homeButton.size = CGSize(width: 175, height: 175)
        homeButton.position = CGPoint(x: -386, y: 801 + deviceHeightOffset)
        homeButton.alpha = 1
        self.addChild(homeButton)
        
        shareButton.name = "shareButton"
        shareButton.size = CGSize(width: 125, height: 125)
        shareButton.position = CGPoint(x: -386, y: -740 - deviceHeightOffset)
        shareButton.alpha = 0.7
        self.addChild(shareButton)
        
        leaderButton.name = "leaderBoardButton"
        leaderButton.size = CGSize(width: 175, height: 175)
        leaderButton.position = CGPoint(x: 386, y: 801 + deviceHeightOffset)
        leaderButton.alpha = 0.7
        self.addChild(leaderButton)
        
        
        movingClockwise = true
        backgroundColor = currentColor
        Circle = SKSpriteNode(imageNamed: "Circle")
        Circle.size = CGSize(width: 600, height: 600)
        Circle.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        //Circle.alpha = 0.7
        self.addChild(Circle)
        
        
        Person = SKSpriteNode(imageNamed: "Person")
        Person.size = CGSize(width: 70, height: 24)
        Person.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 240)
        Person.zRotation = 3.14 / 2
        Person.zPosition = 2.0
        Person.alpha = 0.01
        self.addChild(Person)
        AddDot()
        
        
        LevelLabel.position = CGPoint(x: 0 , y: 0 - 60)
        LevelLabel.text = "\(currentScore)"
        LevelLabel.fontName = "Futura-Bold"
        LevelLabel.fontColor = UIColor.white
        LevelLabel.fontSize = 200
        LevelLabel.name = "LevelLabel"
        self.addChild(self.LevelLabel)
        
        
        
        LevelLabel2.position = CGPoint(x: 0 , y: self.frame.height / 2 - 450 - deviceHeightOffset)
        LevelLabel2.text = "LEVEL"
        LevelLabel2.fontName = "Futura-Bold"
        LevelLabel2.fontColor = UIColor.white
        LevelLabel2.fontSize = 150
        LevelLabel2.name = "LevelLabel"
        self.addChild(self.LevelLabel2)
        
        LevelLabel3.position = CGPoint(x: 0 , y: self.frame.height / 2 - 535  - deviceHeightOffset)
        LevelLabel3.text = "\(highLevel)"
        LevelLabel3.fontName = "Futura-Bold"
        LevelLabel3.fontColor = UIColor.white
        LevelLabel3.fontSize = 75
        LevelLabel3.name = "LevelLabel"
        self.addChild(self.LevelLabel3)
        
        
        box.isHidden = false
        box.position = CGPoint(x: 0, y: -257)
        box.size = CGSize(width: 277, height: 50)
        box.color = UIColor(red: 0.188213, green: 0.188251, blue: 0.188208, alpha: 1)
        //box.alpha = 0.7
        //self.addChild(box)
        
        cuff = SKSpriteNode(imageNamed: "cuff")
        cuff.position = CGPoint(x: 0, y: -317)
        cuff.xScale = 1.5
        cuff.yScale = 1.5
        cuff.color = UIColor(red: 0.188213, green: 0.188251, blue: 0.188208, alpha: 1)
        cuff.colorBlendFactor = 1
        //cuff.alpha = 0.7
        self.addChild(cuff)
        
        run(SKAction.wait(forDuration: 0.5))
        Person.run(SKAction.fadeIn(withDuration: 0.5), completion: { self.coolDown = false})
        
        
        
        mainCamera.position = CGPoint(x: 0, y: 0)
        self.camera = mainCamera
        self.addChild(mainCamera)
        
        
    }
    
    func shakeCamera(duration:Float) {
        let amplitudeX:Float = 50;
        let amplitudeY:Float = 50;
        let numberOfShakes = duration / 0.04;
        var actionsArray:[SKAction] = [];
        for _ in 1...Int(numberOfShakes) {
            // build a new random shake and add it to the list
            let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2;
            let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2;
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02);
            shakeAction.timingMode = SKActionTimingMode.easeOut;
            actionsArray.append(shakeAction);
            actionsArray.append(shakeAction.reversed());
        }
        
        let actionSeq = SKAction.sequence(actionsArray);
        camera?.run(actionSeq);
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if coolDown == true{
        }else{
            
            for touch: AnyObject in touches {
                let location = (touch as! UITouch).location(in: self)
                if let nodeName = self.atPoint(location).name {
                    if nodeName == "homeButton" {
                        let gameScene = SKScene(fileNamed: "menu")
                        gameScene?.scaleMode = .aspectFit
                        view?.presentScene(gameScene!, transition: SKTransition.push(with: .left, duration: 0.5))
                        return
                    }else if nodeName == "leaderBoardButton" {
                        NotificationCenter.default.post(name: NSNotification.Name("showLeaderBoard"), object: nil)
                        return
                    }else if nodeName == "shareButton" {
                        shareText(text: "Check out PIKD!!! https://itunes.apple.com/us/app/split-game/id1245368459?ls=1&mt=8")
                        return
                    }
                }
            }
            if gameStarted == false{
                moveClockWise()
                movingClockwise = true
                gameStarted = true
            } else if gameStarted == true{
                
                if movingClockwise == true{
                    if Dot.name != "doubleDot"{
                        moveCounterClockWise()
                    }
                    movingClockwise = false
                    DotTouched()
                }
                else if movingClockwise == false{
                    if Dot.name != "doubleDot"{
                        moveClockWise()
                    }
                    movingClockwise = true
                    DotTouched()
                }
                
            }
            
            for touch in touches {
                let location = touch.location(in: self)
                let node : SKNode = self.atPoint(location)
                if node.name == "LevelLabel" {
                    //        So I can test any level I want!!! Remove the next 2 lines in final product!!!
                    //currentLevel = 60
                    //Defaults?.set(60, forKey: "HighLevel")
                    
                }
            }
        }
    }
    
    
    func AddDot(){
        
        Dot = SKSpriteNode(imageNamed: "dot1")
        Dot.size = CGSize(width: 60, height: 60)
        Dot.color = UIColor(red: 0.0863, green: 0.8902, blue: 1, alpha: 1.0)
        Dot.colorBlendFactor = 1.0
        Dot.zPosition = 1.0
        
        let dx = Person.position.x - self.frame.midX
        let dy = Person.position.y - self.frame.midY
        
        let rad = atan2(dy, dx)
        
        //Dot will flash green if level is greater than 10
        if currentLevel >= 5 && currentLevel < 10{
            Dot.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5), SKAction.wait(forDuration: 1.0), SKAction.fadeIn(withDuration: 1.0)])) )
        }else if currentLevel >= 10 && currentLevel < 20{
            let action1 = SKAction.colorize(with: UIColor.green, colorBlendFactor: 0.8, duration: 0.2)
            let action2 = SKAction.colorize(with: currentColor, colorBlendFactor: 1.0, duration: 0.5)
            Dot.run(SKAction.repeatForever(SKAction.sequence([action1,action2, SKAction.wait(forDuration: 1.5)])))
            AddBadDot()
        }else if currentLevel >= 20 && currentLevel < 30{
            let action1 = SKAction.colorize(with: UIColor.green, colorBlendFactor: 0.8, duration: 0.1)
            let action2 = SKAction.colorize(with: currentColor, colorBlendFactor: 1.0, duration: 0.1)
            Dot.run(SKAction.repeatForever(SKAction.sequence([action1,action2, SKAction.fadeOut(withDuration: 0.5), SKAction.wait(forDuration: 1.0), fadeIn])))
            AddBadDot()
        }else if currentLevel >= 30 && currentLevel < 40 {
            switch(unsafeRandomIntFrom(start: 1, to: 3)){
            case 1:
                Dot.size = CGSize(width: 50, height: 50)
            case 2:
                Dot.size = CGSize(width: 40, height: 40)
            case 3:
                Dot.size = CGSize(width: 60, height: 60)
            default:
                break
            }
        }else if currentLevel >= 40 && currentLevel < 50 {
            switch(unsafeRandomIntFrom(start: 1, to: 3)){
            case 1:
                Dot.size = CGSize(width: 50, height: 50)
            case 2:
                Dot.size = CGSize(width: 40, height: 40)
            case 3:
                Dot.size = CGSize(width: 60, height: 60)
            default:
                break
            }
            
            Dot.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5), SKAction.wait(forDuration: 1.0), SKAction.fadeIn(withDuration: 1.0)])) )
        }else if currentLevel >= 50 && currentLevel < 60 {
            switch(unsafeRandomIntFrom(start: 1, to: 3)){
            case 1:
                Dot.size = CGSize(width: 50, height: 50)
            case 2:
                Dot.size = CGSize(width: 40, height: 40)
            case 3:
                Dot.size = CGSize(width: 60, height: 60)
            default:
                break
            }
            
            let action1 = SKAction.colorize(with: UIColor.green, colorBlendFactor: 0.8, duration: 0.1)
            let action2 = SKAction.colorize(with: currentColor, colorBlendFactor: 1.0, duration: 0.1)
            Dot.run(SKAction.repeatForever(SKAction.sequence([action1,action2, SKAction.wait(forDuration: 1.5)])))
            AddBadDot()
        }else if currentLevel >= 60 && currentLevel < 70{
            let randomNum = unsafeRandomIntFrom(start: 1, to: 3)
            if randomNum == 1 {
                
                doubleLabel.fontName = "Futura-Bold"
                doubleLabel.text = "x2"
                doubleLabel.fontSize = 45
                doubleLabel.zPosition = 1.5
                doubleLabel.position.y = Dot.position.y - 15
                
                Dot.name = "doubleDot"
                Dot.color = UIColor.orange
                Dot.size = CGSize(width: 85, height: 85)
                Dot.addChild(doubleLabel)
                
            }
        }else if currentLevel >= 70 && currentLevel < 80{
            //case already covered below
        }else if currentLevel >= 80 && currentLevel < 90{
            switch(unsafeRandomIntFrom(start: 1, to: 3)){
            case 1:
                Dot.size = CGSize(width: 50, height: 50)
            case 2:
                doubleLabel.fontName = "Futura-Bold"
                doubleLabel.text = "x2"
                doubleLabel.fontSize = 45
                doubleLabel.zPosition = 1.5
                doubleLabel.position.y = Dot.position.y - 15
                
                Dot.name = "doubleDot"
                Dot.color = UIColor.orange
                Dot.size = CGSize(width: 85, height: 85)
                Dot.addChild(doubleLabel)
            case 3:
                Dot.size = CGSize(width: 60, height: 60)
            default:
                break
            }
            
            attemptsTillAd = 15;
        }else if currentLevel >= 90 && currentLevel < 99{
            switch(unsafeRandomIntFrom(start: 1, to: 3)){
            case 1:
                let action1 = SKAction.colorize(with: UIColor.green, colorBlendFactor: 0.8, duration: 0.2)
                let action2 = SKAction.colorize(with: currentColor, colorBlendFactor: 1.0, duration: 0.5)
                Dot.run(SKAction.repeatForever(SKAction.sequence([action1,action2, SKAction.wait(forDuration: 1.5)])))
                AddBadDot()
            case 2:
                doubleLabel.fontName = "Futura-Bold"
                doubleLabel.text = "x2"
                doubleLabel.fontSize = 45
                doubleLabel.zPosition = 1.5
                doubleLabel.position.y = Dot.position.y - 15
                
                Dot.name = "doubleDot"
                Dot.color = UIColor.orange
                Dot.size = CGSize(width: 85, height: 85)
                Dot.addChild(doubleLabel)
            case 3:
                Dot.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5), SKAction.wait(forDuration: 1.0), SKAction.fadeIn(withDuration: 1.0)])) )
            default:
                break
            }
        }

        if movingClockwise == true{
            let tempAngle = CGFloat.random(min: rad - 1.0, max: rad - 2.5)
            let Path2 = UIBezierPath(arcCenter: CGPoint(x: Circle.position.x, y: Circle.position.y), radius: 240, startAngle: tempAngle, endAngle: tempAngle + CGFloat(Double.pi * 4), clockwise: true)
            Dot.position = Path2.currentPoint
            if gameStarted == true && Dot.name != "doubleDot"{
                if currentLevel >= 70 && currentLevel < 90{
                    let follow = SKAction.follow(Path2.cgPath, asOffset: false, orientToPath: true, speed: CGFloat(350 + speed * 25))
                    Dot.run(SKAction.repeatForever(follow))
                }
            }
        }
        else if movingClockwise == false{
            let tempAngle = CGFloat.random(min: rad + 1.0, max: rad + 2.5)
            let Path2 = UIBezierPath(arcCenter: CGPoint(x: Circle.position.x, y: Circle.position.y), radius: 240, startAngle: tempAngle, endAngle: tempAngle + CGFloat(Double.pi * 4), clockwise: true)
            Dot.position = Path2.currentPoint
            if gameStarted == true && Dot.name != "doubleDot"{
                if currentLevel >= 70 && currentLevel < 90{
                    let follow = SKAction.follow(Path2.cgPath, asOffset: false, orientToPath: true, speed: CGFloat(350 + speed * 25))
                    Dot.run(SKAction.repeatForever(follow).reversed())
                }
            }
        }
        self.addChild(Dot)
        print(Dot.position)
        
    }
    
    
    func AddBadDot(){
        
        badDot = SKSpriteNode(imageNamed: "dot1")
        badDot.size = CGSize(width: 60, height: 60)
        badDot.zPosition = 1.0
        badDot.color = currentColor
        badDot.colorBlendFactor = 1.0
        
        let dx = badDot.position.x - self.frame.midX
        let dy = badDot.position.y - self.frame.midY
        
        let rad = atan2(dy, dx)
        
        //Dot will flash red if level is greater than 10
        if currentLevel >= 10 && currentLevel < 20{
            let action1 = SKAction.colorize(with: UIColor.red, colorBlendFactor: 0.8, duration: 0.2)
            let action2 = SKAction.colorize(with: currentColor, colorBlendFactor: 1.0, duration: 0.5)
            badDot.run(SKAction.repeatForever(SKAction.sequence([action1,action2, SKAction.wait(forDuration: 1.5)])))
            
        }else if currentLevel >= 20 && currentLevel < 30{
            let action1 = SKAction.colorize(with: UIColor.red, colorBlendFactor: 0.8, duration: 0.1)
            let action2 = SKAction.colorize(with: currentColor, colorBlendFactor: 1.0, duration: 0.1)
            badDot.run(SKAction.repeatForever(SKAction.sequence([action1,action2, SKAction.fadeOut(withDuration: 0.5), SKAction.wait(forDuration: 1.0), fadeIn])))
            
        }else if currentLevel >= 50 && currentLevel < 60{
            switch(unsafeRandomIntFrom(start: 1, to: 3)){
            case 1:
                badDot.size = CGSize(width: 50, height: 50)
            case 2:
                badDot.size = CGSize(width: 40, height: 40)
            case 3:
                badDot.size = CGSize(width: 60, height: 60)
            default:
                break
            }
            let action1 = SKAction.colorize(with: UIColor.red, colorBlendFactor: 0.8, duration: 0.1)
            let action2 = SKAction.colorize(with: currentColor, colorBlendFactor: 1.0, duration: 0.1)
            badDot.run(SKAction.repeatForever(SKAction.sequence([action1,action2, SKAction.wait(forDuration: 1.5)])))
        }else if currentLevel >= 80 && currentLevel < 99{
            let action1 = SKAction.colorize(with: UIColor.red, colorBlendFactor: 0.8, duration: 0.1)
            let action2 = SKAction.colorize(with: currentColor, colorBlendFactor: 1.0, duration: 0.1)
            badDot.run(SKAction.repeatForever(SKAction.sequence([action1,action2, SKAction.fadeOut(withDuration: 0.5), SKAction.wait(forDuration: 1.0), fadeIn])))
        }
        
        if movingClockwise == true{
            let tempAngle = CGFloat.random(min: rad - 1.0, max: rad - 2.5)
            let Path2 = UIBezierPath(arcCenter: CGPoint(x: Circle.position.x, y: Circle.position.y), radius: 240, startAngle: tempAngle, endAngle: tempAngle + CGFloat(Double.pi * 4), clockwise: true)
            badDot.position = Path2.currentPoint
        }
        else if movingClockwise == false{
            let tempAngle = CGFloat.random(min: rad + 1.0, max: rad + 2.5)
            let Path2 = UIBezierPath(arcCenter: CGPoint(x: Circle.position.x, y: Circle.position.y), radius: 240, startAngle: tempAngle, endAngle: tempAngle + CGFloat(Double.pi * 4), clockwise: true)
            badDot.position = Path2.currentPoint
        }
        self.addChild(badDot)
        print(Dot.position)
        
    }
    
    
    
    func moveClockWise(){
        
        let dx = Person.position.x - self.frame.midX
        let dy = Person.position.y - self.frame.midY
        var speed = currentLevel
        let rad = atan2(dy, dx)
        
        if currentLevel >= 60 && currentLevel < 70 ||
           currentLevel >= 80 && currentLevel < 99{
            speed = 16
        }else if currentLevel >= 70 && currentLevel < 80{
            speed = 15
        }else if currentLevel > 20 {
            speed = 20
        }
        
        Path = UIBezierPath(arcCenter: CGPoint(x: Circle.position.x, y: Circle.position.y), radius: 240, startAngle: rad, endAngle: rad + CGFloat(Double.pi * 4), clockwise: true)
        let follow = SKAction.follow(Path.cgPath, asOffset: false, orientToPath: true, speed: CGFloat(350 + speed * 25))
        Person.run(SKAction.repeatForever(follow).reversed())
        
    }
    
    func moveCounterClockWise(){
        
        let dx = Person.position.x - self.frame.midX
        let dy = Person.position.y - self.frame.midY
        var speed = currentLevel
        let rad = atan2(dy, dx)
        
        
        if currentLevel >= 60 && currentLevel < 70 ||
           currentLevel >= 80 && currentLevel < 99{
            speed = 16
        }else if currentLevel >= 70 && currentLevel < 80{
            speed = 15
        }else if currentLevel > 20 {
            speed = 20
        }
        
        
        Path = UIBezierPath(arcCenter: CGPoint(x: Circle.position.x, y: Circle.position.y), radius: 240, startAngle: rad, endAngle: rad + CGFloat(Double.pi * 4), clockwise: true)
        let follow = SKAction.follow(Path.cgPath, asOffset: false, orientToPath: true, speed: CGFloat(350 + speed * 25))
        Person.run(SKAction.repeatForever(follow))
        
        
    }
    
    func DotTouched(){
        if intersected == true{
            //Checks for intersection with bad Dot
            if Person.intersects(badDot){
                /*Checks to see if user also intersected good Dot
                 intersection with good Dot takes priority*/
                if Person.intersects(Dot){
                    Dot.removeFromParent()
                    badDot.removeFromParent()
                    AddDot()
                    
                }else{
                    died()
                }
                /*if the dot is a 2x dot it'll only change the color and image untill you tap again*/
            }else if Dot.name == "doubleDot"{
                doubleLabel.text = "x1"
                Dot.color = UIColor(red: 0.0863, green: 0.8902, blue: 1, alpha: 1.0)
                Dot.name = "dot1"
            }else{
                //removes chain on 1 2 3
                
                
                if(highLevel >= 3 && currentScore == 3){
                    self.physicsWorld.remove(joint4)
                    if #available(iOS 10.0, *) {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
                }else if (highLevel >= 3 && currentScore == 2){
                    self.physicsWorld.remove(joint2)
                    if #available(iOS 10.0, *) {
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()
                        
                    }
                    
                }
                //end remove chain on 1 2 3
                Dot.removeFromParent()
                badDot.removeFromParent()
                AddDot()
            }
            intersected = false
            
            currentScore -= 1
            LevelLabel.text = "\(currentScore)"
            if currentScore <= 0{
                nextLevel()
                
            }
            
        }
        else if intersected == false{
            
            died()
        }
        
    }
    
    func createChain(){
        
        box1 = SKSpriteNode(imageNamed: "link1")
        box1.position = CGPoint(x: 0, y: -450)
        box1.physicsBody = SKPhysicsBody(rectangleOf: box1.size)
        box1.physicsBody?.isDynamic = false
        let box2 = SKSpriteNode(imageNamed: "link2")
        box2.physicsBody = SKPhysicsBody(rectangleOf: box2.size)
        box2.position = CGPoint(x: 0, y: -500)
        box2.physicsBody?.isDynamic = true
        self.addChild(box1)
        self.addChild(box2)
        
        let box3 = SKSpriteNode(imageNamed: "link1")
        box3.position = CGPoint(x: 0, y: -650)
        box3.physicsBody = SKPhysicsBody(rectangleOf: box1.size)
        box3.physicsBody?.isDynamic = true
        let box4 = SKSpriteNode(imageNamed: "link2")
        box4.physicsBody = SKPhysicsBody(rectangleOf: box2.size)
        box4.position = CGPoint(x: 0, y: -650)
        box4.physicsBody?.isDynamic = true
        self.addChild(box3)
        self.addChild(box4)
        
        let box5 = SKSpriteNode(imageNamed: "link1")
        box5.position = CGPoint(x: 0, y: -750)
        box5.physicsBody = SKPhysicsBody(rectangleOf: box1.size)
        box5.physicsBody?.isDynamic = true
        let box6 = SKSpriteNode(imageNamed: "link2")
        box6.physicsBody = SKPhysicsBody(rectangleOf: box2.size)
        box6.position = CGPoint(x: -300, y: -750)
        box6.physicsBody?.isDynamic = true
        self.addChild(box5)
        self.addChild(box6)
        
        
        box1.setScale(1.5)
        box2.setScale(1.5)
        box3.setScale(1.5)
        box4.setScale(1.5)
        box5.setScale(1.5)
        box6.setScale(1.5)
        
        box1.color = UIColor(red: 0.188213, green: 0.188251, blue: 0.188208, alpha: 1)
        box2.color = UIColor(red: 0.188213, green: 0.188251, blue: 0.188208, alpha: 1)
        box3.color = UIColor(red: 0.188213, green: 0.188251, blue: 0.188208, alpha: 1)
        box4.color = UIColor(red: 0.188213, green: 0.188251, blue: 0.188208, alpha: 1)
        box5.color = UIColor(red: 0.188213, green: 0.188251, blue: 0.188208, alpha: 1)
        box6.color = UIColor(red: 0.188213, green: 0.188251, blue: 0.188208, alpha: 1)
        
        box1.colorBlendFactor = 1
        box2.colorBlendFactor = 1
        box3.colorBlendFactor = 1
        box4.colorBlendFactor = 1
        box5.colorBlendFactor = 1
        box6.colorBlendFactor = 1
        
        
        let joint1 = SKPhysicsJointLimit.joint(withBodyA: box1.physicsBody!, bodyB: box2.physicsBody!, anchorA: CGPoint(x: box1.position.x , y: box1.position.y - 50), anchorB:CGPoint(x: box2.position.x , y: box2.position.y + 50))
        joint2 = SKPhysicsJointLimit.joint(withBodyA: box2.physicsBody!, bodyB: box3.physicsBody!, anchorA: CGPoint(x: box2.position.x , y: box2.position.y - 50), anchorB:CGPoint(x: box3.position.x , y: box3.position.y + 50))
        let joint3 = SKPhysicsJointLimit.joint(withBodyA: box3.physicsBody!, bodyB: box4.physicsBody!, anchorA: CGPoint(x: box3.position.x , y: box3.position.y - 50), anchorB:CGPoint(x: box4.position.x , y: box4.position.y + 50))
        joint4 = SKPhysicsJointLimit.joint(withBodyA: box4.physicsBody!, bodyB: box5.physicsBody!, anchorA: CGPoint(x: box4.position.x , y: box4.position.y - 50), anchorB:CGPoint(x: box5.position.x , y: box5.position.y + 50))
        let joint5 = SKPhysicsJointLimit.joint(withBodyA: box5.physicsBody!, bodyB: box6.physicsBody!, anchorA: CGPoint(x: box5.position.x , y: box5.position.y - 50), anchorB:CGPoint(x: box6.position.x , y: box6.position.y + 50))
        joint1.maxLength = 2
        joint2.maxLength = 2
        joint3.maxLength = 2
        joint4.maxLength = 2
        joint5.maxLength = 2
        
        self.physicsWorld.add(joint1)
        self.physicsWorld.add(joint2)
        self.physicsWorld.add(joint3)
        self.physicsWorld.add(joint4)
        self.physicsWorld.add(joint5)
        
        
        
    }
    
    
    func nextLevel(){
        currentLevel += 1
        currentScore = currentLevel
        LevelLabel.text  = "\(currentScore)"
        randomHue =  CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        currentColor = UIColor(hue: randomHue, saturation: 0.34, brightness: 0.8, alpha: 1.0)
        if currentLevel > highLevel{
            highLevel = currentLevel
            let Defaults = UserDefaults.standard
            Defaults.set(highLevel, forKey: "HighLevel")
            submitScore(score: Defaults.integer(forKey: "HighLevel"))
        }
        won()
        
    }
    
    
    
    func died(){
        self.removeAllChildren()
        //        let action1 = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.2)
        //        let action2 = SKAction.colorize(with: currentColor, colorBlendFactor: 1.0, duration: 0.2)
        //        self.scene?.run(SKAction.sequence([action1,action2]))
        intersected = false
        gameStarted = false
        LevelLabel.removeFromParent()
        currentScore = currentLevel
        
        if modeLabel.text == "Level Mode"{
            loadLevelMode()
            self.createChain()
        }
        shakeCamera(duration: 0.3)
        if UserDefaults.standard.object(forKey: "attempts") != nil{
            
            UserDefaults.standard.setValue((UserDefaults.standard.integer(forKey: "attempts") + 1), forKeyPath: "attempts")
            if UserDefaults.standard.integer(forKey: "attempts") >= attemptsTillAd{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showInterstitial"), object: nil)
                UserDefaults.standard.setValue(0, forKeyPath: "attempts")
            }
            }else{
                UserDefaults.standard.setValue(0, forKeyPath: "attempts")
            }
            
        
        
        
    }
    
    //FIXME: add cooler win animation
    func won(){
        coolDown = true
        //        let action1 = SKAction.colorize(with: UIColor.green, colorBlendFactor: 1.0, duration: 0.2)
        //        let action2 = SKAction.colorize(with: currentColor, colorBlendFactor: 1.0, duration: 0.2)
        // self.run(SKAction.sequence([action1,action2]))
        box.isHidden = true
        box1.physicsBody = SKPhysicsBody(rectangleOf: box1.size)
        box1.physicsBody?.affectedByGravity = true
        // cuff.physicsBody?.isDynamic = true
        box1.physicsBody?.isDynamic = true
        Person.removeFromParent()
        Dot.removeFromParent()
        LevelLabel.run(SKAction.sequence([fadeOut,SKAction.wait(forDuration: 0.5),fadeIn,]))
        LevelLabel2.run(SKAction.sequence([fadeOut,SKAction.wait(forDuration: 0.5),fadeIn,]))
        LevelLabel3.run(SKAction.sequence([fadeOut,SKAction.wait(forDuration: 0.5),fadeIn,]), completion:
            {
                
                self.removeAllChildren()
                self.intersected = false
                self.gameStarted = false
                self.LevelLabel.removeFromParent()
                if modeLabel.text == "Level Mode"{
                    self.loadLevelMode()
                    self.run(SKAction.wait(forDuration: 0.4), completion: {
                        self.createChain()
                        self.lockEmitter?.resetSimulation()
                        self.addChild(self.lockEmitter!)
                        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                        self.run(SKAction.wait(forDuration: 0.7))
                    })
                }
        })
        
        
        //loadView()
        
        
    }
    
    func unsafeRandomIntFrom(start: Int, to end: Int) -> Int {
        return Int(arc4random_uniform(UInt32(end - start + 1))) + start
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        if Person.intersects(Dot){
            intersected = true
            
        }
        else{
            if intersected == true{
                if Person.intersects(Dot) == false{
                    died()
                }
            }
        }
    }
    
    
    func submitScore(score: Int) {
      if GKLocalPlayer.local.isAuthenticated == true{
            let leaderboardID = "grp.levelModeBoard"
            let sScore = GKScore(leaderboardIdentifier: leaderboardID)
            sScore.value = Int64(score)
            
            GKScore.report([sScore], withCompletionHandler: { (Error) in
                if Error != nil {
                    print(Error!.localizedDescription)
                } else {
                    print("Score submitted")
                    
                }
            })
        }
    }
    
    func shareText(text: String) {
        
        let textToShare = [text]
        let activityVC = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        
      activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        if UIDevice.current.userInterfaceIdiom == .pad {
            if  activityVC.responds(to: #selector(getter: UIViewController.popoverPresentationController))  {
                activityVC.popoverPresentationController?.sourceView = super.view
                /* to adjust pop-up position */
                //activityVC.popoverPresentationController?.sourceRect = CGRect(x: shareCircle.position.x,y: shareCircle.position.y, width: 0, height: 0)
            }
        }
        let currentViewController:UIViewController=UIApplication.shared.keyWindow!.rootViewController!
        
        currentViewController.present(activityVC, animated: true, completion: nil)
    }
}
