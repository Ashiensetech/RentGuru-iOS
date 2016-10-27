//
//  PictureDetails.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/10/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class PictureDetails: Mappable {
    var path : String!
    var type : String!
    var size : PictureSize!
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        path <- map["path"]
        type <- map["type"]
        size <- map["size"]

    }
    
}
