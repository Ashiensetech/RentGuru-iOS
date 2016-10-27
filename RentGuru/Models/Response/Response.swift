//
//  Response.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/17/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class Response: Mappable {
    var responseStat    : ResponseStat!
    var responseData    : AnyObject?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
        
    }

}
