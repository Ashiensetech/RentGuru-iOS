//
//  UserAddress.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/5/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper
class  UserAddress :Mappable{
    var id          : Int!
    var address     : String!
    var zip         : String!
    var city        : String!
    var state       : String!
    var lat         : Double = 0.0
    var lng         : Double = 0.0
    var createdDate : Int!
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        id          <- map["id"]
        address     <- map["address"]
        zip         <- map["zip"]
        city        <- map["city"]
        createdDate <- map["createdDate"]
        state       <- map["state"]
        lat         <- map["lat"]
        lng         <- map["lng"]
    }

}
