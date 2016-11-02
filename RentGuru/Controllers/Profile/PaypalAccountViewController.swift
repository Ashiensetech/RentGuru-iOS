//
//  PaypalAccountViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/2/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class PaypalAccountViewController: UIViewController {
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    var oldAccount : String = ""
    @IBOutlet var accountEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
         baseUrl = defaults.string(forKey: "baseUrl")!
        self.tabBarController?.tabBar.isHidden = true
         self.hideKeyboardWhenTappedAround()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Paypal Account"
       
        let btn1 = UIButton(type: .custom)
       // btn1.setImage(UIImage(named: "imagename"), for: .normal)
        btn1.setTitle("Save", for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn1.addTarget(self, action: #selector(PaypalAccountViewController.saveAccount), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        
         self.navigationItem.setRightBarButtonItems([item1], animated: true)
        self.getMyAccount()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
       
    }
    
    //MARK: - Navigation
    func getMyAccount() {
        Alamofire.request( URL(string: "\(baseUrl)api/auth/paypal/get/my-paypal-account-email" )!, method:.get,parameters: [:])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                // print(response)
                switch response.result {
                case .success(let data):
                   
                    let res: PaypalAccountResponse = Mapper<PaypalAccountResponse>().map(JSONObject: data)!

                    if((res.responseStat.status) != false){
                        
                        self.accountEmail.text = res.responseData?.email!
                        self.oldAccount = (res.responseData?.email!)!
                    }
                    
                case .failure(let error):
                    print(error)
                    
                    
                }
                
        }
    }
    func  saveAccount()  {
        if(self.accountEmail.text! != self.oldAccount){
            self.view.makeToastActivity()
            Alamofire.request( URL(string: "\(baseUrl)api/auth/paypal/add-update/my-paypal-account-email" )!, method:.post,parameters: ["email": self.accountEmail.text!])
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                    // print(response)
                    switch response.result {
                    case .success(let data):
                        print(data)
                        let res: Response = Mapper<Response>().map(JSONObject: data)!
                        
                        if((res.responseStat.status) != false){
                            self.view.makeToast(message:"Save Successfully", duration: 2, position: HRToastPositionCenter as AnyObject)
                            
                        }else{
                            self.accountEmail.text! = self.oldAccount
                            self.view.makeToast(message:(res.responseStat.requestErrors?[0].msg)!, duration: 2, position: HRToastPositionCenter as AnyObject)
                        }
                        self.view.hideToastActivity()
                    case .failure(let error):
                        print(error)
                        self.view.hideToastActivity()
                        
                    }
                    
            }
        }
       
    }
    
    //api/auth/paypal/get/my-paypal-account-email

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
