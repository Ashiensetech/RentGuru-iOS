//
//  CategoriesViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/8/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var preSelectedCategory: Category? = nil
    var data: [ExpandableCategory] = []
    var allCategories : [Category] = []
    var catIds: [Int] = []
    var hiddenCells: [ExpandableCategoriesTableViewCell] = []
    var fromCategoryPage = false
    
    var alternate = 0
    var colors: [UIColor] = [ UIColor(netHex:0xf5f5f5) ]
    
    @IBOutlet weak var expandableTable: UITableView!
    
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        baseUrl = defaults.string(forKey: "baseUrl")!
        expandableTable.dataSource = self
        expandableTable.delegate = self
        for cat in allCategories {
            catIds.append(cat.id)
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       self.navigationItem.title = "Categories"
        self.getCategory()
    }
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
            return self.data.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let expandableCategory = self.data[(indexPath as NSIndexPath).row]
            let category = expandableCategory.category
            let cell = expandableTable.dequeueReusableCell(withIdentifier: "ExpandableCategoriesTableViewCell") as! ExpandableCategoriesTableViewCell
            cell.catName.text = category?.name
            cell.expandableSign.text = ""
            cell.backgroundColor = UIColor.white
            if !expandableCategory.isLastChild {
                if expandableCategory.isExpanded {
                    cell.expandableSign.text = "-"
                }
                else {
                    cell.expandableSign.text = "+"
                }
            }
            if expandableCategory.isVisible {
                cell.isHidden = false
            }
            else {
                cell.isHidden = true
                self.hiddenCells.append(cell)
            }
            
            if expandableCategory.level == 0 {
                cell.catName.text = category!.name
                cell.backgroundColor = colors[0]
                alternate += 1
            }
            else if expandableCategory.level == 1 {
                cell.catName.text = "   \(category!.name!)"
            }
            else if expandableCategory.level == 2 {
                cell.catName.text = "       \(category!.name!)"
            }
            if expandableCategory.isSelected {
                cell.catName.font = UIFont(name:"Whitney-semibold", size: 18.0)
                if expandableCategory.isTopLevelCategory {
                    cell.separator.isHidden = false
                }
            }
            else {
                cell.catName.font = UIFont(name:"Whitney-book", size: 18.0)
                cell.separator.isHidden = true
            }
            return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let expandableCategory = self.data[(indexPath as NSIndexPath).row]
            if expandableCategory.isTopLevelCategory || expandableCategory.isVisible {
                return 50.0
            }
            else {
                return 0.0
            }
      
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

            let expandableCategory = self.data[(indexPath as NSIndexPath).row]
            if expandableCategory.isLastChild {
                performSegue(withIdentifier: "ProductsByCategory", sender: indexPath)
            }
            else {
                let rows: [Int] = makeChildCategoriesVisibleOrHidden(expandableCategory, parentRow: (indexPath as NSIndexPath).row)
                expandableCategory.isExpanded = !expandableCategory.isExpanded
                expandableCategory.isSelected = !expandableCategory.isSelected
                var indexPathsToReload: [IndexPath] = []
                for row in rows {
                    let indexPath = IndexPath(row: row, section: 0)
                    indexPathsToReload.append(indexPath)
                }
                //                self.expandableTable.reloadData()
                self.expandableTable.reloadRows(at: indexPathsToReload, with: .fade)
                if expandableCategory.isTopLevelCategory {
                    self.expandableTable.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
                }
            }

    }
    
    func makeChildCategoriesVisibleOrHidden(_ exCategory: ExpandableCategory, parentRow: Int) ->[Int] {
        var rows: [Int] = [parentRow]
        for (index, exCat) in self.data.enumerated() {
            if exCat.parentCategory != nil {
                if exCat.parentCategory!.category.id == exCategory.category.id {
                    rows.append(index)
                    if exCategory.isExpanded {
                        hideAllChildren(exCategory)
                    }
                    else {
                        exCat.isVisible = !exCat.isVisible
                    }
                }
            }
        }
        return rows
    }
    
    
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
                       self.allCategories = cateRes.responseData!
                        print(self.allCategories)
                        self.prepareData(self.allCategories, parent: nil, level: 0)
                        self.expandableTable.reloadData()
                        
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    func prepareData(_ categories: [Category], parent: ExpandableCategory?, level: Int) {
        for category in categories {
            var isTopLevelCategory = false
            var isVisible = false
            var isLastChild = false
            var isExpanded = false
            let isSelected = false
            if level == 0 {
                isTopLevelCategory = true
                isVisible = true
                isExpanded = false
                //                isSelected = true
            }
            let childCategories = category.subcategory
            if childCategories.count == 0 {
                isLastChild = true
            }
            let exCat = ExpandableCategory(category: category, isTopLevelCategory: isTopLevelCategory, isVisible: isVisible, isExpanded: isExpanded, isLastChild: isLastChild, parentCategory: parent, level: level, isSelected: isSelected)
            data.append(exCat)
            if (childCategories.count) > 0 {
                let newLevel = level + 1
                prepareData(childCategories, parent: exCat, level: newLevel)
            }
        }
    }
    
    
    func hideAllChildren(_ exCategory: ExpandableCategory){
        for expandableCategory in self.data {
            if exCategory.category.id == expandableCategory.parentCategory?.category.id {
                expandableCategory.isVisible = false
                expandableCategory.isExpanded = false
                hideAllChildren(expandableCategory)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductsByCategory" {
            self.navigationController!.navigationBar.barTintColor = UIColor(netHex:0x2D2D2D)
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(netHex:0xD0842D)]
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            self.navigationItem.backBarButtonItem!.tintColor = UIColor.white
            
            let indexPath = sender as! IndexPath
            let category : Category = self.data[(indexPath as NSIndexPath).row].category
            let contrller : CategoryProductViewController = segue.destination as! CategoryProductViewController
            contrller.category = category
            

        }
    }
    
    
    
}

