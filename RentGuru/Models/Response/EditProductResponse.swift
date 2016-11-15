//
//  EditProductResponse.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/14/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class EditProductResponse : Mappable {
    var responseStat    : ResponseStat!
    var responseData    : MyRentalProduct?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
        
    }
}
