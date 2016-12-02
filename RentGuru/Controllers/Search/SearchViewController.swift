import UIKit
import DropDown
import Alamofire
import ObjectMapper
import GooglePlaces
import GooglePlacePicker
import CoreLocation

class SearchViewController: UIViewController ,UITextFieldDelegate ,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource ,UIScrollViewDelegate,CLLocationManagerDelegate{
    
    @IBOutlet var searchProductCollection: UICollectionView!
    @IBOutlet var baseScroll: UIScrollView!
  
    let cateDropdown = DropDown()
    let subCateDropDown = DropDown()
    var selectedProdIndex : Int = 0
    var categoryList : [Category] = []
    var subCategoryList : [Category] = []
    
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    
    var allProducts:[RentalProduct] = []
    var isData : Bool = false
    var presentWindow : UIWindow?
    fileprivate  var lastContentOffset: CGFloat = 0
    
    var  paremeters :[String:AnyObject] = [:]
    var selectedCateId : Int = 0
    var selectedSubcateId :Int = 0
    var radius :Float = 0.0
    var pickedLocValue = CLLocationCoordinate2D()
    var placePicker: GMSPlacePicker?
    var selectedIndexPath :IndexPath?
    
    let locationManager = CLLocationManager()
    var currentLocValue = CLLocationCoordinate2D()
    
    var offset = 0
    var limit = 10
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        baseUrl = defaults.string(forKey: "baseUrl")!
        presentWindow = UIApplication.shared.keyWindow
  
        self.searchProductCollection.delegate = self
        self.searchProductCollection.dataSource = self
    }
    
    func search(parameters :[String:AnyObject]) {
        self.paremeters = parameters
        self.allProducts = []
        self.searchProductCollection.reloadData()
        self.getSearchProduct()
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    //The color switching things are done here
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if(textField == self.searchTxt){
//            self.viewUnderSearchTxt.backgroundColor = UIColor(netHex:0xD0842D)
//        }else{
//            self.viewUnderSearchTxt.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
//        }
//        
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if(textField == self.searchTxt){
//            self.viewUnderSearchTxt.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
//        }
//        
//    }
    
    func perfromNext(_ sender :UITapGestureRecognizer)  {
        self.view.makeToastActivity()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let tapLocation = sender.location(in: self.searchProductCollection)
        let indexPath : IndexPath = self.searchProductCollection.indexPathForItem(at: tapLocation)!
        
        if let cell = self.searchProductCollection.cellForItem(at: indexPath){
            self.selectedIndexPath  = indexPath
            self.selectedProdIndex = cell.tag
        }
        DispatchQueue.main.async(execute: {
            UIApplication.shared.endIgnoringInteractionEvents()
            self.performSegue(withIdentifier: "showDetails", sender: nil)
        })
    }
    
    
    // MARK: - collectionview delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seachCell", for: indexPath) as!SearchCollectionViewCell
        let data: RentalProduct = allProducts [(indexPath as NSIndexPath).row]
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
        cell.tag = (indexPath as NSIndexPath).row
        cell.isUserInteractionEnabled = true
        let selectGesture = UITapGestureRecognizer(target: self, action:#selector(SearchViewController.perfromNext) )
        cell.addGestureRecognizer(selectGesture)
        return cell
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView: SearchHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:"SearchHeader", for: indexPath) as! SearchHeader
        headerView.searchViewController = self
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 100, height: 450)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        searchProductCollection?.reloadData()
        self.view.layoutIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == allProducts.count - 1 {
            self.offset += 1
            getSearchProduct()
        }
    }
    
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
                        print("data", cateRes.responseData!)
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
    
    func getSearchProduct() {
        print("searching............")
        self.view.makeToastActivity()
        UIApplication.shared.beginIgnoringInteractionEvents()
        print(self.paremeters)
        paremeters["limit"] = self.limit as AnyObject
        paremeters["offset"] = self.offset as AnyObject
        Alamofire.request( URL(string: "\(baseUrl)api/search/rental-product")!,method :.get ,parameters: self.paremeters)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    print(data)
                    let proRes: ProductResponse = Mapper<ProductResponse>().map(JSONObject: data)!
                    if(proRes.responseStat.status != false){
                        for i in 0 ..< proRes.responseData!.count {
                            let product : RentalProduct = proRes.responseData![i]
                            self.allProducts.append(product)
                        }
                        self.isData = true
                        self.offset += 1
                        self.searchProductCollection.reloadData()
                    }
                    else{
                        self.isData = false
                        if self.offset == 0 {
                            self.allProducts = []
                            self.searchProductCollection.reloadData()
                        }
                        self.view.makeToast(message:"No Product Found", duration: 1, position: HRToastPositionCenter as AnyObject)
                    }
                    break
                case .failure(let error):
                    print(error)
                    break
                }
                UIApplication.shared.endIgnoringInteractionEvents()
                self.view.hideToastActivity()
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showDetails"){
//            self.setParams(offset: self.offset)
            let navVC = segue.destination as! UINavigationController
            let detailsVC = navVC.viewControllers.first as! ProductDetailsViewController
            detailsVC.product = self.allProducts[self.selectedProdIndex]
            detailsVC.allProducts = self.allProducts
            detailsVC.onIndexPath = self.selectedIndexPath
            detailsVC.paremeters = self.paremeters
            detailsVC.fromController = "Search"
        }
    }
    
}
