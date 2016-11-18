//
//  PostItemThirdViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/11/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import DropDown
import Alamofire
import ObjectMapper

class PostItemThirdViewController: UIViewController {
    
    @IBOutlet var dropDownImage: UIImageView!
    @IBOutlet var dropDownLabel: UILabel!
    @IBOutlet var dropDownContainer: UIView!
    @IBOutlet var rentFee: UITextField!
    @IBOutlet var currentPrice: UITextField!
    let dropDown =  DropDown()
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    var rentTypeList : [RentType]!
    var rentTypeId : Int!
    var selectedCategory : [Int]!
    var productTitle: String!
    var availableFrom: String!
    var availableTill :String!
    var address :String!
    var city: String!
    var zipCode : String!
    var Productdescription: String!
    var imageTokenArray : [Int]!
    var rentType : Int!
    var presentWindow : UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentWindow = UIApplication.shared.keyWindow
        self.hideKeyboardWhenTappedAround()
        baseUrl = defaults.string(forKey: "baseUrl")!
        self.dropDownImage.isUserInteractionEnabled = true
        self.dropDownContainer.isUserInteractionEnabled = true
        let subCateGesture = UITapGestureRecognizer(target: self, action:#selector(PostItemThirdViewController.showHideDropDown) )
        self.dropDownContainer.addGestureRecognizer(subCateGesture)
        self.dropDownImage.addGestureRecognizer(subCateGesture)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Priceing"
        let button = UIButton(type: UIButtonType.system) as UIButton
        //button.setImage(UIImage(named: "back.png"), forState: UIControlState.Normal)
        button.setTitle("Done", for:UIControlState())
        button.tintColor = UIColor.white
        button.addTarget(self, action:#selector(PostItemThirdViewController.submitProduct), for: UIControlEvents.touchUpInside)
        button.frame=CGRect(x: 0, y: 0, width: 40, height: 40)
        let barButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.rightBarButtonItem = barButton
        
        dropDown.anchorView = self.dropDownContainer
        // dropDown.dataSource = ["Daily", "Weekly","Monthly"]
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            // print("Selected item: \(item) at index: \(index)")
            self.dropDownLabel.attributedText  =  NSAttributedString(string: (item), attributes:[NSForegroundColorAttributeName : UIColor.gray])
            self.rentTypeId = self.rentTypeList[index].id
        }
        dropDown.backgroundColor = UIColor.white
        dropDown.textColor = UIColor.gray
        dropDown.selectionBackgroundColor = UIColor(netHex:0xD0842D)
        self.getRentType()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func showHideDropDown() {
        print( "Hello")
        dropDown.show();
    }
    
    func submitProduct() {
        var checkAll = true
        
        if(self.currentPrice.text == ""){
            checkAll = false
            view.makeToast(message:"current market value is required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }
        if(self.rentFee.text == "" && checkAll != false){
            checkAll = false
            view.makeToast(message:"rent fee is required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }
        if(self.rentTypeId == nil && checkAll != false){
            checkAll = false
            view.makeToast(message:"rent fee for is  required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }
        if(checkAll != false){
            presentWindow!.makeToastActivity()
            
            var tokenArray:[Int] = []
            for i in 0  ..< self.imageTokenArray.count {
                if(i != 0 ){
                    tokenArray.append(self.imageTokenArray![i])
                }
            }
            let name          = self.productTitle! as AnyObject
            let description   = self.Productdescription! as AnyObject
            let  profileImageToken = self.imageTokenArray![0] as AnyObject
            let otherImageToken = "\(tokenArray)" as AnyObject
            let currentValue = self.currentPrice.text! as AnyObject
            let rentFee =  self.rentFee.text! as AnyObject
            let avaiableFrom = self.availableFrom! as AnyObject
            let availableTill = self.availableTill! as AnyObject
            let categoryIds = "\(self.selectedCategory)" as AnyObject
            let formattedAdd = self.address! as AnyObject
            let zipCode =  self.zipCode! as AnyObject
            let city = self.city! as AnyObject
            let rentTypeId = self.rentTypeId! as AnyObject
            
            var paremeters : [String :AnyObject] = [:]
            paremeters["name"] = name
            paremeters["description"] = description
            paremeters["profileImageToken"] = profileImageToken
            paremeters["otherImagesToken"] = otherImageToken
            paremeters["currentValue"] = currentValue
            paremeters["rentFee"] = rentFee
            paremeters["availableFrom"] = avaiableFrom
            paremeters["availableTill"] = availableTill
            paremeters["categoryIds"] = categoryIds
            paremeters["formattedAddress"] = formattedAdd
            paremeters["zip"] = zipCode
            paremeters["city"] = city
            paremeters["rentTypeId"] = rentTypeId
            
            print(paremeters)
            Alamofire.request( URL(string: "\(baseUrl)api/auth/product/upload" )!,method:.post ,parameters: paremeters)
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                    print(response)
                    self.presentWindow!.hideToastActivity()
                    switch response.result {
                    case .success(let data):
                        
                        let productRes: PostProductResponse = Mapper<PostProductResponse>().map(JSONObject: data)!
                        if((productRes.responseStat.status) != false){
                            
                            self.view.makeToast(message:"Product Posted successfully", duration: 2, position: HRToastPositionCenter as AnyObject)
                            self.currentPrice.text = ""
                            self.rentFee.text = ""
                            if let tabBarController = self.presentWindow!.rootViewController as? UITabBarController {
                                tabBarController.selectedIndex = 1
                            }
                            
                        }else{
                            self.view.makeToast(message:productRes.responseStat.requestErrors![0].msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                        }
                    case .failure(let error):
                        print(error)
                    }
            }
            
            //
        }
    }
    
    func  getRentType()  {
        Alamofire.request(URL(string: "\(baseUrl)api/utility/get-rent-type" )!,method:.get ,parameters: [:])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                //print(response)
                switch response.result {
                case .success(let data):
                    
                    let rentTypeRes: RentTypeResponse = Mapper<RentTypeResponse>().map(JSONObject: data)!
                    if((rentTypeRes.responseStat.status) != false){
                        
                        self.rentTypeList = rentTypeRes.responseData!
                        var cateSource = Array<String>() ;
                        for i in 0  ..< self.rentTypeList.count {
                            cateSource.append(self.rentTypeList[i].name)
                        }
                        self.dropDown.dataSource = cateSource
                    }
                case .failure(let error):
                    print(error)
                }
        }
        
    }
}
