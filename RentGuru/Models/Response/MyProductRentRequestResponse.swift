//
//  MyProductRentRequestResponse.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/19/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class MyProductRentRequestResponse: Mappable {
    
    var responseStat    : ResponseStat!
    var responseData    : [RentRequest] = []
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
        
    }
}
