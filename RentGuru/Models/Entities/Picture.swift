//
//  Picture.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/10/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper

class Picture: Mappable{
    var original :   PictureDetails!
    var thumb :     [PictureDetails]?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        original <- map["original"]
        thumb    <- map["thumb"]
    }
}
