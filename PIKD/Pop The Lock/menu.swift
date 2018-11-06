//
//  menu.swift
//  Pop The Lock
//
//  Created by Matthew Anguelo on 6/11/17.
//  Copyright © 2017 Mantelot. All rights reserved.
//

import Foundation
import SpriteKit
import StoreKit
import GoogleMobileAds

var modeLabel = SKLabelNode()
var randomHue =  CGFloat(Float(arc4random()) / Float(UINT32_MAX))
var currentColor = UIColor(hue: randomHue, saturation: 0.34, brightness: 0.8, alpha: 1)


class menu: SKScene, GADBannerViewDelegate {
    var mainCamera = SKCameraNode()
    
    var line1 = SKSpriteNode()
    var line2 = SKSpriteNode()
    var line3 = SKSpriteNode()
    
    var leftArrow = SKSpriteNode()
    var rightArrow = SKSpriteNode()
    var soundIMG = SKSpriteNode()
    
    var scoreLabel = SKLabelNode()
    
    var currentLevel = Int()
    var currentScore = Int()
    var highLevel = Int()
    
    let Defaults = UserDefaults.standard as UserDefaults?
    let fadeIn = SKAction.fadeIn(withDuration: 1.5)
    let fadeOut = SKAction.fadeOut(withDuration: 0.5)
    
