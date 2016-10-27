//
//  MyRequestViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/19/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Kingfisher

class MyRequestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet var myRequestTableView: UITableView!
    @IBOutlet var segmentedView: UISegmentedControl!
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    var presentWindow : UIWindow?
    var offset : Int = 0
    var requestList : [RentRequest]! = []
    var currentIndex :Int = 0
    var isData : Bool = true
    var selectedRentRequest :RentRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentWindow = UIApplication.shared.keyWindow
        baseUrl = defaults.string(forKey: "baseUrl")!
        self.myRequestTableView.delegate = self
        self.myRequestTableView.dataSource = self
        self.tabBarController?.tabBar.isHidden = true
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Requested"
        self.getMyPendingRentRequest()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentedViewChangedAction(_ sender: AnyObject) {
        self.currentIndex = segmentedView.selectedSegmentIndex
        self.offset = 0
        self.isData = true
        self.requestList.removeAll()
        
        switch segmentedView.selectedSegmentIndex
        {
        case 0:
            self.getMyPendingRentRequest()
        case 1:
            self.getMyApprovedRentRequest()
        case 2:
            self.getMyDisapprovedRentRequest()
        default:
            break;
        }
    }
    
    //MARK :- TableviewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requestList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyRequestTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MyRequestTableViewCell
        let  data : RentRequest = self.requestList[(indexPath as NSIndexPath).row]
        let path = data.rentalProduct.profileImage.original.path!
        cell.productImageView.kf.setImage(with: URL(string: "\(baseUrl)/images/\(path)")!,
                                                 placeholder: nil,
                                                 options: [.transition(.fade(1))],
                                                 progressBlock: nil,
                                                 completionHandler: nil)
        
        
     
        cell.productName.text = data.rentalProduct.name!
        cell.ownerName.text = "\(data.rentalProduct.owner.userInf.firstName!) \(data.rentalProduct.owner.userInf.lastName!)"
        cell.dateRange.text = "\( data.startDate!) to \(data.endDate!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let  data : RentRequest = self.requestList[(indexPath as NSIndexPath).row]
        
        if(data.requestCancel == false && data.approve == false &&  data.disapprove == false)  {
            let cancel = UITableViewRowAction(style: .normal, title: "Cancel") { action, index in
                self.cancelAction(data.id)
            }
            cancel.backgroundColor = UIColor(netHex:0xD0842D)
            return [ cancel]
        }else if( data.approve == true && data.disapprove == false ){
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
        }else{
         return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRentRequest = requestList[(indexPath as NSIndexPath).row]
        self.performSegue(withIdentifier: "requestDetails", sender: nil)
    }
    
    func cancelAction(_ requestId: Int){
        
        
        
        Alamofire.request(URL(string: "\(baseUrl)api/auth/rent/cancel-request/\(requestId)" )!, method: .get, parameters: [:], encoding: JSONEncoding.default)
          
            .validate { request, response, data in
                // Custom evaluation closure now includes data (allows you to parse data to dig out error messages if necessary)
                return .success
            }
            .responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success(let data):
                    let result : Response = Mapper<Response>().map(JSON: data as! [String : Any] )!
                    if(result.responseStat.status != false){
                        self.view.makeToast(message:"Request Cenceled", duration: 2, position: HRToastPositionCenter as AnyObject)
                        self.offset = 0
                        self.isData = true
                        self.requestList.removeAll()
                        switch  self.currentIndex
                        {
                        case 0:
                            self.getMyPendingRentRequest()
                        case 1:
                            self.getMyApprovedRentRequest()
                        case 2:
                            self.getMyDisapprovedRentRequest()
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
            self.getMyPendingRentRequest()
        case 1:
            self.getMyApprovedRentRequest()
        case 2:
            self.getMyDisapprovedRentRequest()
        default:
            break;
        }
    }
    
    //MARK :- API Access
    func getMyPendingRentRequest() {
        if(self.isData == true){
            presentWindow!.makeToastActivity()
            let  paremeters :[String:AnyObject] = ["limit" : 6 as AnyObject , "offset" : self.offset as AnyObject ]
            
            Alamofire.request(URL(string: "\(baseUrl)api/auth/rent/get-my-pending-rent-request" )!, method: .post, parameters: paremeters)
                .validate(contentType: ["application/json"])
                
                .responseJSON { response in
                    debugPrint(response)
                    switch response.result {
                    case .success(let data):
                        //   print(data)
                        let reqRes : MyProductRentRequestResponse = Mapper<MyProductRentRequestResponse>().map(JSON: data as! [String : Any])!
                        //  print(reqRes)
                        if(reqRes.responseStat.status != false){
                            for i in 0 ..< reqRes.responseData!.count{
                                self.requestList.append(reqRes.responseData![i])
                                
                            }
                            self.offset += 1
                            self.myRequestTableView.reloadData()
                            
                        }else{
                            self.isData = false
                            if(self.requestList.count == 0){
                                self.myRequestTableView.reloadData()
                            }
                            self.view.makeToast(message:"No more data", duration: 2, position: HRToastPositionCenter as AnyObject)
                            
                        }
                        
                        
                        
                    case .failure(let error):
                        print(error)
                        
                    }
                    self.presentWindow!.hideToastActivity()
            }
            
            
            
            
            
          
            
        }
        
    }
    func getMyApprovedRentRequest() {
        if(self.isData == true){
            presentWindow!.makeToastActivity()
            let  paremeters :[String:AnyObject] = ["limit" : 6 as AnyObject , "offset" : self.offset as AnyObject ]
            
            Alamofire.request( URL(string: "\(baseUrl)api/auth/rent/get-my-approved-rent-request" )!, method: .post, parameters: paremeters, encoding: JSONEncoding.default)
              
                .validate { request, response, data in
                    // Custom evaluation closure now includes data (allows you to parse data to dig out error messages if necessary)
                    return .success
                }
                .responseJSON { response in
                    debugPrint(response)
                    switch response.result {
                    case .success(let data):
                        print(data)
                        let reqRes : MyProductRentRequestResponse = Mapper<MyProductRentRequestResponse>().map(JSON: data as! [String : Any])!
                        //  print(reqRes)
                        if(reqRes.responseStat.status != false){
                            for i in 0 ..< reqRes.responseData!.count{
                                self.requestList.append(reqRes.responseData![i])
                                
                            }
                            self.offset += 1
                            self.myRequestTableView.reloadData()
                            
                        }else{
                            self.isData = false
                            if(self.requestList.count == 0){
                                self.myRequestTableView.reloadData()
                            }
                            self.view.makeToast(message:"No more data", duration: 2, position: HRToastPositionCenter as AnyObject)
                            
                        }
                        
                        
                        
                    case .failure(let error):
                        print(error)
                        
                    }
                    self.presentWindow!.hideToastActivity()

            }
            
            
            
            
      
            
        }
        
    }
    func getMyDisapprovedRentRequest() {
        if(self.isData == true){
            presentWindow!.makeToastActivity()
            let  paremeters :[String:AnyObject] = ["limit" : 6 as AnyObject , "offset" : self.offset as AnyObject ]
            
            Alamofire.request(URL(string: "\(baseUrl)api/auth/rent/get-my-disapproved-rent-request" )!, method: .post, parameters: paremeters, encoding: JSONEncoding.default)
                
                .validate { request, response, data in
                    // Custom evaluation closure now includes data (allows you to parse data to dig out error messages if necessary)
                    return .success
                }
                .responseJSON { response in
                    debugPrint(response)
                    switch response.result {
                    case .success(let data):
                        //   print(data)
                        let reqRes : MyProductRentRequestResponse = Mapper<MyProductRentRequestResponse>().map(JSON: data as! [String : Any] )!
                        //  print(reqRes)
                        if(reqRes.responseStat.status != false){
                            for i in 0 ..< reqRes.responseData!.count{
                                self.requestList.append(reqRes.responseData![i])
                                
                            }
                            self.offset += 1
                            self.myRequestTableView.reloadData()
                            
                        }else{
                            self.isData = false
                            if(self.requestList.count == 0){
                                self.myRequestTableView.reloadData()
                            }
                            self.view.makeToast(message:"No more data", duration: 2, position: HRToastPositionCenter as AnyObject)
                        }
                        
                        
                        
                    case .failure(let error):
                        print(error)
                        
                    }
                    self.presentWindow!.hideToastActivity()
            }
            
            
            
         
            
        }
        
    }
  
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "requestDetails"){
            self.navigationController!.navigationBar.barTintColor = UIColor(netHex:0x2D2D2D)
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(netHex:0xD0842D)]
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            self.navigationItem.backBarButtonItem!.tintColor = UIColor.white
            
            let controller : RequestDetailsViewController = segue.destination as! RequestDetailsViewController
            controller.isRequestedToMe = false
            controller.rentRequest = self.selectedRentRequest
            
        }
    
     }
    
}
