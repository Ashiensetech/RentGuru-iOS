//
//  EditProductInformationViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/10/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import DropDown
import GooglePlaces
import GooglePlacePicker
import CoreLocation
class EditProductInformationViewController: UIViewController ,EPCalendarPickerDelegate,CLLocationManagerDelegate{
    @IBOutlet var titleTxt: UITextField!
    @IBOutlet var cateHolder: UIView!
    @IBOutlet var cateTxt: UITextField!
    @IBOutlet var subCateHoder: UIView!
    @IBOutlet var subCateTxt: UITextField!
    @IBOutlet var availableFromHolder: UIView!
    @IBOutlet var avaiableFromTxt: UITextField!
    @IBOutlet var avaiableTillHolder: UIView!
    @IBOutlet var availableTillTxt: UITextField!
    @IBOutlet var locationHolder: UIView!
    @IBOutlet var locationTxt: UITextField!
    @IBOutlet var descriptionTxt: UITextView!
    @IBOutlet var rentTypeHolder: UIView!
    
    @IBOutlet var areaTxt: UITextField!
    @IBOutlet var cityTxt: UITextField!
    @IBOutlet var zipTxt: UITextField!
    @IBOutlet var rentTypeTxt: UITextField!
    @IBOutlet var rentFeeTxt: UITextField!
    @IBOutlet var currentValueTxt: UITextField!
    var editableProduct : MyRentalProduct?
    
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    
    let cateDropdown = DropDown()
    let subCateDropDown = DropDown()
    let typeDropDown = DropDown()
    
    let fromCalendarPicker = EPCalendarPicker(startYear: 2016, endYear: 2017, multiSelection: true, selectedDates: [])
    let toCalendarPicker = EPCalendarPicker(startYear: 2016, endYear: 2017, multiSelection: true, selectedDates: [])
    var categoryList : [Category] = []
    var subCategoryList : [Category] = []
    var didTouchedFromDate = false
    var didTouchedToDate = false
    var selectedCategory = Array<Int>()
    var rentTypeList : [RentType] = []
    var rentTypeId : Int = 0
    var categoryDidChange : Bool! = false
    
    var pickedLocValue = CLLocationCoordinate2D()
    var placePicker: GMSPlacePicker?
    var selectedIndexPath :IndexPath?
    
