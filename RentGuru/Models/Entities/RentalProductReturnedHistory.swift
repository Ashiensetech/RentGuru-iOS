import ObjectMapper

class RentalProductReturnedHistory: Mappable {

    var id: Int!
    var confirm: Bool!
    var dispute: Bool!
    var createdDate: Double!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id              <- map["id"]
        confirm         <- map["confirm"]
        dispute         <- map["dispute"]
        createdDate     <- map["createdDate"]
    }
    
}
