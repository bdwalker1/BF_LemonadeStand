//
//  LemonadeStand.swift
//  BF_LemonadeStand
//
//  Created by Bruce Walker on 3/22/15.
//  Copyright (c) 2015 Bruce D Walker. All rights reserved.
//

import Foundation
import UIKit

struct LemonadeStand_Inventory {
    var funds: Int = 0
    var lemons: Int = 0
    var ice: Int = 0
    
    init( aFunds: Int, aLemons: Int, aIce: Int) {
        self.funds = aFunds
        self.lemons = aLemons
        self.ice = aIce
    }
}

struct LemonadeStand_ShoppingCart {
    let costOfLemon = 2
    let costOfIce = 1
    var lemons: Int = 0
    var ice: Int = 0
    var cost: Int = 0
}

struct LemonadeStand_Lemonade {
    let maxLemonsPerBatch: Int = 5
    let maxIcePerBatch: Int = 5
    let glassesPerBatch: Int = 6

    var lemonsPerBatch: Int = 0
    var icePerBatch: Int = 0
    var glassesAvailable: Int = 0
    var pricePerGlass: Int = 3
    
    func strength() -> Float {
        // For each lemon less than the maximum we need a unit of water to fill the pitcher
        let kWaterPerBatch = self.maxLemonsPerBatch - self.lemonsPerBatch
        
        // Without ice or water we will have very strong lemonade
        if ((self.icePerBatch + kWaterPerBatch) == 0)
        {
            return 2.0
        }
        // Strength will be the ratio of lemons to other ingredients
        else
        {
            return Float(self.lemonsPerBatch) / Float(self.icePerBatch + kWaterPerBatch)
        }
    }

    func tempFactor() -> Float {
        // Temperature will be the ratio of ice to max ice
        var fIceRatio: Float = Float(self.icePerBatch)/Float(self.maxIcePerBatch)
        
        return fIceRatio
    }
    
    func isCold() -> Bool {
        return (tempFactor() > 0.75)
    }
    
    func isCool() -> Bool {
        return (tempFactor() <= 0.75 && tempFactor() >= 0.25)
    }
    
    func isWarm() -> Bool {
        return (tempFactor() < 0.25)
    }
    
    func isAcidic() -> Bool {
        return (self.strength() > 1.33)
    }
    
    func isEqual() -> Bool {
        return (self.strength() <= 1.33 && self.strength() >= 0.67)
    }
    
    func isDilluted() -> Bool {
        return (self.strength() < 0.67)
    }

}

class LemonadeStand {

    // Class constants
    let kAverageCustomersPerDay = 20

    // Class properties
    var inventory = LemonadeStand_Inventory(aFunds: 10, aLemons: 1, aIce: 2)
    var cart = LemonadeStand_ShoppingCart()
    var lemonade = LemonadeStand_Lemonade()

    // Class functions
    init() {
        
    }

