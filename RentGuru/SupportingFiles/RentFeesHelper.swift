
class RentFeesHelper: NSObject {

    static var DAY = 1
    static var WEEK = 2
    static var MONTH = 3
    static var YEAR = 4

    static func daysBetween(d1: String, d2: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let difference  = (Calendar.current as NSCalendar).components(.day, from: dateFormatter.date(from: d1)!, to: dateFormatter.date( from: d2)!, options: []).day
        let noOfDays = difference!
        return noOfDays
    }
    
    static func getPerDayRentFee(rentTypeId: Int, rentFee: Double) -> Double{
        switch (rentTypeId){
            case  DAY:
                return rentFee
            case  WEEK:
                return rentFee/7
            case  MONTH:
                return rentFee/30
            case  YEAR:
                return rentFee/365
            default:
                return rentFee
        }
    }
    
    static func getRentFee(rentTypeId: Int, rentFee: Double, startDate: String, endsDate: String) -> Double {
        let day = daysBetween(d1: startDate, d2: endsDate)
        let fee: Double = Double(day) * getPerDayRentFee(rentTypeId: rentTypeId, rentFee: rentFee)
        return fee
    }
    
}
