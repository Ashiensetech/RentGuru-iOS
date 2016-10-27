//
//  RequestDetailsViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/27/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

extension UIFont {
    func sizeOfString (_ string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: DBL_MAX),
                                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                     attributes: [NSFontAttributeName: self],
                                                     context: nil).size
    }
}




class RequestDetailsViewController: UIViewController ,UICollectionViewDelegateFlowLayout  { //, UICollectionViewDataSource
   

    

    
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    @IBOutlet var userProfilePicImageView: UIImageView!
    
    @IBOutlet var userAddressLbl: UILabel!
    @IBOutlet var userEmailLbl: UILabel!
    @IBOutlet var userPhoneNoLbl: UILabel!
    @IBOutlet var userNameLbl: UILabel!
    @IBOutlet var rentTypeLbl: UILabel!
    @IBOutlet var rentFeeLbl: UILabel!
    @IBOutlet var productOverviewtxt: UITextView!
    @IBOutlet var productAvailableFromLbl: UILabel!
    @IBOutlet var availableTillLbl: UILabel!
    
    @IBOutlet var productNameLbl: UILabel!
    @IBOutlet var productProfileImageView: UIImageView!
    @IBOutlet var totalAmount: UILabel!
    @IBOutlet var totalDaysLbl: UILabel!
    @IBOutlet var orderEndDate: UILabel!
    @IBOutlet var orderStartDateLbl: UILabel!
    
    @IBOutlet var negetiveBtn: UIButton!
    @IBOutlet var positiveBtn: UIButton!
    @IBOutlet var remarkLbl: UITextView!
    @IBOutlet var otherImagesCollection: UICollectionView!
    
    @IBOutlet var remarkBlockHeight: NSLayoutConstraint!
    @IBOutlet var remarkHeight: NSLayoutConstraint!
    @IBOutlet var productOverviewHeight: NSLayoutConstraint!
    @IBOutlet var otherImageHeight: NSLayoutConstraint!
    var isRequestedToMe : Bool!
    var rentRequest : RentRequest!
    var  imageUrls : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseUrl = defaults.string(forKey: "baseUrl")!
        // Do any additional setup after loading the view.
        self.otherImagesCollection.delegate = self
        //self.otherImagesCollection.dataSource = self
        
        let fixedWidth = remarkLbl.frame.size.width
        remarkLbl.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = remarkLbl.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = remarkLbl.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        remarkLbl.frame = newFrame;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- APIAccess
    
