//
//  LoginResponse.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/8/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import Foundation

import ObjectMapper


class LoginResponse :  Mappable  {
    var responseStat    : ResponseStat!
    var responseData    : AuthCredential?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
        
    }

}
