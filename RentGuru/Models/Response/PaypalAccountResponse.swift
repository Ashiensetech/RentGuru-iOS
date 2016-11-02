//
//  PaypalAccountResponse.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/2/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import ObjectMapper
class PaypalAccountResponse: Mappable {
    var responseStat  : ResponseStat!
    var responseData  : UserPaypalCredential?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
        
    }
}
