//
//  BannerImageResponse.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/1/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import ObjectMapper
class BannerImageResponse: Mappable {
    var responseStat  : ResponseStat!
    var responseData  : [BannerImage]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
        
    }
}
