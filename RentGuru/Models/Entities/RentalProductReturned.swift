import ObjectMapper

class RentalProductReturned: Mappable {

    var id: Int!
    var confirm: Bool!
    var dispute: Bool!
    var isExpired: Bool!
    var createdDate: Double!
    var renteeRemarks: String!
    var renterRemarks: String!
    var rentalProductReturnedHistories: [RentalProductReturnedHistory] = []
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id              <- map["id"]
        confirm         <- map["confirm"]
        dispute         <- map["dispute"]
        isExpired       <- map["isExpired"]
        createdDate     <- map["createdDate"]
        renteeRemarks   <- map["renteeRemarks"]
        renterRemarks   <- map["renterRemarks"]
    }
    
}
