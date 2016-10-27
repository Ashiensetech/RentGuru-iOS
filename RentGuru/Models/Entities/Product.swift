//
//  Product.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/10/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class Product: Mappable {
    var id                  : Int!
    var name                : String!
    var description         : String!
    var profileImage        : Picture!
    var  otherImages        : [Picture] = []
    var  averageRating      : Float!
    var  active             : Bool!
    var  isLiked            : Bool!
    var  reviewStatus       : Int!
    var  owner              : AppCredential!
    var  productCategories  : [ProductCategory] = []
    var  productLocation    : ProductLocation?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        id                  <- map["id"]
        name                <- map["name"]
        description         <- map["description"]
        profileImage        <- map["profileImage"]
        otherImages         <- map["otherImages"]
        averageRating       <- map["averageRating"]
        isLiked             <- map["isLiked"]
        active              <- map["active"]
        reviewStatus        <- map["reviewStatus"]
        owner               <- map["owner"]
        productCategories   <- map["productCategories"]
        productLocation     <- map["productLocation"]
    }
    
}
