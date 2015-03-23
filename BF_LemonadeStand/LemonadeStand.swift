//
//  LemonadeStand.swift
//  BF_LemonadeStand
//
//  Created by Bruce Walker on 3/22/15.
//  Copyright (c) 2015 Bruce D Walker. All rights reserved.
//

import Foundation
import UIKit

class LemonadeStand {

    // Class constants
    let kCostOfLemon = 2
    let kCostOfIce = 1
    let kMaxLemonsPerBatch = 3
    let kMaxIcePerBatch = 5
    let kGlassesPerBatch = 6
    let kLemonadeSalesPrice = 1
    let kAverageCustomersPerDay = 20

    // Class properties
    var nFunds:Int = 10
    var nLemons = 1
    var nIce = 2
    var nLemonsToBuy = 0
    var nIceToBuy = 0
    var nStoreCost = 0
    var nLemonsPerBatch = 0
    var nIcePerBatch = 0
    var nLemonadeStrength = 1.0
    var nGlassesAvailable = 0
    
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
        self.nLemonsToBuy = 0
        self.nIceToBuy = 0
        self.nStoreCost = 0
        
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
            if (lemondateIsAcidic())
            {
                strReport += "strong."
            }
            else if (lemondateIsEqual())
            {
                strReport += "balanced."
            }
            else
            {
                strReport += "weak."
            }
            strReport += "\r\n\r\n"

            // Prepare our first pitcher of lemonade
            nGlassesAvailable = 0 // We squeeze fresh, so wash out the pitcher from yesterday.
            if (makeLemonade())
            {
                nBatchesMade++
            }
            
            // Process our customers
            var customers: [Customer] = CustomerFactory.createCustomers(nCustomerCount)
            for cust in customers
            {
                if (nGlassesAvailable==0)
                {
                    // We ran out of lemonade, make more if we can
                    if (makeLemonade())
                    {
                        nBatchesMade++
                    }
                }

                // If we have lemonade, serve the customer
                if (nGlassesAvailable > 0)
                {
                    nCustomersServed++
                    
                    if ( (cust.prefersAcidic() && lemondateIsAcidic()) || (cust.prefersEqual() && lemondateIsEqual()) || (cust.prefersDilluted() && lemondateIsDilluted()) )
                    {
                        nCustomersPaid++
                        nGlassesAvailable--
                    }
                }
                else
                {
                    break
                }
            }

            // Determine our daily results
            nLemonsUsed = nBatchesMade * nLemonsPerBatch
            nIceUsed = nBatchesMade * nIcePerBatch
            nFundsEarned = nCustomersPaid * kLemonadeSalesPrice
            self.nFunds += nFundsEarned
            
            strReport += "You had \(nCustomerCount) customers today.\r\n"
            strReport += "You sold \(nCustomersPaid) glasses of lemonade.\r\n"
            strReport += "\(nCustomersServed - nCustomersPaid) customers did not like your mix.\r\n"
            strReport += "\(nCustomerCount - nCustomersServed) customers were turned away because you ran out of inventory.\r\n"
            strReport += "\r\n"
            strReport += "You made \(nBatchesMade) pitchers of lemonade using \(nLemonsUsed) lemons and \(nIceUsed) ice cubes."
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
        if ( nLemons == 0 && nFunds < kCostOfLemon )
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func addLemonToCart() -> Bool {
        if ( self.nFunds >= kCostOfLemon )
        {
            self.nLemonsToBuy++
            self.nStoreCost += kCostOfLemon
            self.nLemons++
            self.nFunds -= kCostOfLemon
            return true
        }
        else
        {
            return false
        }
    }
    
    func removeLemonFromCart() {
        if (self.nLemonsToBuy > 0)
        {
            self.nLemonsToBuy--
            self.nStoreCost -= kCostOfLemon
            self.nLemons--
            self.nFunds += kCostOfLemon
        }
    }

    func addIceToCart() -> Bool {
        if ( self.nFunds >= kCostOfIce )
        {
            self.nIceToBuy++
            self.nStoreCost += kCostOfIce
            self.nIce++
            self.nFunds -= kCostOfIce
            return true
        }
        else
        {
            return false
        }
    }

    func removeIceFromCart() {
        if (self.nIceToBuy > 0)
        {
            self.nIceToBuy--
            self.nStoreCost -= kCostOfIce
            self.nIce--
            self.nFunds += kCostOfIce
        }
    }
    
    func maxLemonsReached() -> Bool {
        return (self.nLemonsPerBatch >= self.kMaxLemonsPerBatch)
    }
    
    func addLemonToMix() -> Bool {
        if (!self.maxLemonsReached())
        {
            self.nLemonsPerBatch++
            self.updateMixStrength()
            return true
        }
        else
        {
            return false
        }
    }
    
    func removeLemonFromMix() {
        if ( self.nLemonsPerBatch > 0)
        {
            self.nLemonsPerBatch--
            self.updateMixStrength()
        }
    }
    
    func maxIceReached() -> Bool {
        return (self.nIcePerBatch >= self.kMaxIcePerBatch)
    }
    
    func addIceToMix() -> Bool {
        if (!self.maxIceReached())
        {
            self.nIcePerBatch++
            self.updateMixStrength()
            return true
        }
        else
        {
            return false
        }
    }
    
    func removeIceFromMix() {
        if ( self.nIcePerBatch > 0)
        {
            self.nIcePerBatch--
            self.updateMixStrength()
        }
    }

    func makeLemonade() -> Bool {
        if (haveInventoryForOneBatch())
        {
            // Adjust inventory for first batch
            nLemons -= nLemonsPerBatch
            nIce -= nIcePerBatch
            
            // Increase glasses available
            nGlassesAvailable += kGlassesPerBatch
            
            return true
        }
        else
        {
            return false
        }
    }
    
    func haveInventoryForOneBatch() -> Bool {
        return ( (self.nLemonsPerBatch <= self.nLemons) && (self.nIcePerBatch <= self.nIce) )
    }
    
    func updateMixStrength() {
        let kWaterPerBatch = self.kMaxLemonsPerBatch - self.nLemonsPerBatch
        if ((self.nIcePerBatch + kWaterPerBatch) > 0)
        {
            self.nLemonadeStrength = Double(self.nLemonsPerBatch) / Double(self.nIcePerBatch + kWaterPerBatch)
        }
        else
        {
            self.nLemonadeStrength = 2.0
        }
    }
    
    func lemondateIsAcidic() -> Bool {
        return (self.nLemonadeStrength > 1.33)
    }
    
    func lemondateIsEqual() -> Bool {
        return (self.nLemonadeStrength <= 1.33 && self.nLemonadeStrength >= 0.67)
    }
    
    func lemondateIsDilluted() -> Bool {
        return (self.nLemonadeStrength < 0.67)
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