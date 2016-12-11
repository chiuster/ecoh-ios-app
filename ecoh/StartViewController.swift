//
//  StartViewController.swift
//  ecoh
//
//  Created by Ryan Chiu on 5/29/16.
//  Copyright © 2016 Ecoh Technologies, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class StartViewController: UIViewController, UIPageViewControllerDataSource {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var logo: UIImageView!
    
    var pageViewController: UIPageViewController!
    var pageTitles: NSArray!
    var pageImages: NSArray!
    
    var player: AVPlayer!
    
    override func viewDidLoad() {
        self.loadBackground() // video background
        super.viewDidLoad()
        
        // Page View Controller setup for walkthrough
        self.pageTitles = NSArray(objects: "See what's poppin' (and what's not) on our live map of venues.",
                                  "Get directions to the hottest party on the block",
                                  "Rate your vibe once you're there, so that others can join in!")
        self.pageImages = NSArray(objects: "EcohPulse", "Directions", "Ratings")
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let startVC = self.viewControllerAtIndex(0) as TutorialViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        self.pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.width, self.view.frame.size.height * 0.7)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.didMoveToParentViewController(self)
        
        // Do any additional setup after loading the view, typically from a nib.
        self.setupAesthetics()
    }
    
    @IBAction func buttonPress(sender: AnyObject) {
        //player.pause()
    }
    
    func loadBackground() {
        // Video background
        /*let path = NSBundle.mainBundle().pathForResource("bgvideo", ofType: "mp4")
        self.player = AVPlayer(URL: NSURL(fileURLWithPath: path!))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(playerLayer)
        player.seekToTime(kCMTimeZero)
        player.play()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player.currentItem)*/
        
        // Static wallpaper background
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "Wallpaper")
        self.view.insertSubview(backgroundImage, atIndex: 0)
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.player.seekToTime(kCMTimeZero)
        self.player.play()
    }
    
    func viewControllerAtIndex(index: Int) -> TutorialViewController {
        if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return TutorialViewController()
        }
        
        let vc: TutorialViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialViewController") as! TutorialViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.titleText = self.pageTitles[index] as! String
        vc.pageIndex = index
        
        return vc
    }
    
    // MARK -- Page View Controller datasource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! TutorialViewController
        var index = vc.pageIndex as Int
    
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! TutorialViewController
        var index = vc.pageIndex as Int

        if (index == NSNotFound) {
            return nil
        }
        
        index += 1
        
        if (index == self.pageTitles.count) {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func setupAesthetics() {
        // Bring UI to front
        self.view.bringSubviewToFront(self.loginButton)
        self.view.bringSubviewToFront(self.registerButton)
        self.view.bringSubviewToFront(self.logo)
        
        // Make buttons look pretty
        self.loginButton.layer.cornerRadius = 5
        self.loginButton.layer.borderWidth = 2
        self.loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.registerButton.layer.cornerRadius = 5
        self.registerButton.layer.borderWidth = 2
        self.registerButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Changing Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        // LightContent
        return UIStatusBarStyle.LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

