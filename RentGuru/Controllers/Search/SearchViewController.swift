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
    lazy var cellSizes: [CGSize] = {
        var _cellSizes = [CGSize]()
        
        for _ in 0...100 {
            let random = Int(arc4random_uniform((UInt32(100))))
            
            _cellSizes.append(CGSize(width: 155, height: 150 + random))
        }
        
        return _cellSizes
    }()
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        baseUrl = defaults.string(forKey: "baseUrl")!
        
        self.prodCateHolder.isUserInteractionEnabled = true
        let cateGesture = UITapGestureRecognizer(target: self, action:#selector(SearchViewController.showHideCateDropDown) )
        self.prodCateHolder.addGestureRecognizer(cateGesture)
        
        self.proSubCateHolder.isUserInteractionEnabled = true
        let subCateGesture = UITapGestureRecognizer(target: self, action:#selector(SearchViewController.showHideSubCateDropDown) )
        self.proSubCateHolder.addGestureRecognizer(subCateGesture)
        
        self.searchProductCollection.delegate = self
        self.searchProductCollection.dataSource = self
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
       // layout.itemSize = CGSize(width: SCREEN_WIDTH / 2, height: SCREEN_WIDTH / 2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        searchProductCollection.collectionViewLayout = layout
       
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
            if(self.subCategoryList.isEmpty){
               // self.selectedCategory.append(self.categoryList[index].id)
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
           // self.selectedCategory.append(self.subCategoryList[index].id)
        }
        
        
    }
    @IBAction func sliderValueChange(_ sender: UISlider) {
        print (sender.value)
        self.radiusLbl.attributedText  =  NSAttributedString(string:"In Radius Of \(Int(sender.value)) KM", attributes:[NSForegroundColorAttributeName : UIColor.gray])
    }
    
    func showHideCateDropDown() {
        print("Hello")
        cateDropdown.show();
    }
    func showHideSubCateDropDown(){
        subCateDropDown.show()
    }
    @IBAction func seachButtonAction(_ sender: AnyObject) {
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
//        if(collectionView == self.offerCollection){
//            return self.allProducts.count
//        }
        return 10;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seachCell", for: indexPath) as!SearchCollectionViewCell
//            let data : RentalProduct = allProducts [(indexPath as NSIndexPath).row]
//            let path = data.profileImage.original.path!
//            print(URL(string: "\(baseUrl)images/\(path)")!)
//            cell.productImageView.kf.setImage(with: URL(string: "\(baseUrl)images/\(path)")!,
//                                              placeholder: nil,
//                                              options: [.transition(.fade(1))],
//                                              progressBlock: nil,
//                                              completionHandler: nil)
//            
//            //            cell.productImageView.kf_setImageWithURL(URL(string: "\(baseUrl)/images/\(data.profileImage.original.path)")!,
//            //                                                     placeholderImage: UIImage(named: "placeholder.gif"),
//            //                                                     optionsInfo: nil,
//            //                                                     progressBlock: { (receivedSize, totalSize) -> () in
//            //                                                        //  print("Download Progress: \(receivedSize)/\(totalSize)")
//            //                },
//            //                                                     completionHandler: { (image, error, cacheType, imageURL) -> () in
//            //                                                        // print("Downloaded and set!")
//            //                }
//            //            )
        
            cell.productImgeView.image = UIImage(named:"dis1.png")
            cell.productNameLbl.text = "Office Dex" // data.name
            cell.rentFeeLbl.text = "$500/Week"     //"$\(data.rentFee!)/\(data.rentType.name!)"
            
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
            let offsetY = self.searchProductCollection.contentOffset.y
            let contentHeight = self.searchProductCollection.contentSize.height
            if offsetY > contentHeight - self.searchProductCollection.frame.size.height {
                print("this is end, see you in console")
                //self.getProducts()
            }
        }else if(scrollView == self.baseScroll){
            
//            print("baseScrolled ")
//            
//            if (self.lastContentOffset > scrollView.contentOffset.y) {
//                UIView.animate(withDuration: 0.5, animations: {
//                    
//                    self.productScrollHeight.constant =  self.productScrollHeight.constant - 412
//                    self.productScrollBottom.constant =  self.productScrollBottom.constant + 206
//                    self.view.layoutIfNeeded()
//                })
//                self.listName.text = "FEATURED PRODUCTS"
//                
//            }
//            else if (self.lastContentOffset < scrollView.contentOffset.y) {
//                // print("Moved Down \(self.lastContentOffset)")
//                
//                UIView.animate(withDuration: 0.5, animations: {
//                    
//                    self.productScrollHeight.constant =  self.productScrollHeight.constant + 412
//                    self.productScrollBottom.constant =  self.productScrollBottom.constant - 206
//                    self.view.layoutIfNeeded()
//                })
//                
//                self.listName.text = "ALL PRODUCTS"
//            }
//            
//            // update the new position acquired
//            self.lastContentOffset = scrollView.contentOffset.y
//            self.getProducts()
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        if(collectionView == self.searchProductCollection){
         return cellSizes[(indexPath as NSIndexPath).item]
        }else{
            return CGSize(width: 122, height:135)
        }
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = (collectionView.frame.width)
//        if width < 500 {
//            let numberOfItemsPerRow:CGFloat = 2.0
//            let widthAdjustment = CGFloat(1.0)
//            let cellWidth = (width - widthAdjustment) / numberOfItemsPerRow
//            let cellHeight =  cellWidth + 50.0
//            return CGSize(width: cellWidth , height: cellHeight)
//        }
//        else {
//            let numberOfItemsPerRow:CGFloat = 3.0
//            let widthAdjustment =  CGFloat(3.0)
//            let cellWidth = (width - widthAdjustment) / numberOfItemsPerRow
//            let cellHeight =  cellWidth + 50.0
//            return CGSize(width: cellWidth , height: cellHeight)
//        }
//    }
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

}
