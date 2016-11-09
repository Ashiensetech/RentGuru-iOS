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
class CategoryProductViewController: UIViewController ,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,UIScrollViewDelegate{
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let selectGesture = UITapGestureRecognizer(target: self, action:#selector(SearchViewController.perfromNext) )
        //selectGesture.numberOfTapsRequired = 2
        cell.addGestureRecognizer(selectGesture)
        
        return cell
        
        
        
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
    
    func perfromNext(_ sender :UITapGestureRecognizer)  {
        self.view.makeToastActivity()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let tapLocation = sender.location(in: self.productCollection)
        let indexPath : IndexPath = self.productCollection.indexPathForItem(at: tapLocation)!
        
        if let cell = self.productCollection.cellForItem(at: indexPath)
        {
           // self.selectedIndexPath  = indexPath
            self.selectedProdIndex = cell.tag
            
        }
        DispatchQueue.main.async(execute: {
            UIApplication.shared.endIgnoringInteractionEvents()
            self.performSegue(withIdentifier: "showDetails", sender: nil)
        })
        
        
    }
    //Mark : - ApiCall
    
    func getProducts() {
        if(self.isData != false){
            self.view.makeToastActivity()
            UIApplication.shared.beginIgnoringInteractionEvents()
            let  paremeters :[String:AnyObject] = ["categoryId": self.category!.id as AnyObject,"limit" : 10 as AnyObject , "offset" : self.offset as AnyObject ]
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
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showDetails"){
            
           // let navVC = segue.destination as! UINavigationController
            let detailsVC = segue.destination as! ProductDetailsViewController
            detailsVC.product = self.allProduct[self.selectedProdIndex]
          
            detailsVC.fromController = "Category"
        }
     }
    
    
}
