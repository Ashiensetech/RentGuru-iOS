//
//  MyProductRequestViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/19/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Kingfisher
class MyProductRequestViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var segmentedView: UISegmentedControl!
    @IBOutlet var requestTable: UITableView!
    
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    var presentWindow : UIWindow?
    var offset : Int = 0
    var requestList : [RentRequest] = []
    var isData : Bool = true
    var currentIndex :Int = 0
    var selectedRentRequest : RentRequest!
    override func viewDidLoad() {
        super.viewDidLoad()
        presentWindow = UIApplication.shared.keyWindow
        baseUrl = defaults.string(forKey: "baseUrl")!
        self.requestTable.delegate = self
        self.requestTable.dataSource = self
        self.tabBarController?.tabBar.isHidden = true
        self.requestTable.tableFooterView = UIView()
        
        
    }
    @IBAction func segmentedViewChangeAction(_ sender: AnyObject) {
        self.currentIndex = segmentedView.selectedSegmentIndex
        self.offset = 0
        self.isData = true
        self.requestList.removeAll()
        
        switch segmentedView.selectedSegmentIndex
        {
        case 0:
            self.getMyPendingProductRentRequest()
        case 1:
            self.getMyApprovedProductRentRequest()
        case 2:
            self.getMyDisapprovedProductRentRequest()
        default:
            break;
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Requested Items"
        self.getMyPendingProductRentRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- TableviewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requestList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyProductRequestTableViewCell = tableView.dequeueReusableCell(withIdentifier: "requestCell") as! MyProductRequestTableViewCell
        let  data : RentRequest = self.requestList[(indexPath as NSIndexPath).row]
        let path = data.rentalProduct.profileImage.original.path!
        cell.productImageView.kf.setImage(with: URL(string: "\(baseUrl)/images/\(path)")!,
                              placeholder: nil,
                              options: [.transition(.fade(1))],
                              progressBlock: nil,
                              completionHandler: nil)
        cell.productName.text = data.rentalProduct.name!
        cell.userName.text = "\(data.requestedBy.userInf.firstName!) \(data.requestedBy.userInf.lastName!)"
        cell.dateRenge.text = "\( data.startDate!) to \(data.endDate!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRentRequest = requestList[(indexPath as NSIndexPath).row]
        self.performSegue(withIdentifier: "MyProductRequestDetails", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let  data : RentRequest = self.requestList[(indexPath as NSIndexPath).row]
        
        
        
        if( data.approve == true && data.disapprove == false ){
            let accept = UITableViewRowAction(style: .normal, title: "Accepted") { action, index in
                print("favorite button tapped")
            }
            accept.backgroundColor = UIColor(netHex:0xD0842D)
            
            return [accept]
        }else if(data.disapprove == true && data.approve == false ){
            let decline = UITableViewRowAction(style: .normal, title: "Declined") { action, index in
                print("share button tapped")
            }
            decline.backgroundColor = UIColor.red
            
            return [decline]
        }
        else{
            let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
                self.acceptAction(data.id)
            }
            accept.backgroundColor = UIColor(netHex:0xD0842D)
            
            let decline = UITableViewRowAction(style: .normal, title: "Decline") { action, index in
                self.declineAction(data.id)
            }
            decline.backgroundColor = UIColor.red
            
            return [decline, accept]
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    
    
    func acceptAction(_ requestId :Int){
        
        
        Alamofire.request( URL(string: "\(baseUrl)api/auth/rent/approve-request/\(requestId)" )!,method :.get, parameters: [:])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                //print(response)
                switch response.result {
                case .success(let data):
                    let result : Response = Mapper<Response>().map(JSONString: data as! String)!
                    if(result.responseStat.status != false){
                        self.view.makeToast(message:"Request Accepted", duration: 2, position: HRToastPositionCenter as AnyObject)
                        self.offset = 0
                        self.isData = true
                        self.requestList.removeAll()
                        
                        switch  self.currentIndex
                        {
                        case 0:
                            self.getMyPendingProductRentRequest()
                        case 1:
                            self.getMyApprovedProductRentRequest()
                        case 2:
                            self.getMyDisapprovedProductRentRequest()
                        default:
                            break;
                        }
                        
                    }else{
                        self.view.makeToast(message:result.responseStat.msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                    }
                case .failure(let error):
                    print(error)
                }
        }
        
    }
    func declineAction(_ requestId :Int)  {
        
        
        
        Alamofire.request( URL(string: "\(baseUrl)api/auth/rent/disapprove-request/\(requestId)" )!,method : .get ,parameters: [:])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                //print(response)
                switch response.result {
                case .success(let data):
                    let result : Response = Mapper<Response>().map(JSONString: data as! String)!
                    if(result.responseStat.status != false){
                        self.view.makeToast(message:"Request Declined", duration: 2, position: HRToastPositionCenter as AnyObject)
                        self.offset = 0
                        self.isData = true
                        self.requestList.removeAll()
                        switch  self.currentIndex
                        {
                        case 0:
                            self.getMyPendingProductRentRequest()
                        case 1:
                            self.getMyApprovedProductRentRequest()
                        case 2:
                            self.getMyDisapprovedProductRentRequest()
                        default:
                            break;
                        }
                        
                    }else{
                        self.view.makeToast(message:result.responseStat.msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        switch  self.currentIndex
        {
        case 0:
            self.getMyPendingProductRentRequest()
        case 1:
            self.getMyApprovedProductRentRequest()
        case 2:
            self.getMyDisapprovedProductRentRequest()
        default:
            break;
        }
        
    }
    //MARK:- API Access
    func getMyPendingProductRentRequest() {
        if(self.isData == true){
            presentWindow!.makeToastActivity()
            let  paremeters :[String:AnyObject] = ["limit" : 6 as AnyObject , "offset" : self.offset as AnyObject ]
            Alamofire.request( URL(string: "\(baseUrl)api/auth/rent/get-my-pending-product-rent-request" )!,method :.post, parameters: paremeters)
                  .validate(contentType: ["application/json"])
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        print(data)
                        let reqRes : MyProductRentRequestResponse = Mapper<MyProductRentRequestResponse>().map(JSONObject: data)!
                        //  print(reqRes)
                        if(reqRes.responseStat.status != false){
                            for i in 0 ..< reqRes.responseData.count{
                                self.requestList.append(reqRes.responseData[i])
                                
                            }
                            self.offset += 1
                            self.requestTable.reloadData()
                            
                        }else{
                            self.isData = false
                            if(self.requestList.count == 0){
                                self.requestTable.reloadData()
                            }
                            self.view.makeToast(message:"No more data", duration: 2, position: HRToastPositionCenter as AnyObject)
                            
                        }
                        //
                        
                        
                    case .failure(let error):
                        print(error)
                        
                    }
                    self.presentWindow!.hideToastActivity()
            }
            
        }
        
    }
    func getMyApprovedProductRentRequest() {
        if(self.isData == true){
            presentWindow!.makeToastActivity()
            
            var  paremeters :[String:AnyObject] = [:]
            paremeters["limit"] = 6 as AnyObject
            paremeters["offset"] = self.offset as AnyObject
            
            Alamofire.request(URL(string: "\(baseUrl)api/auth/rent/get-my-approved-product-rent-request" )!,method :.post ,parameters: paremeters)
                //  .validate(contentType: ["application/json"])
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        //   print(data)
                        let reqRes : MyProductRentRequestResponse = Mapper<MyProductRentRequestResponse>().map(JSONObject: data)!
                        //  print(reqRes)
                        if(reqRes.responseStat.status != false){
                            for i in 0 ..< reqRes.responseData.count{
                                self.requestList.append(reqRes.responseData[i])
                                
                            }
                            self.offset += 1
                            self.requestTable.reloadData()
                            
                        }else{
                            self.isData = false
                            if(self.requestList.count == 0){
                                self.requestTable.reloadData()
                            }
                            self.view.makeToast(message:"No more data", duration: 2, position: HRToastPositionCenter as AnyObject)
                            
                        }
                        //
                        
                        
                    case .failure(let error):
                        print(error)
                        
                    }
                    self.presentWindow!.hideToastActivity()
            }
            
        }
        
    }
    func getMyDisapprovedProductRentRequest() {
        if(self.isData == true){
            presentWindow!.makeToastActivity()
            
            var  paremeters :[String:AnyObject] = [:]
            paremeters["limit"] = 6 as AnyObject
            paremeters["offset"] = self.offset as AnyObject
            
            Alamofire.request( URL(string: "\(baseUrl)api/auth/rent/get-my-disapproved-product-rent-request" )!,method:.post ,parameters: paremeters)
                //  .validate(contentType: ["application/json"])
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        //   print(data)
                        let reqRes : MyProductRentRequestResponse = Mapper<MyProductRentRequestResponse>().map(JSONObject: data)!
                        //  print(reqRes)
                        if(reqRes.responseStat.status != false){
                            for i in 0 ..< reqRes.responseData.count{
                                self.requestList.append(reqRes.responseData[i])
                                
                            }
                            self.offset += 1
                            self.requestTable.reloadData()
                            
                        }else{
                            self.isData = false
                            if(self.requestList.count == 0){
                                self.requestTable.reloadData()
                            }
                            self.view.makeToast(message:"No more data", duration: 2, position: HRToastPositionCenter as AnyObject)
                            
                        }
                        //
                        
                        
                    case .failure(let error):
                        print(error)
                        
                    }
                    self.presentWindow!.hideToastActivity()
            }
            
        }
        
    }
    
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "MyProductRequestDetails"){
            let row = (sender as! NSIndexPath).row
            let rentRequest = requestList[row]
            self.navigationController!.navigationBar.barTintColor = UIColor(netHex:0x2D2D2D)
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(netHex:0xD0842D)]
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            self.navigationItem.backBarButtonItem!.tintColor = UIColor.white
            
            let controller : RequestedProductDetailsViewController = segue.destination as! RequestedProductDetailsViewController
            controller.rentRequest = rentRequest
            
        }
     }
 
    
}
