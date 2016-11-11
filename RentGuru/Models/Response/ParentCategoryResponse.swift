//
//  ParentCategoryResponse.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/11/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class ParentCategoryResponse: Mappable {
    var responseStat  : ResponseStat!
    var responseData  : Category?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
        
    }
}
