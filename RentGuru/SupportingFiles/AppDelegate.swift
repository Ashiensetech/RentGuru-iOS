//
//  AppDelegate.swift
//  RentGuru
//
//  Created by Workspace Infotech on 7/29/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import DropDown
import Alamofire
import ObjectMapper
import FBSDKCoreKit
import FBSDKLoginKit
import Fabric
import TwitterKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate {
    
    var window: UIWindow?
    let defaults = UserDefaults.standard
    var baseUrl = ""
    var accessToken = "abc"
    var Auth = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DropDown.startListeningToKeyboard()
        
        //setup defaults
        //  defaults.setObject("http://163.53.151.2:8888/develop.rentguru24/", forKey: "baseUrl")//Local
        //defaults.setObject("http://67.205.129.3:8080/develop.rentguru24/", forKey: "baseUrl") //Live
        defaults.set("http://rentguru24.com/", forKey: "baseUrl")
        baseUrl = defaults.string(forKey: "baseUrl")!
        
        
        if let key = UserDefaults.standard.object(forKey: "accesstoken") as? String {
            accessToken = key
        }else{
            defaults.set("abc", forKey: "accesstoken")
        }
        
        UITabBar.appearance().selectedImageTintColor =  UIColor.white
        UITabBar.appearance().barTintColor = UIColor(netHex:0x2D2D2D)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.gray], for:UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for:.selected)
        UITabBar.appearance().tintColor = UIColor.white;
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        Fabric.with([Twitter.self])
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = "584222961341-dbh261kkn2l5dbur713ecjt6l0d6kf7e.apps.googleusercontent.com";
       
        //[PayPalEnvironmentProduction: "YOUR_CLIENT_ID_FOR_PRODUCTION",  PayPalEnvironmentSandbox: "YOUR_CLIENT_ID_FOR_SANDBOX"]
        PayPalMobile .initializeWithClientIds(forEnvironments: [PayPalEnvironmentSandbox:"AWQr0Ls0qt0zRtXFvSBZ2k3zNgt-0ME5eI6qC8A9dTh2RHodYtDre5cJT7BNElg9mm3dZw6v9F-G-vyn"])
            //[PayPalEnvironmentSandbox: "AQyrIOgBWiloIZVoHc0lLHZt-g6CH-DwKmme7tYeDI5XsqPYU-bUA0Xh1N8kREPCpkRHmyQc90SQn1l8"])
        
        return true
    }
  
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if #available(iOS 9.0, *) {
            var options: [String: AnyObject] = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication! as AnyObject,
                                                UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation as AnyObject]
            
        } else {
            
            // Fallback on earlier versions
        }
        GIDSignIn.sharedInstance().handle(url,
                                             sourceApplication: sourceApplication,
                                             annotation: annotation)
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            print("App Delegate : \(user)")
            //            let userId = user.userID                  // For client-side use only!
            //            let idToken = user.authentication.idToken // Safe to send to the server
            //            let fullName = user.profile.name
            //            let givenName = user.profile.givenName
            //            let familyName = user.profile.familyName
            //            let email = user.profile.email
            // ...
        } else {
            print("\(error.localizedDescription)")
        }
    }
    @nonobjc func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

