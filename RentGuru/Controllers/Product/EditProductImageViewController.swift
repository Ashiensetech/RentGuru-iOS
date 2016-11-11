//
//  EditProductImageViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/10/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit

class EditProductImageViewController: UIViewController ,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    @IBOutlet var productProfileImageview: UIImageView!
    @IBOutlet var otheriamgeCollection: UICollectionView!
    var editableProduct : MyRentalProduct?
    
    var defaults = UserDefaults.standard
    var baseUrl : String = ""
    var imageUrls :[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
         baseUrl = defaults.string(forKey: "baseUrl")!
        self.otheriamgeCollection.delegate = self
        self.otheriamgeCollection.dataSource = self
        
        let path = self.editableProduct?.profileImage.original.path!
        productProfileImageview.kf.setImage(with: URL(string: "\(baseUrl)/images/\(path!)")!,
                                            placeholder: nil,
                                            options: [.transition(.fade(1))],
                                            progressBlock: nil,
                                            completionHandler: nil)
        if(self.editableProduct?.otherImages.isEmpty) != false || self.editableProduct?.otherImages.count == 0{
            
        }else{
           // imageUrls.append((editableProduct?.profileImage.original.path)!)
//            
//            for i in 0..<editableProduct?.otherImages.count{
//                let dataImage : Picture  = product.otherImages[i]
//                imageUrls.append(dataImage.original.path)
//            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeProfilePictureAction(_ sender: UIButton) {
    }
    @IBAction func addOtherImageAction(_ sender: UIButton) {
    }
    func removeImage()  {
        
    }
    // MARK:- Collection view Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return (self.editableProduct?.otherImages.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! EditOtherImageCollectionViewCell
        
        
        // Configure the cell
         let dataImage : Picture  = (self.editableProduct?.otherImages[indexPath.row])!
        let path = (dataImage.original.path!)
        print(path)
        cell.imageView.kf.setImage(with: URL(string: "\(baseUrl)/images/\(path)")!,
                                        placeholder: nil,
                                        options: [.transition(.fade(1))],
                                        progressBlock: nil,
                                        completionHandler: nil)
        
        
    
        
        cell.removeBtn.addTarget(self, action: #selector(self.removeImage), for: .touchUpInside)
        
        return cell
        
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (otheriamgeCollection.frame.width)
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
        self.otheriamgeCollection.reloadData()
        self.view.layoutIfNeeded()
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
