//
//  IdentityTypeResponse.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/5/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class IdentityTypeResponse :Mappable {
    
    
    var responseStat : ResponseStat!
    var responseData : [IdentityType]!
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
        
    }
    
}
