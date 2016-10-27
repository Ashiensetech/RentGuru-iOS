//
//   ResponseStat .swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/5/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//
import UIKit
import ObjectMapper
class  ResponseStat : Mappable {
    var status         :Bool!
    var  isLogin       :Bool!
    var  msg           : String!
    var  requestErrors : [RequestError]?
    
    required init?( map: Map) {
        
    }
    func mapping(map: Map) {
        status          <- map["status"]
        isLogin         <- map["isLogin"]
        msg             <- map["msg"]
        requestErrors   <- map["requestErrors"]
    }
    
}
