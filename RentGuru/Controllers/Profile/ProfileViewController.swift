//
//  ProfileViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/19/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet var segmentedView: UISegmentedControl!
    @IBOutlet var MyRentRequest: UIView!
    @IBOutlet var MyProductRentRequest: UIView!
    
    @IBOutlet var MyProducts: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        MyProductRentRequest.isHidden = false
        MyRentRequest.isHidden = true
        MyProducts.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentSelectionChanged(_ sender: AnyObject) {
        switch segmentedView.selectedSegmentIndex
        {
        case 0:
            MyProductRentRequest.isHidden = false
            MyRentRequest.isHidden = true
            MyProducts.isHidden = true
        case 1:
            MyProductRentRequest.isHidden = true
            MyRentRequest.isHidden = false
            MyProducts.isHidden = true
        case 2:
            MyProductRentRequest.isHidden = true
            MyRentRequest.isHidden = true
            MyProducts.isHidden = false
        default:
            break;
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