    override func didMove(to view: SKView) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.size = CGSize(width: 1433, height: 1912)
        }
        
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadInterstitial"), object: nil)
        /* START - Temp fix to format app for iPhone X */
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                print("iPhone X")
                self.size = CGSize(width: 1125, height: 2436)
            default:
                print("unknown")
            }
        }
        /* END - Temp fix to format app for iPhone X */
        
        scoreLabel = self.childNode(withName: "highScoreLabel") as! SKLabelNode
        leftArrow = self.childNode(withName: "leftArrow") as! SKSpriteNode
        rightArrow = self.childNode(withName: "rightArrow") as! SKSpriteNode
        modeLabel = self.childNode(withName: "modeLabel") as! SKLabelNode
        soundIMG = self.childNode(withName: "soundIMG") as! SKSpriteNode
        
        setupLines()
       
        moveLine(line: line1, duration: 1.5)
        moveLine(line: line2, duration: 1.5)
        moveLine(line: line3, duration: 1.5)
        
        getHighScore()
        
        self.backgroundColor = currentColor
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        quickResize(nodeName: "rateButton", size: 175, duration: 0.1)
        quickResize(nodeName: "leaderBoardButton", size: 175, duration: 0.1)
        quickResize(nodeName: "shareButton", size: 175, duration: 0.1)
        quickResize(nodeName: "soundDot", size: 175, duration: 0.1)
        quickResize(nodeName: "soundIMG", size: 100, duration: 0.1)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = (touch as! UITouch).location(in: self)
            if let nodeName = self.atPoint(location).name {
                
                if nodeName == "rightArrow" && modeLabel.text == "Level Mode"{
                    modeLabel.text = "Survival"
                    lockMoveRight()
                }else if nodeName == "rightArrow" && modeLabel.text == "Survival"{
                    modeLabel.text = "Level Mode"
                    lockMoveRight()
                }else if nodeName == "leftArrow" && modeLabel.text == "Level Mode"{
                    modeLabel.text = "Survival"
                    lockMoveLeft()
                }else if nodeName == "leftArrow" && modeLabel.text == "Survival"{
                    modeLabel.text = "Level Mode"
                    lockMoveLeft()
                }else if nodeName == "playButton"{
                    if modeLabel.text == "Level Mode"{
                        let gameScene = SKScene(fileNamed: "GameScene")
                        gameScene?.scaleMode = .aspectFit
                        emptyScreen()
                        run(SKAction.wait(forDuration: 0.7), completion: { self.view?.presentScene(gameScene!, transition: SKTransition.push(with: .left, duration: 0.5))})
                    }else if modeLabel.text == "Survival" {
                        let gameScene = SKScene(fileNamed: "SurvivalMode")
                        gameScene?.scaleMode = .aspectFit
                        emptyScreen()
                        run(SKAction.wait(forDuration: 0.7), completion: { self.view?.presentScene(gameScene!, transition: SKTransition.push(with: .left, duration: 0.5))})
                    }
                    print("play")
                }else if nodeName == "rateButton"{
                    quickResize(nodeName: nodeName, size: 75, duration: 0.1)
                    rateApp(appId: "12345", completion: { (sucess) in
                        print("Rate The APP!!!")
                    })
                    print("rate")
                }else if nodeName == "soundButton"{
                    quickResize(nodeName: "soundDot", size: 75, duration: 0.1)
                    quickResize(nodeName: "soundIMG", size: 45, duration: 0.1)
                    soundButtonPressed()
                    print("sound")
                }else if nodeName == "shareButton"{
                    //quickResize(nodeName: nodeName, size: 75, duration: 0.1)
                    shareText(text: "Check out PIKD!!! https://itunes.apple.com/us/app/split-game/id1245368459?ls=1&mt=8")
                    print("share")
                }else if nodeName == "leaderBoardButton"{
                    //quickResize(nodeName: nodeName, size: 75, duration: 0.1)
                    print("Board")
                    NotificationCenter.default.post(name: NSNotification.Name("showLeaderBoard"), object: nil)

                }
                
                
                
            }
            
        }
    }
    func soundButtonPressed(){
        if Defaults?.bool(forKey: "soundOff") == false{
            //backgroundMusicPlayer.pause()
            self.childNode(withName: "soundIMG")?.alpha = 0.5
            //                        soundOff.isHidden = false
            //                        soundOff.alpha = 1
            Defaults?.set(true, forKey: "soundOff")
            Defaults?.synchronize()
        }else if Defaults?.bool(forKey: "soundOff") == true{
            //                        backgroundMusicPlayer.play()
            //                        soundOff.isHidden = true
            self.childNode(withName: "soundIMG")?.alpha = 1
            Defaults?.set(false, forKey: "soundOff")
            Defaults?.synchronize()
        }else{
            Defaults?.set(false, forKey: "soundOff")
            Defaults?.synchronize()
        }
        
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        if #available(iOS 10.3, *){
            SKStoreReviewController.requestReview()
        }else{
            
            guard let url = URL(string : "https://itunes.apple.com/us/app/split-game/id1245368459?ls=1&mt=8") else {
                completion(false)
                return
            }
            guard #available(iOS 10, *) else {
                completion(UIApplication.shared.openURL(url))
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: completion)
        }
    }
    
    func shareText(text: String) {
        
        let textToShare = [text]
        let activityVC = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
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
    
    func getHighScore(){
        if modeLabel.text == "Level Mode"{
            if Defaults?.integer(forKey: "HighLevel") != 0{
                highLevel = (Defaults?.integer(forKey: "HighLevel") as Int?)!
                currentLevel = highLevel
                scoreLabel.text = "\(highLevel)"
            }
            else{
                Defaults?.set(1, forKey: "HighLevel")
                highLevel = (Defaults?.integer(forKey: "HighLevel") as Int?)!
                currentLevel = highLevel
                scoreLabel.text = "\(highLevel)"
            }
        }else if modeLabel.text == "Survival"{
            if Defaults?.integer(forKey: "SurvivalLevel") != 0{
                highLevel = (Defaults?.integer(forKey: "SurvivalLevel") as Int?)!
                currentLevel = highLevel
                scoreLabel.text = "\(highLevel)"
            }else{
                Defaults?.set(0, forKey: "SurvivalLevel")
                highLevel = (Defaults?.integer(forKey: "SurvivalLevel") as Int?)!
                currentLevel = highLevel
                scoreLabel.text = "\(highLevel)"
            }
        }
    }
    
    func lockMoveLeft(){
        for node in self.children {
            guard let snode = node as? SKSpriteNode else { continue }
            
            if snode.position.y < 375 && snode.position.y > -375 && node.zPosition > -9 {
                snode.run(SKAction.sequence([SKAction.moveBy(x: -1000, y: 0, duration: 0.3), SKAction.moveBy(x: 3000, y: 0, duration: 0)]), completion: {
                    snode.run(SKAction.moveBy(x: -2000, y: 0, duration: 0.3))
                    self.getHighScore()
                })
            }
        }
        //empty label nodes
        for node in self.children {
            guard let snode = node as? SKLabelNode else { continue }
            
            if snode.position.y < 375 && snode.position.y > -375 {
                snode.run(SKAction.sequence([SKAction.moveBy(x: -1000, y: 0, duration: 0.3), SKAction.moveBy(x: 3000, y: 0, duration: 0)]), completion: {
                    snode.run(SKAction.moveBy(x: -2000, y: 0, duration: 0.3))
                    self.getHighScore()
                })
            }
        }
    }
    
    func lockMoveRight(){
        for node in self.children {
            guard let snode = node as? SKSpriteNode else { continue }
            
            if snode.position.y < 375 && snode.position.y > -375 && node.zPosition > -9{
                snode.run(SKAction.sequence([SKAction.moveBy(x: 1000, y: 0, duration: 0.3), SKAction.moveBy(x: -3000, y: 0, duration: 0)]), completion: {
                    snode.run(SKAction.moveBy(x: 2000, y: 0, duration: 0.3))
                    self.getHighScore()
                })
            }
        }
        //empty label nodes
        for node in self.children {
            guard let snode = node as? SKLabelNode else { continue }
            
            if snode.position.y < 375 && snode.position.y > -375 {
                snode.run(SKAction.sequence([SKAction.moveBy(x: 1000, y: 0, duration: 0.3), SKAction.moveBy(x: -3000, y: 0, duration: 0)]), completion: {
                    snode.run(SKAction.moveBy(x: 2000, y: 0, duration: 0.3))
                    self.getHighScore()
                })
            }
        }
    }
    
    func emptyScreen(){
        //empty sprite nodes
        moveLine(line: line1, duration: 0.5)
        moveLine(line: line2, duration: 0.5)
        moveLine(line: line3, duration: 0.5)
        
        for node in self.children {
            guard let snode = node as? SKSpriteNode else { continue }
            
            if snode.position.y > 375 && node.zPosition > -9{
                snode.run(SKAction.moveBy(x: 0, y: 800, duration: 0.3))
            }
            
            if snode.position.y < -375 && node.zPosition > -9{
                snode.run(SKAction.moveBy(x: 0, y: -800, duration: 0.3))
            }
            
        }
        //empty label nodes
        for node in self.children {
            guard let snode = node as? SKLabelNode else { continue }
            
            if snode.position.y > 375 {
                snode.run(SKAction.moveBy(x: 0, y: 800, duration: 0.3))
            }
            
            if snode.position.y < -375 {
                snode.run(SKAction.moveBy(x: 0, y: -800, duration: 0.3))
            }
        }
    }
    
    func quickResize(nodeName: String, size: CGFloat, duration: Double){
        self.childNode(withName: nodeName)?.run(SKAction.resize(toWidth: size, height: size, duration: duration))
    }
    
    func moveLine(line: SKSpriteNode, duration: CGFloat){
        line.run(SKAction.moveBy(x: -1650, y: -1650, duration: TimeInterval(duration)))
    }
   
    
    
    
    /**********************************************
     *             CONFIGURING ADS                *
     **********************************************/
    
    
    
    
    
    
}
