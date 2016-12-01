import ObjectMapper

class ProductLocation: Mappable {
    
    var id               : Int!
    var productId        : Int!
    var city             : String?
    var state            : State?
    var formattedAddress : String!
    var zip              : String?
    var lat              : Double?
    var lng              : Double?
    
    required init?(map: Map) {
        
    }
    
    func mapping( map: Map) {
        id               <- map["id"]
        productId        <- map["productId"]
        city             <- map["city"]
        state            <- map["state"]
        formattedAddress <- map["formattedAddress"]
        zip              <- map["zip"]
        lat              <- map["lat"]
        lng              <- map["lng"]
    }
    
}
