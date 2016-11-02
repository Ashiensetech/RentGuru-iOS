//
//  UserPaypalCredential.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/2/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit
import ObjectMapper
class UserPaypalCredential: Mappable {
    var id              :Int!
    var AppCredential   :AppCredential!
    var email           :String!
    var createdDate     :Int?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        id              <- map["id"]
        AppCredential   <- map["AppCredential"]
        email           <- map["email"]
        createdDate     <- map["createdDate"]
        
    }
}
