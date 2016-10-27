//
//  User.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/5/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class UserInf :Mappable{
    var id              : Int!
    var addressId       : Int!
    var lastName        : String!
    var firstName       : String!
    var createdDate     : Int!
    var userAddress     : UserAddress!
    var profilePicture  : Picture?
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        id              <- map["id"]
        addressId       <- map["addressId"]
        lastName        <- map["lastName"]
        firstName       <- map["firstName"]
        createdDate     <- map["createdDate"]
        userAddress     <- map["userAddress"]
        profilePicture  <- map["profilePicture"]
    }
    
    
}
