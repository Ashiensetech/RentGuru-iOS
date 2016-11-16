import ObjectMapper

class RentalProductReturnRequest: Mappable {
    
    var id: Int!
    var remarks: String!
    var isExpired: Bool!
    var createdDate: Double!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        remarks     <- map["remarks"]
        isExpired   <- map["isExpired"]
        createdDate <- map["createdDate"]
    }
    
}
