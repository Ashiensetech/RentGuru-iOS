import UIKit
import Alamofire
import DropDown
import ObjectMapper
import GooglePlaces
import GooglePlacePicker
import CoreLocation

class SearchHeader: UICollectionReusableView, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var searchTxt: UITextField!
    
    @IBOutlet weak var prodCateHolder: UIView!
    @IBOutlet weak var categoryTxt: UITextField!
    
    @IBOutlet weak var proSubCateHolder: UIView!
    @IBOutlet weak var subCateTxt: UITextField!
    
    @IBOutlet weak var stateHolder: UIView!
    @IBOutlet weak var stateTxt: UITextField!
    
    @IBOutlet weak var placePickerView: UIView!
    
    var searchViewController: SearchViewController!
    
    var baseUrl: String = ""
    var parameters :[String:AnyObject] = [:]
    
    let cateDropdown = DropDown()
    var categoryList: [Category] = []
    var selectedCateId = -1
    
    let subCateDropDown = DropDown()
    var subCategoryList: [Category] = []
    var selectedSubcateId = -1
    
    let stateDropDown = DropDown()
    var stateList: [State] = []
    var selectedStateId = -1
    
    let locationManager = CLLocationManager()
    var currentLocValue = CLLocationCoordinate2D()
    var radius :Float = 0.0
    var pickedLocValue = CLLocationCoordinate2D()
    var placePicker: GMSPlacePicker?
    
    @IBOutlet weak var locTxt: UITextField!
    @IBOutlet weak var radiusLbl: UILabel!
    
    override func awakeFromNib() {
        let defaults = UserDefaults.standard
        baseUrl = defaults.string(forKey: "baseUrl")!
        handleDropDowns()
        handlePlacePicker()
        getCategories()
        getStates()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func search(_ sender: UIButton) {
        setParams()
    }
    
    func setParams(){
        
        if(self.selectedCateId != -1 && self.selectedSubcateId == -1  ){
            parameters["categoryId"] = self.selectedCateId as AnyObject?
        }
        else{
            parameters["categoryId"] = self.selectedSubcateId as AnyObject?
        }
        if(self.selectedStateId != -1) {
            self.parameters["stateId"] = self.selectedStateId as AnyObject?
        }
        if(self.searchTxt.text! != ""){
            print(self.searchTxt.text!)
            parameters["title"] = (self.searchTxt.text!) as AnyObject?
        }
        if(self.locTxt.text != "Let Rent Guru Pick your Location"){
            self.parameters["lat"] = self.pickedLocValue.latitude as AnyObject?
            self.parameters ["lng"] = self.pickedLocValue.longitude as AnyObject?
            self.parameters["radius"] = self.radius as AnyObject?
        }
        searchViewController.paremeters = self.parameters
        searchViewController.offset = 0
        searchViewController.getSearchProduct()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print (sender.value)
        self.radiusLbl.attributedText  =  NSAttributedString(string:"In Radius Of \(Int(sender.value)) KM", attributes:[NSForegroundColorAttributeName : UIColor.gray])
        self.radius = Float(sender.value)
    }
    
    // MARK: - Place Picker
    
    func handlePlacePicker() {
        self.placePickerView.isUserInteractionEnabled = true
        let pickplace = UITapGestureRecognizer(target: self, action:#selector(self.pickPlaceAction))
        self.placePickerView.addGestureRecognizer(pickplace)
    }
    
    func pickPlaceAction() {
        let center = CLLocationCoordinate2DMake(self.currentLocValue.latitude,self.currentLocValue.longitude)
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)
        placePicker?.pickPlace(callback: { (place: GMSPlace?, error: Error?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            if let place = place {
                self.pickedLocValue = place.coordinate
                self.locTxt.text = place.name
            } else {
                print("No place selected")
            }
        } )
    }
    
    //MARK: - DropDown
    
    func handleDropDowns() {
        // category dropdown
        cateDropdown.anchorView = prodCateHolder
        self.prodCateHolder.isUserInteractionEnabled = true
        let cateGesture = UITapGestureRecognizer(target: self, action:#selector(self.showCateDropDown))
        self.prodCateHolder.addGestureRecognizer(cateGesture)
        cateDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.categoryTxt.attributedText  =  NSAttributedString(string: (item), attributes:[NSForegroundColorAttributeName : UIColor.gray])
            self.subCateTxt.attributedText  =  NSAttributedString(string:"Product Sub Category", attributes:[NSForegroundColorAttributeName : UIColor.gray])
            self.subCategoryList = self.categoryList[index].subcategory
            self.selectedCateId  = self.categoryList[index].id
            if(self.subCategoryList.isEmpty){
                self.subCateDropDown.dataSource = []
            }
            else{
                var subCates = Array<String>();
                for i in 0  ..< self.subCategoryList.count{
                    subCates.append(self.subCategoryList[i].name)
                }
                self.subCateDropDown.dataSource = subCates
            }
        }
        
        // sub-category dropdown
        subCateDropDown.anchorView = proSubCateHolder
        self.proSubCateHolder.isUserInteractionEnabled = true
        let subCateGesture = UITapGestureRecognizer(target: self, action:#selector(self.showSubCateDropDown))
        self.proSubCateHolder.addGestureRecognizer(subCateGesture)
        subCateDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.subCateTxt.attributedText  =  NSAttributedString(string: (item), attributes:[NSForegroundColorAttributeName : UIColor.gray])
            self.selectedSubcateId = self.subCategoryList[index].id
        }
        
        //state dropdown
        stateDropDown.anchorView = stateHolder
        self.stateHolder.isUserInteractionEnabled = true
        let stateGesture = UITapGestureRecognizer(target: self, action:#selector(self.showStateDropDown) )
        self.stateHolder.addGestureRecognizer(stateGesture)
        stateDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.stateTxt.attributedText  =  NSAttributedString(string: (item), attributes:[NSForegroundColorAttributeName : UIColor.gray])
            self.selectedStateId = self.stateList[index].id
        }
    }
    
    
    //MARK: - ApiAccess
    
    func  getCategories()  {
        Alamofire.request(URL(string: "\(baseUrl)api/utility/get-category" )!, method: .get, encoding: JSONEncoding.default)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success(let data):
                    
                    let cateRes: CategoryResponse = Mapper<CategoryResponse>().map(JSON: data as! [String : Any])!
                    if((cateRes.responseStat.status) != false){
                        print("data", cateRes.responseData!)
                        self.categoryList = cateRes.responseData!
                        var cateSource = Array<String>()
                        for i in 0  ..< self.categoryList.count {
                            cateSource.append(self.categoryList[i].name)
                        }
                        self.cateDropdown.dataSource = cateSource
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func  getStates()  {
        Alamofire.request(URL(string: "\(baseUrl)api/state/get-all-state" )!, method: .get, encoding: JSONEncoding.default)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success(let data):
                    let stateResponse :StateResponse = Mapper<StateResponse>().map(JSON: data as! [String : Any])!
                    if((stateResponse.responseStat.status) != false){
                        self.stateList = stateResponse.responseData!
                        var stateSource = Array<String>()
                        for i in 0  ..< self.stateList.count {
                            stateSource.append(self.stateList[i].name)
                        }
                        self.stateDropDown.dataSource = stateSource
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    //MARK: - Show Dropdowns
    
    func showCateDropDown() {
        cateDropdown.show()
    }
    
    func showSubCateDropDown() {
        subCateDropDown.show()
    }
    
    func showStateDropDown() {
        stateDropDown.show()
    }
}
