import ObjectMapper

class State: Mappable {
    
    var id: Int!
    var code: String = ""
    var name: String = ""
    var createdDate: String = ""

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        code        <- map["code"]
        name        <- map["name"]
        createdDate <- map["createdDate"]
    }

}
