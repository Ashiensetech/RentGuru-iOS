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


class SearchViewController: UIViewController ,UITextFieldDelegate ,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource ,UIScrollViewDelegate{
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
    
    var categoryList : [Category] = []
    var subCategoryList : [Category] = []
    
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    
    @IBOutlet var productCollectionBottom: NSLayoutConstraint!
    @IBOutlet var searchViewBottom: NSLayoutConstraint!
    
    var allProducts:[RentalProduct] = []
    var offset : Int = 0
    var isData : Bool = true
    var presentWindow : UIWindow?
    fileprivate  var lastContentOffset: CGFloat = 0
    
    var  paremeters :[String:AnyObject] = [:]
    var selectedCateId : Int = 0
    var selectedSubcateId :Int = 0
    var radius :Float = 0.0
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
        
        
    }
    override func viewDidLayoutSubviews() {
        self.baseScroll.contentSize = CGSize(
            width: self.view.frame.size.width,
            height: self.view.frame.size.height + 407
        );
        
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
        // let selectGesture = UITapGestureRecognizer(target: self, action:#selector(HomeViewController.perfromNext) )
        //selectGesture.numberOfTapsRequired = 2
        //  cell.addGestureRecognizer(selectGesture)
        
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
        
        // api/search/rental-product
        
        //title
        //        lat
        //        lng
        //        radius // Float
        //        *offset
        //        *limit
        //        categoryId
        
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
                        self.offset += 1
                        self.searchProductCollection.reloadData()
                        
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
    
}
