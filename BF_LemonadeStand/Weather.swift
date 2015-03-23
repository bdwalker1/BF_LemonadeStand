//
//  Weather.swift
//  BF_LemonadeStand
//
//  Created by Bruce Walker on 3/22/15.
//  Copyright (c) 2015 Bruce D Walker. All rights reserved.
//

import Foundation
import UIKit

class Weather {
    var outsideTemp: Int
    var description: String
    var image: UIImage!
    
    init () {
        outsideTemp = 70
        description = "Mild"
        image = UIImage(named: description)
    }
    
    func generateRandomWeather() {
        outsideTemp = 32 + Int(arc4random_uniform(UInt32(59)))
        var img: UIImage!
        if (outsideTemp < 40)
        {
            description = "Cold"
        }
        else if (outsideTemp > 80)
        {
            description = "Warm"
        }
        else
        {
            description = "Mild"
        }
        image = UIImage(named: description)
    }
    
    func isCold() -> Bool {
        return (self.description=="Cold")
    }
    
    func isMild() -> Bool {
        return (self.description=="Mild")
    }
    
    func isWarm() -> Bool {
        return (self.description=="Warm")
    }
    
}