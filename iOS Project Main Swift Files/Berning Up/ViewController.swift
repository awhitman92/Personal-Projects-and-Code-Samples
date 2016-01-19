//
//  ViewController.swift
//  berningup
//
//  Created by Andy on 2015-10-29.
//  Copyright © 2015 awhitman92. All rights reserved.
//
import CameraManager
import UIKit
import Spring
import RFAboutView_Swift
import Social
import Photos
import AVKit

class ViewController: UIViewController, UIDocumentInteractionControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var alertButton: SpringButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var InstagramButton: UIButton!
    @IBOutlet weak var topBar: SpringView!
    @IBOutlet weak var captureMenuHeight: NSLayoutConstraint!
    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var switchCamera: UIButton!
    @IBOutlet weak var capture: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var savedImage: UIImageView!
    @IBOutlet weak var squareSavedImage: UIImageView!
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    @IBOutlet weak var cameraModeTopBar: UIView!
    @IBOutlet weak var cropSquareBarHeight: NSLayoutConstraint!
    @IBOutlet weak var cropSquareBar: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var behindScrollView: UIView!
    @IBOutlet weak var nextFilterView: UIView!
    @IBOutlet weak var previousFilterView: UIView!
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var buttonCenterDist: NSLayoutConstraint!
    @IBOutlet weak var filterPageView: UIView!
    
    @IBOutlet weak var bernify2: UIButton!
    @IBOutlet weak var bernify1: UIButton!
    
    var isBernieFront:Bool = false
    var currentPageIndex: Int = 0
    var pageImages:NSArray!
    var pageViewController:UIPageViewController!
    var imageView = UIImageView()
    private var documentController:UIDocumentInteractionController!
    var menuHeightPortrait: CGFloat!
    var menuHeightSquare: CGFloat!
    var menuHeightOriginal: CGFloat!
    var buttonOriginalDist: CGFloat!
    var myImage: UIImage!
    var isFrontCamera: Bool = false
    var isSquareScaled: Bool = false
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var tallScreen:CGFloat!
    var squareScreen:CGFloat!
    let aboutNav = UINavigationController()
  
    let cameraManager = CameraManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setBlur()
        setScreenScaleValues()
        setupAbout()
        buttonOriginalDist = buttonCenterDist.constant
        savedImage.hidden = true
        animateGoBackToPhoto()
        setupPageView()
        self.view.layoutIfNeeded()
        behindScrollView.hidden = true
        originalPlacement = bernieImage.center
        filterPageView.userInteractionEnabled = true
        gestureView.userInteractionEnabled = true
        bernify1.setImage(UIImage(named:"bernster_smiles"), forState: UIControlState.Normal)
        bernify2.setImage(UIImage(named:"bernster_smiles"), forState: UIControlState.Normal)
        filterOnScreen = .noBernie
        bernieImage.image = UIImage(named: "bernify")
        bernieImage.hidden = true
        isBernieOnScreen = true
        BernierResetToggle()
        setFlashOff()
        scrollView.hidden = true
        setScrollView()
        setGestures()
        setCamera()
        InstagramButton.hidden = true
        checkSocialApps()
    }
    
    
    func setGestures(){
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "gesturePrevious:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        gestureView.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "gestureNext:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        gestureView.addGestureRecognizer(swipeLeft)
        let filterTap2 = UITapGestureRecognizer(target: self, action: "gestureNext:")
        filterTap2.numberOfTapsRequired = 2
        filterPageView.addGestureRecognizer(filterTap2)
    }
    
    func setCamera(){
        ////print("success")
        cameraManager.addPreviewLayerToView(self.cameraView)
        cameraManager.cameraOutputMode = .StillImage
        cameraManager.cameraOutputQuality = .High
        cameraManager.writeFilesToPhoneLibrary = false
        cameraManager.cameraDevice = .Back
        isFrontCamera = false
    }
    
    func setBlur(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView2 = UIVisualEffectView(effect: blurEffect)
        blurEffectView2.frame = cameraModeTopBar.bounds
        blurEffectView2.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        captureView.addSubview(blurEffectView2)
        captureView.sendSubviewToBack(blurEffectView2)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = cropSquareBar.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        cropSquareBar.addSubview(blurEffectView)
        cropSquareBar.sendSubviewToBack(blurEffectView)
    }
    
    enum filterState {
        case noBernie
        case bernieGlasses
        case bernieFull
    }
    var filterOnScreen = filterState.noBernie
    
    @IBAction func switchFilter(sender: AnyObject){
        if (bernieImage.isAnimating() == false){
        switch filterOnScreen {
        case .noBernie:
            bernieImage.hidden = false
            BernierResetToggle()
            bernify1.setImage(UIImage(named:"bernster"), forState: UIControlState.Normal)
            bernify2.setImage(UIImage(named:"bernster"), forState: UIControlState.Normal)
            filterOnScreen = .bernieFull
        case .bernieFull:
            bernify1.setImage(UIImage(named:"bernster_glasses"), forState: UIControlState.Normal)
            bernify2.setImage(UIImage(named:"bernster_glasses"), forState: UIControlState.Normal)
            filterOnScreen = .bernieGlasses
            bernieImage.image = UIImage(named: "bernifyglasses")
        
        case .bernieGlasses:
            BernierResetToggle()
            bernify1.setImage(UIImage(named:"bernster_smiles"), forState: UIControlState.Normal)
            bernify2.setImage(UIImage(named:"bernster_smiles"), forState: UIControlState.Normal)
            filterOnScreen = .noBernie
            
            }
        }
    }
    
    
    
    @IBOutlet weak var bernieImageRatio: NSLayoutConstraint!
    @IBOutlet weak var bernieCentery: NSLayoutConstraint!
    @IBOutlet weak var bernieCenterX: NSLayoutConstraint!
    func setNewCenter(){
        bernieCenterX.constant = bernieImage.center.x-(screenSize.width/2)
        bernieCentery.constant = bernieImage.center.y-(screenSize.height/2)
    }
    var isBernieOnScreen:Bool = false
    var originalPlacement: CGPoint!
    @IBOutlet weak var bernieImage: SpringImageView!
    
    func BernierResetToggle(){
        if(!isBernieOnScreen){
            self.bernieImage.image = UIImage(named: "bernify")
            bernieImage.hidden = false
            bernieImage.animation = "wobble"
            bernieImage.curve = "easeIn"
            bernieImage.duration = 0.8
            bernieImage.animate()
            bernieImage.userInteractionEnabled = true
            isBernieOnScreen = true
        }
        else{
            UIView.animateWithDuration(0.3, delay: 0.0, options: [], animations: {
                self.bernieImage.alpha = 0.0
                }, completion: { finished in
                    self.bernieImage.hidden = true
                    self.bernieImage.alpha = 1.0
                    self.bernieImage.userInteractionEnabled = false
                    self.bernieImage.center = self.originalPlacement
                    self.bernieImage.transform = CGAffineTransformMakeScale(1, 1)
                    self.bernieImage.transform = CGAffineTransformMakeRotation(0.0)
                    self.isBernieOnScreen = false
                    
                })


            
            
        }
        
        
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        if let view = recognizer.view {
           
                //let doRectsIntersect = bernieImage.frame.intersects(filterPageView.frame)

            if(CGRectContainsPoint(filterPageView.frame, CGPoint(x: bernieImage.center.x, y: bernieImage.frame.maxY-20.0 )))
            {
                //print("overlap")
                bernieImage.center.y+=3
                
            }
            else{
                view.center = CGPoint(x:view.center.x + translation.x,
                    y:view.center.y + translation.y)
            }
            
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
    }
    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            if(self.bernieImage.transform.a > 6){
                view.transform = CGAffineTransformScale(view.transform,
                    0.99, 0.99)
                    recognizer.scale = 1
            }
            else{
                view.transform = CGAffineTransformScale(view.transform,
                    recognizer.scale, recognizer.scale)
                recognizer.scale = 1
            }
        }
    }
    
    @IBAction func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = CGAffineTransformRotate(view.transform, recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    func gestureNext (recognizer:UITapGestureRecognizer){
        showNextFilter()
    }
    func gesturePrevious (recognizer:UITapGestureRecognizer){
        showPreviousFilter()
    }
    
    
    @IBAction func pressPrevious(sender: AnyObject){
        showPreviousFilter()
        
    }
    
    @IBAction func pressNext(sender: AnyObject){
        showNextFilter()
    }
    
    func setScrollView(){
        scrollView.delegate = self
        imageView.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
        imageView.image = UIImage(named: "image")
        scrollView.addSubview(imageView)
        
    }
    
    @IBAction func getImage(sender: AnyObject) {
        loadImage()
    }
    func changeToImageLoadedState(){
        //cameraManager.stopAndRemoveCaptureSession()
        animatePhotoTaken()
        savedImage.hidden = true
        behindScrollView.hidden = false
        capture.hidden = true
        gestureView.userInteractionEnabled = false
    }
     
    func changeToCameraState(){
        scrollView.hidden = true
        capture.hidden = false
        if(behindScrollView.hidden == false){
            gestureView.userInteractionEnabled = true
            behindScrollView.hidden = true
        }
        cameraModeTopBar.userInteractionEnabled = true
        cameraModeTopBar.hidden = false
    }
    
    func loadImage (){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        scrollView.zoomScale = 1
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height)
        
        scrollView.contentSize = image.size
        
        let scrollViewFrame = scrollView.frame
        //print(scrollView.frame)
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        //print(scaleWidth)
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        //print(scaleHeight)
        let minScale = max(scaleHeight, scaleWidth)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 2
        scrollView.zoomScale = minScale
        scrollView.hidden = false
        centerScrollViewContents()
        changeToImageLoadedState()
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func centerScrollViewContents(){
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width{
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        }
        else{
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        }
        else{
            contentsFrame.origin.y = 0
        }
        imageView.frame = contentsFrame
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    @IBAction func goToSettings(sender: AnyObject) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    
    func isAllPermissionsGiven() -> Bool {
        
        if ((AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Denied) || (PHPhotoLibrary.authorizationStatus() == .Denied))
        {
            return false
        }
        return true
    }
    
    @IBAction func infoButtonPressed(sender: AnyObject) {
        
        self.presentViewController(aboutNav, animated: true, completion: nil)
        
    }
    
    
    func setupAbout(){
        // Initialise the RFAboutView:
        let aboutView = RFAboutViewController(appName: "Berning Up", appVersion: "1.1", appBuild: "1", copyrightHolderName: "", contactEmail: "berningupapp@gmail.com", contactEmailTitle: "Contact us", websiteURL: NSURL(string: "https://instagram.com/berningup2016"), websiteURLTitle: "Follow on Instagram", pubYear: nil)
        
        // Set some additional options:
        aboutView.addAdditionalButton("Help and Support", content: "Thank you for using BerningUp! \nPlease Post to Social Media with #BerningUp, #FeeltheBern, #BernieforPresident, or whatever else you think will help get the most campaign coverage\n\nTo activate the 'Bernie' filter, press the smiley face in the toolbar and resize and move it as you need.\n\nIf at any point you lose the 'Bernie' filter, press the smiley face again twice to reset its size and position.\n\nIf you have any suggestions for new filters or slogans to be used in the app, please reach out and let us know.\n\nIf you are having trouble either taking a photo or accessing your photo library, check your settings app to make sure you have properly approved Berning Up to access them.\n\nThanks to Andrew Hart owner of www.dirt2.com for creating many of the logos and filters.\n\n\nWe are not tied to the Sanders campaign and have created this to allow others to show their support")
        
        aboutView.headerBackgroundColor = .blackColor()
        aboutView.headerTextColor = .whiteColor()
        aboutView.blurStyle = .Dark
        aboutView.headerBackgroundImage = UIImage(named: "background")
        
        // Add an additional button:
        //aboutView.addAdditionalButton("Privacy Policy", content: "Here's the privacy policy")
        
        // Add the aboutView to the NavigationController:
        aboutNav.setViewControllers([aboutView], animated: false)
    }

    func setupPageView(){
        pageImages = NSArray(objects:"iamwith", "feelit", "bernup", "revolution", "sanderspres", "votingfor", "nextprez", "blank")
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MyPageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        let initialContenViewController = self.pageAtIndex(0) as FilterViewController
        let viewControllers = NSArray(object: initialContenViewController)
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        self.pageViewController.view.frame = CGRectMake(0, 0, self.filterPageView.frame.size.width, self.filterPageView.frame.size.height)
        self.addChildViewController(self.pageViewController)
        self.filterPageView.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
    func setFlashOff(){
        cameraManager.flashMode = .Off
        flashButton.setImage(UIImage(named:"flash_off"), forState: UIControlState.Normal)
    }
    
    @IBAction func switchFlashMode(sender: AnyObject) {
        cameraManager.changeFlashMode()
        if (cameraManager.flashMode == .Auto){
            flashButton.setImage(UIImage(named:"flash_auto"), forState: UIControlState.Normal)
        }
        else if (cameraManager.flashMode == .On){
            flashButton.setImage(UIImage(named:"flash"), forState: UIControlState.Normal)
        }
        else if (cameraManager.flashMode == .Off){
            flashButton.setImage(UIImage(named:"flash_off"), forState: UIControlState.Normal)
        }
        
    }
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int{
      return 0
    }
   
    func pageAtIndex(index: Int) ->FilterViewController
    {
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("FilterViewController") as! FilterViewController
        pageContentViewController.imageFileName = pageImages[index] as! String
        pageContentViewController.pageIndex = index
        return pageContentViewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        let viewController = viewController as! FilterViewController
        var index = viewController.pageIndex as Int
        
        if(index == NSNotFound){
            return nil
        }
        
        if(index == 0){
            index = pageImages.count-1
        }
        else{
          index--
        }
        return self.pageAtIndex(index)
    }
   
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        let viewController = viewController as! FilterViewController
        var index = viewController.pageIndex as Int
        
        if((index == NSNotFound))
        {
            return nil
        }
        
        
        
        if(index == pageImages.count-1)
        {
            index = 0
        }
        else{
            index++
        }
        currentPageIndex = index
        
        return self.pageAtIndex(index)
    }
    
    @IBAction func nextFilter(sender: AnyObject) {
      showNextFilter()
    }
    
    @IBAction func previousFilter(sender: AnyObject) {
     showPreviousFilter()
    }
    
    func showNextFilter(){
        var nextPage = currentPageIndex+1
        //////print(pageImages.count)
        if(currentPageIndex == pageImages.count-1){
            nextPage = 0
        }
        //pageViewIndicator.currentPage = nextPage
        let vc = self.pageAtIndex(nextPage)
        self.pageViewController.setViewControllers([vc], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: { (complete) -> Void in
            self.currentPageIndex = nextPage
        })
    }
    
    func showPreviousFilter(){
        
        var nextPage = currentPageIndex-1
        //////print(pageImages.count)
        if(currentPageIndex == 0){
            nextPage = pageImages.count-1
        }
        //pageViewIndicator.currentPage = nextPage
        let vc = self.pageAtIndex(nextPage)
        self.pageViewController.setViewControllers([vc], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: { (complete) -> Void in
            self.currentPageIndex = nextPage
        })
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setScreenScaleValues(){
        let originalWidth  = screenSize.size.width
        menuHeightOriginal =  self.captureMenuHeight.constant
        var height = floor(4*(originalWidth/3))
        menuHeightPortrait = screenSize.size.height - height
        if (menuHeightPortrait < (menuHeightOriginal+75)){
            menuHeightPortrait = menuHeightOriginal
        }
    }
    
    enum ScreenState {
        case Full
        case Portrait
        case Square
    }
    
    var currentSize = ScreenState.Full
    
    func scaleScreen(){
        switch currentSize {
        case .Full:
            if(menuHeightPortrait == menuHeightOriginal){
                currentSize = .Square
                self.cropSquareBarHeight.constant = screenSize.size.height-screenSize.size.width-menuHeightPortrait
                if(cropSquareBarHeight.constant > 44){
                    cropSquareBarHeight.constant = 44
                    self.captureMenuHeight.constant = screenSize.size.height-screenSize.size.width-cropSquareBarHeight.constant
                    self.buttonCenterDist.constant = -20.0
                }
            }
            else{
                //print("gotoportrait")
            currentSize = .Portrait
            self.captureMenuHeight.constant = menuHeightPortrait
            //print(menuHeightPortrait)
                self.buttonCenterDist.constant = -20.0
            }
        case .Portrait:
            currentSize = .Square
            self.cropSquareBarHeight.constant = screenSize.size.height-screenSize.size.width-menuHeightPortrait
            if(cropSquareBarHeight.constant > 44){
                cropSquareBarHeight.constant = 44
                self.captureMenuHeight.constant = screenSize.size.height-screenSize.size.width-cropSquareBarHeight.constant
            }
        case .Square:
           currentSize = .Full
           self.cropSquareBarHeight.constant = 0.0
           self.captureMenuHeight.constant = menuHeightOriginal
            self.buttonCenterDist.constant = buttonOriginalDist
        }
        setNewCenter()
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    var scaleSize: CGFloat = 4.0
    
    func trimPixels(image: UIImage) -> UIImage {
        //print(image.size)
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        var edgex: CGFloat
        var edgey: CGFloat
        var posY: CGFloat
        let posX = CGFloat(0.0)
        
        edgex = originalWidth
        switch currentSize {
        case .Full:
                edgey = originalHeight - captureMenuHeight.constant
                //print(captureMenuHeight.constant)
                posY = 0.0
        case .Portrait:
                edgey = originalHeight - captureMenuHeight.constant
                posY = 0.0
        case .Square:
                edgey = originalHeight - captureMenuHeight.constant - cropSquareBarHeight.constant
                posY = (cropSquareBarHeight.constant)*scaleSize //(originalHeight - edge) / 2.0
        }
      
        edgex = edgex*scaleSize
        edgey = edgey*scaleSize
        let cropSquare = CGRectMake(posX, posY, edgex, edgey)
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func switchCamera(sender: AnyObject) {
        if(isFrontCamera){
            cameraManager.cameraDevice = .Back
            isFrontCamera = false
        }
        else{
            cameraManager.cameraDevice = .Front
            isFrontCamera = true
        }
        
    }

    
    @IBAction func shareBasic(sender: AnyObject){
        //Sharing Function
        let firstActivityItem = trimPixels(createImageofImages())
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)

        
        activityViewController.popoverPresentationController?.sourceView = self.shareView
        activityViewController.popoverPresentationController?.sourceRect = sender.frame
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
        
    }
    

    @IBAction func saveImage(sender: UIButton){
        //UIImageWriteToSavedPhotosAlbum(self.savedImage.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
        UIImageWriteToSavedPhotosAlbum(trimPixels(createImageofImages()), self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your photo was saved", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save Error", message: "Check your settings to make sure you have approved BerningUp to save photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    func getPhoto(){
        cameraManager.capturePictureWithCompletition({ (image, error) -> Void in
            self.savedImage.image = image
        })
        
    }
    
    
    @IBAction func takePhoto(sender: AnyObject) {
        
        getPhoto()
        
        if(isFrontCamera){
           savedImage.transform = CGAffineTransformMakeScale(-1, 1)
        }
        else{
            savedImage.transform = CGAffineTransformMakeScale(1, 1)
        }
        
        animatePhotoTaken()
        
        capture.hidden = true
        savedImage.hidden = false
        //CameraManager.sharedInstance.stopAndRemoveCaptureSession()
    }
    
    var instaInstalled: Bool = true

    func checkSocialApps(){
        let instagramUrl = NSURL(string: "instagram://app")
        if(UIApplication.sharedApplication().canOpenURL(instagramUrl!)){
            instaInstalled = true
            
        } else {
            instaInstalled = false
            
        }
    }
    
    @IBAction func tweetButtonPressed(sender: UIButton) {
        shareToTwitter()
    }
    
    func shareToTwitter(){
        // 1
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            // 2
            let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            // 3
            tweetSheet.setInitialText("#FeeltheBern #BerningUp")
            tweetSheet.addImage(self.trimPixels(self.createImageofImages()))
            
            // 4
            self.presentViewController(tweetSheet, animated: true, completion: nil)
        } else {
            // 5
            ////print("error")
            
        }
    }
    
    
    
    func animatePhotoTaken(){
        if(instaInstalled){
            InstagramButton.hidden = false
        }
        
        topBar.animation = "fadeIn"
        topBar.curve = "easeIn"
        topBar.duration = 1.0
        topBar.y = 300.0
        topBar.animate()
        cameraModeTopBar.userInteractionEnabled = false
        cameraModeTopBar.hidden = true
    }
    
    func animateGoBackToPhoto(){
        InstagramButton.hidden = true
        topBar.animation = "fadeOut"
        topBar.curve = "easeIn"
        topBar.duration = 1.0
        topBar.y = 300.0
        topBar.animate()
    }
    
    
    @IBAction func deleteRedo(sender: AnyObject) {
        animateGoBackToPhoto()
        savedImage.hidden = true
        savedImage.image = nil
        changeToCameraState()
    }
    
    func createImageofImages() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(self.mainView.bounds.size, true, scaleSize)
        //////print(self.gridContainerView.bounds.size)
        self.mainView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //print(image.size)
        return image
    }
    
    
    
    @IBAction func instagramButton(sender: AnyObject) {
        shareToInstagram()
    }
    func shareToInstagram(){
        loadingIcon.hidden = false
        loadingIcon.startAnimating()
        let backgroundQueue: dispatch_queue_t = dispatch_queue_create("com.a.identifier", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(backgroundQueue) {
            let finalImage = self.trimPixels(self.createImageofImages())
            dispatch_async(dispatch_get_main_queue()) {
                self.postToInstagram(finalImage)
                self.loadingIcon.stopAnimating()
                self.loadingIcon.hidden = true
            }
        }
    }
    
    func postToInstagram(YourImage: UIImage){
        
        let instagramUrl = NSURL(string: "instagram://Camera")
        if(UIApplication.sharedApplication().canOpenURL(instagramUrl!)){
            
            //Instagram App avaible
            
            let imageData = UIImageJPEGRepresentation(YourImage, 100)
            let writePath = NSTemporaryDirectory().stringByAppendingPathComponent("instagram.igo")
            
            if(!imageData!.writeToFile(writePath, atomically: true)){
                //Fail to write. Don't post it
                return
            } else{
                //Safe to post
                
                let fileURL = NSURL(fileURLWithPath: writePath)
                self.documentController = UIDocumentInteractionController(URL: fileURL)
                self.documentController.delegate = self
                self.documentController.UTI = "com.instagram.exclusivegram"
                self.documentController.presentOpenInMenuFromRect(self.view.frame, inView: self.view, animated: true)
            }
        } else {
            ////print("Instagram App NOT avaible...")
        }
    }
    
    @IBAction func cropAfterPressed(sender: AnyObject) {
        scaleScreen()
    }
   
    @IBAction func cropBeforePressed(sender: AnyObject) {
        scaleScreen()
        
    }
}


extension String {
    var lastPathComponent: String {
        get {
            return (self as NSString).lastPathComponent
        }
    }
    var pathExtension: String {
        get {
            return (self as NSString).pathExtension
        }
    }
    var stringByDeletingLastPathComponent: String {
        get {
            return (self as NSString).stringByDeletingLastPathComponent
        }
    }
    var stringByDeletingPathExtension: String {
        get {
            return (self as NSString).stringByDeletingPathExtension
        }
    }
    var pathComponents: [String] {
        get {
            return (self as NSString).pathComponents
        }
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
    
    func stringByAppendingPathExtension(ext: String) -> String? {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathExtension(ext)
    }
}

