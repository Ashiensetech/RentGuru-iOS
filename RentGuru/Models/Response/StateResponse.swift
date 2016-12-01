import ObjectMapper

class StateResponse: Mappable {
    
    var responseStat  : ResponseStat!
    var responseData  : [State]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStat   <- map["responseStat"]
        responseData   <- map["responseData"]
    }
    
}
