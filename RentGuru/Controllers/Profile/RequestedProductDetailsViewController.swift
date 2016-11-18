import UIKit
import Alamofire
import ObjectMapper

class RequestedProductDetailsViewController: UITableViewController {
    
    var rentRequest: RentRequest!
    var baseUrl : String = ""
    var buttonSectionToShow = -1
    var rentInf: RentInf!
    var presentWindow: UIWindow?
    
    @IBOutlet weak var requesterName: UILabel!
    @IBOutlet weak var requesterImage: UIImageView!
    @IBOutlet weak var requesterEmail: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var noOfDays: UILabel!
    @IBOutlet weak var rentPerDay: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var totalRent: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var depositAmount: UILabel!
    @IBOutlet weak var remarks: UITextView!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productOverview: UITextView!
    @IBOutlet weak var productFromTo: UILabel!
    @IBOutlet weak var productImageCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Order Information"
        presentWindow = UIApplication.shared.keyWindow
        let defaults = UserDefaults.standard
        baseUrl = defaults.string(forKey: "baseUrl")!
        productImageCollectionView.dataSource = self
        fillData()
    }
    
    func fillData(){
        requesterName.text = "\(rentRequest.requestedBy.userInf.firstName!) \(rentRequest.requestedBy.userInf.firstName!)"
        requesterEmail.text = rentRequest.requestedBy.email
        startDate.text = rentRequest.startDate
        endDate.text = rentRequest.endDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let difference  = (Calendar.current as NSCalendar).components(.day, from: dateFormatter.date(from: rentRequest.startDate)!, to: dateFormatter.date( from: rentRequest.endDate )!, options: []).day
        noOfDays.text = "\(difference!) Days"
        rentPerDay.text = String(RentFeesHelper.getPerDayRentFee(rentTypeId: rentRequest.rentalProduct.rentType.id!, rentFee: rentRequest.rentalProduct.rentFee!))
        totalRent.text = String(RentFeesHelper.getRentFee(rentTypeId: rentRequest.rentalProduct.rentType.id!, rentFee: rentRequest.rentalProduct.rentFee!, startDate: rentRequest.startDate!, endsDate: rentRequest.endDate!))
        depositAmount.text = String(rentRequest.rentalProduct.currentValue!)
        currentPrice.text = String(rentRequest.rentalProduct.currentValue!)
        total.text = String(rentRequest.rentalProduct.currentValue!)
        remarks.text = rentRequest.remark
        productName.text = rentRequest.rentalProduct.name!
        productOverview.text = rentRequest.rentalProduct.description!
        let imagePath = (rentRequest.requestedBy.userInf.profilePicture?.original!.path!)!
        requesterImage.kf.setImage(with: URL(string: "\(baseUrl)profile-image/\(imagePath)"),
                                  placeholder: nil,
                                  options: [.transition(.fade(1))],
                                  progressBlock: nil,
                                  completionHandler: nil)
        productImage.kf.setImage(with: URL(string: "\(baseUrl)images/\(rentRequest.rentalProduct.profileImage.original.path!)")!,
                                                 placeholder: nil,
                                                 options: [.transition(.fade(1))],
                                                 progressBlock: nil,
                                                 completionHandler: nil)
        
        showAppropriateButtons()
        
    }
    
    func handleRentInf() {
        let rentInf = self.rentInf
        
        if(rentInf?.rentalProductReturned != nil) {
            if rentInf?.rentalProductReturned.confirm == false && rentInf?.rentalProductReturned.dispute == false {
                self.buttonSectionToShow = 2
            }
        }
        else if(rentInf?.rentalProductReturnRequest != nil) {
            self.buttonSectionToShow = -1
        }
        else {
            self.buttonSectionToShow = 1
        }
        self.tableView.reloadSections([3], with: UITableViewRowAnimation.fade)
    }
    
    func showAppropriateButtons() {
        print(!rentRequest.approve)
        if (!rentRequest.approve && !rentRequest.disapprove) {
            buttonSectionToShow = 0
            tableView.reloadData()
        }
        else {
            print("\(baseUrl)api/auth/rent-inf/get-by-rent-request-id/\(self.rentRequest.id!)")
            Alamofire.request( URL(string: "\(baseUrl)api/auth/rent-inf/get-by-rent-request-id//\(self.rentRequest.id!)" )!,method: .get ,parameters: [:])
                .validate(contentType: ["application/json"])
                .responseJSON { response in
//                    print(response)
                    self.view.hideToastActivity()
                    switch response.result {
                        case .success(let data):
                            let rentInfResponse: RentInfResponse = Mapper<RentInfResponse>().map(JSONObject: data)!
                            if(rentInfResponse.responseStat.status != false){
                                self.rentInf = rentInfResponse.responseData!
                                self.handleRentInf()
                            }
                            else{
                                
                            }
                        self.tableView.reloadData()
                        case .failure(let error):
                            print(error)
                    }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor(netHex: 0xf2f2f2)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(netHex: 0xCA7D27)
        header.textLabel?.frame = header.frame
    }
    
    static func showLoader(view: UIView) {
        view.makeToastActivity()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    static func hideLoader(view: UIView) {
        view.hideToastActivity()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    // MARK: - Button Actions
    
    @IBAction func approveAction(_ sender: UIButton) {
        print("approve")
        RequestedProductDetailsViewController.showLoader(view: self.view)
        Alamofire.request( URL(string: "\(baseUrl)api/auth/rent/approve-request/\(rentRequest.id!)" )!,method :.get, parameters: [:])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                RequestedProductDetailsViewController.hideLoader(view: self.view)
                print(response)
                switch response.result {
                    case .success(let data):
                        let rentRequestResponse : RentRequestResponse = Mapper<RentRequestResponse>().map(JSONObject: data)!
                        if(rentRequestResponse.responseStat.status != false){
                            self.rentRequest = rentRequestResponse.responseData
                            self.presentWindow!.makeToast(message:"Request Approved", duration: 2, position: HRToastPositionCenter as AnyObject)
                            self.fillData()
                            self.tableView.reloadData()
                        }else{
                            self.presentWindow!.makeToast(message:rentRequestResponse.responseStat.msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                        }
                    case .failure(let error):
                        print(error)
                }
        }
    }
    
    @IBAction func disapproveAction(_ sender: UIButton) {
        print("dis approve")
        Alamofire.request( URL(string: "\(baseUrl)api/auth/rent/disapprove-request/\(rentRequest.id!)" )!,method : .get ,parameters: [:])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                print(response)
                switch response.result {
                case .success(let data):
                    let rentRequestResponse : RentRequestResponse = Mapper<RentRequestResponse>().map(JSONObject: data)!
                    if(rentRequestResponse.responseStat.status != false){
                        self.rentRequest = rentRequestResponse.responseData
                        self.presentWindow!.makeToast(message:"Request Declined", duration: 1, position: HRToastPositionCenter as AnyObject)
                        self.fillData()
                        self.tableView.reloadData()
                    }
                    else{
                        self.presentWindow!.makeToast(message: rentRequestResponse.responseStat.msg, duration: 1, position: HRToastPositionCenter as AnyObject)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    @IBAction func returnRequestAction(_ sender: UIButton) {
        Alamofire.request( URL(string: "\(baseUrl)api/auth/return-request/make-request/\(self.rentInf.id!)" )!,method : .post ,parameters: [:])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
//                print(response)
                switch response.result {
                case .success(let data):
                    let rentInfResponse : RentInfResponse = Mapper<RentInfResponse>().map(JSONObject: data)!
                    if(rentInfResponse.responseStat.status != false){
                        self.rentInf = rentInfResponse.responseData!
                        self.view.makeToast(message:"Return request sent", duration: 1, position: HRToastPositionCenter as AnyObject)
                        self.fillData()
                        self.handleRentInf()
                        self.tableView.reloadData()
                    }
                    else{
                        self.presentWindow!.makeToast(message: rentInfResponse.responseStat.msg, duration: 1, position: HRToastPositionCenter as AnyObject)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    @IBAction func disputeAction(_ sender: UIButton) {
        Alamofire.request( URL(string: "\(baseUrl)api/auth/receive-product/dispute-receive/\((self.rentInf?.rentalProductReturned.id!)!)")!,method : .post ,parameters: [:])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                print(response)
                switch response.result {
                case .success(let data):
                    let response : Response = Mapper<Response>().map(JSONObject: data)!
                    if(response.responseStat.status != false){
                        self.buttonSectionToShow = -1
                        self.tableView.reloadSections([3], with: UITableViewRowAnimation.fade)
                        self.view.makeToast(message:"Dispute", duration: 1, position: HRToastPositionCenter as AnyObject)
                    }
                    else{
                        self.presentWindow!.makeToast(message: response.responseStat.msg, duration: 1, position: HRToastPositionCenter as AnyObject)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    @IBAction func confirmAction(_ sender: UIButton) {
        print("\(baseUrl)api/auth/receive-product/confirm-receive/\((self.rentInf?.rentalProductReturned.id!)!)")
        Alamofire.request( URL(string: "\(baseUrl)api/auth/receive-product/confirm-receive/\((self.rentInf?.rentalProductReturned.id!)!)")!,method : .post ,parameters: [:])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                print(response)
                switch response.result {
                case .success(let data):
                    let response : Response = Mapper<Response>().map(JSONObject: data)!
                    if(response.responseStat.status != false){
                        self.buttonSectionToShow = -1
                        self.tableView.reloadSections([3], with: UITableViewRowAnimation.fade)
                        self.presentWindow!.makeToast(message:"Product received confirmed", duration: 2, position: HRToastPositionCenter as AnyObject)
                    }
                    else{
                        self.presentWindow!.makeToast(message: response.responseStat.msg, duration: 1, position: HRToastPositionCenter as AnyObject)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    // MARK: - Height for table rows
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        if indexPath.section == 0 {
            height = 130.0
        }
        if indexPath.section == 1 {
            height = 44.0
        }
        else if indexPath.section == 2 {
            if indexPath.row == 9 {
                height = 120
            }
            else {
                height = 44.0
            }
        }
        else if indexPath.section == 3 {
            if indexPath.row == 0 && buttonSectionToShow == 0 {
                height = 44.0
            }
            else if indexPath.row == 1 && buttonSectionToShow == 1 {
                height = 44.0
            }
            else if indexPath.row == 2 && buttonSectionToShow == 2 {
                height = 90.0
            }
        }
        else if indexPath.section == 4 {
            if indexPath.row == 0 || indexPath.row == 2 {
                height = 160
            }
            else {
                height = 44.0
            }
        }
        else if indexPath.section == 5 {
            height = 160.0
        }
        return height
    }

}

// MARK: - Product Image CollectionView DataSource

extension RequestedProductDetailsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rentRequest.rentalProduct.otherImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCollectionViewCell", for: indexPath) as! ProductImageCollectionViewCell
        var otherImages = rentRequest.rentalProduct.otherImages
        let path = otherImages[indexPath.row].original.path!
        cell.image.kf.setImage(with: URL(string: "\(baseUrl)/images/\(path)")!,
                                        placeholder: nil,
                                        options: [.transition(.fade(1))],
                                        progressBlock: nil,
                                        completionHandler: nil)
        return cell
    }

}
