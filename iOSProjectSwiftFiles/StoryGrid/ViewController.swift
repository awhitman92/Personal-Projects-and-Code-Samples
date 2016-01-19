//
//  ViewController.swift
//  StoryGrid
//
//  Created by Andrew Whitman on 2015-10-02.
//  Copyright © 2015 awhitman92. All rights reserved.
//
import UIKit
import BSImagePicker
import Photos
import ChameleonFramework
import PKHUD
import RFAboutView_Swift
import Spring
var imageArray: [PHAsset] = []
class ViewController: UIViewController {

    @IBOutlet weak var mainDescription: SpringLabel!
    @IBOutlet weak var sampleImage: UIImageView!
    @IBOutlet weak var selectImagesButton: UIButton!
    
    var imageSet: UIImage!
    var imagesSelected: Int = 0
    var isFinished: Bool = false {
        willSet(incomingStatus) {
            print("About to set status to:  \(incomingStatus)")
            if(incomingStatus){
                self.performSegueWithIdentifier("gotoGrid", sender: nil)
            }
        }
    }
    
    let aboutNav = UINavigationController()
    
    override func viewDidLoad() {
        setupAbout()
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        view.backgroundColor = HexColor(backgroundColor)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        // Do any additional setup after loading the view, typically from a nib.
        mainDescription.text = "Combine countless photos to tell a story without saying a word."
            mainDescription.animation = "fadeInDown"
            mainDescription.curve = "easeIn"
            mainDescription.duration = 2.0
            mainDescription.y = -300.0
            mainDescription.delay = 0.5
            mainDescription.animate()
    }
    
    func setupAbout(){
        // Initialise the RFAboutView:
        let aboutView = RFAboutViewController(appName: "Story Grid", appVersion: "1.1.1", appBuild: "2", copyrightHolderName: "", contactEmail: "storygrid@gmail.com", contactEmailTitle: "Contact us", websiteURL: NSURL(string:"instagram://user?username=storygrid"), websiteURLTitle: "Follow us Instagram", pubYear: nil)
        // Set some additional options:
        aboutView.headerBackgroundColor = .blackColor()
        aboutView.headerTextColor = .whiteColor()
        aboutView.blurStyle = .Dark
        aboutView.headerBackgroundImage = UIImage(named: "BACKGROUND")
        // Add an additional button:
        aboutView.addAdditionalButton("Upcoming Features", content: "Story Grid is working hard to add the following features to upcoming versions:\n\nManual re-arrangement of photos on the grid\n\nManual adjustment of what is cropped on each image\n\nChanging photo selection without having to restart\n\nSaving grid for future use\n\n\nPlease contact us if you have other suggestions or if you think that some of these features should be a higher priority.")
        // Add the aboutView to the NavigationController:
        aboutNav.setViewControllers([aboutView], animated: false)
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func goToSettings() {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    func isAllPermissionsGiven() -> Bool {
        if (PHPhotoLibrary.authorizationStatus() == .Denied)
        {
            return false
        }
        return true
    }
    
    @IBAction func aboutButtonPressed(sender: AnyObject) {
        self.presentViewController(aboutNav, animated: true, completion: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    @IBAction func selectImagesPressed(sender: AnyObject) {
        if(!isAllPermissionsGiven()){
            let ac = UIAlertController(title: "Error", message: "Story Grid needs persmission to access your photo library.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "Fix Permissions", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
                self.goToSettings()
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
        else{
            imageArray = []
            isFinished = false
            let vc = BSImagePickerViewController()
            //vc.preferredStatusBarStyle()
            vc.takePhotos = true
            vc.selectionFillColor = HexColor(primaryColor)
            bs_presentImagePickerController(vc, animated: true,
            select: { (asset: PHAsset) -> Void in
                imageArray.append(asset)
            }, deselect: { (asset: PHAsset) -> Void in
                imageArray = imageArray.filter() {$0 != asset}
            }, cancel: { (assets: [PHAsset]) -> Void in
                imageArray = []
                self.isFinished = false
            }, finish: { (assets: [PHAsset]) -> Void in
                self.isFinished = true
            }, completion: { finished in
            })
          }
       }
}
