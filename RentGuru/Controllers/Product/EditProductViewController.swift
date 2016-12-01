import UIKit

class EditProductViewController: UIViewController {
    @IBOutlet var segmentView: UISegmentedControl!
    @IBOutlet var infoContainer: UIView!

    @IBOutlet var imageContainer: UIView!
    var editableProduct :MyRentalProduct?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infoContainer.isHidden = true
        self.imageContainer.isHidden = false
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.infoContainer.isHidden = true
            self.imageContainer.isHidden = false
            break
        case 1:
            self.infoContainer.isHidden = false
            self.imageContainer.isHidden = true
            break
        default:
            break;
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //infoView
        if(segue.identifier == "infoView"){
            let controller : EditProductInformationViewController = segue.destination as! EditProductInformationViewController
            controller.editableProduct = self.editableProduct
        }
        if(segue.identifier == "editImage"){
            let controller : EditProductImageViewController = segue.destination as! EditProductImageViewController
            controller.editableProduct = self.editableProduct
        }
    }
 

}
