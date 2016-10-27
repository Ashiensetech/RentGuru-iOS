//
//  RatingResponse.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/17/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class RatingResponse: Mappable {
    var responseStat    : ResponseStat!
    //var responseData  : String!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        //responseData   <- map["responseData"]
        
    }
}
