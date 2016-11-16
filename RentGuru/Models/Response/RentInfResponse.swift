import ObjectMapper

class RentInfResponse: Mappable {
    
    var responseStat    : ResponseStat!
    var responseData    : RentInf?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
    }
    
}
