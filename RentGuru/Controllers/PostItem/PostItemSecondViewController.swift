
//  PostItemSecondViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/4/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Photos
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class PostItemSecondViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate ,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet var productDescription: UITextView!
    @IBOutlet var baseScroll: UIScrollView!
    @IBOutlet var imageCollection: UICollectionView!
    let imagePicker = UIImagePickerController()
    var imageArray : [UIImage] = []
    var imageToken  = Array<Int>()
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    var UploadCounter = 0
    var filenames :[String] = []
    //From Previous Controller
    
    var selectedCategory: [Int] = []
    var productTitle: String!
    var availableFrom : String!
    var availableTill :String!
    var address :String!
    var city: String!
    var zipCode: String!
    var stateId: Int!
    
    
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var presentWindow : UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.tabBarController!.tabBar.hidden = true;
        self.hideKeyboardWhenTappedAround()
        imagePicker.delegate = self
        presentWindow = UIApplication.shared.keyWindow
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        baseUrl = defaults.string(forKey: "baseUrl")!
        
        
        
        self.imageCollection.delegate = self
        self.imageCollection.dataSource = self
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationItem.title = "Details"
        let button = UIButton(type: UIButtonType.system) as UIButton
        //button.setImage(UIImage(named: "back.png"), forState: UIControlState.Normal)
        button.setTitle("Next", for:UIControlState())
        //.attributedText = NSAttributedString(string: "Next", attributes:[NSForegroundColorAttributeName : UIColor.lightGrayColor()])
        button.tintColor = UIColor.white
        button.addTarget(self, action:#selector(PostItemSecondViewController.performNext), for: UIControlEvents.touchUpInside)
        button.frame=CGRect(x: 0, y: 0, width: 35, height: 35)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        // layout.minimumInteritemSpacing = 0
        self.imageCollection.collectionViewLayout = layout
        
    }
    override func viewDidLayoutSubviews() {
        self.baseScroll.contentSize = CGSize(
            width: self.view.frame.size.width,
            height: self.view.frame.size.height + 206
        );
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func performNext(){
        var checkAll = true
        if(self.productDescription.text == ""){
            checkAll = false
            view.makeToast(message:"product description Required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }
        if(self.imageArray.isEmpty && checkAll != false){
            checkAll = false
            view.makeToast(message:"add some images ", duration: 2, position: HRToastPositionCenter as AnyObject)
            
        }
        if(checkAll != false){
            self.uploadFiles()
        }
        //  self.performSegueWithIdentifier("third", sender: nil)
    }
    
    
    @IBAction func chooseimageAction(_ sender: AnyObject) {
        if(self.imageArray.count<5){
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            
            present(imagePicker, animated: true, completion: nil)
        }else{
            view.makeToast(message:"maximum 5 images are allowed", duration: 2, position: HRToastPositionCenter as AnyObject)
        }
        
    }
    func uploadFiles(){
        presentWindow!.makeToastActivity()
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append( UIImageJPEGRepresentation(self.imageArray[self.UploadCounter],0.8)!,withName: "productImage", fileName: self.filenames[self.UploadCounter], mimeType: "image/jpeg")
                
            },
            to: "\(baseUrl)fileupload/upload/product-image",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        switch response.result {
                        case .success(let data):
                            print(data)
                            let idenDocRes: IdentityDocumentResponse = Mapper<IdentityDocumentResponse>().map(JSONObject: data)!
                            
                            if(idenDocRes.responseStat.status != false){
                                self.imageToken.append(idenDocRes.responseData)
                                self.UploadCounter += 1
                                if(self.imageArray.count >  self.UploadCounter){
                                    self.uploadFiles()
                                }
                                else{
                                    self.presentWindow!.hideToastActivity()
                                    self.performSegue(withIdentifier: "third", sender:nil)
                                }
                            }else{
                                self.presentWindow!.hideToastActivity()
                               self.view.makeToast(message:idenDocRes.responseStat.requestErrors![0].msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                            }
                            
                        case .failure(let error):
                            print("Request failed with error: \(error)")
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let imageUrl          = info[UIImagePickerControllerReferenceURL] as! NSURL
        let imageName         = imageUrl.lastPathComponent
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let photoURL          = NSURL(fileURLWithPath: documentDirectory)
        let localPath         = photoURL.appendingPathComponent(imageName!)
        let image             = info[UIImagePickerControllerOriginalImage]as! UIImage
        let data              = UIImagePNGRepresentation(image)
        
        do
        {
            try data?.write(to: localPath!, options: Data.WritingOptions.atomic)
        }
        catch
        {
            // Catch exception here and act accordingly
        }
        
        self.filenames.append(imageName!)
        self.imageArray.append(image)
        self.imageCollection.reloadData()
        self.dismiss(animated: true, completion: nil);
    }
    
    //    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    //        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
    //            print("picked image :\(pickedImage)")
    //            self.imageArray.append(pickedImage)
    //            self.imageCollection.reloadData()
    //
    //        }
    //        if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL {
    //            let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
    //            let filename = result.firstObject?.filename ?? ""
    //            print(filename)
    //
    //            self.filenames.append(filename!)
    //        }
    //        dismiss(animated: true, completion: nil)
    //    }
    
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return   self.imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as!SelectedImageCollectionViewCell
        cell.frame.size.width = screenWidth / 3
        cell.frame.size.height = screenWidth / 3
        cell.imageView.image = imageArray[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        if indexPath.row == 0
        //        {
        //            return CGSize(width: screenWidth, height: screenWidth/3)
        //        }
        return CGSize(width: screenWidth/3, height: screenWidth/3);
        
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "third"){
            let contrller : PostItemThirdViewController = segue.destination as! PostItemThirdViewController
            contrller.productTitle = self.productTitle
            contrller.selectedCategory = self.selectedCategory
            contrller.address = self.address
            contrller.city = self.city
            contrller.zipCode = self.zipCode
            contrller.availableFrom = self.availableFrom
            contrller.availableTill = self.availableTill
            contrller.stateId = self.stateId
            contrller.Productdescription = self.productDescription.text!
            contrller.imageTokenArray  = self.imageToken
            
            
            self.navigationController!.navigationBar.barTintColor = UIColor(netHex:0x2D2D2D)
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(netHex:0xD0842D)]
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        }
    }
}
