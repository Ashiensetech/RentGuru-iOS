//
//  MyProductsViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/23/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
class MyProductsViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var myProductTable: UITableView!
    
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    var presentWindow : UIWindow?
    var offset : Int = 0
    var productList : [MyRentalProduct]! = []
    var isData : Bool = true
    var editableProduct : MyRentalProduct?
    override func viewDidLoad() {
        super.viewDidLoad()
        presentWindow = UIApplication.shared.keyWindow
        baseUrl = defaults.string(forKey: "baseUrl")!
        self.myProductTable.delegate = self
        self.myProductTable.dataSource = self
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "My Products"
        self.getMyProductRentalProduct()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- TableviewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyProductTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MyProductTableViewCell
        let  data : MyRentalProduct = self.productList[(indexPath as NSIndexPath).row]
        let path = data.profileImage.original.path!
        cell.productImageView.kf.setImage(with: URL(string: "\(baseUrl)/images/\(path)")!,
                                          placeholder: nil,
                                          options: [.transition(.fade(1))],
                                          progressBlock: nil,
                                          completionHandler: nil)
        //        cell.productImageView.kf_setImageWithURL(URL(string: "\(baseUrl)/images/\(data.profileImage.original.path)")!,
        //                                                 placeholderImage: nil,
        //                                                 optionsInfo: nil,
        //                                                 progressBlock: { (receivedSize, totalSize) -> () in },
        //                                                 completionHandler: { (image, error, cacheType, imageURL) -> () in  }
        //        )
        cell.productName.text = data.name
        var cateString : String = ""
        for i in 0 ..< data.productCategories.count{
            if(i == 0){
                cateString = "\(data.productCategories[i].category.name!)"
            }else {
                cateString = "\(cateString), \(data.productCategories[i].category.name!)"
            }
        }
        
        
        
        
        cell.category.text = cateString
        
        
        let timeInter1 :TimeInterval = data.availableFrom as TimeInterval
        let date1 = Date(timeIntervalSince1970: timeInter1/1000)
        let timeInter2 :TimeInterval = data.availableTill as TimeInterval
        let date2 = Date(timeIntervalSince1970: timeInter2/1000)
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd YYYY"
        
        
        
        let dateString1 = dayTimePeriodFormatter.string(from: date1)
        let dateString2 = dayTimePeriodFormatter.string(from: date2)
        
        cell.dateRange.text = "\(dateString1) to \(dateString2)"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let  data : MyRentalProduct = self.productList[indexPath.row]
        //        print(data.id)
        //        self.performSegueWithIdentifier("productRentRequest", sender: nil)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            
          self.editableProduct = self.productList[indexPath.row]
            
            self.performSegue(withIdentifier: "editProduct", sender: self)
        }
        edit.backgroundColor = UIColor(netHex:0xD0842D)
        
        
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let data : MyRentalProduct = self.productList[indexPath.row]
            self.deleteProduct(data)
            
            
            
            
            
        }
        delete.backgroundColor = UIColor.red
        
        return [edit , delete]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.getMyProductRentalProduct()
        
    }
    
    //MARK:- API Access
    func getMyProductRentalProduct() {
        if(self.isData == true){
            presentWindow!.makeToastActivity()
            let  paremeters :[String:AnyObject] = ["limit" : 6 as AnyObject , "offset" : self.offset as AnyObject ]
            Alamofire.request(URL(string: "\(baseUrl)api/auth/product/get-my-rental-product" )!,method:.post ,parameters: paremeters)
                //  .validate(contentType: ["application/json"])
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        // print(data)
                        let reqRes : MyRentalProductResponse = Mapper<MyRentalProductResponse>().map(JSONObject: data )!
                        
                        if(reqRes.responseStat.status != false){
                            for i in 0 ..< reqRes.responseData!.count{
                                self.productList.append(reqRes.responseData![i])
                                
                            }
                            self.offset += 1
                            print( self.productList)
                            self.myProductTable.reloadData()
                            
                        }else{
                            self.isData = false
                            self.view.makeToast(message:"No more data", duration: 2, position: HRToastPositionCenter as AnyObject)
                            
                        }
                        
                        
                        
                    case .failure(let error):
                        print(error)
                        
                    }
                    self.presentWindow!.hideToastActivity()
            }
            
        }
        
    }
    
    func deleteProduct(_ product: RentalProduct) {
        
        
        let alertController = UIAlertController(title: "Delete", message: "All information related to \(product.name!) will be lost, are you sure to proceed ? ", preferredStyle: UIAlertControllerStyle.alert)
        //alertController.view.tintColor = UIColor(netHex:0xD0842D)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alert :UIAlertAction!) in
        })
        alertController.addAction(cancelAction)
        let loginAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {(alert :UIAlertAction!) in
           // print("post \(self.baseUrl)api/auth/product/delete-Product/\(product.id!)")
            
            Alamofire.request( URL(string: "\(self.baseUrl)api/auth/product/delete-Product/\(product.id!)" )!,method :.post ,parameters: [:])
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        debugPrint(data)
                        let response : Response = Mapper<Response>().map(JSONObject: data)!
                        print(response.responseStat.status)
                        
                        if(response.responseStat.status != false){
                            self.view.makeToast(message: (response.responseStat.msg)!, duration: 2, position: HRToastPositionCenter as AnyObject)
                            self.getMyProductRentalProduct()
                        }
                        else{
                            if(response.responseStat.msg != ""){
                                self.view.makeToast(message: (response.responseStat.msg)!, duration: 2, position: HRToastPositionCenter as AnyObject)
                            }else{
                                self.view.makeToast(message: (response.responseStat.requestErrors?[0].msg)!, duration: 2, position: HRToastPositionCenter as AnyObject)
                            }
                            
                        }
                        
                        
                    case .failure(let error):
                        print(error)
                        
                    }
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.presentWindow!.hideToastActivity()
            }
        })
        alertController.addAction(loginAction)
        present(alertController, animated: true, completion: nil)
        // print(productid)
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "editProduct"){
            
            
            let controller : EditProductViewController = segue.destination as! EditProductViewController
            controller.editableProduct = self.editableProduct
//            controller.isRequestedToMe = true
//            controller.rentRequest = self.selectedRentRequest
            
        }
    }
    
    
}
