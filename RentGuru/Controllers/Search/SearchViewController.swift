//
//  SearchViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/1/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import DropDown
import Alamofire
import ObjectMapper
import GooglePlaces
import GooglePlacePicker
import CoreLocation
class SearchViewController: UIViewController ,UITextFieldDelegate ,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource ,UIScrollViewDelegate,CLLocationManagerDelegate{
    @IBOutlet var searchTxt: UITextField!
    @IBOutlet var categoryTxt: UITextField!
    @IBOutlet var subCateTxt: UITextField!
    @IBOutlet var locTxt: UITextField!
    @IBOutlet var rangeSlider: UISlider!
    @IBOutlet var viewUnderSearchTxt: UIView!
    @IBOutlet var radiusLbl: UILabel!
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchViewHeight: NSLayoutConstraint!
    @IBOutlet var placePickerView: UIView!
    
    @IBOutlet var collectionviewHeight: NSLayoutConstraint!
    
    @IBOutlet var searchProductCollection: UICollectionView!
    @IBOutlet var baseScroll: UIScrollView!
    @IBOutlet var prodCateHolder: UIView!
    @IBOutlet var prodCateArrowDown: UIImageView!
    @IBOutlet var proSubCateHolder: UIView!
    @IBOutlet var prodSubCateArrowDown: UIImageView!
    let cateDropdown = DropDown()
    let subCateDropDown = DropDown()
    var selectedProdIndex : Int = 0
    var categoryList : [Category] = []
    var subCategoryList : [Category] = []
    
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    
    @IBOutlet var productCollectionBottom: NSLayoutConstraint!
    @IBOutlet var searchViewBottom: NSLayoutConstraint!
    
    var allProducts:[RentalProduct] = []
    var offset : Int = 0
    var isData : Bool = false
    var presentWindow : UIWindow?
    fileprivate  var lastContentOffset: CGFloat = 0
    
    var  paremeters :[String:AnyObject] = [:]
    var selectedCateId : Int = 0
    var selectedSubcateId :Int = 0
    var radius :Float = 0.0
    var pickedLocValue = CLLocationCoordinate2D()
    var placePicker: GMSPlacePicker?
    var selectedIndexPath :IndexPath?
    
