//
//  CategoryResponse.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/8/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class CategoryResponse: Mappable {
    var responseStat  : ResponseStat!
    var responseData  : [Category]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
        
    }
}
