//
//  VerifyPaymentResponse.swift
//  RentGuru
//
//  Created by Workspace Infotech on 9/26/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class VerifyPaymentResponse: Mappable {
    var responseStat  : ResponseStat!
    var responseData  : RentPayment?
    
    required init?(map:Map) {
        
    }
    
    func mapping(map:Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
        
    }
}
