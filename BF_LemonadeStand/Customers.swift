//
//  Customers.swift
//  BF_LemonadeStand
//
//  Created by Bruce Walker on 3/22/15.
//  Copyright (c) 2015 Bruce D Walker. All rights reserved.
//

import Foundation

struct Customer {

    var number:Int
    let strengthPreference:Float

    func prefersAcidic() -> Bool {
        return (strengthPreference >= 0.0 && strengthPreference <= 0.4)
    }
    
    func prefersEqual() -> Bool {
        return (strengthPreference > 0.4  && strengthPreference < 0.8)
    }
    
    func prefersDilluted() -> Bool {
        return (strengthPreference >= 0.8 && strengthPreference <= 1.0)
    }
    
}

class CustomerFactory {
    
    class func createCustomers(nCount: Int) -> [Customer] {
        var customers:[Customer] = []
        for (var n=1; n <= nCount; n++)
        {
            let kStrengthPreference = (Float(arc4random_uniform(UInt32(100))+1) / 100.0)
            var customer = Customer(number: n, strengthPreference: kStrengthPreference)
            customers.append(customer)
        }
        return customers
    }
}