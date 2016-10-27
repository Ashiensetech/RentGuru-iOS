//
//  MyRentalProductResponse.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/24/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class MyRentalProductResponse: Mappable {
    var responseStat    : ResponseStat!
    var responseData    : [MyRentalProduct]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
        
    }
}
