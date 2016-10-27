//
//  MyRentalProduct.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/24/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class MyRentalProduct: RentalProduct {
    var rentInf : [RentInf] = []
   
    override func mapping(map: Map) {
        super.mapping(map: map)
       
        rentInf <- map["rentInf"]
    }

}
