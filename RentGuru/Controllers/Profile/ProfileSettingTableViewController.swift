//
//  ProfileSettingTableViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/24/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit

class ProfileSettingTableViewController: UITableViewController {
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.tableFooterView?.backgroundColor = UIColor.gray
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController!.navigationBar.barTintColor = UIColor(netHex:0x2D2D2D)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(netHex:0xD0842D)]
    }
    
    func logout(){
        AppDelegate.resetToFirst()
//        defaults.set("abc", forKey: "accesstoken")
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "LoginSignupView") as! LoginViewController
//        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell != nil {
           print("Section :\(indexPath.section) Row :\(indexPath.row)")
            if((indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0){
                self.performSegue(withIdentifier: "myProductRequest", sender: nil)
            
            }else if ((indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 1){
                 self.performSegue(withIdentifier: "myRequest", sender: nil)
            
            }else if(((indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0)){
                 self.performSegue(withIdentifier: "myProduct", sender: nil)
            
            }else if(((indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0)){
             self.performSegue(withIdentifier: "editProfile", sender: nil)
            }else if(((indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 1)){
                self.performSegue(withIdentifier: "paypalAccount", sender: nil)
            }
            else if(((indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 2)){
                self.logout()
            }

            
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    //    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    
    //    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        // #warning Incomplete implementation, return the number of rows
    //        return 0
    //    }
    
    /*
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationController!.navigationBar.barTintColor = UIColor(netHex:0x2D2D2D)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(netHex:0xD0842D)]
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationItem.backBarButtonItem!.tintColor = UIColor.white
     }
 
    
}
