//
//  RentType.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/12/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class RentType: Mappable {
    var  id     : Int!
    var name    : String!
    
    
    required init?(map:Map) {
        
    }
    func mapping(map:Map) {
        id      <- map["id"]
        name    <- map["name"]
   
    }
}
