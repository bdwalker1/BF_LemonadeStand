//
//  ViewController.swift
//  BF_LemonadeStand
//
//  Created by Bruce Walker on 3/20/15.
//  Copyright (c) 2015 Bruce D Walker. All rights reserved.
//

import UIKit
import iAd

class ViewController: UIViewController, ADBannerViewDelegate {
    
    // Constants
    let kEighth: CGFloat = 1.0 / 8.0
    let kSixth: CGFloat = 1.0 / 6.0
    let kFourth: CGFloat = 1.0 / 4.0
    let kThird: CGFloat = 1.0 / 3.0
    let kHalf: CGFloat = 1.0 / 2.0
    
    let kSectionGutter: CGFloat = 2.0
    
    let kLightYellow = UIColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 0.75)
    
    // Main view containers
    var viewTitle: UIView!
    var viewInventory: UIView!
    var viewStore: UIView!
    var viewWeather: UIView!
    var viewMix: UIView!
    var viewControl: UIView!
    var viewReportHolder: UIView!
    var viewDailyReport: UIView!
    
    // Title items
    var imgVwLogo: UIImageView!
    var lblTitle: UILabel!
    
    // Inventory items
    var lblInventoryTitle: UILabel!
    var imgVwFunds: UIImageView!
    var lblFunds: UILabel!
    var imgVwLemons: UIImageView!
    var lblLemons: UILabel!
    var imgVwIce: UIImageView!
    var lblIce: UILabel!
    
    // Store items
    var lblStoreTitle: UILabel!
    var imgVwStoreLemons: UIImageView!
    var lblStoreLemons: UILabel!
    var btnStoreAddLemon: UIButton!
    var btnStoreSubtractLemon: UIButton!
    var imgVwStoreIce: UIImageView!
    var lblStoreIce: UILabel!
    var btnStoreAddIce: UIButton!
    var btnStoreSubtractIce: UIButton!
    var imgVwStoreCost: UIImageView!
    var lblStoreCost: UILabel!
    
    // Weather items
    var lblWeatherTitle: UILabel!
    var lblWeatherTempTitle: UILabel!
    var lblWeatherTemp: UILabel!
    var imgVwWeatherPrecip: UIImageView!
    
    // Mix items
    var imgVwMixPitcher: UIImageView!
    var lblMixTitle: UILabel!
    var imgVwMixLemons: UIImageView!
    var lblMixLemons: UILabel!
    var btnMixAddLemon: UIButton!
    var btnMixSubtractLemon: UIButton!
    var imgVwMixIce: UIImageView!
    var lblMixIce: UILabel!
    var btnMixAddIce: UIButton!
    var btnMixSubtractIce: UIButton!
    var progMixStrength: UIProgressView!
    var lblMixStrong: UILabel!
    var lblMixWeak: UILabel!
    
    // Control items
    var btnDoBusiness: UIButton!
    
    // Variables
    var lemonadeStand = LemonadeStand()
    var weatherToday = Weather()
    
    // UIView functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.canDisplayBannerAds = true
        
        // Build our views
        self.setupContainerViews()
        self.setupTitleView(viewTitle)
        self.setupInventoryView(viewInventory)
        self.setupStoreView(viewStore)
        self.setupWeatherView(viewWeather)
        self.setupMixView(viewMix)
        self.setupControlView(viewControl)
        
        // Perform initial updates
        self.updateInventoryView()
        self.updateStoreView()
        self.updateMixView()
        
        // Setup initial weather
        weatherToday.generateRandomWeather()
        self.updateWeatherView()
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    override func supportedInterfaceOrientations() -> Int
    {
        // Restrict interface to portrait mode
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Action Functions
    
    func pressAddLemon(button: UIButton) {
        
        if ( lemonadeStand.addLemonToCart() )
        {
            self.updateStoreView()
        }
        else
        {
            self.showAlertWithText(header: "Insufficient Funds", message: "You do not have enough funds to buy another lemon.  Lemons cost $\(lemonadeStand.cart.costOfLemon) each.")
        }
    }
    
    func pressSubtractLemon(button: UIButton) {
        lemonadeStand.removeLemonFromCart()
        self.updateStoreView()
    }
    
    func pressAddIce(button: UIButton) {
        
        if ( lemonadeStand.addIceToCart() )
        {
            self.updateStoreView()
        }
        else
        {
            self.showAlertWithText(header: "Insufficient Funds", message: "You do not have enough funds to buy another lemon.  Lemons cost $\(lemonadeStand.cart.costOfLemon) each.")
        }
    }
    
    func pressSubtractIce(button: UIButton) {
        lemonadeStand.removeIceFromCart()
        self.updateStoreView()
    }
    
    func pressMixAddLemon(button: UIButton) {

        if (!lemonadeStand.maxLemonsReached())
        {
            lemonadeStand.addLemonToMix()
            self.updateMixView()
        }
        else
        {
            self.showAlertWithText(header: "Max Reached", message: "You can have a maximum of \(lemonadeStand.lemonade.maxLemonsPerBatch) lemons in each batch.")
        }
    }
    
    func pressMixSubtractLemon(button: UIButton) {
        lemonadeStand.removeLemonFromMix()
        self.updateMixView()
    }
    
    func pressMixAddIce(button: UIButton) {
        
        if (!lemonadeStand.maxIceReached())
        {
            lemonadeStand.addIceToMix()
            self.updateMixView()
        }
        else
        {
            self.showAlertWithText(header: "Max Reached", message: "You can have a maximum of \(lemonadeStand.lemonade.maxIcePerBatch) ice cubes in each batch.")
        }
    }
    
    func pressMixSubtractIce(button: UIButton) {
        lemonadeStand.removeIceFromMix()
        self.updateMixView()
    }
    
    func pressDoBusiness(button: UIButton) {
        
        if (lemonadeStand.lemonade.lemonsPerBatch <= 0)
        {
            showAlertWithText(header: "Doh!", message: "You cannot make lemonade without at least one lemon in the mix!")
        }
        else
        {
            viewReportHolder = UIView(frame: self.originalContentView.frame)
            viewReportHolder.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            viewDailyReport = lemonadeStand.doBusiness(weatherToday.description)
            viewDailyReport.center = self.originalContentView.center
            viewReportHolder.addSubview(viewDailyReport)
            self.scaleViewBasedOnSpecifiedOrigWidth(viewDailyReport, viewNewContainer: viewReportHolder, origWidth: 375.0)
//            var nAspectRatio: CGFloat = viewDailyReport.frame.height / viewDailyReport.frame.width
//            var scaleX = ( viewReportHolder.frame.width / viewDailyReport.frame.width) * (viewDailyReport.frame.width / 375.0)
//            var nNewWidth = viewDailyReport.frame.width * scaleX
//            var nNewHeight = nNewWidth * nAspectRatio
//            var scaleY = nNewHeight / viewDailyReport.frame.height
//            viewDailyReport.layer.transform = CATransform3DMakeScale( scaleX, scaleY, 1 )
            viewDailyReport.center = viewReportHolder.center
            self.originalContentView.addSubview(viewReportHolder)
            self.originalContentView.bringSubviewToFront(viewReportHolder)
            
            // Add close button to report
            var btnClose = UIButton()
            btnClose.setTitle("Close", forState: UIControlState.Normal)
            btnClose.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            btnClose.backgroundColor = UIColor.yellowColor()
            btnClose.sizeToFit()
            btnClose.bounds.size.width = btnClose.bounds.width * 1.5
            btnClose.layer.borderColor = UIColor.blackColor().CGColor
            btnClose.layer.borderWidth = 1.0
            viewDailyReport.bounds.size.height = viewDailyReport.bounds.size.height + btnClose.bounds.size.height * 1.5
            btnClose.center = CGPoint(x: viewDailyReport.bounds.size.width * kHalf, y: viewDailyReport.bounds.size.height - btnClose.bounds.size.height * 0.8 )
            btnClose.addTarget(self, action: "closeDailyReport:", forControlEvents: UIControlEvents.TouchUpInside)
            viewDailyReport.addSubview(btnClose)
            
            if (lemonadeStand.outOfBusiness())
            {
                lemonadeStand = LemonadeStand()
            }
            
        }

        // update our views
        updateInventoryView()
        updateStoreView()
    }
    
    // Helper Functions

    func scaleViewBasedOnSpecifiedOrigWidth(viewTarget: UIView, viewNewContainer: UIView, origWidth: CGFloat) {
        var nAspectRatio: CGFloat = viewTarget.frame.height / viewTarget.frame.width
        var scaleX = ( viewNewContainer.frame.width / viewTarget.frame.width) * (viewTarget.frame.width / origWidth)
        var nNewWidth = viewTarget.frame.width * scaleX
        var nNewHeight = nNewWidth * nAspectRatio
        var scaleY = nNewHeight / viewTarget.frame.height
        viewTarget.layer.transform = CATransform3DMakeScale( scaleX, scaleY, 1 )
    }
    
    func radiusButtonCorners(btn: UIButton, clrBorderColor: UIColor = UIColor.clearColor()) -> UIButton {
        btn.layer.cornerRadius = (btn.bounds.size.height * 0.25)
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = clrBorderColor.CGColor
        return btn
    }
    
    func closeDailyReport(button: UIButton) {
        
        // Close the daily report view
        viewReportHolder.removeFromSuperview()

        // Generate random weather for the new day
        weatherToday.generateRandomWeather()
        self.updateWeatherView()
    }
    
    func updateInventoryView() {
        self.lblFunds.text = "$\(lemonadeStand.inventory.funds)"
        self.lblLemons.text = "\(lemonadeStand.inventory.lemons)"
        self.lblIce.text = "\(lemonadeStand.inventory.ice)"
    }
    
    func updateStoreView() {
        self.lblStoreLemons.text = "\(lemonadeStand.cart.lemons)"
        self.lblStoreIce.text = "\(lemonadeStand.cart.ice)"
        self.lblStoreCost.text = "$\(lemonadeStand.cart.cost)"
        self.updateInventoryView()
    }
    
    func updateMixView() {
        self.lblMixLemons.text = "\(lemonadeStand.lemonade.lemonsPerBatch)"
        self.lblMixIce.text = "\(lemonadeStand.lemonade.icePerBatch)"
        self.progMixStrength.progress = Float(lemonadeStand.lemonade.strength()) / 2.0
    }

    func updateWeatherView() {
        var nTemp = self.weatherToday.outsideTemp
        self.lblWeatherTemp.text = "\(nTemp)°"
        self.imgVwWeatherPrecip.image = self.weatherToday.image
    }
    
    func degreesToRadians(x: CGFloat) -> CGFloat { return (CGFloat(M_PI) * x / 180.0) }

    func showAlertWithText(header: String = "Warning", message: String ) {
        var alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil )
    }
    
    // Setup Functions
    
    func setupContainerViews() {
        
        self.originalContentView.backgroundColor = UIColor.blackColor()
        
        // Setup title container
        self.viewTitle = UIView(frame: CGRect(x: self.originalContentView.bounds.origin.x, y: self.originalContentView.bounds.origin.y, width: self.originalContentView.bounds.width, height: self.originalContentView.bounds.height * kSixth))
        self.viewTitle.backgroundColor = UIColor.brownColor()
        self.originalContentView.addSubview(self.viewTitle)
        
        // Setup inventory container
        self.viewInventory = UIView(frame: CGRect(x: self.originalContentView.bounds.origin.x, y: self.viewTitle.frame.height, width: self.originalContentView.bounds.width * kHalf - (kSectionGutter / 2.0), height: self.originalContentView.bounds.height * kFourth))
        self.viewInventory.backgroundColor = UIColor.whiteColor()
        self.originalContentView.addSubview(self.viewInventory)
        
        // Setup store container
        self.viewStore = UIView(frame: CGRect(x: self.viewInventory.bounds.width + kSectionGutter, y: self.viewTitle.frame.height, width: self.originalContentView.bounds.width * kHalf - (kSectionGutter / 2.0), height: self.originalContentView.bounds.height * kFourth))
        self.viewStore.backgroundColor = UIColor.whiteColor()
        self.originalContentView.addSubview(self.viewStore)
        
        // Setup weather forecast container
        self.viewWeather = UIView(frame: CGRect(x: self.originalContentView.bounds.origin.x, y: self.viewInventory.frame.origin.y + self.viewInventory.frame.height, width: self.originalContentView.bounds.width, height: self.originalContentView.bounds.height * kSixth))
        self.viewWeather.backgroundColor = UIColor.whiteColor()
        self.viewWeather.layer.borderColor = UIColor.blackColor().CGColor
        self.viewWeather.layer.borderWidth = 2.0
        self.originalContentView.addSubview(self.viewWeather)
        
        // Setup lemonade mixing container
        self.viewMix = UIView(frame: CGRect(x: self.originalContentView.bounds.origin.x, y: self.viewWeather.frame.origin.y + self.viewWeather.frame.height, width: self.originalContentView.bounds.width, height: self.originalContentView.bounds.height * kFourth))
        self.viewMix.backgroundColor = UIColor.whiteColor() // UIColor(red: 1.0, green: 1.0, blue: 0.3, alpha: 1.0)
        self.originalContentView.addSubview(self.viewMix)
        
        // Setup the control container
        self.viewControl = UIView(frame: CGRect(x: self.originalContentView.bounds.origin.x, y: self.viewMix.frame.origin.y + self.viewMix.frame.height, width: self.originalContentView.bounds.width, height: self.originalContentView.bounds.height * kSixth))
        self.viewControl.backgroundColor = UIColor.brownColor()
        self.originalContentView.addSubview(self.viewControl)
    }
    
    func setupTitleView(viewContainer: UIView) {
        // Set title font size based on container height
        let kTitleFontSize = (viewContainer.frame.height * 0.27)
        
        // Setup Logo
        self.imgVwLogo = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: viewContainer.frame.height, height: viewContainer.frame.height))
        self.imgVwLogo.image = UIImage(named: "Stand")
        self.imgVwLogo.contentMode = UIViewContentMode.ScaleAspectFit
        viewContainer.addSubview(self.imgVwLogo)
       
        // Setup title
        self.lblTitle = UILabel()
        self.lblTitle.numberOfLines = 0
        self.lblTitle.text = "Lemonade\r\nStand"
        self.lblTitle.textAlignment = NSTextAlignment.Center
        self.lblTitle.textColor = UIColor.yellowColor()
        self.lblTitle.font = UIFont(name: "Noteworthy-Bold", size: kTitleFontSize)
        self.lblTitle.sizeToFit()
        self.lblTitle.center = CGPoint(x: self.imgVwLogo.frame.width + (viewContainer.frame.width - self.imgVwLogo.frame.width) * kHalf, y: viewContainer.frame.height * kHalf)
        viewContainer.addSubview(self.lblTitle)
    }

    func setupInventoryView(viewContainer: UIView) {
        
        // Set font sizes based on container height
        let kTitleFontSize = (viewContainer.frame.height * 0.15)
        let kLabelFontSize = (viewContainer.frame.height * 0.13)
        
        // Setup section title
        self.lblInventoryTitle = UILabel()
        self.lblInventoryTitle.text = "Inventory"
        self.lblInventoryTitle.textAlignment = NSTextAlignment.Center
        self.lblInventoryTitle.textColor = UIColor.whiteColor()
        self.lblInventoryTitle.backgroundColor = UIColor.darkGrayColor()
        self.lblInventoryTitle.font = UIFont(name: "AmericanTypewriter", size: kTitleFontSize)
        self.lblInventoryTitle.sizeToFit()
        self.lblInventoryTitle.bounds.size.width = viewContainer.frame.width
        self.lblInventoryTitle.bounds.size.height = self.lblInventoryTitle.frame.height * 1.1
        self.lblInventoryTitle.center = CGPoint(x: viewContainer.frame.width * kHalf, y: self.lblInventoryTitle.frame.height * kHalf)
        viewContainer.addSubview(self.lblInventoryTitle)
        
        // Setup funds icon
        self.imgVwFunds = UIImageView()
        self.imgVwFunds.image = UIImage(named: "Coins")
        self.imgVwFunds.contentMode = UIViewContentMode.ScaleAspectFit
        self.imgVwFunds.frame = CGRect(x: 10.0, y: self.lblInventoryTitle.frame.height * 1.1, width: (viewContainer.frame.height - self.lblInventoryTitle.frame.height) * kFourth, height: (viewContainer.frame.height - self.lblInventoryTitle.frame.height) * kFourth)
        viewContainer.addSubview(self.imgVwFunds)
        
        // Setup lemons icon
        self.imgVwLemons = UIImageView()
        self.imgVwLemons.image = UIImage(named: "Lemon")
        self.imgVwLemons.contentMode = UIViewContentMode.ScaleAspectFit
        self.imgVwLemons.frame = CGRect(x: self.imgVwFunds.frame.origin.x, y: self.imgVwFunds.frame.origin.y + ((viewContainer.frame.height-self.lblInventoryTitle.frame.height) * kThird), width: (viewContainer.frame.height - self.lblInventoryTitle.frame.height) * kFourth, height: (viewContainer.frame.height - self.lblInventoryTitle.frame.height) * kFourth)
        viewContainer.addSubview(self.imgVwLemons)
        
        // Setup ice icon
        self.imgVwIce = UIImageView()
        self.imgVwIce.image = UIImage(named: "IceCube")
        self.imgVwIce.contentMode = UIViewContentMode.ScaleAspectFit
        self.imgVwIce.frame = CGRect(x: self.imgVwLemons.frame.origin.x, y: self.imgVwLemons.frame.origin.y + ((viewContainer.frame.height-self.lblInventoryTitle.frame.height) * kThird), width: (viewContainer.frame.height - self.lblInventoryTitle.frame.height) * kFourth, height: (viewContainer.frame.height - self.lblInventoryTitle.frame.height) * kFourth)
        viewContainer.addSubview(self.imgVwIce)
        
        // Setup funds label
        self.lblFunds = UILabel()
        self.lblFunds.text = "$\(999999)"
        self.lblFunds.textAlignment = NSTextAlignment.Center
        self.lblFunds.textColor = UIColor.blackColor()
        self.lblFunds.font = UIFont(name: "AmericanTypewriter", size: kLabelFontSize)
        self.lblFunds.sizeToFit()
        self.lblFunds.center = CGPoint(x: viewContainer.frame.width * kHalf + self.imgVwFunds.frame.width * kHalf, y: self.imgVwFunds.frame.midY)
        viewContainer.addSubview(self.lblFunds)
        
        // Setup lemons label
        self.lblLemons = UILabel()
        self.lblLemons.text = "0000"
        self.lblLemons.textAlignment = NSTextAlignment.Center
        self.lblLemons.textColor = UIColor.blackColor()
        self.lblLemons.font = UIFont(name: "AmericanTypewriter", size: kLabelFontSize)
        self.lblLemons.sizeToFit()
        self.lblLemons.center = CGPoint(x: viewContainer.frame.width * kHalf + self.imgVwLemons.frame.width * kHalf, y: self.imgVwLemons.frame.midY)
        viewContainer.addSubview(self.lblLemons)
        
        // Setup ice label
        self.lblIce = UILabel()
        self.lblIce.text = "0000"
        self.lblIce.textAlignment = NSTextAlignment.Center
        self.lblIce.textColor = UIColor.blackColor()
        self.lblIce.font = UIFont(name: "AmericanTypewriter", size: kLabelFontSize)
        self.lblIce.sizeToFit()
        self.lblIce.center = CGPoint(x: viewContainer.frame.width * kHalf + self.imgVwIce.frame.width * kHalf, y: self.imgVwIce.frame.midY)
        viewContainer.addSubview(self.lblIce)
        
    }

    func setupStoreView(viewContainer: UIView) {
        
        // Set font sizes based on container height
        let kTitleFontSize = (viewContainer.frame.height * 0.15)
        let kLabelFontSize = (viewContainer.frame.height * 0.13)
        let kAddSubButtonFontSize = (viewContainer.frame.height * 0.14)
        
        // Setup section title
        self.lblStoreTitle = UILabel()
        self.lblStoreTitle.text = "Store"
        self.lblStoreTitle.textAlignment = NSTextAlignment.Center
        self.lblStoreTitle.textColor = UIColor.whiteColor()
        self.lblStoreTitle.backgroundColor = UIColor.darkGrayColor()
        self.lblStoreTitle.font = UIFont(name: "AmericanTypewriter", size: kTitleFontSize)
        self.lblStoreTitle.sizeToFit()
        self.lblStoreTitle.bounds.size.width = viewContainer.frame.width
        self.lblStoreTitle.bounds.size.height = self.lblStoreTitle.frame.height * 1.1
        self.lblStoreTitle.center = CGPoint(x: viewContainer.frame.width * kHalf, y: self.lblStoreTitle.frame.height * kHalf)
        viewContainer.addSubview(self.lblStoreTitle)
        
        // Setup lemons icon
        self.imgVwStoreLemons = UIImageView()
        self.imgVwStoreLemons.image = UIImage(named: "Lemon")
        self.imgVwStoreLemons.contentMode = UIViewContentMode.ScaleAspectFit
        self.imgVwStoreLemons.frame = CGRect(x: 10.0, y: self.lblStoreTitle.frame.height * 1.1, width: (viewContainer.frame.height - self.lblStoreTitle.frame.height) * kFourth, height: (viewContainer.frame.height - self.lblStoreTitle.frame.height) * kFourth)
        viewContainer.addSubview(self.imgVwStoreLemons)
        
        // Setup ice icon
        self.imgVwStoreIce = UIImageView()
        self.imgVwStoreIce.image = UIImage(named: "IceCube")
        self.imgVwStoreIce.contentMode = UIViewContentMode.ScaleAspectFit
        self.imgVwStoreIce.frame = CGRect(x: self.imgVwStoreLemons.frame.origin.x, y: self.imgVwStoreLemons.frame.origin.y + ((viewContainer.frame.height-self.lblStoreTitle.frame.height) * kThird), width: (viewContainer.frame.height - self.lblStoreTitle.frame.height) * kFourth, height: (viewContainer.frame.height - self.lblStoreTitle.frame.height) * kFourth)
        viewContainer.addSubview(self.imgVwStoreIce)
        
        // Setup cost icon
        self.imgVwStoreCost = UIImageView()
        self.imgVwStoreCost.image = UIImage(named: "Receipt")
        self.imgVwStoreCost.contentMode = UIViewContentMode.ScaleAspectFit
        self.imgVwStoreCost.frame = CGRect(x: self.imgVwStoreIce.frame.origin.x, y: self.imgVwStoreIce.frame.origin.y + ((viewContainer.frame.height-self.lblStoreTitle.frame.height) * kThird), width: (viewContainer.frame.height - self.lblStoreTitle.frame.height) * kFourth, height: (viewContainer.frame.height - self.lblStoreTitle.frame.height) * kFourth)
        viewContainer.addSubview(self.imgVwStoreCost)
        
        // Setup lemons label
        self.lblStoreLemons = UILabel()
        self.lblStoreLemons.text = "000"
        self.lblStoreLemons.textAlignment = NSTextAlignment.Center
        self.lblStoreLemons.textColor = UIColor.blackColor()
        self.lblStoreLemons.font = UIFont(name: "AmericanTypewriter", size: kLabelFontSize)
        self.lblStoreLemons.sizeToFit()
        self.lblStoreLemons.center = CGPoint(x: viewContainer.frame.width * kHalf + self.imgVwStoreLemons.frame.width * kHalf, y: self.imgVwStoreLemons.frame.midY)
        viewContainer.addSubview(self.lblStoreLemons)
        
        // Setup add lemon button
        self.btnStoreAddLemon = UIButton()
        self.btnStoreAddLemon.setTitle("+", forState: UIControlState.Normal)
        self.btnStoreAddLemon.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.btnStoreAddLemon.backgroundColor = kLightYellow
        self.btnStoreAddLemon.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: kAddSubButtonFontSize)
        self.btnStoreAddLemon.sizeToFit()
        self.btnStoreAddLemon.bounds.size.height = self.btnStoreAddLemon.frame.width
        self.btnStoreAddLemon.center = CGPoint(x: self.lblStoreLemons.frame.maxX + (self.btnStoreAddLemon.frame.width * 0.75), y: self.imgVwStoreLemons.frame.midY)
        self.btnStoreAddLemon.addTarget(self, action: "pressAddLemon:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnStoreAddLemon = radiusButtonCorners( self.btnStoreAddLemon )
        viewContainer.addSubview(self.btnStoreAddLemon)
        
        // Setup subtract lemon button
        self.btnStoreSubtractLemon = UIButton()
        self.btnStoreSubtractLemon.setTitle("—", forState: UIControlState.Normal)
        self.btnStoreSubtractLemon.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.btnStoreSubtractLemon.backgroundColor = kLightYellow
        self.btnStoreSubtractLemon.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: kAddSubButtonFontSize)
        self.btnStoreSubtractLemon.sizeToFit()
        self.btnStoreSubtractLemon.bounds.size.height = self.btnStoreAddLemon.frame.width
        self.btnStoreSubtractLemon.bounds.size.width = self.btnStoreAddLemon.frame.width
        self.btnStoreSubtractLemon.center = CGPoint(x: self.lblStoreLemons.frame.minX - (self.btnStoreSubtractLemon.frame.width * 0.75), y: self.imgVwStoreLemons.frame.midY)
        self.btnStoreSubtractLemon.addTarget(self, action: "pressSubtractLemon:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnStoreSubtractLemon = radiusButtonCorners( self.btnStoreSubtractLemon )
        viewContainer.addSubview(self.btnStoreSubtractLemon)
        
        // Setup ice label
        self.lblStoreIce = UILabel()
        self.lblStoreIce.text = "000"
        self.lblStoreIce.textAlignment = NSTextAlignment.Center
        self.lblStoreIce.textColor = UIColor.blackColor()
        self.lblStoreIce.font = UIFont(name: "AmericanTypewriter", size: kLabelFontSize)
        self.lblStoreIce.sizeToFit()
        self.lblStoreIce.center = CGPoint(x: viewContainer.frame.width * kHalf + self.imgVwStoreIce.frame.width * kHalf, y: self.imgVwStoreIce.frame.midY)
        viewContainer.addSubview(self.lblStoreIce)
        
        // Setup add ice button
        self.btnStoreAddIce = UIButton()
        self.btnStoreAddIce.setTitle("+", forState: UIControlState.Normal)
        self.btnStoreAddIce.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.btnStoreAddIce.backgroundColor = kLightYellow
        self.btnStoreAddIce.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: kAddSubButtonFontSize)
        self.btnStoreAddIce.sizeToFit()
        self.btnStoreAddIce.bounds.size.height = self.btnStoreAddIce.frame.width
        self.btnStoreAddIce.center = CGPoint(x: self.lblStoreIce.frame.maxX + (self.btnStoreAddIce.frame.width * 0.75), y: self.imgVwStoreIce.frame.midY)
        self.btnStoreAddIce.addTarget(self, action: "pressAddIce:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnStoreAddIce = radiusButtonCorners( self.btnStoreAddIce )
        viewContainer.addSubview(self.btnStoreAddIce)
        
        // Setup subtract ice button
        self.btnStoreSubtractIce = UIButton()
        self.btnStoreSubtractIce.setTitle("—", forState: UIControlState.Normal)
        self.btnStoreSubtractIce.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.btnStoreSubtractIce.backgroundColor = kLightYellow
        self.btnStoreSubtractIce.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: kAddSubButtonFontSize)
        self.btnStoreSubtractIce.sizeToFit()
        self.btnStoreSubtractIce.bounds.size.height = self.btnStoreAddIce.frame.width
        self.btnStoreSubtractIce.bounds.size.width = self.btnStoreAddIce.frame.width
        self.btnStoreSubtractIce.center = CGPoint(x: self.lblStoreIce.frame.minX - (self.btnStoreSubtractIce.frame.width * 0.75), y: self.imgVwStoreIce.frame.midY)
        self.btnStoreSubtractIce.addTarget(self, action: "pressSubtractIce:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnStoreSubtractIce = radiusButtonCorners( self.btnStoreSubtractIce )
       viewContainer.addSubview(self.btnStoreSubtractIce)
        
        // Setup cost label
        self.lblStoreCost = UILabel()
        self.lblStoreCost.text = "$\(999)"
        self.lblStoreCost.textAlignment = NSTextAlignment.Center
        self.lblStoreCost.textColor = UIColor.blackColor()
        self.lblStoreCost.font = UIFont(name: "AmericanTypewriter", size: kLabelFontSize)
        self.lblStoreCost.sizeToFit()
        self.lblStoreCost.center = CGPoint(x: viewContainer.frame.width * kHalf + self.imgVwStoreCost.frame.width * kHalf, y: self.imgVwStoreCost.frame.midY)
        viewContainer.addSubview(self.lblStoreCost)
        
    }

    func setupWeatherView(viewContainer: UIView) {

        // Set font sizes based on container height
        let kTitleFontSize = (viewContainer.frame.height * 0.16)
        let kLabelFontSize = (viewContainer.frame.height * 0.14)
        let kTempFontSize = (viewContainer.frame.height * 0.40)
        
        // Setup title
        self.lblWeatherTitle = UILabel()
        self.lblWeatherTitle.text = "Today's Weather Forecast"
        self.lblWeatherTitle.textAlignment = NSTextAlignment.Center
        self.lblWeatherTitle.textColor = UIColor.blackColor()
        self.lblWeatherTitle.font = UIFont(name: "AmericanTypewriter", size: kTitleFontSize)
        self.lblWeatherTitle.sizeToFit()
        self.lblWeatherTitle.center = CGPoint(x: viewContainer.frame.width * kHalf, y: self.lblWeatherTitle.frame.height * kHalf + 2.0)
        viewContainer.addSubview(self.lblWeatherTitle)

        // Setup weather image view
        self.imgVwWeatherPrecip = UIImageView()
        self.imgVwWeatherPrecip.image = UIImage(named: "Mild")
        self.imgVwWeatherPrecip.backgroundColor = UIColor.clearColor()
        self.imgVwWeatherPrecip.contentMode = UIViewContentMode.ScaleAspectFit
        self.imgVwWeatherPrecip.frame = CGRect(x: viewContainer.frame.width * kSixth, y: self.lblWeatherTitle.frame.origin.y + self.lblWeatherTitle.frame.height + 10.0, width: viewContainer.frame.height - self.lblWeatherTitle.frame.height - 22.0, height: viewContainer.frame.height - self.lblWeatherTitle.frame.height - 22.0)
        viewContainer.addSubview(self.imgVwWeatherPrecip)
        
        // Setup temperature title
        self.lblWeatherTempTitle = UILabel()
        self.lblWeatherTempTitle.text = "Temperature"
        self.lblWeatherTempTitle.textAlignment = NSTextAlignment.Center
        self.lblWeatherTempTitle.textColor = UIColor.blackColor()
        self.lblWeatherTempTitle.font = UIFont(name: "AmericanTypewriter", size: kLabelFontSize)
        self.lblWeatherTempTitle.sizeToFit()
        self.lblWeatherTempTitle.center = CGPoint(x: viewContainer.frame.midX + self.imgVwWeatherPrecip.frame.midX * kHalf, y: self.imgVwWeatherPrecip.frame.origin.y + self.lblWeatherTempTitle.frame.height * (2.0 * kThird))
        viewContainer.addSubview(self.lblWeatherTempTitle)

        // Setup temperature label
        self.lblWeatherTemp = UILabel()
        self.lblWeatherTemp.text = "72°"
        self.lblWeatherTemp.textAlignment = NSTextAlignment.Center
        self.lblWeatherTemp.textColor = UIColor.blackColor()
        self.lblWeatherTemp.font = UIFont(name: "Copperplate-Bold", size: kTempFontSize)
        self.lblWeatherTemp.sizeToFit()
        self.lblWeatherTemp.center = CGPoint(x: self.lblWeatherTempTitle.frame.midX + 3.0, y: self.imgVwWeatherPrecip.frame.maxY - self.lblWeatherTemp.frame.height * kHalf)
        viewContainer.addSubview(self.lblWeatherTemp)
    }

    func setupMixView(viewContainer: UIView) {
        // Set title font size based on container height
        let kTitleFontSize = (viewContainer.frame.height * 0.15)
        let kLabelFontSize = (viewContainer.frame.height * 0.14)
        let kAddSubButtonFontSize = (viewContainer.frame.height * 0.16)

        // Setup title
        self.lblMixTitle = UILabel()
        self.lblMixTitle.text = "Today's Lemonade Mix"
        self.lblMixTitle.textAlignment = NSTextAlignment.Center
        self.lblMixTitle.textColor = UIColor.blackColor()
        self.lblMixTitle.font = UIFont(name: "AmericanTypewriter", size: kTitleFontSize)
        self.lblMixTitle.sizeToFit()
        self.lblMixTitle.center = CGPoint(x: viewContainer.frame.width * kHalf, y: (self.lblMixTitle.frame.height * kHalf) + 2.0)
        viewContainer.addSubview(self.lblMixTitle)
        
        // Setup pitcher image
        self.imgVwMixPitcher = UIImageView()
        self.imgVwMixPitcher.image = UIImage(named: "Lemonade")
        self.imgVwMixPitcher.contentMode = UIViewContentMode.ScaleAspectFit
        self.imgVwMixPitcher.bounds.size.height = viewContainer.frame.height * kHalf
        self.imgVwMixPitcher.bounds.size.width = self.imgVwMixPitcher.bounds.size.height
        self.imgVwMixPitcher.center = CGPoint(x: viewContainer.frame.height * kThird, y: (viewContainer.frame.height * kHalf) + (self.lblMixTitle.bounds.maxY * kHalf))
        viewContainer.addSubview(self.imgVwMixPitcher)
        
        // Setup strong label
        self.lblMixStrong = UILabel()
        self.lblMixStrong.text = "Strong"
        self.lblMixStrong.textColor = UIColor.blackColor()
        self.lblMixStrong.textAlignment = NSTextAlignment.Center
        self.lblMixStrong.font = UIFont(name: "AmericanTypewriter", size: kLabelFontSize)
        self.lblMixStrong.sizeToFit()
        self.lblMixStrong.center = CGPoint(x: viewContainer.frame.width - self.lblMixStrong.frame.width, y: self.lblMixStrong.bounds.maxY + self.lblMixStrong.frame.height )
        viewContainer.addSubview(self.lblMixStrong)
        
        // Setup strength bar
        self.progMixStrength = UIProgressView()
        self.progMixStrength.progress = 0.5
        self.progMixStrength.bounds.size.width = viewContainer.frame.height * kThird
        self.progMixStrength.bounds.size.height = 10.0
        self.progMixStrength.center = CGPoint(x: self.lblMixStrong.center.x, y: (self.lblMixStrong.center.y + (self.lblMixStrong.frame.height * 0.6)) + (self.progMixStrength.frame.width * kHalf))
        self.progMixStrength.transform = CGAffineTransformMakeScale(6.0, 1.0)
        self.progMixStrength.transform = CGAffineTransformRotate(self.progMixStrength.transform, degreesToRadians(270))
        viewContainer.addSubview(self.progMixStrength)
        
        // Setup weak label
        self.lblMixWeak = UILabel()
        self.lblMixWeak.text = "Weak"
        self.lblMixWeak.textColor = UIColor.blackColor()
        self.lblMixWeak.textAlignment = NSTextAlignment.Center
        self.lblMixWeak.font = UIFont(name: "AmericanTypewriter", size: kLabelFontSize)
        self.lblMixWeak.sizeToFit()
        self.lblMixWeak.center = CGPoint(x: self.lblMixStrong.center.x, y: self.progMixStrength.center.y + (self.progMixStrength.frame.height * kHalf) + (self.lblMixWeak.frame.height * 0.6) )
        viewContainer.addSubview(self.lblMixWeak)
        
        // Setup lemons label
        self.lblMixLemons = UILabel()
        self.lblMixLemons.text = "000"
        self.lblMixLemons.textAlignment = NSTextAlignment.Center
        self.lblMixLemons.textColor = UIColor.blackColor()
        self.lblMixLemons.font = UIFont(name: "AmericanTypewriter", size: kLabelFontSize)
        self.lblMixLemons.sizeToFit()
        self.lblMixLemons.center = CGPoint(x: viewContainer.frame.width * kHalf, y: self.lblMixTitle.bounds.maxY + ((viewContainer.frame.height - self.lblMixTitle.bounds.maxY) * kThird))
        viewContainer.addSubview(self.lblMixLemons)
        
        // Setup lemons icon
        self.imgVwMixLemons = UIImageView()
        self.imgVwMixLemons.image = UIImage(named: "Lemon")
        self.imgVwMixLemons.contentMode = UIViewContentMode.ScaleAspectFit
        self.imgVwMixLemons.bounds.size = CGSize(width: (viewContainer.frame.height - self.lblMixTitle.frame.maxY) * kFourth, height: (viewContainer.frame.height - self.lblMixTitle.frame.maxY) * kFourth)
        self.imgVwMixLemons.center = self.lblMixLemons.center
        self.imgVwMixLemons.alpha = CGFloat(0.4)
        viewContainer.addSubview(self.imgVwMixLemons)
        viewContainer.sendSubviewToBack(self.imgVwMixLemons)
        
        // Setup add lemon button
        self.btnMixAddLemon = UIButton()
        self.btnMixAddLemon.setTitle("+", forState: UIControlState.Normal)
        self.btnMixAddLemon.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.btnMixAddLemon.backgroundColor = kLightYellow
        self.btnMixAddLemon.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: kAddSubButtonFontSize)
        self.btnMixAddLemon.sizeToFit()
        self.btnMixAddLemon.bounds.size.height = self.btnMixAddLemon.frame.width
        self.btnMixAddLemon.center = CGPoint(x: self.lblMixLemons.frame.maxX + (self.btnMixAddLemon.frame.width * 0.75), y: self.lblMixLemons.center.y)
        self.btnMixAddLemon.addTarget(self, action: "pressMixAddLemon:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnMixAddLemon = radiusButtonCorners( self.btnMixAddLemon )
        viewContainer.addSubview(self.btnMixAddLemon)
        
        // Setup subtract lemon button
        self.btnMixSubtractLemon = UIButton()
        self.btnMixSubtractLemon.setTitle("—", forState: UIControlState.Normal)
        self.btnMixSubtractLemon.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.btnMixSubtractLemon.backgroundColor = kLightYellow
        self.btnMixSubtractLemon.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: kAddSubButtonFontSize)
        self.btnMixSubtractLemon.sizeToFit()
        self.btnMixSubtractLemon.bounds.size.height = self.btnMixAddLemon.frame.width
        self.btnMixSubtractLemon.center = CGPoint(x: self.lblMixLemons.frame.minX - (self.btnMixSubtractLemon.frame.width * 0.75), y: self.lblMixLemons.center.y)
        self.btnMixSubtractLemon.addTarget(self, action: "pressMixSubtractLemon:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnMixSubtractLemon = radiusButtonCorners( self.btnMixSubtractLemon )
        viewContainer.addSubview(self.btnMixSubtractLemon)
        
        // Setup ice label
        self.lblMixIce = UILabel()
        self.lblMixIce.text = "000"
        self.lblMixIce.textAlignment = NSTextAlignment.Center
        self.lblMixIce.textColor = UIColor.blackColor()
        self.lblMixIce.font = UIFont(name: "AmericanTypewriter", size: kLabelFontSize)
        self.lblMixIce.sizeToFit()
        self.lblMixIce.center = CGPoint(x: viewContainer.frame.width * kHalf, y: self.lblMixTitle.bounds.maxY + ((viewContainer.frame.height - self.lblMixTitle.bounds.maxY) * (2.0 * kThird)))
        viewContainer.addSubview(self.lblMixIce)
        
        // Setup ice icon
        self.imgVwMixIce = UIImageView()
        self.imgVwMixIce.image = UIImage(named: "IceCube")
        self.imgVwMixIce.contentMode = UIViewContentMode.ScaleAspectFit
        self.imgVwMixIce.bounds.size = CGSize(width: (viewContainer.frame.height - self.lblMixTitle.frame.maxY) * kFourth, height: (viewContainer.frame.height - self.lblMixTitle.frame.maxY) * kFourth)
        self.imgVwMixIce.center = self.lblMixIce.center
        self.imgVwMixIce.alpha = CGFloat(0.5)
        viewContainer.addSubview(self.imgVwMixIce)
        viewContainer.sendSubviewToBack(self.imgVwMixIce)
        
        // Setup add ice button
        self.btnMixAddIce = UIButton()
        self.btnMixAddIce.setTitle("+", forState: UIControlState.Normal)
        self.btnMixAddIce.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.btnMixAddIce.backgroundColor = kLightYellow
        self.btnMixAddIce.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: kAddSubButtonFontSize)
        self.btnMixAddIce.sizeToFit()
        self.btnMixAddIce.bounds.size.height = self.btnMixAddIce.frame.width
        self.btnMixAddIce.center = CGPoint(x: self.lblMixIce.frame.maxX + (self.btnMixAddIce.frame.width * 0.75), y: self.lblMixIce.center.y)
        self.btnMixAddIce.addTarget(self, action: "pressMixAddIce:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnMixAddIce = radiusButtonCorners( self.btnMixAddIce )
        viewContainer.addSubview(self.btnMixAddIce)
        
        // Setup subtract ice button
        self.btnMixSubtractIce = UIButton()
        self.btnMixSubtractIce.setTitle("—", forState: UIControlState.Normal)
        self.btnMixSubtractIce.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.btnMixSubtractIce.backgroundColor = kLightYellow
        self.btnMixSubtractIce.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: kAddSubButtonFontSize)
        self.btnMixSubtractIce.sizeToFit()
        self.btnMixSubtractIce.bounds.size.height = self.btnMixSubtractIce.frame.width
        self.btnMixSubtractIce.center = CGPoint(x: self.lblMixIce.frame.minX - (self.btnMixSubtractIce.frame.width * 0.75), y: self.lblMixIce.center.y)
        self.btnMixSubtractIce.addTarget(self, action: "pressMixSubtractIce:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnMixSubtractIce = radiusButtonCorners( self.btnMixSubtractIce )
        viewContainer.addSubview(self.btnMixSubtractIce)
    }
    
    func setupControlView(viewContainer: UIView) {
        // Set title font size based on container height
       let kControlButtonFontSize = (viewContainer.frame.height * 0.16)
        
        // Setup DoBusiness button
        self.btnDoBusiness = UIButton()
        self.btnDoBusiness.setTitle("Open For Business", forState: UIControlState.Normal)
        self.btnDoBusiness.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.btnDoBusiness.backgroundColor = UIColor.yellowColor()
        self.btnDoBusiness.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: kControlButtonFontSize)
        self.btnDoBusiness.sizeToFit()
        self.btnDoBusiness.bounds.size.width = self.btnDoBusiness.frame.width * 1.1
        self.btnDoBusiness.center = CGPoint(x: viewContainer.frame.width * kHalf, y: viewContainer.frame.height * kFourth)
        self.btnDoBusiness.addTarget(self, action: "pressDoBusiness:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnDoBusiness = radiusButtonCorners( self.btnDoBusiness, clrBorderColor: UIColor.blackColor() )
        viewContainer.addSubview(self.btnDoBusiness)
    }
}

