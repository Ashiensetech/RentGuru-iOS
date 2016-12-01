//
//  RentalProduct.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/16/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class RentalProduct: Product {
    
    var  currentValue           : Double!
    var  rentFee                : Double!
    var  currentlyAvailable     : Bool!
    var  availableFrom          : Double!
    var  availableTill          : Double!
    var  rentType               : RentType!
    
    override func mapping(map:Map) {
        super.mapping(map: map)
        currentValue       <- map["currentValue"]
        rentFee            <- map["rentFee"]
        currentlyAvailable <- map["currentlyAvailable"]
        availableFrom      <- map["availableFrom"]
        availableTill      <- map["availableTill"]
        rentType           <- map["rentType"]
    }
    
}
