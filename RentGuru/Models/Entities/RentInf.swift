//
//  RentInf.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/24/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class RentInf: Mappable {
    var id              : Int!
    var startDate       : String!
    var endsDate        : String!
    var  expired        : Bool!
    var  createdDate    : Double!
    var  rentRequest    : RentRequest!
    var isRentComplete  :Bool!
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        id              <- map["id"]
        startDate       <- map["startDate"]
        endsDate        <- map["endsDate"]
        expired         <- map["expired"]
        createdDate     <- map["createdDate"]
        isRentComplete  <- map["isRentComplete"]
        rentRequest     <- map["rentRequest"]
    }
}
