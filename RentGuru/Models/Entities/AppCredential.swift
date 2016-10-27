//
//  AppCredential.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/5/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper
class AppCredential :Mappable  {
    var id          : Int!
    var userId      : Int!
    var role        : Int!
    var email       : String!
    var createdDate : Int!
    var userInf     : UserInf!
    
    required init?(map: Map) {
        
    }
    func mapping( map: Map) {
        id          <- map["id"]
        userId      <- map["userId"]
        role        <- map["role"]
        email       <- map["email"]
        createdDate <- map["createdDate"]
        userInf     <- map["userInf"]
    }
   
}
