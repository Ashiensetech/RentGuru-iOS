//
//  IdentityType.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/5/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import ObjectMapper

class IdentityType : Mappable {
    var  id          : Int!
    var name         : String!
    var  createdDate : Int!
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        createdDate <- map["createdDate"]
    }
    
}
