import UIKit
import Alamofire
import ObjectMapper
import Kingfisher
import ImageSlideshow

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UIScrollViewDelegate,CollectionViewWaterfallLayoutDelegate{
    @IBOutlet var productScrollHeight: NSLayoutConstraint!
    @IBOutlet var offerCollection: UICollectionView!
    @IBOutlet var productScrollBottom: NSLayoutConstraint!
    @IBOutlet var baseScroll: UIScrollView!
  
    @IBOutlet var productScrollView: UIView!
    @IBOutlet var slideShow: ImageSlideshow!
    var defaults = UserDefaults.standard
    var baseUrl : String = ""
    var allProducts:[RentalProduct] = []
    var offset : Int = 0
    var isData : Bool = true
    var selectedProdIndex : Int = 0
    lazy var cellSizes: [CGSize] = {
        var _cellSizes = [CGSize]()
        
        for _ in 0...100 {
            let random = Int(arc4random_uniform((UInt32(100))))
            
            _cellSizes.append(CGSize(width: 155, height: 150 + random))
        }
        
        return _cellSizes
    }()
    fileprivate  var lastContentOffset: CGFloat = 0
    var presentWindow : UIWindow?
    var bannerImages : [ImageSource] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
      
        self.offerCollection.delegate = self
        self.offerCollection.dataSource = self
        self.baseScroll.delegate = self
        baseUrl = defaults.string(forKey: "baseUrl")!
        presentWindow = UIApplication.shared.keyWindow
        //staggered View
        
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerInset = UIEdgeInsetsMake(20, 0, 0, 0)
        layout.headerHeight = 50
        layout.footerHeight = 20
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        self.offerCollection.collectionViewLayout = layout
        self.offerCollection.allowsSelection = true
       
        slideShow.backgroundColor = UIColor.white
        slideShow.slideshowInterval = 5.0
        slideShow.pageControlPosition = PageControlPosition.insideScrollView
        slideShow.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        slideShow.pageControl.pageIndicatorTintColor = UIColor.red
        slideShow.contentScaleMode = UIViewContentMode.scaleToFill
        self.getBannerImages()
        
        self.getProducts()
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        print("Home")
//        self.offset = 0
//        self.isData = true
//        self.allProducts.removeAll()
//        self.getProducts()
//        //self.tabBarController?.tabBar.items?[1].badgeValue = "10"
//    }
//    override func viewDidLayoutSubviews() {
//        //Getting iDevice's screen width
//        let screenRect  : CGRect  = UIScreen.main.bounds // [[UIScreen mainScreen] bounds];
////        let  screenWidth : CGFloat = screenRect.size.width
//        let screenHeight :CGFloat = screenRect.size.height
//        
//           self.productScrollHeight.constant =   screenHeight - (self.slideShow.frame.size.height+20)
//        
//        
//        
//        self.baseScroll.contentSize = CGSize(
//            width: self.view.frame.size.width,
//            height: screenHeight + 206
//        );
//        
//    }
    
    // MARK: - collectionview delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.offerCollection){
            return self.allProducts.count
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == self.offerCollection ){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "offerCell", for: indexPath) as!OfferStaggeredCell
            let data : RentalProduct = allProducts [(indexPath as NSIndexPath).row]
            let path = data.profileImage.original.path!
            print(URL(string: "\(baseUrl)images/\(path)")!)
            cell.productImageView.kf.setImage(with: URL(string: "\(baseUrl)images/\(path)")!,
                                  placeholder: nil,
                                  options: [.transition(.fade(1))],
                                  progressBlock: nil,
                                  completionHandler: nil)
            cell.productName.text = data.name
            cell.offerLabel.text = "$\(data.rentFee!)/\(data.rentType.name!)"
            cell.tag = (indexPath as NSIndexPath).row
            return cell
            
            
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as!FeaturedProductsCell
            
            // Configure the cell
            cell.productImageView.image = UIImage(named:"thumb1.png")
            cell.productName.text = "Delux Bed"
            cell.productPrice.text = "$300/m"
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == self.offerCollection ){
            self.performSegue(withIdentifier: "ProductDetailsFromHome", sender: indexPath)
        }
    }
    

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if(scrollView == self.offerCollection){
            let offsetY = self.offerCollection.contentOffset.y
            let contentHeight = self.offerCollection.contentSize.height
            if offsetY > contentHeight - self.offerCollection.frame.size.height {
                print("this is end, see you in console")
                self.getProducts()
            }
        }else if(scrollView == self.baseScroll){
            
            print("baseScrolled ")
            
            if (self.lastContentOffset > scrollView.contentOffset.y) {
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.productScrollHeight.constant =  self.productScrollHeight.constant - 412
                    //self.productScrollBottom.constant =  self.productScrollBottom.constant + 206
                    self.view.layoutIfNeeded()
                })
              
                
            }
            else if (self.lastContentOffset < scrollView.contentOffset.y) {
                // print("Moved Down \(self.lastContentOffset)")
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.productScrollHeight.constant =  self.productScrollHeight.constant + 412
                   // self.productScrollBottom.constant =  self.productScrollBottom.constant - 206
                    self.view.layoutIfNeeded()
                })
                
               
            }
            
            // update the new position acquired
            self.lastContentOffset = scrollView.contentOffset.y
            self.getProducts()
        }
    }

    // MARK: - WaterfallLayoutDelegate
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if(collectionView == self.offerCollection){
            return cellSizes[(indexPath as NSIndexPath).item]
        }else{
            return CGSize(width: 122, height:135)
        }
    }
    
    
    //MARK: - ApiCall
    
    func getProducts() {
        if(self.isData != false){
            presentWindow!.makeToastActivity()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            var  paremeters :[String:AnyObject] = [:]
            paremeters["limit"] = 6 as AnyObject
            paremeters["offset"] = self.offset as AnyObject
            
            Alamofire.request( URL(string: "\(baseUrl)api/product/get-product" )!,method :.get ,parameters: paremeters)
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
                                self.allProducts.append(product)
                            }
                            self.offset += 1
                            self.offerCollection.reloadData()
                            
                        }else{
                            self.isData = false
                            self.view.makeToast(message:"No more data", duration: 2, position: HRToastPositionCenter as AnyObject)
                        }
                        
                    case .failure(let error):
                        print(error)
                        
                    }
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.presentWindow!.hideToastActivity()
            }
        }
    }
    func getBannerImages(){
        Alamofire.request( URL(string: "\(baseUrl)api/banner-image/get-all" )!,method :.get ,parameters: [:])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    //  print(data)
                    let imageRes : BannerImageResponse = Mapper<BannerImageResponse>().map(JSONObject: data)!
                    print(imageRes.responseStat.status)
                    
                    if(imageRes.responseStat.status != false){
                      
                        for i in 0 ..< imageRes.responseData!.count {
                            let banner : BannerImage = imageRes.responseData![i]
                            
                            let imageView:UIImageView! = UIImageView()
                              print("image response : \(self.baseUrl)images-banner/\(banner.imagePath!)")
                            
                            imageView.kf.setImage(with: URL(string: "\(self.baseUrl)images-banner/\(banner.imagePath!)")!,
                                                         placeholder: nil,
                                                         options: [.transition(.fade(1))],
                                                         progressBlock: nil,
                                                         completionHandler:{(
                                                            image, error, cacheType, imageURL) -> () in
                                                            if image != nil {
                                                                print("Imgae received")
                                                                self.bannerImages.append(ImageSource(image: imageView.image!))
                                                            }
                                                            if i == imageRes.responseData!.count - 1 {
                                                                self.slideShow.setImageInputs(self.bannerImages)
                                                            }
                            })
                        }
                    }else{
                      
                    }
                    
                case .failure(let error):
                    print(error)
                    
                }
                UIApplication.shared.endIgnoringInteractionEvents()
                self.presentWindow!.hideToastActivity()
        }
    
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ProductDetailsFromHome") {
            let indexPath = sender as! NSIndexPath
            let destinationVc = segue.destination as! ProductDetailsViewController
            destinationVc.product = self.allProducts[indexPath.row]
        }
    }
    
}
