//
//  RentRequestViewController.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/18/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class RentRequestViewController: UIViewController ,EPCalendarPickerDelegate ,PayPalPaymentDelegate{
    //, PayPalFuturePaymentDelegate, PayPalProfileSharingDelegate, FlipsideViewControllerDelegate
    @IBOutlet var fromDateView: UIView!
    @IBOutlet var fromDateSelector: UIImageView!
    @IBOutlet var toDateSelector: UIImageView!
    @IBOutlet var toDateView: UIView!
    @IBOutlet var startDate: UITextField!
    @IBOutlet var endDate: UITextField!
    @IBOutlet var remark: UITextView!
    var product : RentalProduct!
    var fromController : String!
    var fromCalendarPicker : EPCalendarPicker!
    var toCalendarPicker :EPCalendarPicker!
    var didTouchedFromDate = false
    var didTouchedToDate = false
    let defaults = UserDefaults.standard
    var baseUrl : String = ""
    var presentWindow : UIWindow?
     var payPalConfig = PayPalConfiguration() // default
    var environment:String = PayPalEnvironmentSandbox {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var acceptCreditCards: Bool = false {
        didSet {
            payPalConfig.acceptCreditCards = acceptCreditCards
        }
    }
     var resultText = "" // empty
    
    var rentRequestId : Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        baseUrl = defaults.string(forKey: "baseUrl")!
        presentWindow = UIApplication.shared.keyWindow
        self.fromDateSelector.isUserInteractionEnabled = true
        self.fromDateView.isUserInteractionEnabled = true
        let fromDateGexture = UITapGestureRecognizer(target: self, action:#selector(RentRequestViewController.selectFromDateAction) )
        self.fromDateSelector.addGestureRecognizer(fromDateGexture)
        self.fromDateView.addGestureRecognizer(fromDateGexture)
        
        self.toDateSelector.isUserInteractionEnabled = true
        self.toDateView.isUserInteractionEnabled = true
        let toDateGesture =  UITapGestureRecognizer(target: self, action:#selector(RentRequestViewController.selectToDateAction) )
        self.toDateSelector.addGestureRecognizer(toDateGesture)
        self.toDateView.addGestureRecognizer(toDateGesture)
        
        
        
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = acceptCreditCards;
        payPalConfig.merchantName = "Awesome Shirts, Inc."
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        // Setting the languageOrLocale property is optional.
        //
        // If you do not set languageOrLocale, then the PayPalPaymentViewController will present
        // its user interface according to the device's current language setting.
        //
        // Setting languageOrLocale to a particular language (e.g., @"es" for Spanish) or
        // locale (e.g., @"es_MX" for Mexican Spanish) forces the PayPalPaymentViewController
        // to use that language/locale.
        //
        // For full details, including a list of available languages and locales, see PayPalPaymentViewController.h.
        
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        
        // Setting the payPalShippingAddressOption property is optional.
        //
        // See PayPalConfiguration.h for details.
        
        payPalConfig.payPalShippingAddressOption = .payPal;
        
        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")

        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
          PayPalMobile.preconnect(withEnvironment: environment)
        self.navigationController!.navigationBar.barTintColor = UIColor(netHex:0x2D2D2D)
        self.navigationItem.title =  "Request To Rent"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(netHex:0xD0842D)]
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
        let year =  components.year
        
        
        self.fromCalendarPicker =  EPCalendarPicker(startYear: year!, endYear: year!+2, multiSelection: true, selectedDates: [])
        self.toCalendarPicker  =   EPCalendarPicker(startYear: year!, endYear: year!+2, multiSelection: true, selectedDates: [])
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backToDetailsAction(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "backToDetails", sender: nil)
    }
    
    
    func selectFromDateAction()
    {
        
        self.didTouchedFromDate = true;
        fromCalendarPicker.calendarDelegate = self
        fromCalendarPicker.startDate = Date()
        fromCalendarPicker.hightlightsToday = true
        fromCalendarPicker.showsTodaysButton = true
        fromCalendarPicker.hideDaysFromOtherMonth = true
        fromCalendarPicker.tintColor = UIColor(netHex:0xD0842D)
        fromCalendarPicker.multiSelectEnabled = false
        fromCalendarPicker.barTintColor = UIColor(netHex:0x2D2D2D)
        fromCalendarPicker.dayDisabledTintColor = UIColor.gray
        fromCalendarPicker.title = "Start From "
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
        toCalendarPicker.tintColor = UIColor(netHex:0xD0842D)
        toCalendarPicker.multiSelectEnabled = false
        toCalendarPicker.barTintColor = UIColor(netHex:0x2D2D2D)
        toCalendarPicker.dayDisabledTintColor = UIColor.gray
        toCalendarPicker.title = "End Date"
        let navigationController = UINavigationController(rootViewController: toCalendarPicker)
        self.present(navigationController, animated: true, completion: nil)
    }
    // MARK:- EPCalendarPicker
    func epCalendarPicker(_: EPCalendarPicker, didSelectDate date : Date) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyy"
        let str = formatter.string(from: date)
        
        if(self.didTouchedFromDate){
            self.didTouchedFromDate = false
            self.startDate.text = str//"User selected date: \n\(date)"
        }
        if(self.didTouchedToDate){
            self.didTouchedToDate = false
            self.endDate.text = str
        }
        
    }
    func epCalendarPicker(_: EPCalendarPicker, didCancel error: NSError) {
        
    }
    @IBAction func submitRequest(_ sender: AnyObject) {
        var check : Bool = true
        if(startDate.text == ""){
            check = false
            self.view.makeToast(message:"Start Date Required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }
        if(endDate.text == "" && check != false){
            check = false
            self.view.makeToast(message:"Start Date Required", duration: 2, position: HRToastPositionCenter as AnyObject)
        }
        if(check != false){
            self.postRentRequest()
        }
    }
    
    //MARK:- API Access
    
    
    func postRentRequest()  {
        
        // Remove our last completed payment, just for demo purposes.
        resultText = ""
        
        // Note: For purposes of illustration, this example shows a payment that includes
        //       both payment details (subtotal, shipping, tax) and multiple items.
        //       You would only specify these if appropriate to your situation.
        //       Otherwise, you can leave payment.items and/or payment.paymentDetails nil,
        //       and simply set payment.amount to your total charge.
        
        // Optional: include multiple items
//        let item1 = PayPalItem(name: "Old jeans with holes", withQuantity: 2, withPrice: NSDecimalNumber(string: "84.99"), withCurrency: "USD", withSku: "Hip-0037")
//        let item2 = PayPalItem(name: "Free rainbow patch", withQuantity: 1, withPrice: NSDecimalNumber(string: "0.00"), withCurrency: "USD", withSku: "Hip-00066")
//        let item3 = PayPalItem(name: "Long-sleeve plaid shirt (mustache not included)", withQuantity: 1, withPrice: NSDecimalNumber(string: "37.99"), withCurrency: "USD", withSku: "Hip-00291")
//        
//        let items = [item1, item2, item3]
//        let subtotal = PayPalItem.totalPriceForItems(items)
//        
//        // Optional: include payment details
//        let shipping = NSDecimalNumber(string: "5.99")
//        let tax = NSDecimalNumber(string: "2.50")
//        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
//        
//        let total = subtotal.decimalNumberByAdding(shipping).decimalNumberByAdding(tax)
        
       
        
//        payment.items = items
//        payment.paymentDetails = paymentDetails
        
       
        
        
        
        self.presentWindow!.makeToastActivity()
        let paremeters : [String :AnyObject] =
            ["startDate" : self.startDate.text! as AnyObject,"endsDate" : self.endDate.text! as AnyObject,"remark":self.remark.text! as AnyObject]
        print(paremeters)
        //urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default
        print(URL(string: "\(baseUrl)api/auth/rent/make-request/\(self.product.id!)" )!)
        Alamofire.request( URL(string: "\(baseUrl)api/auth/rent/make-request/\(self.product.id!)" )!, method: .post, parameters: paremeters)
            ///.validate(contentType: ["application/json"])
            .responseJSON { response in
                print(response)
                self.presentWindow!.hideToastActivity()
                switch response.result {
                case .success(let data):
                    let proRes: RentRequestResponse = Mapper<RentRequestResponse>().map(JSONObject: data)!
                    
                    if(proRes.responseStat.status != false){
                        self.view.makeToast(message:"Request Successful", duration: 2, position: HRToastPositionCenter as AnyObject)
                        self.startDate.text! = ""
                        self.endDate.text! = ""
                        self.remark.text! = ""
                        self.rentRequestId = proRes.responseData?.id
                         let payment = PayPalPayment(amount: 1.0, currencyCode: "USD", shortDescription: "Hipster Clothing", intent: .sale)
                        if (payment.processable) {
                            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: self.payPalConfig, delegate: self)
                            self.present(paymentViewController!, animated: true, completion: nil)
                        }
                        else {
                            // This particular payment will always be processable. If, for
                            // example, the amount was negative or the shortDescription was
                            // empty, this payment wouldn't be processable, and you'd want
                            // to handle that here.
                            print("Payment not processalbe: \(payment)")
                        }
                        
                        
                    }else{
                        if(proRes.responseStat.requestErrors?.count > 0){
                            
                            self.view.makeToast(message:proRes.responseStat.requestErrors![0].msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                        }else{
                            self.view.makeToast(message:proRes.responseStat.msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                            
                        }
                    }
                    
                    
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    
    // PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        resultText = ""
        //successView.hidden = true
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            
            
            let paymentResultDic = completedPayment.confirmation as NSDictionary
            let dicResponse: AnyObject? = paymentResultDic.object(forKey: "response") as AnyObject?
            print("Here is your proof of payment:\n\n\(dicResponse!.object(forKey: "id"))\n\nSend this to your server for confirmation and fulfillment.")
            
            self.resultText = completedPayment.description
            let paremeters : [String :AnyObject] =
                ["paymentId" : (dicResponse!.object(forKey: "id") as AnyObject?)!]
            
            
            
            
            //urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default
            
            Alamofire.request(URL(string: "\(self.baseUrl)api/auth/rent-payment/verify-payment/\(self.rentRequestId)" )!,method: .post, parameters: paremeters, encoding: JSONEncoding.default)
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                    print(response)
                    self.presentWindow!.hideToastActivity()
                    switch response.result {
                    case .success(let data):
                        let proRes: VerifyPaymentResponse = Mapper<VerifyPaymentResponse>().map(JSONObject: data)!
                       
                        if(proRes.responseStat.status != false){
                            self.view.makeToast(message:"Payment Made Sucessfully", duration: 2, position: HRToastPositionCenter as AnyObject)
                             print(proRes)
                            
                        }else{
                            if(proRes.responseStat.requestErrors?.count > 0){
                                
                                self.view.makeToast(message:proRes.responseStat.requestErrors![0].msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                            }else{
                                self.view.makeToast(message:proRes.responseStat.msg, duration: 2, position: HRToastPositionCenter as AnyObject)
                                
                            }
                        }
                        
                        
                    case .failure(let error):
                        print(error)
                    }
            }

            

        })
    }
    
    
   
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC = segue.destination as! UINavigationController
        let detailsVC = navVC.viewControllers.first as! ProductDetailsViewController
        detailsVC.product = self.product
        
    }
    
}
/*
 // MARK: Future Payments
 
 @IBAction func authorizeFuturePaymentsAction(sender: AnyObject) {
 let futurePaymentViewController = PayPalFuturePaymentViewController(configuration: payPalConfig, delegate: self)
 presentViewController(futurePaymentViewController!, animated: true, completion: nil)
 }
 
 
 func payPalFuturePaymentDidCancel(futurePaymentViewController: PayPalFuturePaymentViewController) {
 print("PayPal Future Payment Authorization Canceled")
 //   successView.hidden = true
 futurePaymentViewController.dismissViewControllerAnimated(true, completion: nil)
 }
 
 func payPalFuturePaymentViewController(futurePaymentViewController: PayPalFuturePaymentViewController, didAuthorizeFuturePayment futurePaymentAuthorization: [NSObject : AnyObject]) {
 print("PayPal Future Payment Authorization Success!")
 // send authorization to your server to get refresh token.
 futurePaymentViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
 self.resultText = futurePaymentAuthorization.description
 // self.showSuccess()
 })
 }
 
 // MARK: Profile Sharing
 
 @IBAction func authorizeProfileSharingAction(sender: AnyObject) {
 let scopes = [kPayPalOAuth2ScopeOpenId, kPayPalOAuth2ScopeEmail, kPayPalOAuth2ScopeAddress, kPayPalOAuth2ScopePhone]
 let profileSharingViewController = PayPalProfileSharingViewController(scopeValues: NSSet(array: scopes) as Set<NSObject>, configuration: payPalConfig, delegate: self)
 presentViewController(profileSharingViewController!, animated: true, completion: nil)
 }
 
 // PayPalProfileSharingDelegate
 
 func userDidCancelPayPalProfileSharingViewController(profileSharingViewController: PayPalProfileSharingViewController) {
 print("PayPal Profile Sharing Authorization Canceled")
 //  successView.hidden = true
 profileSharingViewController.dismissViewControllerAnimated(true, completion: nil)
 }
 
 func payPalProfileSharingViewController(profileSharingViewController: PayPalProfileSharingViewController, userDidLogInWithAuthorization profileSharingAuthorization: [NSObject : AnyObject]) {
 print("PayPal Profile Sharing Authorization Success!")
 
 // send authorization to your server
 
 profileSharingViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
 self.resultText = profileSharingAuthorization.description
 //self.showSuccess()
 })
 
 }
 */