    let locationManager = CLLocationManager()
    var currentLocValue = CLLocationCoordinate2D()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        baseUrl = defaults.string(forKey: "baseUrl")!
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        self.cateHolder.isUserInteractionEnabled = true
        let cateGesture = UITapGestureRecognizer(target: self, action:#selector(self.showHideCateDropDown) )
        self.cateHolder.addGestureRecognizer(cateGesture)
        
        
        self.subCateHoder.isUserInteractionEnabled = true
        let subCateGesture = UITapGestureRecognizer(target: self, action:#selector(self.showHideSubCateDropDown) )
        self.subCateHoder.addGestureRecognizer(subCateGesture)
        
        
        self.availableFromHolder.isUserInteractionEnabled = true
        let fromDateGexture = UITapGestureRecognizer(target: self, action:#selector(self.selectFromDateAction) )
        self.availableFromHolder.addGestureRecognizer(fromDateGexture)
        
        
        self.avaiableTillHolder.isUserInteractionEnabled = true
        let toDateGesture =  UITapGestureRecognizer(target: self, action:#selector(self.selectToDateAction) )
        self.avaiableTillHolder.addGestureRecognizer(toDateGesture)
        
        self.rentTypeHolder.isUserInteractionEnabled = true
        let typeGasture = UITapGestureRecognizer(target: self, action:#selector(self.showHideSubTypeDropDown) )
        self.rentTypeHolder.addGestureRecognizer(typeGasture)
        
        
        self.locationHolder.isUserInteractionEnabled = true
        let pickplace = UITapGestureRecognizer(target: self, action:#selector(self.pickPlaceAction) )
        self.locationHolder.addGestureRecognizer(pickplace)
        
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Edit Product"
        
        self.titleTxt.text = self.editableProduct?.name!
        self.areaTxt.text = self.editableProduct?.productLocation?.formattedAddress!
        self.cityTxt.text = self.editableProduct?.productLocation?.city!
        self.zipTxt.text = self.editableProduct?.productLocation?.zip!
        self.descriptionTxt.text = self.editableProduct?.description!
        self.currentValueTxt.text = "\((self.editableProduct?.currentValue!)!)"
        self.rentFeeTxt.text = "\((self.editableProduct?.rentFee!)!)"
        self.rentTypeTxt.text = self.editableProduct?.rentType.name!
        
        
        let timeInter1 :TimeInterval = self.editableProduct!.availableFrom! as TimeInterval
        let date1 = Date(timeIntervalSince1970: timeInter1/1000)
        let timeInter2 :TimeInterval = self.editableProduct!.availableTill as TimeInterval
        let date2 = Date(timeIntervalSince1970: timeInter2/1000)
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "dd-MM-yyyy"
        
        let dateString = dayTimePeriodFormatter.string(from: date1 as Date)
        let dateString1 = dayTimePeriodFormatter.string(from: date2 as Date)
        
        self.avaiableFromTxt.text = dateString
        self.availableTillTxt.text = dateString1
        
        
        if(self.editableProduct?.productCategories[0].category.isSubcategory != false){
            self.subCateTxt.text = self.editableProduct?.productCategories[0].category.name!
            self.getParentCate(categoryid: (self.editableProduct?.productCategories[0].category.id!)!)
        }else{
            self.cateTxt.text = self.editableProduct?.productCategories[0].category.name!
        }
        
        cateDropdown.anchorView = self.cateHolder
        subCateDropDown.anchorView = self.subCateHoder
        
        cateDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.categoryDidChange = true
            self.subCateTxt.text = ""
            self.cateTxt.text = item
            self.subCategoryList = self.categoryList[index].subcategory
            if(self.subCategoryList.isEmpty){
                
                self.selectedCategory.append(self.categoryList[index].id)
                self.subCateDropDown.dataSource = []
            }else{
                var subCates = Array<String>();
                for i in 0  ..< self.subCategoryList.count{
                    subCates.append(self.subCategoryList[i].name)
                }
                self.subCateDropDown.dataSource = subCates
            }
            
            
        }
        
        subCateDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
           
            self.subCateTxt.text = item
            self.selectedCategory.append(self.subCategoryList[index].id)
        }
        typeDropDown.anchorView = self.rentTypeHolder
        typeDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.rentTypeTxt.text = item
            self.rentTypeId = self.rentTypeList[index].id
        }
        if(self.categoryList.isEmpty){
            self.getCategory()
        }
        if(self.rentTypeList.isEmpty){
         self.getRentType()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func saveChangesAction(_ sender: UIButton) {
        var checkAll = true
        var paremeters : [String :AnyObject] = [:]
        if(self.titleTxt.text == ""){
            checkAll = false
            view.makeToast(message:"Title  is required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }else {
            if(self.titleTxt.text != self.editableProduct?.name){
                paremeters["name"] =  self.titleTxt.text as AnyObject?
            }
        }
        if(self.descriptionTxt.text == "" && checkAll != false){
            checkAll = false
            view.makeToast(message:"Product Description is required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }else{
            if(self.descriptionTxt.text != self.editableProduct?.description){
                paremeters["description"] =  self.descriptionTxt.text as AnyObject?
            }
        }
        if(self.rentTypeId != 0 && self.rentTypeId != self.editableProduct?.rentType.id && checkAll != false){
            paremeters["rentTypeId"] = self.rentTypeId as AnyObject?
        }
        if(self.currentValueTxt.text == "" && checkAll != false){
            checkAll = false
            view.makeToast(message:"Product current value is required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }else{
            if(currentValueTxt.text != "\(self.editableProduct?.currentValue)"){
                paremeters["currentValue"] = self.currentValueTxt.text as AnyObject?
            }
        }
        if(self.rentFeeTxt.text == "" && checkAll != false){
            checkAll = false
            view.makeToast(message:"Product rent fee is required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }else{
            if(self.rentFeeTxt.text != "\(self.editableProduct?.rentFee)"){
                paremeters["rentFee"] = self.rentFeeTxt.text as AnyObject?
            }
            
        }
        if(self.avaiableFromTxt.text != "" && checkAll != false){
            paremeters["availableFrom"] = self.avaiableFromTxt.text as AnyObject?
        }
        if(self.availableTillTxt.text != "" && checkAll != false){
            paremeters["availableTill"] = self.availableTillTxt.text as AnyObject?
        }
        if (self.areaTxt.text == "" && checkAll != false) {
            checkAll = false
            view.makeToast(message:"Area information  is required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }else{
            if(self.areaTxt.text != self.editableProduct?.productLocation?.formattedAddress!){
                paremeters["formattedAddress"] = self.areaTxt.text as AnyObject?
            }
        }
        if(self.cityTxt.text == "" && checkAll != false){
            checkAll = false
            view.makeToast(message:"City  is required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }else{
            if(self.cityTxt.text != self.editableProduct?.productLocation?.city!){
                paremeters["city"] = self.cityTxt.text as AnyObject?
            }
        }
        if(self.zipTxt.text == "" && checkAll != false){
            checkAll = false
            view.makeToast(message:"Zip code  is required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }else{
            if(self.zipTxt.text != self.editableProduct?.productLocation?.zip){
                paremeters["zip"] = self.zipTxt.text as AnyObject?
            }
        }
        if(categoryDidChange != false && self.selectedCategory.isEmpty && checkAll != false){
            checkAll = false
            view.makeToast(message:"Product category required is required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }else{
            if(self.categoryDidChange != false && !self.selectedCategory.isEmpty){
             paremeters["categoryIds"]  = "\(self.selectedCategory)" as AnyObject
            }
        }
        if(checkAll != false){
           
            print(paremeters)
            self.postEdit(paremeter: paremeters)
        }
    }
    //MARK: - PickPlace
    func pickPlaceAction (){
        print("Hello")
        
        
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
                self.locationTxt.text = place.name
            } else {
                print("No place selected")
            }
        } )
        
        
        
    }
    
    //MARK : - Calender
    func selectFromDateAction()
    {
        
        self.didTouchedFromDate = true;
        fromCalendarPicker.calendarDelegate = self
        fromCalendarPicker.startDate = Date()
        fromCalendarPicker.hightlightsToday = true
        fromCalendarPicker.showsTodaysButton = true
        fromCalendarPicker.hideDaysFromOtherMonth = true
        fromCalendarPicker.tintColor = UIColor.orange
        fromCalendarPicker.multiSelectEnabled = false
        fromCalendarPicker.dayDisabledTintColor = UIColor.gray
        fromCalendarPicker.title = "Available From "
        
        
        let navigationController = UINavigationController(rootViewController: fromCalendarPicker)
        self.present(navigationController, animated: true, completion: nil)
    }
    func selectToDateAction()  {
        self.didTouchedToDate = true
        toCalendarPicker.calendarDelegate = self
        toCalendarPicker.startDate = Date()
        toCalendarPicker.hightlightsToday = true
        toCalendarPicker.showsTodaysButton = true
        toCalendarPicker.hideDaysFromOtherMonth = true
        toCalendarPicker.tintColor = UIColor.orange
        toCalendarPicker.multiSelectEnabled = false
        toCalendarPicker.dayDisabledTintColor = UIColor.gray
        toCalendarPicker.title = "Will Available To"
        
        
        let navigationController = UINavigationController(rootViewController: toCalendarPicker)
        self.present(navigationController, animated: true, completion: nil)
    }
    // MARK: - EPCalendarPicker
    
    
    func epCalendarPicker(_: EPCalendarPicker, didCancel error : NSError) {
    }
    func epCalendarPicker(_: EPCalendarPicker, didSelectDate date : Date) {
        self.avaiableFromTxt.text =  ""
        self.availableTillTxt.text = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let str = formatter.string(from: date)
        
        if(self.didTouchedFromDate != false){
           
            toCalendarPicker.startDate = date
            self.didTouchedFromDate = false
            self.avaiableFromTxt.text = str//"User selected date: \n\(date)"
        }
        if(self.didTouchedToDate != false){
            self.didTouchedToDate = false
            self.availableTillTxt.text = str
        }
        
        
        
    }
    
    
    //MARK:- Dropdown
    func showHideCateDropDown() {
        cateDropdown.show();
    }
    func showHideSubCateDropDown(){
        subCateDropDown.show()
    }
    func showHideSubTypeDropDown()  {
        typeDropDown.show()
    }
    //MARK: - KeyBoard
    
    func keyboardWillShow(_ sender: Notification) {
        let userInfo: [AnyHashable: Any] = (sender as NSNotification).userInfo!
        
        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
        let offset: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                print("if in")
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= 100//keyboardSize.height
                })
            }
        } else {
            print("else in")
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
        print(self.view.frame.origin.y)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        if (((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += 100//keyboardSize.height
            }
            else {
                
            }
        }
    }
    
    //MARK : - ApiAccess
    
    
    func  getCategory()  {
        
        
        Alamofire.request(URL(string: "\(baseUrl)api/utility/get-category" )!, method: .get, encoding: JSONEncoding.default)
            
            .validate { request, response, data in
                // Custom evaluation closure now includes data (allows you to parse data to dig out error messages if necessary)
                return .success
            }
            .responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success(let data):
                    
                    let cateRes: CategoryResponse = Mapper<CategoryResponse>().map(JSON: data as! [String : Any])!
                    if((cateRes.responseStat.status) != false){
                        
                        self.categoryList = cateRes.responseData!
                        var cateSource = Array<String>() ;
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
                        self.typeDropDown.dataSource = cateSource
                    }
                case .failure(let error):
                    print(error)
                }
        }
        
    }
    func postEdit(paremeter : [String : AnyObject]) {
        print("post :\(baseUrl)api/auth/product/update-Product/\((self.editableProduct?.id!)!)")
        Alamofire.request(URL(string: "\(baseUrl)api/auth/product/update-product/\((self.editableProduct?.id!)!)" )!,method:.post ,parameters: paremeter)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                //print(response)
                switch response.result {
                case .success(let data):
                    let productRes: PostProductResponse = Mapper<PostProductResponse>().map(JSONObject: data)!
                    if((productRes.responseStat.status) != false){
                        
                        self.view.makeToast(message:"Product Updated successfully", duration: 2, position: HRToastPositionCenter as AnyObject)
                        //                        self.currentPrice.text = ""
                        //                        self.rentFee.text = ""
                        //                        if let tabBarController = self.presentWindow!.rootViewController as? UITabBarController {
                        //                            tabBarController.selectedIndex = 1
                        //                        }
                        
                    }else{
                        if(productRes.responseStat.msg == ""){
                            self.view.makeToast(message:productRes.responseStat.requestErrors![0].msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                        }else{
                            self.view.makeToast(message:productRes.responseStat.msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                        }
                        
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    func getParentCate(categoryid :Int)  {
      Alamofire.request(URL(string: "\(baseUrl)api/utility/get-parent-by-subcategory-id/\(categoryid)" )!,method:.get ,parameters: [:])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                //print(response)
                switch response.result {
                case .success(let data):
                    
                    let response: ParentCategoryResponse = Mapper<ParentCategoryResponse>().map(JSONObject: data)!
                    if((response.responseStat.status) != false){
                        self.cateTxt.text = response.responseData?.name!
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