    func doBusiness(weatherDescription: String) -> UIView {
        
        // Local constants
        let kPaperColor = UIColor(red: 0.9, green: 0.9, blue: 0.7, alpha: 1.0)

        // Initialize report variable
        var strReport = ""
        var nCustomerCount: Int = 0
        var nWeatherAdjust: Int = 0
        var nCustomersServed: Int = 0
        var nCustomersPaid: Int = 0
        var nFundsEarned: Int = 0
        var nBatchesMade: Int = 0
        var nLemonsUsed: Int = 0
        var nIceUsed: Int = 0
        
        // Complete store purchase by resetting store values
        self.cart = LemonadeStand_ShoppingCart()
        
        // Generate customers
        nCustomerCount = Int( arc4random_uniform(UInt32(kAverageCustomersPerDay)) ) + 1
        nWeatherAdjust = Int( arc4random_uniform(UInt32(kAverageCustomersPerDay/3)) ) + 1
        
        switch (weatherDescription)
        {
        case ("Warm"):
            nCustomerCount += nWeatherAdjust
        case ("Cold"):
            nCustomerCount -= nWeatherAdjust
        default:
            nCustomerCount = nCustomerCount * 1
        }
        // Adjust customer count to zero if negative
        if (nCustomerCount < 0)
        {
            nCustomerCount = 0
        }
        
        if (!haveInventoryForOneBatch())
        {
            strReport += "You did not have enough inventory to even make one batch of lemonade.  Your lemonade stand was closed for the day.\r\n\r\n"
            strReport += "You lost out on \(nCustomerCount) potential customers."
        }
        else
        {
            strReport += "Weather for the day was \(weatherDescription). "
            strReport += "Your lemonade mix for the day was "
            if (self.lemonade.isAcidic())
            {
                strReport += "strong."
            }
            else if (self.lemonade.isEqual())
            {
                strReport += "balanced."
            }
            else
            {
                strReport += "weak."
            }
            strReport += "\r\n\r\n"

            // We squeeze fresh, so wash out the pitcher from yesterday.
            lemonade.glassesAvailable = 0
            
            // Process our customers
            var customers: [Customer] = CustomerFactory.createCustomers(nCustomerCount)
            for cust in customers
            {
                nCustomersServed++
                
                if ( ( (cust.prefersAcidic() && self.lemonade.isAcidic()) || (cust.prefersEqual() && self.lemonade.isEqual()) || (cust.prefersDilluted() && self.lemonade.isDilluted()) ) && ( (cust.prefersCold() && self.lemonade.isCold()) || (cust.prefersCool() && self.lemonade.isCool()) || (cust.prefersWarm() && self.lemonade.isWarm()) ) )
                {
                    if (lemonade.glassesAvailable==0)
                    {
                        // We ran out of lemonade, make more if we can
                        if (makeLemonade())
                        {
                            nBatchesMade++
                        }
                    }
                    
                    // If we have lemonade, serve the customer
                    if (lemonade.glassesAvailable > 0)
                    {
                        // Update our paid count and available glasses
                        nCustomersPaid++
                        self.lemonade.glassesAvailable--
                    }
                    else
                    {
                        break
                    }
                }
            }

            // Determine our daily results
            nLemonsUsed = nBatchesMade * self.lemonade.lemonsPerBatch
            nIceUsed = nBatchesMade * self.lemonade.icePerBatch
            nFundsEarned = nCustomersPaid * self.lemonade.pricePerGlass
            self.inventory.funds += nFundsEarned
            
            strReport += "You had \(nCustomerCount) customers today.\r\n"
            strReport += "You sold \(nCustomersPaid) glasses of lemonade.\r\n"
            strReport += "\(nCustomersServed - nCustomersPaid) customers did not like your mix.\r\n"
            strReport += "\(nCustomerCount - nCustomersServed) customers were turned away because you ran out of inventory.\r\n"
            strReport += "\r\n"
            var strPitchers = "\(nBatchesMade) pitcher"
            if (nBatchesMade != 1)
            {
                strPitchers += "s"
            }
            strReport += "You made \(strPitchers) of lemonade using \(nLemonsUsed) lemons and \(nIceUsed) ice cubes."
            strReport += "\r\n"
            strReport += "For selling \(nCustomersPaid) glasses of lemonade you earned $\(nFundsEarned)."
        }
        
        if (self.outOfBusiness())
        {
            strReport += "\r\n\r\n"
            strReport += "OUT OF BUSINESS"
            strReport += "\r\n"
            strReport += "You have run out of lemons and do not have enough to buy more. The game will be reset."
        }

        // Prepare report view to return
        var vwReport: UIView = UIView()
        vwReport.bounds.size.width = 300
        vwReport.bounds.size.height = 10
        vwReport.backgroundColor = UIColor.whiteColor()
        vwReport.layer.borderColor = UIColor.blackColor().CGColor
        vwReport.layer.borderWidth = 3.0
        var lblTitle: UILabel = UILabel()
        lblTitle.numberOfLines = 0
        lblTitle.text = "Daily Report"
        lblTitle.textAlignment = NSTextAlignment.Center
        lblTitle.font = UIFont(name: "HoeflerText-Black", size: 16.0)
        lblTitle.backgroundColor = kPaperColor
        lblTitle.sizeToFit()
        lblTitle.bounds.size.height = lblTitle.bounds.size.height * 2
        lblTitle.bounds.size.width = 250
        lblTitle.center = CGPoint(x: vwReport.bounds.size.width * 0.5, y: 10.0 + (lblTitle.frame.height * 0.5) )
        vwReport.bounds.size.height += lblTitle.bounds.size.height
        vwReport.addSubview(lblTitle)
        var lblReport: UIReportLabel = UIReportLabel(frame: CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: 250, height: 290)))
        lblReport.numberOfLines = 0
        var insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        lblReport.text = strReport
        lblReport.textAlignment = NSTextAlignment.Center
        lblReport.font = UIFont(name: "Helvetica", size: 13.0)
        lblReport.backgroundColor = kPaperColor
        lblReport.center.x = lblTitle.center.x
        lblReport.center.y = lblTitle.frame.maxY + lblReport.bounds.size.height * 0.5
        vwReport.bounds.size.height += lblReport.bounds.size.height
        vwReport.addSubview(lblReport)
        
        return vwReport
    }

    func outOfBusiness() -> Bool {

        // If we are out of lemons and don't have enough funds to buy more it's game over
        if ( inventory.lemons == 0 && inventory.funds < self.cart.costOfLemon )
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func addLemonToCart() -> Bool {
        if ( self.inventory.funds >= self.cart.costOfLemon )
        {
            self.cart.lemons++
            self.cart.cost += self.cart.costOfLemon
            self.inventory.lemons++
            self.inventory.funds -= self.cart.costOfLemon
            return true
        }
        else
        {
            return false
        }
    }
    
    func removeLemonFromCart() {
        if (self.cart.lemons > 0)
        {
            self.cart.lemons--
            self.cart.cost -= self.cart.costOfLemon
            self.inventory.lemons--
            self.inventory.funds += self.cart.costOfLemon
        }
    }

    func addIceToCart() -> Bool {
        if ( self.inventory.funds >= self.cart.costOfIce )
        {
            self.cart.ice++
            self.cart.cost += self.cart.costOfIce
            self.inventory.ice++
            self.inventory.funds -= self.cart.costOfIce
            return true
        }
        else
        {
            return false
        }
    }

    func removeIceFromCart() {
        if (self.cart.ice > 0)
        {
            self.cart.ice--
            self.cart.cost -= self.cart.costOfIce
            self.inventory.ice--
            self.inventory.funds += self.cart.costOfIce
        }
    }
    
    func maxLemonsReached() -> Bool {
        return (self.lemonade.lemonsPerBatch >= self.lemonade.maxLemonsPerBatch)
    }
    
    func addLemonToMix() -> Bool {
        if (!self.maxLemonsReached())
        {
            self.lemonade.lemonsPerBatch++
            return true
        }
        else
        {
            return false
        }
    }
    
    func removeLemonFromMix() {
        if ( self.lemonade.lemonsPerBatch > 0)
        {
            self.lemonade.lemonsPerBatch--
        }
    }
    
    func maxIceReached() -> Bool {
        return (self.lemonade.icePerBatch >= self.lemonade.maxIcePerBatch)
    }
    
    func addIceToMix() -> Bool {
        if (!self.maxIceReached())
        {
            self.lemonade.icePerBatch++
            return true
        }
        else
        {
            return false
        }
    }
    
    func removeIceFromMix() {
        if ( self.lemonade.icePerBatch > 0)
        {
            self.lemonade.icePerBatch--
        }
    }

    func makeLemonade() -> Bool {
        if (haveInventoryForOneBatch())
        {
            // Adjust inventory for first batch
            inventory.lemons -= self.lemonade.lemonsPerBatch
            inventory.ice -= self.lemonade.icePerBatch
            
            // Increase glasses available
            self.lemonade.glassesAvailable += self.lemonade.glassesPerBatch
            
            return true
        }
        else
        {
            return false
        }
    }
    
    func haveInventoryForOneBatch() -> Bool {
        return ( (self.lemonade.lemonsPerBatch <= self.inventory.lemons) && (self.lemonade.icePerBatch <= self.inventory.ice) )
    }
}

class UIReportLabel: UILabel {
    
    var topInset:       CGFloat = 0
    var rightInset:     CGFloat = 8
    var bottomInset:    CGFloat = 0
    var leftInset:      CGFloat = 8
    
    override func drawTextInRect(rect: CGRect) {
        var insets: UIEdgeInsets = UIEdgeInsets(top: self.topInset, left: self.leftInset, bottom: self.bottomInset, right: self.rightInset)
        self.setNeedsLayout()
        return super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
    
}