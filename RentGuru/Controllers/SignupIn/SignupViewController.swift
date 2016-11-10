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

class SignupViewController: UIViewController ,UITextFieldDelegate {
   
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var viewUnderPassword: UIView!
    @IBOutlet var viewUnderEmail: UIView!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var viewUnderLastname: UIView!
    @IBOutlet var lastNameTxt: UITextField!
    @IBOutlet var viewUnderFirstname: UIView!
    @IBOutlet var firstNameTxt: UITextField!

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
   
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.viewUnderEmail.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        self.viewUnderFirstname.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        self.viewUnderLastname.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        self.viewUnderPassword.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
     
        
        
        self.emailTxt.attributedPlaceholder = NSAttributedString(string: "Email", attributes:[NSForegroundColorAttributeName : UIColor.lightGray])
        self.firstNameTxt.attributedPlaceholder = NSAttributedString(string: "First Name", attributes:[NSForegroundColorAttributeName : UIColor.lightGray])
        self.lastNameTxt.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes:[NSForegroundColorAttributeName : UIColor.lightGray])
        self.passwordTxt.attributedPlaceholder = NSAttributedString(string: "Password", attributes:[NSForegroundColorAttributeName : UIColor.lightGray])
    
        
        
        
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

   
    
    
    func isValidEmail(_ testStr:String) -> Bool {
        print("validate emilId: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
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
            view.makeToast(message:"First Name Is required", duration: 2, position: HRToastPositionCenter as AnyObject)
            
        }
        if(self.lastNameTxt.text == "" && checkAll != false)
        {
            checkAll = false
            view.makeToast(message:"Last Name Is required", duration: 2, position: HRToastPositionCenter as AnyObject)
            
        }
        if(self.emailTxt.text == "" && checkAll != false)
        {
            checkAll = false
            view.makeToast(message:"Email Is required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }
        if(!self.isValidEmail(self.emailTxt.text!) && checkAll != false){
            checkAll = false
            view.makeToast(message:"Invalid email", duration: 2, position: HRToastPositionCenter as AnyObject)
        }
        if(self.passwordTxt.text == "" && checkAll != false){
            checkAll = false
            view.makeToast(message:"Password is required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }
        
        
        if(checkAll != false){
            
            //Now we have to upload image to get token ,then we will sign up
             self.view.makeToastActivity()
            let firstname =  self.firstNameTxt.text
            let lastName = self.lastNameTxt.text
            let email = self.emailTxt.text
            let passWord = self.passwordTxt.text
       
            
            let dict : [String : AnyObject] =
                ["firstName":firstname! as AnyObject,"lastName":lastName! as AnyObject ,"email" :email! as AnyObject ,"password" :passWord! as AnyObject]
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
