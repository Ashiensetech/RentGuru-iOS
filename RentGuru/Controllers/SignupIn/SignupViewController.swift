//
//  SignupViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/2/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit




import DropDown
import Alamofire
import ObjectMapper
import Toast_Swift
import Photos
class SignupViewController: UIViewController ,UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    @IBOutlet var viewUnderIdentyLabel: UIView!
    @IBOutlet var identityLabel: UILabel!
    @IBOutlet var dropDownCotainer: UIView!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var viewUnderPassword: UIView!
    @IBOutlet var viewUnderEmail: UIView!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var viewUnderLastname: UIView!
    @IBOutlet var lastNameTxt: UITextField!
    @IBOutlet var viewUnderFirstname: UIView!
    @IBOutlet var firstNameTxt: UITextField!
    let imagePicker = UIImagePickerController()
    let dropDown = DropDown ()
    var isDropDownHidden = true
    var image :UIImage? = UIImage()
    var filename : String!
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    var identityTypeList = [IdentityType]()
    var selectedIdentityIndex  = 0;
    var singupMsg : String = ""
    var presentWindow : UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        baseUrl = defaults.string(forKey: "baseUrl")!
        presentWindow = UIApplication.shared.keyWindow
        
        imagePicker.delegate = self
        
        self.emailTxt.delegate = self
        self.firstNameTxt.delegate = self
        self.lastNameTxt.delegate = self
        self.passwordTxt.delegate = self
        
        self.navigationController!.navigationBar.barTintColor = UIColor(netHex:0x2D2D2D)
        
        let button = UIButton(type: UIButtonType.custom) as UIButton
        button.setImage(UIImage(named: "back-arrow"), for: UIControlState())
        button.addTarget(self, action:#selector(SignupViewController.backToLogin), for: UIControlEvents.touchUpInside)
        button.frame=CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        self.navigationItem.title = "Sign Up"
        let gesture = UITapGestureRecognizer(target: self, action:#selector(SignupViewController.showHideDropDown) )
        self.dropDownCotainer.addGestureRecognizer(gesture)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.viewUnderEmail.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        self.viewUnderFirstname.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        self.viewUnderLastname.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        self.viewUnderPassword.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        self.viewUnderIdentyLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        
        
        self.emailTxt.attributedPlaceholder = NSAttributedString(string: "Email", attributes:[NSForegroundColorAttributeName : UIColor.lightGray])
        self.firstNameTxt.attributedPlaceholder = NSAttributedString(string: "First Name", attributes:[NSForegroundColorAttributeName : UIColor.lightGray])
        self.lastNameTxt.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes:[NSForegroundColorAttributeName : UIColor.lightGray])
        self.passwordTxt.attributedPlaceholder = NSAttributedString(string: "Password", attributes:[NSForegroundColorAttributeName : UIColor.lightGray])
        self.identityLabel.attributedText  =  NSAttributedString(string: "Identity Type", attributes:[NSForegroundColorAttributeName : UIColor.lightGray])
        
        
        self.getIdentityTypes()
        
        print(self.identityTypeList.count)
        
        // The view to which the drop down will appear on
        dropDown.anchorView = self.dropDownCotainer
        
        //dropdown onSelect method
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.identityLabel.attributedText  =  NSAttributedString(string: (item), attributes:[NSForegroundColorAttributeName : UIColor.white])
            self.selectedIdentityIndex = self.identityTypeList[index].id
        }
        dropDown.backgroundColor = UIColor.black
        dropDown.textColor = UIColor.white.withAlphaComponent(1)
        dropDown.selectionBackgroundColor = UIColor(netHex:0xD0842D)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    func backToLogin() {
        self.performSegue(withIdentifier: "backToLogin", sender: nil)
        
    }
    func showHideDropDown()  {
        dropDown.show()
        
    }
    @IBAction func chooseimageAction(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func isValidEmail(_ testStr:String) -> Bool {
        print("validate emilId: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    func getIdentityTypes(){
        
        Alamofire.request(URL(string: "\(baseUrl)api/utility/get-identity" )!,method:.get ,parameters: [:])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    print(data)
                    let idenRes: IdentityTypeResponse = Mapper<IdentityTypeResponse>().map(JSONObject: data)!
                    if((idenRes.responseStat.status) != false){
                        self.identityTypeList = idenRes.responseData
                        var animDictionary = Array<String>()
                        for i in 0 ..< self.identityTypeList.count{
                            animDictionary.append(self.identityTypeList[i].name)
                        }
                        self.dropDown.dataSource = animDictionary
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    //    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    //        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
    //            //                    imageView.contentMode = .ScaleAspectFit
    //            //                    imageView.image = pickedImage
    //            print("picked image :\(pickedImage)")
    //            self.image = pickedImage
    //        }
    //        if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL {
    ////            let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
    ////            let filename = result.firstObject.filename
    ////           self.filename = filename!
    //        }
    //        dismiss(animated: true, completion: nil)
    //    }
    //
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
        
        
        self.dismiss(animated: true, completion: nil);
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - UITextFieldDelegate Methods
    
    //The color switching things are done here
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == self.emailTxt){
            self.viewUnderEmail.backgroundColor = UIColor(netHex:0xD0842D)
        }else{
            self.viewUnderEmail.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
        if(textField == self.firstNameTxt){
            self.viewUnderFirstname.backgroundColor = UIColor(netHex:0xD0842D)
        }else{
            self.viewUnderFirstname.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
        if(textField == self.lastNameTxt){
            self.viewUnderLastname.backgroundColor = UIColor(netHex:0xD0842D)
        }else{
            self.viewUnderLastname.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
        if(textField == self.passwordTxt){
            self.viewUnderPassword.backgroundColor = UIColor(netHex:0xD0842D)
        }else{
            self.viewUnderPassword.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == self.emailTxt){
            self.viewUnderEmail.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
        if(textField == self.firstNameTxt){
            self.viewUnderFirstname.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
        if(textField==self.lastNameTxt){
            self.viewUnderLastname.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
        if(textField == self.passwordTxt){
            self.viewUnderPassword.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
    }
    
    //MARK: - Signup
    //when sign up button is clicked
    //Api Access , cos you cant signup without  letting server know
    
    @IBAction func submitButtonAction(_ sender: AnyObject) {
      
        var checkAll = true
        
        if(self.firstNameTxt.text == ""){
            checkAll = false
            view.makeToast(message:"First Name Is required", duration: 2, position: HRToastPositionDefault as AnyObject)
            
        }
        if(self.lastNameTxt.text == "" && checkAll != false)
        {
            checkAll = false
            view.makeToast(message:"Last Name Is required", duration: 2, position: HRToastPositionDefault as AnyObject)
            
        }
        if(self.emailTxt.text == "" && checkAll != false)
        {
            checkAll = false
            view.makeToast(message:"Email Is required", duration: 2, position: HRToastPositionDefault as AnyObject)
        }
        if(!self.isValidEmail(self.emailTxt.text!) && checkAll != false){
            checkAll = false
            view.makeToast(message:"Invalid email", duration: 2, position: HRToastPositionDefault as AnyObject)
        }
        if(self.passwordTxt.text == "" && checkAll != false){
            checkAll = false
            view.makeToast(message:"Password is required", duration: 2, position: HRToastPositionDefault as AnyObject)
        }
        if(self.selectedIdentityIndex == 0  && checkAll != false){
            checkAll = false
            view.makeToast(message:"Identity Type Required", duration: 2, position: HRToastPositionDefault as AnyObject)
        }
        if(UIImageJPEGRepresentation(self.image!,0.8) == nil && checkAll != false){
            checkAll = false
            view.makeToast(message:"Identity Doc Required", duration: 2, position: HRToastPositionDefault as AnyObject)
        }
        
        if(checkAll != false){
            
            //Now we have to upload image to get token ,then we will sign up
             self.view.makeToastActivity()
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(UIImageJPEGRepresentation(self.image!,0.8)!, withName: "documentIdentity", fileName: self.filename, mimeType: "image/jpeg")
                },
                to: "\(baseUrl)fileupload/upload/document-identity",
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                            switch response.result {
                            case .success(let data):
                                // print(data)
                                let idenDocRes: IdentityDocumentResponse = Mapper<IdentityDocumentResponse>().map(JSONObject: data)!
                                
                                if(idenDocRes.responseStat.status != false){
                                    // print(idenDocRes.responseData)
                                    let firstname =  self.firstNameTxt.text
                                    let lastName = self.lastNameTxt.text
                                    let email = self.emailTxt.text
                                    let passWord = self.passwordTxt.text
                                    let identityType = self.selectedIdentityIndex
                                    
                                    
                                    
                                    let dict : [String : AnyObject] =
                                        ["firstName":firstname! as AnyObject,"lastName":lastName! as AnyObject ,"email" :email! as AnyObject ,"password" :passWord! as AnyObject,"identityTypeId" : identityType as AnyObject,"identityDocToken" : "\(idenDocRes.responseData! )" as AnyObject]
                                    print(dict)
                                    // //URL(string: "\(self!.baseUrl)api/signup/user" )!
                                    Alamofire.request(URL(string: "\(self.baseUrl)api/signup/user" )!, method: .post, parameters: dict)
                                        .validate(contentType: ["application/json"])
                                        .responseJSON { response in
                                            print(response)
                                            switch response.result {
                                            case .success(let data):
                                                let signUpRes: SignUpResponse = Mapper<SignUpResponse>().map(JSONObject: data)!
                                                print(signUpRes.responseStat.status)
                                                if(signUpRes.responseStat.status != false){
                                                    self.singupMsg = "Signup Successful"
                                                    self.backToLogin()
                                                    
                                                }else{
                                                    
                                                    print(signUpRes.responseStat)
                                                     self.view.hideToastActivity()
                                                    self.view.makeToast(message:signUpRes.responseStat.requestErrors![0].msg, duration: 2, position: HRToastPositionDefault as AnyObject)
                                                    
                                                }
                                                
                                            case .failure(let error):
                                                print(error)
                                            }
                                    }
                                    
                                    
                                }else{
                                    print(idenDocRes.responseStat)
                                    
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
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "backToLogin"){
            let contrller : LoginViewController = segue.destination as! LoginViewController
            contrller.signUpmsg = self.singupMsg
        }
    }
    
    
}
