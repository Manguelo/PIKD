//
//  colorLinesHelper.swift
//  Pop The Lock
//
//  Created by Mantelot on 7/2/18.
//  Copyright © 2018 Mantelot. All rights reserved.
//

import Foundation
import SpriteKit

extension menu {
     
    

    func setupLines(){
        var finish = false
        
        line1 = self.childNode(withName: "line1") as! SKSpriteNode
        line2 = self.childNode(withName: "line2") as! SKSpriteNode
        line3 = self.childNode(withName: "line3") as! SKSpriteNode
        
        var line1Hue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var line2Hue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var line3Hue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
        //var defaultLineColor = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
      
        line1Hue = randomHue + 0.11
        line2Hue = CGFloat(randomHue + 0.05)
        line3Hue = CGFloat(randomHue - 0.1)
        finish = true
      
        print(randomHue)
        print(randomHue)
        print(randomHue)
            
        line1.color = UIColor(hue: line1Hue, saturation: 0.44, brightness: 0.75, alpha: 1)
        line2.color = UIColor(hue: line2Hue, saturation: 0.44, brightness: 0.75, alpha: 1)
        line3.color = UIColor(hue: line3Hue, saturation: 0.44, brightness: 0.75, alpha: 1)

        
        print(CGFloat(line1Hue).distance(to: line2Hue))
        
    }
    
    func removeLines(){
        
    }
    
    
}
