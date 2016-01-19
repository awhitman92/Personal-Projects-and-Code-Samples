//
//  GridViewController.swift
//  StoryGrid
//
//  Created by Andrew Whitman on 2015-10-02.
//  Copyright © 2015 awhitman92. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos
import Spring
import PKHUD
import ChameleonFramework

class GridViewController: UIViewController, UIScrollViewDelegate, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shuffleToggle: UIBarButtonItem!
    @IBOutlet weak var topBarButtonView: UIView!
    @IBOutlet weak var statusBarButtonView: UIView!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var instagramShareButton:UIBarButtonItem!
    @IBOutlet weak var dimensionsLabel: UIButton!
    @IBOutlet weak var selectCropImageView: UIView!
    
    private var documentController:UIDocumentInteractionController!
    var assetCollection: PHAssetCollection!
    var albumFound : Bool = false
    var photosAsset: PHFetchResult!
    var assetThumbnailSize:CGSize!
    var collection: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    var squareImage = UIImage()
    var shortrectangle = UIImage()
    var tallrectangle = UIImage()
    var randomsquareImage = UIImage()
    var randomshortrectangle = UIImage()
    var randomtallrectangle = UIImage()
    var gridContainerView = UIView()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var shuffledImageArray: [PHAsset] = []
    var originalImageArray: [PHAsset] = []
    var UIImageArray: [UIImage] = []
    var imagesSelected: Int = 0
    var isShuffled: Bool = false
    var imageWidth: CGFloat!
    var imageHeight: CGFloat!
    var imagenumset:Int = 0
    var manager = PHImageManager.defaultManager()
    
    //Shapes of Image Sets
    enum Shape {
        case tallRectangle
        case square
        case shortRectangle
    }
    enum Sides : Int {
        case square
        case long
        case short
    }

    enum Sizes{
        case small
        case medium
        case large
    }
    
    var dimensions = (square: 0, long: 0, short: 0)
    var squareSet:Bool = false
    var tallrectangleSet:Bool = false
    var shortrectangleSet:Bool = false
    var squareRandomSet:Bool = false
    var tallrectangleRandomSet:Bool = false
    var shortrectangleRandomSet:Bool = false
    var currentSize: Sizes!
    var currentShape = Shape.square
    
    override func viewDidLoad() {
        super.viewDidLoad()

        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        navigationController?.navigationBarHidden = false
        let backgroundQueue: dispatch_queue_t = dispatch_queue_create("com.a.identifier", DISPATCH_QUEUE_CONCURRENT)
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        scrollView.maximumZoomScale = 2
        scrollView.minimumZoomScale = 1
        self.imageView.contentMode = .ScaleAspectFit
        instagramShareButton.enabled = isInstagramInstalled()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        dimensionsLabel.setTitle("Loading", forState: UIControlState.Normal)
        dimensionsLabel.titleLabel?.textAlignment = .Center
        dimensionsLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        
        dispatch_async(backgroundQueue) {
            self.originalImageArray = imageArray
            self.dimensions = getRowColNumbers(imageArray.count)
            self.currentShape = self.getBestShape()
            self.getImageSizes(Sizes.medium)
            let imageDisplay = self.getOrderedShape()
            dispatch_async(dispatch_get_main_queue()) {
                if(self.currentShape == .square){
                    self.dimensionsLabel.setTitle((String(self.dimensions.square) + " x " + String(self.dimensions.square)), forState: UIControlState.Normal)
                }
                else{
                    self.dimensionsLabel.setTitle((String(self.dimensions.short) + " x " + String(self.dimensions.long)), forState: UIControlState.Normal)
                }
                self.imageView.image = imageDisplay
                PKHUD.sharedHUD.hide()
            }
        }
        dispatch_async(backgroundQueue){
            self.shuffledImageArray = imageArray
        }
    }
    

    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
    }
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }

    func getBestShape() -> Shape{
        let squareloss = imageArray.count-(dimensions.square * dimensions.square)
        let portraitloss = imageArray.count-(dimensions.short * dimensions.long)
        if(portraitloss < squareloss){
            if(imageArray.count > 15){
                if((squareloss-portraitloss) < 6){
                    return Shape.square
                }
                else{
                    return Shape.tallRectangle
                }
            }
            else{
                return Shape.tallRectangle
            }
        }
        else{
            return Shape.square
        }
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
        else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    func getOrderedShape() -> UIImage {
        var imageReturn: UIImage!
        switch currentShape {
        case .square:
            if(squareSet == false){
                squareImage = fillScreen(Shape.square, photoArray: self.originalImageArray)
                squareSet = true
            }
            imageReturn = squareImage
        case .tallRectangle:
            if(tallrectangleSet == false){
                tallrectangle = fillScreen(Shape.tallRectangle, photoArray: self.originalImageArray)
                tallrectangleSet = true
            }
            imageReturn = tallrectangle
        case.shortRectangle:
            if(shortrectangleSet == false){
                shortrectangle = fillScreen(Shape.shortRectangle, photoArray: self.originalImageArray)
                shortrectangleSet = true
            }
            imageReturn = shortrectangle
        }
        return imageReturn
    }
    
    func getRandomShape() -> UIImage {
        var imageReturn: UIImage!
        switch currentShape {
            case .square:
                if(squareRandomSet == false){
                    randomsquareImage = fillScreen(Shape.square, photoArray: self.shuffledImageArray)
                    squareRandomSet = true
                }
                imageReturn = randomsquareImage
            case .tallRectangle:
                if(tallrectangleRandomSet == false){
                    randomtallrectangle = fillScreen(Shape.tallRectangle, photoArray: self.shuffledImageArray)
                    tallrectangleRandomSet = true
                }
                imageReturn = randomtallrectangle
            case.shortRectangle:
                if(shortrectangleRandomSet == false){
                    randomshortrectangle = fillScreen(Shape.shortRectangle, photoArray: self.shuffledImageArray)
                    shortrectangleRandomSet = true
                }
                imageReturn = randomshortrectangle
            }
        return imageReturn
    }
    
    
    func randomPressed() {
        squareRandomSet = false
        tallrectangleRandomSet = false
        shortrectangleRandomSet = false
        self.isShuffled = true
        PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Shuffling Photos…")
        PKHUD.sharedHUD.show()

        let backgroundQueue: dispatch_queue_t = dispatch_queue_create("com.a.identifier", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(backgroundQueue) {
            self.shuffledImageArray.shuffle()
            let imageDisplay = self.getRandomShape()
            dispatch_async(dispatch_get_main_queue()) {
                self.imageView.image = imageDisplay
                PKHUD.sharedHUD.hide()
            }
        }
    
    }
    
    func originalPressed(){
        PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Reorganizing Photos…")
        PKHUD.sharedHUD.show()
        self.isShuffled = false
        
        let backgroundQueue: dispatch_queue_t = dispatch_queue_create("com.a.identifier", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(backgroundQueue) {
            let imageDisplay = self.getOrderedShape()
            dispatch_async(dispatch_get_main_queue()) {
                self.imageView.image = imageDisplay
                PKHUD.sharedHUD.hide()
            }
        }
    }
    
    
   
    
    @IBAction func changelayout(sender: AnyObject) {
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Set Dimensions:", preferredStyle: .ActionSheet)
        // 2
        let squareAction = UIAlertAction(title: "Square: " + (String(self.dimensions.square) + " x " + String(self.dimensions.square) + "   - " + String(self.dimensions.square*self.dimensions.square) + " Photos" ), style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.currentShape = .square
            self.dimensionsLabel.setTitle((String(self.dimensions.square) + " x " + String(self.dimensions.square)), forState: UIControlState.Normal)
            if(self.isShuffled){
                self.imageView.image = self.getRandomShape()
            }
            else{
                self.imageView.image = self.getOrderedShape()
            }
        })
        let tallAction = UIAlertAction(title: "Portrait: " + (String(self.dimensions.short) + " x " + String(self.dimensions.long) + "   - " + String(self.dimensions.short*self.dimensions.long) + " Photos"), style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.dimensionsLabel.setTitle((String(self.dimensions.short) + " x " + String(self.dimensions.long)), forState: UIControlState.Normal)
            self.currentShape = .tallRectangle
            if(self.isShuffled){
                self.imageView.image = self.getRandomShape()
            }
            else{
                self.imageView.image = self.getOrderedShape()
            }
        })
        let shortAction = UIAlertAction(title: "Landscape: " + (String(self.dimensions.long) + " x " + String(self.dimensions.short) + "   - " + String(self.dimensions.short*self.dimensions.long) + " Photos"), style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.currentShape = .shortRectangle
            self.dimensionsLabel.setTitle((String(self.dimensions.long) + " x " + String(self.dimensions.short)), forState: UIControlState.Normal)
            if(self.isShuffled){
                self.imageView.image = self.getRandomShape()
            }
            else{
                self.imageView.image = self.getOrderedShape()
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        // 4
        optionMenu.addAction(squareAction)
        optionMenu.addAction(tallAction)
        optionMenu.addAction(shortAction)
        optionMenu.addAction(cancelAction)
        optionMenu.popoverPresentationController?.sourceView = view
        optionMenu.popoverPresentationController?.sourceRect = sender.frame
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    
    func getImageSizes(size :Sizes){
        print("Size set to: \(size)")
        if(currentSize != size){
        if (size == .small){
            let fullImageWidth = 1080.0
            imageWidth = CGFloat(floor(Float(fullImageWidth)/Float(dimensions.square)))
            imageHeight = imageWidth
            currentSize = .small
        }
        else if (size == .medium){
            let fullImageWidth = 2048.0
            imageWidth = CGFloat(floor(Float(fullImageWidth)/Float(dimensions.square)))
            imageHeight = imageWidth
            currentSize = .medium
        }
        else{
            let fullImageWidth = 3008.0
            imageWidth = CGFloat(floor(Float(fullImageWidth)/Float(dimensions.square)))
            imageHeight = imageWidth
            currentSize = .large
        }
        }
    }
    
    @IBAction func orderPressed(sender: AnyObject) {
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Image Order:", preferredStyle: .ActionSheet)
        // 2
        let originalOrderAction = UIAlertAction(title: "Original Order", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.originalPressed()
        })
        let randomOrderAction = UIAlertAction(title: "Random Order", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.randomPressed()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        // 4
        optionMenu.addAction(originalOrderAction)
        optionMenu.addAction(randomOrderAction)
        optionMenu.addAction(cancelAction)
        optionMenu.popoverPresentationController?.sourceView = view
        optionMenu.popoverPresentationController?.sourceRect = sender.frame
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }

    //Set GridView as Image
    func createImageofImages() -> UIImage{
        UIGraphicsBeginImageContext(self.gridContainerView.bounds.size)
        print(self.gridContainerView.bounds.size)
        self.gridContainerView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        var image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        print(image.size)
        image = trimPixels(image)
        print(image.size)
        return image
    }
    func trimPixels(image: UIImage) -> UIImage {
        print("trimPrixels")
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        var edgex: CGFloat
        var edgey: CGFloat
        edgex = originalWidth - 2.0
        edgey = originalHeight - 2.0
        let posX = CGFloat(0.0)
        let posY = CGFloat(0.0)
        let cropSquare = CGRectMake(posX, posY, edgex, edgey)
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    }
    @IBAction func saveButton(sender: AnyObject) {
        let backgroundQueue: dispatch_queue_t = dispatch_queue_create("com.a.identifier", DISPATCH_QUEUE_CONCURRENT)
        var isSaved: Bool = true
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Image Size", preferredStyle: .ActionSheet)
        // 2
        let largeAction = UIAlertAction(title: "Large", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            dispatch_async(backgroundQueue) {
                isSaved = CustomPhotoAlbum.sharedInstance.saveImage(self.imageToSave(Sizes.large, shapeToSave: self.currentShape ))
                dispatch_async(dispatch_get_main_queue()) {
                    self.showSuccessFailure(isSaved)
                }
            }
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Saving to Camera Roll…")
            PKHUD.sharedHUD.show()
        })
        let mediumAction = UIAlertAction(title: "Medium", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            dispatch_async(backgroundQueue) {
                isSaved = CustomPhotoAlbum.sharedInstance.saveImage(self.imageToSave(Sizes.medium, shapeToSave: self.currentShape))
                dispatch_async(dispatch_get_main_queue()) {
                    self.showSuccessFailure(isSaved)
                }
            }
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Saving to Camera Roll…")
            PKHUD.sharedHUD.show()
        })
        let smallAction = UIAlertAction(title: "Small", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            dispatch_async(backgroundQueue) {
                isSaved = CustomPhotoAlbum.sharedInstance.saveImage(self.imageToSave(Sizes.small, shapeToSave: self.currentShape ))
                dispatch_async(dispatch_get_main_queue()) {
                    self.showSuccessFailure(isSaved)
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        // 4
        optionMenu.addAction(largeAction)
        optionMenu.addAction(mediumAction)
        optionMenu.addAction(smallAction)
        optionMenu.addAction(cancelAction)
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func showSuccessFailure(worked: Bool){
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            if (worked == true){
                PKHUD.sharedHUD.contentView = PKHUDSuccessView()
                PKHUD.sharedHUD.hide(afterDelay: 2.0)
            }
            else{
                PKHUD.sharedHUD.contentView = PKHUDErrorView()
                PKHUD.sharedHUD.hide(afterDelay: 2.0)
            }
        }
    }
    
    @IBAction func shareButton(sender: AnyObject) {
        let firstActivityItem = self.imageToSave(Sizes.medium, shapeToSave: self.currentShape )
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func instagramButton(sender: AnyObject) {
        postToInstagram(self.imageToSave(Sizes.medium, shapeToSave: self.currentShape ))
    }
    
    func isInstagramInstalled() -> Bool {
        let instagramUrl = NSURL(string: "instagram://app")
        if(UIApplication.sharedApplication().canOpenURL(instagramUrl!)){
            print("Instagram Available")
            return true
          
        }
        else {
            print("Instagram App NOT avaible...")
            return false
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
        }
        else {
            print("Instagram App NOT avaible...")
        }
    }
    
    func showAnimatedProgressHUD() {
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.contentView = PKHUDSuccessView()
        PKHUD.sharedHUD.hide(afterDelay: 2.0)
    }
    
    func imageToSave(sizeToSave: Sizes, shapeToSave: Shape) -> UIImage {
        var imageReturn: UIImage!
        if (sizeToSave == currentSize){
            imageReturn = imageView.image!
        }
        else{
            getImageSizes(sizeToSave)
            if(isShuffled){
                imageReturn = fillScreen(currentShape, photoArray: self.shuffledImageArray)
            }
            else{
                imageReturn = fillScreen(currentShape, photoArray: self.originalImageArray)
            }
        }
        getImageSizes(.medium)
        print("Getting Image: Size: \(sizeToSave)   Shape: \(currentShape)")
        return imageReturn
    }
    
    @IBAction func goBackHome(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to Quit?", preferredStyle: .ActionSheet)
        let originalQuitAction = UIAlertAction(title: "Delete and Start Over", style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
            self.navigationController?.navigationBarHidden = true
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(originalQuitAction)
        optionMenu.addAction(cancelAction)
        optionMenu.popoverPresentationController?.sourceView = view
        optionMenu.popoverPresentationController?.sourceRect = sender.frame
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    //Setup Functions
    func getAsset(asset: PHAsset, widthSet: CGFloat , heightSet: CGFloat) -> UIImage {
        let manager = PHImageManager.defaultManager()
        let imageSize = CGSize(width: widthSet, height: heightSet)
        let option = PHImageRequestOptions()
        option.resizeMode = PHImageRequestOptionsResizeMode.Exact
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.Opportunistic
        option.networkAccessAllowed = true
        var image = UIImage()
        option.synchronous = true
        
        manager.requestImageForAsset(asset, targetSize: imageSize, contentMode: PHImageContentMode.AspectFill, options: option, resultHandler: {(result, info)->Void in
            if (result != nil) {
                image = result!
            }
            else{
                image = UIImage(named: "errorImage")!
            }
        })
        return image
    }
    
    func fillScreen(shapeType: Shape, photoArray: [PHAsset]) -> UIImage{
        print("fillscreen")
        var numberOfColumns : Int
        var numberOfRows : Int
        switch shapeType {
        case .square:
            numberOfColumns = dimensions.square
            numberOfRows = dimensions.square
        case .tallRectangle:
            numberOfColumns = dimensions.short
            numberOfRows = dimensions.long
        case .shortRectangle:
            numberOfColumns = dimensions.long
            numberOfRows = dimensions.short
        }
        gridContainerView.frame.size.height = floor(CGFloat(imageHeight*CGFloat(numberOfRows)))
        gridContainerView.frame.size.width  = floor(CGFloat(imageWidth*CGFloat(numberOfColumns)))
        
        /*print("image width: \(imageWidth)  image height: \(imageHeight)")
        print("multiimage image height: \(imageHeight*CGFloat(numberOfRows))")
        print("fullimage height: \(gridContainerView.frame.size.height)")
        print("multiimage image width: \(imageWidth*CGFloat(numberOfColumns))")
        print("fullimage width: \(gridContainerView.frame.size.width)")*/
        
        var presentRow = 0
        var presentColumn = 0
        var isNoSpaceLeft: Bool = false
        for i in 0..<photoArray.count {
            if(!isNoSpaceLeft){
                let image = getAsset(photoArray[i], widthSet: imageWidth, heightSet: imageHeight)
                let imageView = UIImageView(image: image)
                imageView.contentMode = .ScaleAspectFill
                imageView.clipsToBounds = true
                if(presentColumn == numberOfColumns){
                    presentColumn = 0
                    presentRow = presentRow+1
                    if (presentRow == numberOfRows){
                        isNoSpaceLeft = true
                    }
                }
                if(!isNoSpaceLeft){
                    imageView.frame = CGRect(x: CGFloat(presentColumn*Int(imageWidth)), y: CGFloat(presentRow*Int(imageHeight)), width: imageWidth, height: imageHeight)
                    //imageView.contentMode = UIViewContentMode.Center
                    gridContainerView.addSubview(imageView)
                    presentColumn = presentColumn+1
                }
            }
        }
        let image = createImageofImages()
        return image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.setZoomScale(1.0, animated: true)
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentSize.height = 0.0
        self.scrollView.contentSize.width = 0.0
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
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


