//
//  ProductDetailsViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/9/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import ObjectMapper
import Foundation
class ProductDetailsViewController: UIViewController,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource ,RatingViewDelegate {
    
    @IBOutlet var ratingView: RatingView!
    @IBOutlet var baseScroll: UIScrollView!
   
    @IBOutlet var productName: UILabel!
    @IBOutlet var productProfileImageView: UIImageView!
    @IBOutlet var otherImageCollection: UICollectionView!
    @IBOutlet var rentFee: UILabel!
    @IBOutlet var available: UILabel!
    @IBOutlet var otherImageHeight: NSLayoutConstraint!
    @IBOutlet var categories: UILabel!
    @IBOutlet var descriptionText: UITextView!
    @IBOutlet var pickupLoc: UILabel!
    var fromController :String = ""
    var product :RentalProduct!
    var defaults = UserDefaults.standard
    var baseUrl : String = ""
    var imageUrls :[String] = []
    var allProducts:[RentalProduct] = []
    var onIndexPath :IndexPath?
    var  paremeters :[String:AnyObject] = [:]
    override func viewDidLoad() {
        
        super.viewDidLoad()
        baseUrl = defaults.string(forKey: "baseUrl")!
        
        self.otherImageCollection.delegate = self
        self.otherImageCollection.dataSource = self
        
        var scalingTransform : CGAffineTransform!
        scalingTransform = CGAffineTransform(scaleX: 1, y: -1);
        otherImageCollection.transform = scalingTransform
        
        self.ratingView.editable = false;
        self.ratingView.delegate = self;
        
       
        
      
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.navigationBar.barTintColor = UIColor(netHex:0x2D2D2D)
        self.navigationItem.title =  product.name.uppercased()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(netHex:0xD0842D)]
               self.productName.text = product.name.uppercased()
        self.rentFee.text = "$\(product.rentFee!) / \(product.rentType.name!)"
        self.descriptionText.text = product.description
        
//        if let url  = URL(string: "\(baseUrl)/images/\(product.profileImage.original.path)"),
//            let imageData = try? Data(contentsOf: url)
//        {
//            productProfileImageView.image = UIImage(data: imageData)
//        }
        
        let path = product.profileImage.original.path!
        productProfileImageView.kf.setImage(with: URL(string: "\(baseUrl)/images/\(path)")!,
                                        placeholder: nil,
                                        options: [.transition(.fade(1))],
                                        progressBlock: nil,
                                        completionHandler: nil)
        
        var cateString : String = ""
        
        for i in 0 ..< self.product.productCategories.count{
            if(i == 0){
                cateString = "\(self.product.productCategories[i].category.name!)"
            }else {
                cateString = "\(cateString), \(self.product.productCategories[i].category.name!)"
            }
        }
        
        self.categories.text = cateString
        
        print(self.product.otherImages)
        if(self.product.otherImages.isEmpty) != false || self.product.otherImages.count == 0{
            self.otherImageHeight.constant = 0.0
            self.otherImageCollection.setNeedsUpdateConstraints()
        }else{
            imageUrls.append(product.profileImage.original.path)
            
            for i in 0..<product.otherImages.count{
                let dataImage : Picture  = product.otherImages[i]
                imageUrls.append(dataImage.original.path)
            }
        }
        
        let timeInter1 :TimeInterval = product.availableFrom as TimeInterval
        let date1 = Date(timeIntervalSince1970: timeInter1/1000)
        let timeInter2 :TimeInterval = product.availableTill as TimeInterval
        let date2 = Date(timeIntervalSince1970: timeInter2/1000)
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd YYYY"
        
        
        
        let dateString1 = dayTimePeriodFormatter.string(from: date1)
        let dateString2 = dayTimePeriodFormatter.string(from: date2)
        