    func acceptAction(){
        let requestId = self.rentRequest.id
        //urlString parameters: parameters, encoding: JSONEncoding.default
        Alamofire.request( URL(string: "\(baseUrl)api/auth/rent/approve-request/\(requestId)" )!, method: .get, parameters: [:], encoding: JSONEncoding.default)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                print(response)
                switch response.result {
                case .success(let data):
                    let result : Response = Mapper<Response>().map(JSON: data as! [String : Any])!
                    if(result.responseStat.status != false){
                        self.view.makeToast(message:"Request Accepted", duration: 2, position: HRToastPositionCenter as AnyObject)
                        self.positiveBtn.setTitle("Accepted", for: UIControlState())
                        self.negetiveBtn.isHidden = true
                       // self.positiveBtn.removeTarget(self, action: Selector(), for: UIControlEvents.allEvents)
                        
                    }else{
                        self.view.makeToast(message:result.responseStat.requestErrors![0].msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                    }
                case .failure(let error):
                    print(error)
                }
        }
        
    }
    func declineAction()  {
        
        let requestId = self.rentRequest.id
        //urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default
        Alamofire.request( URL(string: "\(baseUrl)api/auth/rent/disapprove-request/\(requestId)" )!,method:.post, parameters: [:],encoding: JSONEncoding.default)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                //print(response)
                switch response.result {
                case .success(let data):
                    let result : Response = Mapper<Response>().map(JSONString: data as! String)!
                    if(result.responseStat.status != false){
                        self.view.makeToast(message:"Request Declined", duration: 2, position: HRToastPositionCenter as AnyObject)
                        self.negetiveBtn.setTitle("Declined", for:UIControlState())
                        self.positiveBtn.isHidden = true
                        //self.negetiveBtn.removeTarget(self, action: Selector(), for: UIControlEvents.allEvents)
                    }else{
                        self.view.makeToast(message:result.responseStat.requestErrors![0].msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    func cancelAction(){
        let requestId = self.rentRequest.id
        //urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default
        Alamofire.request( URL(string: "\(baseUrl)api/auth/rent/cancel-request/\(requestId)" )!,method: .get, parameters: [:],encoding: JSONEncoding.default)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                print(response)
                switch response.result {
                case .success(let data):
                    let result : RentRequestActionResponse = Mapper<RentRequestActionResponse>().map(JSONString: data as! String)!
                    if(result.responseStat.status != false){
                        self.view.makeToast(message:"Request Cenceled", duration: 2, position: HRToastPositionCenter as AnyObject)
                        self.negetiveBtn.setTitle("Canceled", for:UIControlState())
                       // self.negetiveBtn.removeTarget(self, action: Selector(), for: UIControlEvents.allEvents)
                        self.positiveBtn.isHidden = true
                        
                    }else{
                        self.view.makeToast(message:result.responseStat.msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Request Details"
        if(self.rentRequest.rentalProduct.otherImages.isEmpty) != false || self.rentRequest.rentalProduct.otherImages.count == 0{
            self.otherImageHeight.constant = 0.0
            self.otherImagesCollection.setNeedsUpdateConstraints()
        }else{
            imageUrls.append(rentRequest.rentalProduct.profileImage.original.path)
            
            for i in 0..<rentRequest.rentalProduct.otherImages.count{
                let dataImage : Picture  = rentRequest.rentalProduct.otherImages[i]
                imageUrls.append(dataImage.original.path)
            }
        }
        
        
        
        if(self.isRequestedToMe == true){
            self.userNameLbl.text = "\(rentRequest.requestedBy.userInf.firstName) \(rentRequest.requestedBy.userInf.lastName)"
            self.userEmailLbl.text = "\(rentRequest.requestedBy.email)"
            self.userAddressLbl.text =  "\(rentRequest.requestedBy.userInf.userAddress.address) \(rentRequest.requestedBy.userInf.userAddress.city) \(rentRequest.requestedBy.userInf.userAddress!.zip)"
            if(rentRequest.requestedBy.userInf.profilePicture != nil){
                print("\(baseUrl)/images/\(rentRequest.requestedBy.userInf.profilePicture!.original.path)")
                self.userProfilePicImageView.kf.setImage(with: URL(string: "\(baseUrl)profile-image/\(rentRequest.requestedBy.userInf.profilePicture!.original.path)")!,
                                                         placeholder: nil,
                                                         options: [.transition(.fade(1))],
                                                         progressBlock: nil,
                                                         completionHandler: nil)
                
                
                
                
                
                
                
            }else{
                self.userNameLbl.text = "\(rentRequest.rentalProduct.owner.userInf.firstName) \(rentRequest.rentalProduct.owner.userInf.lastName)"
                self.userEmailLbl.text = "\(rentRequest.rentalProduct.owner.email)"
                self.userAddressLbl.text =  "\(rentRequest.rentalProduct.productLocation!.formattedAddress!) \(rentRequest.rentalProduct.productLocation!.city!) \(rentRequest.rentalProduct.productLocation!.zip!)"
                if(rentRequest.rentalProduct.owner.userInf.profilePicture != nil){
                    self.userProfilePicImageView.kf.setImage(with: URL(string: "\(baseUrl)profile-image/\(rentRequest.rentalProduct.owner.userInf.profilePicture!.original.path)")!,
                                                             placeholder: nil,
                                                             options: [.transition(.fade(1))],
                                                             progressBlock: nil,
                                                             completionHandler: nil)
                    
                }
            }
            self.orderStartDateLbl.text = rentRequest.startDate
            self.orderEndDate.text = rentRequest.endDate
            self.rentTypeLbl.text = "Rent/\(rentRequest.rentalProduct.rentType.name)"
            self.rentFeeLbl.text = "\(rentRequest.rentalProduct.rentFee)"
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let difference  = (Calendar.current as NSCalendar).components(.day, from: dateFormatter.date(from: rentRequest.startDate)!, to: dateFormatter.date( from: rentRequest.endDate )!, options: []).day
            self.totalDaysLbl.text = "\(difference! + 1) Days"
            self.totalAmount.text = "\(Double(difference! + 1)*rentRequest.rentalProduct.rentFee)"
            
            //        if(rentRequest.remark != ""){
            //            let sizeOfString = rentRequest.remark.boundingRectWithSize(
            //                CGSizeMake(self.remarkLbl.frame.size.width, CGFloat.infinity),
            //                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            //                attributes: [NSFontAttributeName:UIFont.systemFontOfSize(14)!],
            //                context: nil).size
            //            print("String height :\(sizeOfString.height)")
            //
            //
            //            self.remarkLbl.text = rentRequest.remark
            //            self.remarkHeight.constant = sizeOfString.height
            //            self.remarkBlockHeight.constant = sizeOfString.height+20
            //
            //        }else{
            //            self.remarkLbl.text = ""
            //            self.remarkBlockHeight.constant = 0.0
            //            self.remarkHeight.constant = 0.0
            //        }
            self.remarkLbl.text = rentRequest.remark
            
            
            self.productProfileImageView.kf.setImage(with: URL(string: "\(baseUrl)images/\(rentRequest.rentalProduct.profileImage.original.path!)")!,
                                                     placeholder: nil,
                                                     options: [.transition(.fade(1))],
                                                     progressBlock: nil,
                                                     completionHandler: nil)
            
            
            
            
            
            
            self.productNameLbl.text =  rentRequest.rentalProduct.name
            self.productOverviewtxt.text = rentRequest.rentalProduct.description
            
            let timeInter1 :TimeInterval = rentRequest.rentalProduct.availableFrom as TimeInterval
            let date1 = Date(timeIntervalSince1970: timeInter1/1000)
            let timeInter2 :TimeInterval = rentRequest.rentalProduct.availableTill as TimeInterval
            let date2 = Date(timeIntervalSince1970: timeInter2/1000)
            
            let dayTimePeriodFormatter = DateFormatter()
            dayTimePeriodFormatter.dateFormat = "MMM dd YYYY"
            
            
            
            let dateString1 = dayTimePeriodFormatter.string(from: date1)
            let dateString2 = dayTimePeriodFormatter.string(from: date2)
            
            self.productAvailableFromLbl.text = "\(dateString1)"
            self.availableTillLbl.text  =  dateString2
            
            
            
            //ButtonControl
            if(isRequestedToMe == true && rentRequest.approve == false && rentRequest.disapprove == false){
                self.positiveBtn.setTitle("Accept", for: UIControlState())
                self.negetiveBtn.setTitle("Decline", for:UIControlState())
                self.positiveBtn.addTarget(self, action: #selector(acceptAction), for: .touchUpInside)
                self.negetiveBtn.addTarget(self, action: #selector(declineAction), for: .touchUpInside)
            }else if(isRequestedToMe == true && rentRequest.approve == true && rentRequest.disapprove == false){
                self.positiveBtn.setTitle("Dispute", for: UIControlState())
                self.negetiveBtn.isHidden = true
            }else if(isRequestedToMe == true && rentRequest.approve == false && rentRequest.disapprove == true){
                self.negetiveBtn.setTitle("Declined", for:UIControlState())
                self.positiveBtn.isHidden = true
            }else if(isRequestedToMe == false && rentRequest.approve == false && rentRequest.disapprove == false && rentRequest.requestCancel == false){
                self.negetiveBtn.setTitle("Cancel", for:UIControlState())
                self.positiveBtn.isHidden = true
                self.negetiveBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
            }
            else if(isRequestedToMe == false && rentRequest.approve == false && rentRequest.disapprove == false && rentRequest.requestCancel == true){
                self.negetiveBtn.setTitle("Canceled", for:UIControlState())
                self.positiveBtn.isHidden = true
                
            }else if(isRequestedToMe == false && rentRequest.approve == true && rentRequest.disapprove == false && rentRequest.requestCancel == true){
                self.positiveBtn.setTitle("Complete", for:UIControlState())
                self.negetiveBtn.isHidden = true
                
            }
                
            else{
                self.positiveBtn.isHidden = true
                self.negetiveBtn.isHidden = true
            }
            
            
        }
        
        // MARK: - UICollectionViewDataSource protocol
     
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            //  return   self.product.otherImages!.count
            return self.imageUrls.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! OtherImageCollectionViewCell
            
            // Configure the cell
            // let dataImage : Picture  = product.otherImages![indexPath.row]
            
            cell.iamgeContainer.kf.setImage(with: URL(string: "\(baseUrl)/images/\(imageUrls[(indexPath as NSIndexPath).row])")!,
                                            placeholder: nil,
                                            options: [.transition(.fade(1))],
                                            progressBlock: nil,
                                            completionHandler: nil)
            
            
            
            
            //        var scalingTransform : CGAffineTransform!
            //        scalingTransform = CGAffineTransformMakeScale(1, -1);
            //        cell.transform = scalingTransform
            
            return cell
            
            
            
        }
        
//        func numberOfSections(in collectionView: UICollectionView) -> Int {
//            return 1
//        }
//        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let cell = collectionView.cellForItem(at: indexPath) as! OtherImageCollectionViewCell
            self.productProfileImageView.image = cell.iamgeContainer.image
            
        }
        
       

        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
         }
         */
        
        
        
    }
}
