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
        
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let startVC = self.viewControllerAtIndex(0) as TutorialViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        self.pageViewController.view.frame = CGRect(x: 0, y: 30, width: self.view.frame.width, height: self.view.frame.size.height * 0.7)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.didMove(toParentViewController: self)
        
        // Do any additional setup after loading the view, typically from a nib.
        self.setupAesthetics()
    }
    
    @IBAction func buttonPress(_ sender: AnyObject) {
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
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Wallpaper")
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    func playerItemDidReachEnd(_ notification: Notification) {
        self.player.seek(to: kCMTimeZero)
        self.player.play()
    }
    
    func viewControllerAtIndex(_ index: Int) -> TutorialViewController {
        if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return TutorialViewController()
        }
        
        let vc: TutorialViewController = self.storyboard?.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.titleText = self.pageTitles[index] as! String
        vc.pageIndex = index
        
        return vc
    }
    
    // MARK -- Page View Controller datasource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! TutorialViewController
        var index = vc.pageIndex as Int
    
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func setupAesthetics() {
        // Bring UI to front
        self.view.bringSubview(toFront: self.loginButton)
        self.view.bringSubview(toFront: self.registerButton)
        self.view.bringSubview(toFront: self.logo)
        
        // Make buttons look pretty
        self.loginButton.layer.cornerRadius = 5
        self.loginButton.layer.borderWidth = 2
        self.loginButton.layer.borderColor = UIColor.white.cgColor
        
        self.registerButton.layer.cornerRadius = 5
        self.registerButton.layer.borderWidth = 2
        self.registerButton.layer.borderColor = UIColor.white.cgColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Changing Status Bar
    override var preferredStatusBarStyle : UIStatusBarStyle {
        // LightContent
        return UIStatusBarStyle.lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}

