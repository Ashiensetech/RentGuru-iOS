//
//  ProductLocation.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/10/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class ProductLocation: Mappable {
    var id               : Int!
    var productId        : Int!
    var city             : String?
    var state            : String?
    var formattedAddress : String!
    var zip              : String?
    var lat              : Double?
    var lng              : Double?
    
    required init?(map: Map) {
        
    }
    func mapping( map: Map) {
        id               <- map["id"]
        productId        <- map["productId"]
        city             <- map["city"]
        state            <- map["state"]
        formattedAddress <- map["formattedAddress"]
        zip              <- map["zip"]
        lat              <- map["lat"]
        lng              <- map["lng"]
    }
}
