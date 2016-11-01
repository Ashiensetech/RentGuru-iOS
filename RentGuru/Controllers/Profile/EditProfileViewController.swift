//
//  EditProfileViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/1/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import ObjectMapper
import Photos
class EditProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var oldPassword: UITextField!
    @IBOutlet var newPassword: UITextField!
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    let imagePicker = UIImagePickerController()
    var image :UIImage? = UIImage()
    var filename : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        baseUrl = defaults.string(forKey: "baseUrl")!
        imagePicker.delegate = self
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Edit Profile"
        let delegate = AppDelegate.getDelegate()
        let credential : AuthCredential = delegate.authCredential!
        //  print("credential :\()");
        
        self.firstName.text = credential.userInf.firstName!
        self.lastName.text = credential.userInf.lastName!
        self.email.text = credential.email!
        let path = credential.userInf.profilePicture?.original!.path!
        if(path != ""){
            self.profileImageView.kf.setImage(with: URL(string: "\(baseUrl)profile-image/\(path!)")!,
                                              placeholder: nil,
                                              options: [.transition(.fade(1))],
                                              progressBlock: nil,
                                              completionHandler: nil)
        }else{
          self.profileImageView.image =  UIImage(named: "dummy.png")
        }
        
       
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cahngeProfilePicAction(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func saveChangeAction(_ sender: AnyObject) {
        var checkAll :Bool = true
        if(self.firstName.text == ""){
            self.view.makeToast(message:"First Name Required", duration: 2, position: HRToastPositionDefault as AnyObject)
            checkAll = false
        }
        if(self.lastName.text == ""){
            self.view.makeToast(message:"Last Name Required", duration: 2, position: HRToastPositionDefault as AnyObject)
            checkAll = false
        }
        if(self.email.text == ""){
            self.view.makeToast(message:"Email Required", duration: 2, position: HRToastPositionDefault as AnyObject)
            checkAll = false

        }
        if(self.newPassword.text != "" && self.oldPassword.text == ""){
            self.view.makeToast(message:"Enter your current password", duration: 2, position: HRToastPositionDefault as AnyObject)
            checkAll = false

        }
        if((self.newPassword.text?.characters.count)! > 6 ){
            self.view.makeToast(message:"Password must be atleast 6 characters ", duration: 2, position: HRToastPositionDefault as AnyObject)
            checkAll = false

        }
        if( checkAll != false){
             var  paremeters :[String:AnyObject] = [:]
            let delegate = AppDelegate.getDelegate()
            let credential : AuthCredential = delegate.authCredential!
            if(credential.userInf.firstName! != self.firstName.text){
                paremeters["firstName"] = self.firstName.text as AnyObject?
            }
            if(credential.userInf.lastName! != self.lastName.text){
                paremeters["lastName"] = self.lastName.text as AnyObject?
            }
            if(credential.email != self.email.text){
                paremeters["email"] = self.lastName.text as AnyObject?
            }
            if(self.newPassword.text != ""){
                paremeters["email"] = self.lastName.text as AnyObject?
            }
            if(paremeters.isEmpty != true){
                 self.view!.makeToastActivity()
                Alamofire.request( URL(string: "\(baseUrl)api/auth/profile/edit" )!, method:.post,parameters: paremeters)
                    .validate(contentType: ["application/json"])
                    .responseJSON { response in
                        // print(response)
                        switch response.result {
                        case .success(let data):
                            let res: LoginResponse = Mapper<LoginResponse>().map(JSONObject: data)!
                            print(res)
                            if((res.responseStat.status) != false){
                                let delegate = AppDelegate.getDelegate()
                                delegate.authCredential = res.responseData!
                               
                                self.firstName.text = delegate.authCredential?.userInf.firstName!
                                self.lastName.text = delegate.authCredential?.userInf.lastName!
                                self.email.text = delegate.authCredential?.email!
                                self.view.makeToast(message:"Profile info saved", duration: 2, position: HRToastPositionDefault as AnyObject)
                                self.view.hideToastActivity()
                            }
                            
                        case .failure(let error):
                            self.view.hideToastActivity()
                            print(error)
                            
                            
                        }
                        
                }
                
            }
            
        }
    }
    
    // MARK: - ImagePicker
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
        self.filename = imageName!
        self.image  = image
        self.uploadFile()
        self.dismiss(animated: true, completion: nil);
    }
    
    func uploadFile() {
        print("uploadFile")
        self.view!.makeToastActivity()
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(UIImageJPEGRepresentation(self.image!,0.8)!, withName: "profileImage", fileName: self.filename, mimeType: "image/jpeg")
            },
            to: "\(baseUrl)fileupload/upload/auth/user/profile-image",
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
                                print(idenDocRes.responseData)
                                Alamofire.request( URL(string: "\(self.baseUrl)api/auth/profile/edit" )!, method:.post,parameters: ["profileImageToken": idenDocRes.responseData])
                                    .validate(contentType: ["application/json"])
                                    .responseJSON { response in
                                        // print(response)
                                        switch response.result {
                                        case .success(let data):
                                            
                                            let res: LoginResponse = Mapper<LoginResponse>().map(JSONObject: data)!
                                            print(res)
                                            if((res.responseStat.status) != false){
                                                let delegate = AppDelegate.getDelegate()
                                                delegate.authCredential = res.responseData!
                                                let path = delegate.authCredential?.userInf.profilePicture?.original!.path!
                                                print("link : \(self.baseUrl)profile-image/\(path!))")
                                                self.profileImageView.kf.setImage(with: URL(string: "\(self.baseUrl)profile-image/\(path!)")!,
                                                                                  placeholder: nil,
                                                                                  options: [.transition(.fade(1))],
                                                                                  progressBlock: nil,
                                                                                  completionHandler: nil)
                                                self.view.makeToast(message:"Profile image changed", duration: 2, position: HRToastPositionDefault as AnyObject)
                                                self.view.hideToastActivity()
                                            }
                                            
                                        case .failure(let error):
                                            print(error)
                                            
                                            
                                        }
                                        
                                }
                                
                                
                                
                            }
                            
                        case .failure(let error):
                            self.view.hideToastActivity()
                            print("Request failed with error: \(error)")
                        }
                    }
                case .failure(let encodingError):
                    self.view.hideToastActivity()
                    print(encodingError)
                }
            }
        )
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
