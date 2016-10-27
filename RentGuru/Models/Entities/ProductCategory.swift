//
//  ProductCategory.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/11/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class ProductCategory: Mappable {
    var id          : Int!
    var productId   : Int?
    var categoryId  : Int?
    var createdBy   : Int?
    var createdDate : Int?
    var category    : Category!
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        id <- map["id"]
        category    <- map["category"]
        productId   <- map["productId"]
        categoryId  <- map["categoryId"]
        createdBy   <- map["createdBy"]
        createdDate <- map["createdDate"]
    }

}
