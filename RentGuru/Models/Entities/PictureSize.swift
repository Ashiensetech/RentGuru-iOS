//
//  PictureSize.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/10/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class PictureSize: Mappable {
    var width   :Int!
    var height  : Int!
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        width   <- map["width"]
        height  <- map["height"]
    }
}
