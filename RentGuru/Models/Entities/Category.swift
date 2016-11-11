//
//  Category.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/8/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//
import UIKit
import ObjectMapper

class Category : Mappable {
    var id           :Int!
    var name         :String!
    var sortedOrder  : Int?
    var subcategory  :[Category] = []
    var isSubcategory:Bool = false
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        id              <- map["id"]
        name            <- map["name"]
        sortedOrder     <- map["sortedOrder"]
        subcategory     <- map["subcategory"]
        isSubcategory   <- map["isSubcategory"]
    }
    
}
