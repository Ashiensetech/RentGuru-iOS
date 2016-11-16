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
    var rentee: AppCredential!
    var startDate       : String!
    var endsDate        : String!
    var isRentComplete  :Bool!
    var expired        : Bool!
    var productReturned: Bool!
    var productReceived: Bool!
    var hasReturnRequest: Bool!
    var hasReceiveConfirmation: Bool!
    var rentalProductReturnRequest: RentalProductReturnRequest!
    var rentalProductReturned: RentalProductReturned!
    var createdDate    : Double!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                          <- map["id"]
        rentee                      <- map["rentee"]
        startDate                   <- map["startDate"]
        endsDate                    <- map["endsDate"]
        isRentComplete              <- map["isRentComplete"]
        expired                     <- map["expired"]
        productReturned             <- map["productReturned"]
        productReceived             <- map["productReceived"]
        hasReturnRequest            <- map["hasReturnRequest"]
        hasReceiveConfirmation      <- map["hasReceiveConfirmation"]
        rentalProductReturnRequest  <- map["rentalProductReturnRequest"]
        rentalProductReturned       <- map["rentalProductReturned"]
        createdDate                 <- map["createdDate"]
    }
    
}
