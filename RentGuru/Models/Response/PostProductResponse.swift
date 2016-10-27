//
//  PostProductResponse.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/12/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class PostProductResponse: Mappable {
    var responseStat    : ResponseStat!
    var responseData    : [RentalProduct]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
        
    }
}
