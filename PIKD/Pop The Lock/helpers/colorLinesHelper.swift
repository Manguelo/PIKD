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
        
        var defaultLineColor = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        //while finish != true {
            //if defaultLineColor <= 0.80 || defaultLineColor >= 0.20{
                line1Hue = defaultLineColor
                line2Hue = CGFloat(defaultLineColor + 0.2)
                line3Hue = CGFloat(defaultLineColor - 0.2)
                finish = true
           // }else{
             //   defaultLineColor = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            
            //            if abs(CGFloat(line1Hue).distance(to: line3Hue)) <= 0.1 && abs(CGFloat(line1Hue).distance(to: line3Hue)) >= 2{
            //                line1Hue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            //            }
            //            if abs(CGFloat(line2Hue).distance(to: line3Hue)) <= 0.1 && abs(CGFloat(line2Hue).distance(to: line3Hue)) >= 2{
            //                line3Hue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            //            }
           // }
            print(line1Hue)
            print(line2Hue)
            print(line3Hue)
       // }
            
            
            
        line1.color = UIColor(hue: defaultLineColor, saturation: 0.34, brightness: 0.8, alpha: 1)
        line2.color = UIColor(hue: line2Hue, saturation: 0.34, brightness: 0.8, alpha: 1)
        line3.color = UIColor(hue: line3Hue, saturation: 0.34, brightness: 0.8, alpha: 1)

        
        print(CGFloat(line1Hue).distance(to: line2Hue))
        
    }
    
    func removeLines(){
        
    }
    
    
}
