//
//  GameViewController.swift
//  Pop The Lock
//
//  Created by Mantelot on 4/6/17.
//  Copyright © 2017 Mantelot. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds
import AudioToolbox
import GameKit

var gcEnabled = Bool()
var gcDefaultLeaderBoard = String()
class GameViewController: UIViewController, GADInterstitialDelegate, GADBannerViewDelegate, GKGameCenterControllerDelegate {
    
    var interstitial : GADInterstitial?
    var adMobBannerView = GADBannerView()
    let ADMOB_BANNER_UNIT_ID = "ca-app-pub-3465645126290249/1453653873"

    override func viewDidLoad() {
        super.viewDidLoad()
            initAdMobBanner()
            interstitial = createAndLoadInterstitial()
            self.authenticateLocalPlayer()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "menu") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    /*************************************************************
     *                  CONFIGURING BANNER ADS                   *
     *************************************************************/
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3465645126290249~4271388904")
        return true
    }
    
  @objc func initAdMobBanner() {

        adMobBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adMobBannerView.frame = CGRect(x:0.0, y:self.view.frame.size.height - adMobBannerView.frame.size.height, width:adMobBannerView.frame.size.width, height:adMobBannerView.frame.size.height)
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
       
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "a6dbcb49b5215ff9caff2557045d8d52", "499ee92ad170acfda54945aea6be4b19"]
        adMobBannerView.load(request)

        view.addSubview(adMobBannerView)

        //adMobBannerView.center = CGPoint(x: 329, y: 350)
    
    }
    /*************************************************************
     *              CONFIGURING INTERSTITIAL ADS                 *
     *************************************************************/
  @objc func createAndLoadInterstitial() -> GADInterstitial? {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3465645126290249/6372197810")
        
        guard let interstitial = interstitial else {
            return nil
        }
        if interstitial.isReady == false{
            let request = GADRequest()
            // Remove the following line
            request.testDevices = [ kGADSimulatorID, "a6dbcb49b5215ff9caff2557045d8d52", "e7bd65674fae98af0a5538d8a2eb991a", "499ee92ad170acfda54945aea6be4b19"]
            interstitial.load(request)
            interstitial.delegate = self
            print("interstitial Load")
        }
        return interstitial
    }
    
  @objc func presentInterstitial() {
        interstitial?.present(fromRootViewController: self)
        interstitial = createAndLoadInterstitial()
    }
    
    /*************************************************************
     *                     DISPLAYING FUNCTIONS                  *
     *************************************************************/
    override func viewWillLayoutSubviews() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.initAdMobBanner), name: NSNotification.Name(rawValue: "showAdBanner"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createAndLoadInterstitial), name: NSNotification.Name(rawValue: "loadInterstitial"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.presentInterstitial), name: NSNotification.Name(rawValue: "showInterstitial"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showLeaderboard), name: NSNotification.Name(rawValue: "showLeaderBoard"), object: nil)

    }
 
    
    /*************************************************************
     *                  CONFIGURING GAME CENTER                  *
     *************************************************************/
    
  @objc func showLeaderboard() {
        
        let gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = GKGameCenterViewControllerState.default
        
        
        gcViewController.leaderboardIdentifier = "grp.levelModeBoard"
        
        self.show(gcViewController, sender: self)
        self.navigationController?.pushViewController(gcViewController, animated: true)
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func authenticateLocalPlayer() {
      let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                gcEnabled = true
                
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer: String?, error: NSError?) -> Void in
                    if error != nil {
                        print(error!)
                    } else {
                        gcDefaultLeaderBoard = leaderboardIdentifer!
                    }
                    } as? (String?, Error?) -> Void)
                
              self.getLeaderBoards(localPlayer: localPlayer)
            } else {
                gcEnabled = false
                print("Local player could not be authenticated, disabling game center")
                print(error!)
            }
            
        }
    }
  
  func getLeaderBoards(localPlayer: GKLocalPlayer)
  {
      let Defaults = UserDefaults.standard as UserDefaults?

      let leaderboard = GKLeaderboard(players: [localPlayer])
      leaderboard.identifier = "grp.survivalBoard"
      leaderboard.timeScope = .allTime
      leaderboard.loadScores(completionHandler: {
        (scores, error) in
        if ((Defaults?.integer(forKey: "SurvivalLevel"))! < Int(exactly: (scores?.first?.value)!)!)
        {
          Defaults?.set(scores?.first?.value, forKey: "SurvivalLevel")
        }
      })
  
      leaderboard.identifier = "grp.levelModeBoard"
      leaderboard.timeScope = .allTime
      leaderboard.loadScores(completionHandler: {
        (scores, error) in
        if ((Defaults?.integer(forKey: "HighLevelR"))! < Int(exactly: (scores?.first?.value)!)!)
        {
          Defaults?.set(scores?.first?.value, forKey: "HighLevelR")
        }
      })
  }
    
}


