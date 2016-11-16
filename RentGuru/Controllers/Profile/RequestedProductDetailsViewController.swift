import UIKit
import Alamofire
import ObjectMapper

class RequestedProductDetailsViewController: UITableViewController {
    
    var rentRequest: RentRequest!
    var baseUrl : String = ""
    var buttonSectionToShow = -1
    
    @IBOutlet weak var requesterName: UILabel!
    @IBOutlet weak var requesterImage: UIImageView!
    @IBOutlet weak var requesterEmail: UILabel!
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
        noOfDays.text = "\(difference! + 1) Days"
//        rentPerDay.text = rentRequest.rentalProduct.currentValue
//        totalRent.text = rentRequest.rentFee
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
                                let rentInf = rentInfResponse.responseData
                                if (rentInf?.rentalProductReturnRequest != nil) {
                                    self.buttonSectionToShow = -1
                                }
                                else {
                                    if (rentInf?.rentalProductReturned != nil) {
                                        if rentInf?.rentalProductReturned.confirm == false && rentInf?.rentalProductReturned.dispute == false {
                                            self.buttonSectionToShow = 2
                                        }
                                        else {
                                            self.buttonSectionToShow = 1
                                        }
                                    }
                                    else {
                                        self.buttonSectionToShow = 1
                                    }
                                }
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
    
    

//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let header = view as! UITableViewHeaderFooterView
//        header.textLabel?.textColor = UIColor(red: 243/255, green: 153/255, blue: 193/255, alpha: 1.0)
//        header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 18)
//        header.textLabel?.text = "About Us"
//        header.textLabel?.frame = header.frame
//        header.textLabel?.textAlignment = NSTextAlignment.left
//    }
    
    
    
    @IBAction func approveAction(_ sender: UIButton) {
    }
    
    @IBAction func disapproveAction(_ sender: UIButton) {
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
