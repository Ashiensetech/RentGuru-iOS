//
//  BannerImage.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/1/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import ObjectMapper
class BannerImage: Mappable {
    var id          :Int!
    var imagePath   :String!
    var url         :String!
    var createdDate :Int?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        id          <- map["id"]
        imagePath   <- map["imagePath"]
        url         <- map["url"]
        createdDate <- map["createdDate"]
       
    }
}
