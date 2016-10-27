//
//  RequestError.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/5/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper
import UIKit
class RequestError :Mappable{
    var params  : String!
    var msg     : String!
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        params   <- map["params"]
        msg      <- map["msg"]
      
    }
    
}
