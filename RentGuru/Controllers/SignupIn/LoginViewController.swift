//
//  ViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 7/29/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit


import Alamofire
import ObjectMapper
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import AddressBook
import MediaPlayer
import AssetsLibrary
import CoreLocation
import CoreMotion
import TwitterKit

class LoginViewController: UIViewController ,UITextFieldDelegate,GIDSignInUIDelegate,GIDSignInDelegate{
    @IBOutlet var twitterLoginButton: UIButton!
   // @IBOutlet var gplusLoginButton: GIDSignInButton!
    @IBOutlet var fbLoginbutton: UIButton!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var viewUnderEmail: UIView!
    @IBOutlet var viewUnderPassword: UIView!
    var signUpmsg  = ""
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    var accessToken : String = ""
 
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        emailText.delegate = self
        passwordText.delegate = self
        baseUrl = defaults.string(forKey: "baseUrl")!
        accessToken = defaults.string(forKey: "accesstoken")!
        //GIDSignIn.sharedInstance().uiDelegate = self
       
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewUnderEmail.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        self.viewUnderPassword.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        self.emailText.attributedPlaceholder = NSAttributedString(string: "Email", attributes:[NSForegroundColorAttributeName : UIColor.lightGray])
        self.passwordText.attributedPlaceholder = NSAttributedString(string: "Password", attributes:[NSForegroundColorAttributeName : UIColor.lightGray])
        
        
        if(self.signUpmsg != ""){
            view.makeToast(message:self.signUpmsg, duration: 2, position: HRToastPositionDefault as AnyObject)
        }
        
        
        //If you Already have an access token donnt irritate user
        self.loginWithAccessToken()
    }
    
    
    //This Method will be executed when you click on Login button
    @IBAction func signInAction(_ sender: AnyObject) {
        var check = true
        if(self.emailText.text == ""){
            check = false
            view.makeToast(message:"Email is required", duration: 2, position: HRToastPositionDefault as AnyObject)
        }
        if(self.passwordText.text == "" && check != false){
            check = false
            view.makeToast(message:"Password is required", duration: 2, position: HRToastPositionDefault as AnyObject)
        }
        if(!self.isValidEmail(self.emailText.text!) && check != false){
            check = false
            view.makeToast(message:"Invalid email", duration: 2, position: HRToastPositionDefault as AnyObject)
        }
        if(check != false){
            self.view.makeToastActivity()
            let paremeters: [String :AnyObject] =
                [ "email" : emailText.text! as AnyObject, "password"  : passwordText.text! as AnyObject]
            Alamofire.request( URL(string: "\(baseUrl)api/signin/by-email-password" )!,method:.post ,parameters: paremeters)
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                    self.view.hideToastActivity()
                    switch response.result {
                    case .success(let data):
                        print(data)
                        let loginRes: LoginResponse = Mapper<LoginResponse>().map(JSONObject: data as AnyObject)!
                        if(loginRes.responseStat.status != false){
                            self.defaults.set(loginRes.responseData!.accesstoken, forKey: "accesstoken")
                            
                            
                            
                            self.performSegue(withIdentifier: "logInsuccess", sender: nil)
                        }else{
                            self.view.makeToast(message:loginRes.responseStat.msg, duration: 2, position: HRToastPositionDefault as AnyObject)
                        }
                    case .failure(let error):
                        print(error)
                    }
            }
            
            
        }
        
    }
    
    func loginWithAccessToken()  {
        //cos "abc" is our default accesstoken , go check on appdelegate
        if(accessToken != "abc"){
            Alamofire.request( URL(string: "\(baseUrl)api/signin/by-accesstoken" )!, method:.post,parameters: ["accessToken": accessToken])
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                   // print(response)
                    switch response.result {
                    case .success(let data):
                        
                        let res: LoginResponse = Mapper<LoginResponse>().map(JSONObject: data)!
                        print(res)
                        if((res.responseStat.status) != false){
                           self.performSegue(withIdentifier: "logInsuccess", sender: nil)
                        }
                        
                    case .failure(let error):
                        print(error)
                        
                        
                    }
                    
            }
            
        }
        
    }
    
    //Twitter Login
    @IBAction func twitterLoginAction(_ sender: AnyObject) {
        Twitter.sharedInstance().logIn {
            (session, error) -> Void in
            if (session != nil) {
                
                print(session!.userID)
                print(session!.userName)
                print(session!.authToken)
                print(session!.authTokenSecret)
                
            }else {
                print("Not Login")
            }
        }
    }
    
    //Google Id Login
    @IBAction func gplusLoginAction(_ sender: AnyObject) {
      
        print("Hello")
        GIDSignIn.sharedInstance().uiDelegate = self
         GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    //Facebook Login
    @IBAction @objc func fbLoginAction(_ sender: AnyObject) {
         self.view.makeToastActivity()
        let login = FBSDKLoginManager()
        login.loginBehavior = FBSDKLoginBehavior.systemAccount
        login.logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: {(result, error) in
            if error != nil {
              //  print("Error :  \(error.description)")
            }
            else if (result?.isCancelled)! {
                
            }
            else {
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name, picture.type(large), email, name, id, gender"]).start(completionHandler: {(connection, result, error) -> Void in
                    if error != nil{
                     //   print("Error : \(error.description)")
                    }else{
                        // let token : String = result.accessToken
                        
                      //  print("userInfo is \(FBSDKAccessToken.currentAccessToken().tokenString))")
                        Alamofire.request( URL(string: "\(self.baseUrl)api/social-media/facebook/login/by-facebook-access-token" )!,method: .post ,parameters: ["accessToken": FBSDKAccessToken.current().tokenString])
                            .validate(contentType: ["application/json"])
                            .responseJSON { response in
                                switch response.result {
                                case .success(let data):
                                    print(data)
                                    let res: LoginResponse = Mapper<LoginResponse>().map(JSONObject: data)!
                                    if((res.responseStat.status) != false){
                                         self.defaults.set(res.responseData!.accesstoken, forKey: "accesstoken")
                                          self.performSegue(withIdentifier: "logInsuccess", sender: nil)
                                     //   print(res.responseData!.accesstoken)
                                    }
                                    
                                case .failure(let error):
                                    print(error)
                                    
                                    
                                }
                                
                        }
                        
                    }
                })
            }
            
        })
         self.view.hideToastActivity()
    }
    func isValidEmail(_ testStr:String) -> Bool {
        print("validate emilId: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    //MARK: - GoogleSignIn
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                withError error: Error!) {
         self.view.makeToastActivity()
        if (error == nil) {
            print("View Controller : \(user.authentication.accessToken)")
            Alamofire.request(URL(string: "\(self.baseUrl)api/social-media/google/login/by-google-access-token" )!,method:.post ,parameters: ["accessToken": user.authentication.accessToken])
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                         print(data)
                        let res: LoginResponse = Mapper<LoginResponse>().map(JSONObject: data)!
                       
                        if((res.responseStat.status) != false){
                            self.defaults.set(res.responseData!.accesstoken, forKey: "accesstoken")
                            self.performSegue(withIdentifier: "logInsuccess", sender: nil)
                          //print(res.responseData!.accesstoken)
                        }
                        
                    case .failure(let error):
                        print(error)
                        
                        
                    }
                    
            }
            
        
        } else {
            print("\(error.localizedDescription)")
        }
         self.view.hideToastActivity()
    }
    @nonobjc func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
   
   
    
    //MARK: - TextviewDelegate
    
    //The color switching under text field will be  controlled from here
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == self.emailText){
            self.viewUnderEmail.backgroundColor = UIColor(netHex:0x996600)
        }else{
            self.viewUnderEmail.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
        if(textField == self.passwordText){
            self.viewUnderPassword.backgroundColor = UIColor(netHex:0x996600)
        }else{
            self.viewUnderPassword.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == self.emailText){
            self.viewUnderEmail.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
        if(textField == self.passwordText){
            self.viewUnderPassword.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
    }
    
   
}

