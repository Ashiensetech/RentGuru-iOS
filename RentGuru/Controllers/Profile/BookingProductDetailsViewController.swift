import UIKit
import Alamofire
import ObjectMapper

class BookingProductDetailsViewController: UITableViewController {
    
    var rentRequest: RentRequest!
    var baseUrl : String = ""
    var buttonSectionToShow = -1
    var rentInf: RentInf!
    var presentWindow: UIWindow?
    
    @IBOutlet weak var renterName: UILabel!
    @IBOutlet weak var renterImage: UIImageView!
    @IBOutlet weak var renterEmail: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var noOfDays: UILabel!
    @IBOutlet weak var rentPerDay: UILabel!
    @IBOutlet weak var totalRent: UILabel!
    @IBOutlet weak var remarks: UITextView!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productOverview: UITextView!
    @IBOutlet weak var productFromTo: UILabel!
    @IBOutlet weak var productImageCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentWindow = UIApplication.shared.keyWindow
        let defaults = UserDefaults.standard
        baseUrl = defaults.string(forKey: "baseUrl")!
        productImageCollectionView.dataSource = self
        fillData()
    }
    
    func fillData(){
        let userInf = rentRequest.rentalProduct.owner.userInf!
        renterName.text = "\(userInf.firstName!) \(userInf.lastName!)"
        renterEmail.text = rentRequest.rentalProduct.owner.email!
        startDate.text = rentRequest.startDate
        endDate.text = rentRequest.endDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let difference  = (Calendar.current as NSCalendar).components(.day, from: dateFormatter.date(from: rentRequest.startDate)!, to: dateFormatter.date( from: rentRequest.endDate )!, options: []).day
        noOfDays.text = "\(difference! + 1) Days"
        rentPerDay.text = String(RentFeesHelper.getPerDayRentFee(rentTypeId: rentRequest.rentalProduct.rentType.id!, rentFee: rentRequest.rentalProduct.rentFee!))
        //        totalRent.text = rentRequest.rentFee
        remarks.text = rentRequest.remark
        productName.text = rentRequest.rentalProduct.name!
        productOverview.text = rentRequest.rentalProduct.description!
        let imagePath = (rentRequest.requestedBy.userInf.profilePicture?.original!.path!)!
        renterImage.kf.setImage(with: URL(string: "\(baseUrl)profile-image/\(imagePath)"),
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
        if rentInf?.rentalProductReturned == nil && rentRequest.approve {
            buttonSectionToShow = 1
        }
        else {
            buttonSectionToShow = -1
        }
        self.tableView.reloadSections([3], with: UITableViewRowAnimation.fade)
    }
    
    func showAppropriateButtons() {
        print(!rentRequest.approve && !rentRequest.requestCancel)
        if (!rentRequest.approve) {
            print("not approved")
            buttonSectionToShow = 0
            self.tableView.reloadSections([3], with: UITableViewRowAnimation.fade)
        }
        else {
            print("approved")
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
    
    @IBAction func cancelRequestAction(_ sender: UIButton) {
        print("cancel")
        RequestedProductDetailsViewController.showLoader(view: self.view)
        Alamofire.request( URL(string: "\(baseUrl)api/auth/rent/cancel-request//\(rentRequest.id!)" )!,method :.get, parameters: [:])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                RequestedProductDetailsViewController.hideLoader(view: self.view)
                print(response)
                switch response.result {
                case .success(let data):
                    let rentRequestResponse : RentRequestResponse = Mapper<RentRequestResponse>().map(JSONObject: data)!
                    if(rentRequestResponse.responseStat.status != false){
                        self.rentRequest = rentRequestResponse.responseData
                        self.fillData()
                        self.handleRentInf()
                        self.tableView.reloadData()
                        self.presentWindow!.makeToast(message:"Request Canceled", duration: 2, position: HRToastPositionCenter as AnyObject)
                    }else{
                        self.presentWindow!.makeToast(message:rentRequestResponse.responseStat.msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    
    
    @IBAction func returnProductAction(_ sender: UIButton) {
        Alamofire.request( URL(string: "\(baseUrl)api/auth/return-product/confirm-return/\(self.rentInf.id!)" )!,method : .post ,parameters: [:])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                print(response)
                switch response.result {
                case .success(let data):
                    let rentInfResponse : RentInfResponse = Mapper<RentInfResponse>().map(JSONObject: data)!
                    if(rentInfResponse.responseStat.status != false){
                        self.rentInf = rentInfResponse.responseData!
                        self.view.makeToast(message:"Product returned", duration: 2, position: HRToastPositionCenter as AnyObject)
                        self.handleRentInf()
                        self.tableView.reloadData()
                        self.presentWindow!.makeToast(message:"Request Canceled", duration: 2, position: HRToastPositionCenter as AnyObject)
                    }
                    else{
                        self.presentWindow!.makeToast(message: rentInfResponse.responseStat.msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    
    
    
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
                height = 106
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

extension BookingProductDetailsViewController: UICollectionViewDataSource {
    
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
