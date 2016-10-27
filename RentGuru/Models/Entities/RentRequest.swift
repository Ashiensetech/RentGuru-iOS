//
//  RentRequest.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/18/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class RentRequest: Mappable {
    var  id                 : Int!
    var  rentalProduct      : RentalProduct!
    var  requestedBy        : AppCredential!
    var  requestExtension   : [RentRequest]!
    var  requestCancel      : Bool!
    var  startDate          : String!
    var  endDate            : String!
    var  approve            : Bool!
    var  disapprove         : Bool!
    var  isExtension        : Bool!
    var  remark             : String = ""
    var isRentComplete      : Bool!
    var rentFee             : Double!
   
    
    required init?(map: Map) {
        
    }
    func mapping( map: Map) {
        id                  <- map["id"]
        rentalProduct       <- map["rentalProduct"]
        requestedBy         <- map["requestedBy"]
        requestExtension    <- map["requestExtension"]
        requestCancel       <- map["requestCancel"]
        startDate           <- map["startDate"]
        endDate             <- map["endDate"]
        approve             <- map["approve"]
        disapprove          <- map["disapprove"]
        isExtension         <- map["isExtension"]
        isRentComplete      <- map["isRentComplete"]
        rentFee             <- map["rentFee"]
        remark              <- map["remark"]
      
    }
    
}