        self.available.text = "\(dateString1) to \(dateString2)"
        self.ratingView.rating = self.product.averageRating
        self.pickupLoc.text = self.product.productLocation?.formattedAddress
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    @IBAction func rentNowAction(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "rentNow", sender: nil)
    }

    @IBAction func navigateBackAction(_ sender: AnyObject) {
       // if(self.fromController == "Home"){
            self.performSegue(withIdentifier: "Back", sender: nil)
       // }
    }
    
    override func viewDidLayoutSubviews() {
        self.baseScroll.contentSize = CGSize(
            width: self.view.frame.size.width,
            height: self.view.frame.size.height + 550
        );
        
    }
    override func viewWillDisappear(_ animated: Bool)
    {

            super.viewWillDisappear(animated)
            self.navigationController?.isNavigationBarHidden = true
//
    }
    
    
    
    func likeProductAction() {
        print(self.product.id)
    }
    // MARK:- Collection view Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //  return   self.product.otherImages!.count
        return self.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionCell
        
        // Configure the cell
        // let dataImage : Picture  = product.otherImages![indexPath.row]
        
         cell.imageContainer.kf.setImage(with: URL(string: "\(baseUrl)/images/\(imageUrls[(indexPath as NSIndexPath).row])")!,
                              placeholder: nil,
                              options: [.transition(.fade(1))],
                              progressBlock: nil,
                              completionHandler: nil)
        
        
//        cell.imageContainer.kf_setImageWithURL(URL(string: "\(baseUrl)/images/\(imageUrls[(indexPath as NSIndexPath).row])")!,
//                                               placeholderImage:UIImage(named: "placeholder.gif"),
//                                               optionsInfo: nil,
//                                               progressBlock: { (receivedSize, totalSize) -> () in
//                                                //  print("Download Progress: \(receivedSize)/\(totalSize)")
//            },
//                                               completionHandler: { (image, error, cacheType, imageURL) -> () in
//                                                // print("Downloaded and set!")
//            }
//        )
        
        var scalingTransform : CGAffineTransform!
        scalingTransform = CGAffineTransform(scaleX: 1, y: -1);
        cell.transform = scalingTransform
        
        return cell
        
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionCell
        self.productProfileImageView.image = cell.imageContainer.image
        
    }
    
    
    
    //MARK:- RatingViewDelegate
    
    func ratingView(_ ratingView: RatingView, didChangeRating newRating: Float) {
        print(newRating)
        
        self.view.makeToastActivity()
        Alamofire.request( URL(string: "\(baseUrl)api/auth/product/rate-product/\(self.product.id)/\(newRating)" )!,method: .get ,parameters: [:])
          //  .validate(contentType: ["application/json"])
            .responseJSON { response in
                print(response)
                self.view.hideToastActivity()
                switch response.result {
                case .success(let data):
                    let ratingRes: RatingResponse = Mapper<RatingResponse>().map(JSONString: data as! String)!
                    if(ratingRes.responseStat.status != false){
                        self.view.makeToast(message:"Successfully rated", duration: 2, position: HRToastPositionDefault as AnyObject)
                        
                    }else{
                        self.ratingView.rating = self.product.averageRating
                        self.view.makeToast(message:ratingRes.responseStat.msg, duration: 2, position: HRToastPositionDefault as AnyObject)
                    }
                    
                    
                    
                    
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "rentNow"){
            let navVC = segue.destination as! UINavigationController
            let rentVC = navVC.viewControllers.first as! RentRequestViewController
          
            rentVC.product = self.product
        }
        if(segue.identifier == "Back"){
            let tabVc = segue.destination as! UITabBarController
            if(self.fromController == "Home"){
             tabVc.selectedIndex = 0
            }else if(self.fromController == "Category"){
                tabVc.selectedIndex = 2
               
            }
            else{
                print(tabVc.viewControllers?[1])
                let vc = tabVc.viewControllers?[1] as! SearchViewController
                vc.allProducts = self.allProducts
                vc.selectedIndexPath = self.onIndexPath
                vc.paremeters = self.paremeters
                 tabVc.selectedIndex = 1
            }
            
        }
    }
    
    
}