    let locationManager = CLLocationManager()
    var currentLocValue = CLLocationCoordinate2D()
    override func viewDidLoad(){
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        baseUrl = defaults.string(forKey: "baseUrl")!
        presentWindow = UIApplication.shared.keyWindow
        self.prodCateHolder.isUserInteractionEnabled = true
        let cateGesture = UITapGestureRecognizer(target: self, action:#selector(SearchViewController.showHideCateDropDown) )
        self.prodCateHolder.addGestureRecognizer(cateGesture)
        
        self.proSubCateHolder.isUserInteractionEnabled = true
        let subCateGesture = UITapGestureRecognizer(target: self, action:#selector(SearchViewController.showHideSubCateDropDown) )
        self.proSubCateHolder.addGestureRecognizer(subCateGesture)
        
        self.placePickerView.isUserInteractionEnabled = true
        let pickplace = UITapGestureRecognizer(target: self, action:#selector(SearchViewController.pickPlaceAction) )
        self.placePickerView.addGestureRecognizer(pickplace)
        
        self.searchProductCollection.delegate = self
        self.searchProductCollection.dataSource = self
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        // layout.itemSize = CGSize(width: SCREEN_WIDTH / 2, height: SCREEN_WIDTH / 2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        searchProductCollection.collectionViewLayout = layout
        
        self.baseScroll.delegate = self
        
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocValue = manager.location!.coordinate
        print("locations = \(currentLocValue.latitude) \(currentLocValue.longitude)")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cateDropdown.anchorView = self.prodCateHolder
        subCateDropDown.anchorView = self.proSubCateHolder
        self.getCategory()
        self.searchTxt.delegate = self
        
        
        
        cateDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            // print("Selected item: \(item) at index: \(index)")
            self.categoryTxt.attributedText  =  NSAttributedString(string: (item), attributes:[NSForegroundColorAttributeName : UIColor.gray])
            self.subCateTxt.attributedText  =  NSAttributedString(string:"Product Sub Category", attributes:[NSForegroundColorAttributeName : UIColor.gray])
            self.subCategoryList = self.categoryList[index].subcategory
            self.selectedCateId  = self.categoryList[index].id
            if(self.subCategoryList.isEmpty){
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
            // print("Selected item: \(item) at index: \(index)")
            self.subCateTxt.attributedText  =  NSAttributedString(string: (item), attributes:[NSForegroundColorAttributeName : UIColor.gray])
            self.selectedSubcateId = self.subCategoryList[index].id
        }
        
        if(self.allProducts.isEmpty != true){
            self.isData = true
            self.baseScroll.contentSize = CGSize(
                width: self.view.frame.size.width,
                height: self.view.frame.size.height + 407
            );
            self.getSearchProduct(paremeters: self.paremeters)
            self.view.layoutIfNeeded()
         
            self.searchProductCollection.scrollToItem(at: self.selectedIndexPath!, at: UICollectionViewScrollPosition.centeredVertically, animated: true)
            
        }
        
        
    }
    override func viewDidLayoutSubviews() {
        
        
    }
    @IBAction func sliderValueChange(_ sender: UISlider) {
        print (sender.value)
        self.radiusLbl.attributedText  =  NSAttributedString(string:"In Radius Of \(Int(sender.value)) KM", attributes:[NSForegroundColorAttributeName : UIColor.gray])
        self.radius = Float(sender.value)
    }
    
    func showHideCateDropDown() {
        
        cateDropdown.show();
    }
    func showHideSubCateDropDown(){
        subCateDropDown.show()
    }
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
                self.locTxt.text = place.name
            } else {
                print("No place selected")
            }
        } )
        
        
        
    }
    @IBAction func seachButtonAction(_ sender: AnyObject) {
        self.allProducts.removeAll()
        self.searchProductCollection.reloadData()
        self.setParams(offset: 0)
        self.getSearchProduct(paremeters: self.paremeters)
    }
    
    func setParams(offset : Int){
        let limit = 6 as AnyObject!
        self.paremeters = ["limit" : limit! , "offset" : offset as AnyObject ]
        
        if(self.selectedCateId != 0 && self.selectedSubcateId == 0  )
        {
            paremeters["categoryId"] = self.selectedCateId as AnyObject?
        }else{
            paremeters["categoryId"] = self.selectedSubcateId as AnyObject?
        }
        if(self.searchTxt.text != ""){
            paremeters["title"] = self.searchTxt.text as AnyObject?
        }
        if(self.locTxt.text != "Let Rent Guru Pick your Location"){
            self.paremeters["lat"] = self.pickedLocValue.latitude as AnyObject?
            self.paremeters ["lng"] = self.pickedLocValue.longitude as AnyObject?
            self.paremeters["radius"] = self.radius as AnyObject?
        }
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    //The color switching things are done here
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == self.searchTxt){
            self.viewUnderSearchTxt.backgroundColor = UIColor(netHex:0xD0842D)
        }else{
            self.viewUnderSearchTxt.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == self.searchTxt){
            self.viewUnderSearchTxt.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
        
    }
    func perfromNext(_ sender :UITapGestureRecognizer)  {
        self.view.makeToastActivity()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let tapLocation = sender.location(in: self.searchProductCollection)
        let indexPath : IndexPath = self.searchProductCollection.indexPathForItem(at: tapLocation)!
        
        if let cell = self.searchProductCollection.cellForItem(at: indexPath)
        {
            self.selectedIndexPath  = indexPath
            self.selectedProdIndex = cell.tag
            
        }
        DispatchQueue.main.async(execute: {
            UIApplication.shared.endIgnoringInteractionEvents()
            self.performSegue(withIdentifier: "showDetails", sender: nil)
        })
        
        
    }
    // MARK: - collectionview delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.allProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seachCell", for: indexPath) as!SearchCollectionViewCell
        
        let data : RentalProduct = allProducts [(indexPath as NSIndexPath).row]
        let path = data.profileImage.original.path!
        print(URL(string: "\(baseUrl)images/\(path)")!)
        cell.productImgeView.kf.setImage(with: URL(string: "\(baseUrl)images/\(path)")!,
                                         placeholder: nil,
                                         options: [.transition(.fade(1))],
                                         progressBlock: nil,
                                         completionHandler: nil)
        cell.productNameLbl.text = data.name
        cell.rentFeeLbl.text = "$\(data.rentFee!)/\(data.rentType.name!)"
        
        
        cell.tag = (indexPath as NSIndexPath).row
        cell.isUserInteractionEnabled = true
        cell.tag = (indexPath as NSIndexPath).row
        cell.isUserInteractionEnabled = true
        let selectGesture = UITapGestureRecognizer(target: self, action:#selector(SearchViewController.perfromNext) )
        //selectGesture.numberOfTapsRequired = 2
        cell.addGestureRecognizer(selectGesture)
        
        return cell
        
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if(scrollView == self.searchProductCollection){
            print("searchProductCollection")
            let offsetY = self.searchProductCollection.contentOffset.y
            let contentHeight = self.searchProductCollection.contentSize.height
            if offsetY > contentHeight - self.searchProductCollection.frame.size.height {
                self.setParams(offset: self.offset)
                self.getSearchProduct(paremeters: self.paremeters)
                
            }
        }else if(scrollView == self.baseScroll){
            
            print("baseScrolled ")
            if(self.isData != false){
                if (self.lastContentOffset > scrollView.contentOffset.y) {
                    print("if")
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.collectionviewHeight.constant =  self.collectionviewHeight.constant - 412
                        self.productCollectionBottom.constant =  self.productCollectionBottom.constant + 206
                        self.view.layoutIfNeeded()
                    })
                    
                    
                }
                else if (self.lastContentOffset < scrollView.contentOffset.y) {
                    print("Else")
                    self.collectionviewHeight.constant = 800
                    self.view.layoutIfNeeded()
                    // print("Moved Down \(self.lastContentOffset)")
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.collectionviewHeight.constant =  self.collectionviewHeight.constant + 412
                        self.productCollectionBottom.constant =  self.productCollectionBottom.constant - 206
                        self.view.layoutIfNeeded()
                    })
                    
                    
                }
                
                // update the new position acquired
                self.lastContentOffset = self.baseScroll.contentOffset.y
                self.setParams(offset: self.offset)
                self.getSearchProduct(paremeters: self.paremeters)
            }
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (searchProductCollection.frame.width)
        if width < 500 {
            let numberOfItemsPerRow:CGFloat = 2.0
            let widthAdjustment = CGFloat(10.0)
            let cellWidth = (width - widthAdjustment) / numberOfItemsPerRow
            let cellHeight =  cellWidth + 3.0
            return CGSize(width: cellWidth , height: cellHeight)
        }
        else {
            let numberOfItemsPerRow:CGFloat = 3.0
            let widthAdjustment =  CGFloat(15.0)
            let cellWidth = (width - widthAdjustment) / numberOfItemsPerRow
            let cellHeight =  cellWidth + 3.0
            return CGSize(width: cellWidth , height: cellHeight)
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        searchProductCollection?.reloadData()
        self.view.layoutIfNeeded()
    }
    //
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
                        print("data", cateRes.responseData)
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
    
    func getSearchProduct(paremeters :[ String :AnyObject]) {
        self.view.makeToastActivity()
        UIApplication.shared.beginIgnoringInteractionEvents()
        Alamofire.request( URL(string: "\(baseUrl)api/search/rental-product" )!,method :.get ,parameters: paremeters)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    //  print(data)
                    let proRes: ProductResponse = Mapper<ProductResponse>().map(JSONObject: data)!
                    print(proRes.responseStat.status)
                    
                    if(proRes.responseStat.status != false){
                        //  print(proRes.responseData!)
                        for i in 0 ..< proRes.responseData!.count {
                            let product : RentalProduct = proRes.responseData![i]
                            self.allProducts.append(product)
                        }
                        
                        self.isData = true
                        self.offset += 1
                        self.searchProductCollection.reloadData()
                        
                        if(self.offset == 1){
                            self.baseScroll.contentSize = CGSize(
                                width: self.view.frame.size.width,
                                height: self.view.frame.size.height + 407
                            );
                        }
                        
                    }else{
                        self.isData = false
                        self.view.makeToast(message:"No Product Found", duration: 2, position: HRToastPositionCenter as AnyObject)
                    }
                    
                case .failure(let error):
                    print(error)
                    
                }
                UIApplication.shared.endIgnoringInteractionEvents()
                self.view.hideToastActivity()
        }
        
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showDetails"){
             self.setParams(offset: self.offset)
            let navVC = segue.destination as! UINavigationController
            let detailsVC = navVC.viewControllers.first as! ProductDetailsViewController
            detailsVC.product = self.allProducts[self.selectedProdIndex]
            detailsVC.allProducts = self.allProducts
            detailsVC.onIndexPath = self.selectedIndexPath
            detailsVC.paremeters = self.paremeters
            detailsVC.fromController = "Search"
        }
    }
    
}
