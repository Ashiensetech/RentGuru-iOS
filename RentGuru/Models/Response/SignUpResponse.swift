//
//  SignUpResponse.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/5/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import ObjectMapper
//{
//    "responseStat":{
//        "status": boolean,
//        "isLogin": boolean,
//        "msg": String,
//        "requestErrors":[]
//    },
//    "responseData":AuthCredential
//}

class SignUpResponse : Mappable {
    var responseStat    : ResponseStat!
    var responseData    : AuthCredential?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
        
    }
    
}
