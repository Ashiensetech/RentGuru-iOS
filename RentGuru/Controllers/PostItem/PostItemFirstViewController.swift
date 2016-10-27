//
//  PostItemFirstViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/4/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import DropDown
import Alamofire
import ObjectMapper


class PostItemFirstViewController: UIViewController ,EPCalendarPickerDelegate{
    @IBOutlet var baseScroll: UIScrollView!
    @IBOutlet var prodCateHolder: UIView!
    @IBOutlet var prodCateLabel: UILabel!
    @IBOutlet var proSubCateHolder: UIView!
    @IBOutlet var prodSubCateLabel: UILabel!
    @IBOutlet var fromDateSelector: UIImageView!
    @IBOutlet var toDateSelector: UIImageView!
    
    @IBOutlet var toDateTxt: UITextField!
    @IBOutlet var fromDateTxt: UITextField!
    @IBOutlet var productTitleTxt: UITextField!
    @IBOutlet var areaText: UIView!
    @IBOutlet var areaTextField: UITextField!
    @IBOutlet var cityTxt: UITextField!
    @IBOutlet var zipTxt: UITextField!
    @IBOutlet var fromDateView: UIView!
    @IBOutlet var toDateView: UIView!
    
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    
    let cateDropdown = DropDown()
    let subCateDropDown = DropDown()
    let fromCalendarPicker = EPCalendarPicker(startYear: 2016, endYear: 2017, multiSelection: true, selectedDates: [])
    let toCalendarPicker = EPCalendarPicker(startYear: 2016, endYear: 2017, multiSelection: true, selectedDates: [])
    var categoryList : [Category] = []
    var subCategoryList : [Category] = []
    var didTouchedFromDate = false
    var didTouchedToDate = false
    var selectedCategory = Array<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        baseUrl = defaults.string(forKey: "baseUrl")!
        
        
        
       
        NotificationCenter.default.addObserver(self, selector: #selector(PostItemFirstViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostItemFirstViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        self.navigationController!.navigationBar.barTintColor = UIColor(netHex:0x2D2D2D)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(netHex:0xD0842D)]
        
        self.prodCateHolder.isUserInteractionEnabled = true
        self.prodCateLabel.isUserInteractionEnabled = true
        let cateGesture = UITapGestureRecognizer(target: self, action:#selector(PostItemFirstViewController.showHideCateDropDown) )
        self.prodCateHolder.addGestureRecognizer(cateGesture)
        self.prodCateLabel.addGestureRecognizer(cateGesture)
        
        
        self.proSubCateHolder.isUserInteractionEnabled = true
        self.prodSubCateLabel.isUserInteractionEnabled = true
        let subCateGesture = UITapGestureRecognizer(target: self, action:#selector(PostItemFirstViewController.showHideSubCateDropDown) )
        self.proSubCateHolder.addGestureRecognizer(subCateGesture)
        self.prodSubCateLabel.addGestureRecognizer(subCateGesture)
        
        self.fromDateSelector.isUserInteractionEnabled = true
        self.fromDateView.isUserInteractionEnabled = true
        let fromDateGexture = UITapGestureRecognizer(target: self, action:#selector(PostItemFirstViewController.selectFromDateAction) )
        self.fromDateSelector.addGestureRecognizer(fromDateGexture)
        self.fromDateView.addGestureRecognizer(fromDateGexture)
        
        self.toDateSelector.isUserInteractionEnabled = true
        self.toDateSelector.isUserInteractionEnabled = true
        let toDateGesture =  UITapGestureRecognizer(target: self, action:#selector(PostItemFirstViewController.selectToDateAction) )
        self.toDateSelector.addGestureRecognizer(toDateGesture)
        self.toDateView.addGestureRecognizer(toDateGesture)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.getCategory()
        
        cateDropdown.anchorView = self.prodCateHolder
        subCateDropDown.anchorView = self.prodCateHolder
        
        self.navigationItem.title = "Primary Information"
        
        cateDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            // print("Selected item: \(item) at index: \(index)")
            self.prodCateLabel.attributedText  =  NSAttributedString(string: (item), attributes:[NSForegroundColorAttributeName : UIColor.gray])
            self.prodSubCateLabel.attributedText  =  NSAttributedString(string:"Product Sub Category", attributes:[NSForegroundColorAttributeName : UIColor.gray])
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
//        cateDropdown.backgroundColor = UIColor.white
//        cateDropdown.textColor = UIColor.gray
//        cateDropdown.selectionBackgroundColor = UIColor(netHex:0xD0842D)
//        
//        
        subCateDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            // print("Selected item: \(item) at index: \(index)")
            self.prodSubCateLabel.attributedText  =  NSAttributedString(string: (item), attributes:[NSForegroundColorAttributeName : UIColor.gray])
            self.selectedCategory.append(self.subCategoryList[index].id)
        }
//        subCateDropDown.backgroundColor = UIColor.white
//        subCateDropDown.textColor = UIColor.gray
//        subCateDropDown.selectionBackgroundColor = UIColor(netHex:0xD0842D)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showHideCateDropDown() {
        cateDropdown.show();
    }
    func showHideSubCateDropDown(){
        subCateDropDown.show()
    }
    @IBAction func nextButonAction(_ sender: AnyObject) {
        var check = true
        if(self.selectedCategory.isEmpty){
            check = false
            view.makeToast(message:"Category Required", duration: 2, position: HRToastPositionCenter as AnyObject)
            
        }
        if(self.productTitleTxt.text == "" && check != false){
            check = false
            view.makeToast(message:"Title Required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }
        if(self.fromDateTxt.text == "" && check != false)
        {
            check = false
            view.makeToast(message:"Available from date Required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }
        if(self.toDateTxt.text == "" && check != false){
            check = false
            view.makeToast(message:"Available till date Required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }
        if(areaTextField.text == "" && check != false){
            check = false
            view.makeToast(message:"Area Required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }
        if(check != false){
            self .performSegue(withIdentifier: "second", sender: nil)
            
        }
       //  self .performSegueWithIdentifier("second", sender: nil)
    }
    
    func keyboardWillShow(_ sender: Notification) {
        let userInfo: [AnyHashable: Any] = (sender as NSNotification).userInfo!
        
        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
        let offset: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                print("if in")
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= 140//keyboardSize.height
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
                self.view.frame.origin.y += 140//keyboardSize.height
            }
            else {
                
            }
        }
    }
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
        //        calendarPicker.barTintColor = UIColor.greenColor()
        fromCalendarPicker.dayDisabledTintColor = UIColor.gray
        fromCalendarPicker.title = "Available From "
        
        //        calendarPicker.backgroundImage = UIImage(named: "background_image")
        //        calendarPicker.backgroundColor = UIColor.blueColor()
        
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
        //        calendarPicker.barTintColor = UIColor.greenColor()
        toCalendarPicker.dayDisabledTintColor = UIColor.gray
        toCalendarPicker.title = "Will Available To"
        
        //        calendarPicker.backgroundImage = UIImage(named: "background_image")
        //        calendarPicker.backgroundColor = UIColor.blueColor()
        
        let navigationController = UINavigationController(rootViewController: toCalendarPicker)
        self.present(navigationController, animated: true, completion: nil)
    }
    // MARK: - EPCalendarPicker
    
    
    func epCalendarPicker(_: EPCalendarPicker, didCancel error : NSError) {
        //if(self == self.fromCalendarPicker)
        //  fromDateTxt.text = "User cancelled selection"
        
    }
    func epCalendarPicker(_: EPCalendarPicker, didSelectDate date : Date) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyy"
        let str = formatter.string(from: date)
        
        if(self.didTouchedFromDate){
            toCalendarPicker.startDate = date
            self.didTouchedFromDate = false
            fromDateTxt.text = str//"User selected date: \n\(date)"
        }
        if(self.didTouchedToDate){
            self.didTouchedToDate = false
            toDateTxt.text = str
        }
        
        
        
    }
    //    func epCalendarPicker(_: EPCalendarPicker, didSelectMultipleDate dates : [NSDate]) {
    //        fromDateTxt.text = "User selected dates: \n\(dates)"
    //    }
    
    
    
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
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "second"){
            
            self.navigationController!.navigationBar.barTintColor = UIColor(netHex:0x2D2D2D)
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(netHex:0xD0842D)]
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            self.navigationItem.backBarButtonItem!.tintColor = UIColor.white
            let contrller : PostItemSecondViewController = segue.destination as! PostItemSecondViewController
            contrller.productTitle = self.productTitleTxt.text!
            contrller.selectedCategory = self.selectedCategory
            contrller.address = self.areaTextField.text!
            contrller.city = self.cityTxt.text!
            contrller.zipCode = self.cityTxt.text!
            contrller.availableFrom = self.fromDateTxt.text!
            contrller.availableTill = self.toDateTxt.text!
            
        }
    }
    
    
}
