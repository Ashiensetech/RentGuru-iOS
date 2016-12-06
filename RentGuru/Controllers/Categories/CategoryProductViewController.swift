//
//  CategoryProductViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/8/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class CategoryProductViewController: UIViewController ,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,UIScrollViewDelegate {
    
    @IBOutlet var productCollection: UICollectionView!
    var allProduct : [RentalProduct] = []
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    var isData : Bool = true
    var offset : Int = 0
    var category : Category?
    var selectedProdIndex : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        baseUrl = defaults.string(forKey: "baseUrl")!
        self.productCollection.delegate = self
        self.productCollection.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.category?.name!
        self.tabBarController!.tabBar.isHidden = true;
        self.getProducts()
    }
    
    // MARK: - collectionview delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.allProduct.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "prodCell", for: indexPath) as! CategoryProductCollectionViewCell
        
        let data : RentalProduct = allProduct [(indexPath as NSIndexPath).row]
        let path = data.profileImage.original.path!
        print(URL(string: "\(baseUrl)images/\(path)")!)
        cell.productImageView.kf.setImage(with: URL(string: "\(baseUrl)images/\(path)")!,
                                          placeholder: nil,
                                          options: [.transition(.fade(1))],
                                          progressBlock: nil,
                                          completionHandler: nil)
        cell.productName.text = data.name
        cell.productPrice.text = "$\(data.rentFee!)/\(data.rentType.name!)"
        
        
        cell.tag = (indexPath as NSIndexPath).row
        cell.isUserInteractionEnabled = true
        cell.tag = (indexPath as NSIndexPath).row
        cell.isUserInteractionEnabled = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ProductDetailsFromCategory", sender: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.productCollection.frame.width)
        if width < 500 {
            let numberOfItemsPerRow:CGFloat = 2.0
            let widthAdjustment = CGFloat(10.0)
            let cellWidth = (width - widthAdjustment) / numberOfItemsPerRow
            let cellHeight =  cellWidth + 3.0
            return CGSize(width: cellWidth , height: cellHeight)
        }
        else {
            let numberOfItemsPerRow:CGFloat = 3.0
            let widthAdjustment =  CGFloat(20.0)
            let cellWidth = (width - widthAdjustment) / numberOfItemsPerRow
            let cellHeight =  cellWidth + 3.0
            return CGSize(width: cellWidth , height: cellHeight)
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.productCollection.reloadData()
        self.view.layoutIfNeeded()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if(scrollView == self.productCollection){
            print("searchProductCollection")
            let offsetY = self.productCollection.contentOffset.y
            let contentHeight = self.productCollection.contentSize.height
            if offsetY > contentHeight - self.productCollection.frame.size.height {
                self.getProducts()
                
                
            }
        }
    }
    
    //Mark : - ApiCall
    
    func getProducts() {
        if(self.isData != false){
            self.view.makeToastActivity()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            var  paremeters :[String:AnyObject] = [:]
            paremeters["categoryId"] = self.category!.id as AnyObject
            paremeters["limit"] = 10 as AnyObject
            paremeters["offset"] = self.offset as AnyObject
            
            Alamofire.request( URL(string: "\(baseUrl)api/product/get-product-by-category" )!,method :.get ,parameters: paremeters)
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
                                self.allProduct.append(product)
                            }
                            self.offset += 1
                            self.productCollection.reloadData()
                            
                        }else{
                            self.isData = false
                            self.view.makeToast(message:"No more data", duration: 2, position: HRToastPositionCenter as AnyObject)
                        }
                        
                    case .failure(let error):
                        print(error)
                        
                    }
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.view.hideToastActivity()
            }
        }
    }
    
     // MARK: - Navigation
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ProductDetailsFromCategory") {
            let indexPath = sender as! NSIndexPath
            let destinationVc = segue.destination as! ProductDetailsViewController
            destinationVc.product = self.allProduct[indexPath.row]
        }
     }
    
    
}
