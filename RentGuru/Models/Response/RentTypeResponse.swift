//
//  RentTypeResponse.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/12/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class RentTypeResponse: Mappable {
    var responseStat    : ResponseStat!
    var responseData    : [RentType]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
        
    }
}
