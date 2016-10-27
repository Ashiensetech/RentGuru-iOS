//
//  AuthCredential.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/5/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class AuthCredential:AppCredential {
    var accesstoken : String!
    var verified    : Bool!
    var blocked     : Bool!
    
  
     override func mapping(map: Map) {
        super.mapping(map: map)
        accesstoken <- map["accesstoken"]
        verified    <- map["verified"]
        blocked     <- map["blocked"]
    }
}
