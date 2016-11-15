//
//  EditProductImageViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/10/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Photos
class EditProductImageViewController: UIViewController ,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var productProfileImageview: UIImageView!
    @IBOutlet var otheriamgeCollection: UICollectionView!
    var editableProduct : MyRentalProduct?
    
    var defaults = UserDefaults.standard
    var baseUrl : String = ""
    var imageUrls :[String] = []
    var selectedImageIndex :Int = 0
    let imagePicker = UIImagePickerController()
    var imageArray : [UIImage] = []
    var imageToken  = Array<Int>()
    var filenames :[String] = []
    var pickingProfileImage :Bool = false
    var profileImage :UIImage?
    var profileImageFilename :String = ""
    var UploadCounter = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        baseUrl = defaults.string(forKey: "baseUrl")!
        self.otheriamgeCollection.delegate = self
        self.otheriamgeCollection.dataSource = self
        imagePicker.delegate = self
        let path = self.editableProduct?.profileImage.original.path!
        productProfileImageview.kf.setImage(with: URL(string: "\(baseUrl)/images/\(path!)")!,
                                            placeholder: nil,
                                            options: [.transition(.fade(1))],
                                            progressBlock: nil,
                                            completionHandler: nil)
        if(self.editableProduct?.otherImages.isEmpty) != false || self.editableProduct?.otherImages.count == 0{
            
        }else{
            // imageUrls.append((editableProduct?.profileImage.original.path)!)
            //
            //            for i in 0..<editableProduct?.otherImages.count{
            //                let dataImage : Picture  = product.otherImages[i]
            //                imageUrls.append(dataImage.original.path)
            //            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeProfilePictureAction(_ sender: UIButton) {
        //        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        self.pickingProfileImage = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func addOtherImageAction(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    func removeImage()  {
        print(self.selectedImageIndex)
        let dataImage : Picture  = (self.editableProduct?.otherImages[self.selectedImageIndex])!
        let path = (dataImage.original.path!)
        Alamofire.request(URL(string: "\(baseUrl)api/auth/product/delete-product/other-image" )!,method:.post ,parameters: ["productId":self.editableProduct?.id! as AnyObject,"path":path as AnyObject])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success(let data):
                    let res : Response = Mapper<Response>().map(JSONObject: data)!
                    if(res.responseStat.status != false){
                        self.view.makeToast(message:"Image delete successful", duration: 2, position: HRToastPositionDefault as AnyObject)
                        self.editableProduct?.otherImages.remove(at: self.selectedImageIndex)
                        self.otheriamgeCollection.reloadData()
                    }else{
                        self.view.makeToast(message:"Something went wrong", duration: 2, position: HRToastPositionDefault as AnyObject)
                    }
                    
                case .failure(let error):
                    print(error)
                }
        }
        
    }
    // MARK:- Collection view Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.editableProduct?.otherImages.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! EditOtherImageCollectionViewCell
        
        
        // Configure the cell
        let dataImage : Picture  = (self.editableProduct?.otherImages[indexPath.row])!
        let path = (dataImage.original.path!)
        print(path)
        cell.imageView.kf.setImage(with: URL(string: "\(baseUrl)/images/\(path)")!,
                                   placeholder: nil,
                                   options: [.transition(.fade(1))],
                                   progressBlock: nil,
                                   completionHandler: nil)
        
        
        
        self.selectedImageIndex = indexPath.row
        cell.removeBtn.addTarget(self, action: #selector(self.removeImage), for: .touchUpInside)
        
        return cell
        
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (otheriamgeCollection.frame.width)
        if width < 500 {
            let numberOfItemsPerRow:CGFloat = 2.0
            let widthAdjustment = CGFloat(10.0)
            let cellWidth = (width - widthAdjustment) / numberOfItemsPerRow
            let cellHeight =  cellWidth + 3.0
            return CGSize(width: cellWidth , height: cellHeight)
        }
        else {
            let numberOfItemsPerRow:CGFloat = 3.0
            let widthAdjustment =  CGFloat(15.0)
            let cellWidth = (width - widthAdjustment) / numberOfItemsPerRow
            let cellHeight =  cellWidth + 3.0
            return CGSize(width: cellWidth , height: cellHeight)
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.otheriamgeCollection.reloadData()
        self.view.layoutIfNeeded()
    }
    // MARK: - UIImagePickerControllerDelegate Methods
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
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
        if(pickingProfileImage != false){
            self.profileImage  = image
            self.profileImageFilename = imageName!
            self.uploadProfileImage()
        }else{
            self.filenames.append(imageName!)
            self.imageArray.append(image)
            self.uploadOtherImages()
        }
        //        self.filenames.append(imageName!)
        //        self.imageArray.append(image)
        //        self.imageCollection.reloadData()
        self.dismiss(animated: true, completion: nil);
    }
    
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK: - APIAccess
    func uploadProfileImage(){
        self.view.makeToastActivity()
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append( UIImageJPEGRepresentation(self.profileImage!,0.8)!,withName: "productImage", fileName:  self.profileImageFilename , mimeType: "image/jpeg")
                
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
                                self.view!.hideToastActivity()
                                self.imageToken.append(idenDocRes.responseData)
                                self.saveNewImage(token: self.imageToken, type: "profileImageToken")
                                //                                self.UploadCounter += 1
                                //                                if(self.imageArray.count >  self.UploadCounter){
                                //                                    self.uploadFiles()
                                //                                }
                                //                                else{
                                //                                    self.presentWindow!.hideToastActivity()
                                //                                    self.performSegue(withIdentifier: "third", sender:nil)
                                //                                }
                            }else{
                                self.view!.hideToastActivity()
                                self.view.makeToast(message:idenDocRes.responseStat.requestErrors![0].msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                            }
                            
                        case .failure(let error):
                            self.view!.hideToastActivity()
                            print("Request failed with error: \(error)")
                        }
                    }
                case .failure(let encodingError):
                    self.view!.hideToastActivity()
                    print(encodingError)
                }
        }
        )
        
    }
    func  uploadOtherImages(){
        self.view.makeToastActivity()
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append( UIImageJPEGRepresentation(self.imageArray[self.UploadCounter],0.8)!,withName: "productImage", fileName: self.filenames[self.UploadCounter], mimeType: "image/jpeg")
                
        },
            to: "\(baseUrl)fileupload/upload/product-image",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        //debugPrint(response)
                        switch response.result {
                        case .success(let data):
                            print(data)
                            let idenDocRes: IdentityDocumentResponse = Mapper<IdentityDocumentResponse>().map(JSONObject: data)!
                            
                            if(idenDocRes.responseStat.status != false){
                                self.imageToken.append(idenDocRes.responseData)
                                self.UploadCounter += 1
                                if(self.imageArray.count >  self.UploadCounter){
                                    self.uploadOtherImages()
                                }
                                else{
                                    self.view!.hideToastActivity()
                                   self.saveNewImage(token: self.imageToken, type: "otherImagesToken")
                                }
                            }else{
                                self.view!.hideToastActivity()
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
    func saveNewImage(token : [Int], type imageType : String){
        
      self.view.makeToastActivity()
        var paremeters  : [String :AnyObject] = [:]
        if(imageType == "profileImageToken"){
            paremeters["profileImageToken"] = token[0] as AnyObject?
        }else if(imageType == "otherImagesToken"){
            paremeters["otherImagesToken"] = "\(token)" as AnyObject?
        }
        print("paremeters :\(paremeters)")
        Alamofire.request(URL(string: "\(baseUrl)api/auth/product/update-product/\((self.editableProduct?.id!)!)" )!,method:.post ,parameters: paremeters)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                print(response)
                switch response.result {
                case .success(let data):
                    let productRes: EditProductResponse = Mapper<EditProductResponse>().map(JSONObject: data)!
                    if((productRes.responseStat.status) != false){
                        
                        self.view.makeToast(message:"Product Updated successfully", duration: 2, position: HRToastPositionCenter as AnyObject)
                        self.editableProduct? = (productRes.responseData)!
                        if(imageType == "profileImageToken"){
                            let path = self.editableProduct?.profileImage.original.path!
                            print("path :\(path!)")
                            self.productProfileImageview.kf.setImage(with: URL(string: "\(self.baseUrl)/images/\(path!)")!,
                                                                placeholder: nil,
                                                                options: [.transition(.fade(1))],
                                                                progressBlock: nil,
                                                                completionHandler: nil)
                            self.view.hideToastActivity()
                        }else{
                            
                            
                            self.otheriamgeCollection.reloadData()
                            self.view.hideToastActivity()
                        }
                        
                        //                        self.currentPrice.text = ""
                        //                        self.rentFee.text = ""
                        //                        if let tabBarController = self.presentWindow!.rootViewController as? UITabBarController {
                        //                            tabBarController.selectedIndex = 1
                        //                        }
                        
                    }else{
                        self.view.hideToastActivity()
                        if(productRes.responseStat.msg == ""){
                            self.view.makeToast(message:productRes.responseStat.requestErrors![0].msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                        }else{
                            self.view.makeToast(message:productRes.responseStat.msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                        }
                        
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
