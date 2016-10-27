//
//  RentPayment.swift
//  RentGuru
//
//  Created by Workspace Infotech on 9/26/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//
import UIKit
import ObjectMapper

class RentPayment: Mappable {
    var id                 :Int!
    var appCredential      :AppCredential!
    var rentRequest        :RentRequest!
    var rentInf            :RentInf!
    var rentFee            :Double!
    var refundAmount       :Double!
    var totalAmount        :Double!
    var transactionFee     :Double!
    var currency           :String!
    var paypalPayerId      :String!
    var paypalPayId        :String!
    var paypalSaleId       :String!
    var authorizationId    :String!
    var paypalPaymentDate  :Int!
    var createdDate        :Int!
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        id                  <- map["id"]
        appCredential       <- map["appCredential"]
        rentRequest         <- map["rentRequest"]
        rentInf             <- map["rentInf"]
        rentFee             <- map["rentFee"]
        refundAmount        <- map["refundAmount"]
        totalAmount         <- map["totalAmount"]
        transactionFee      <- map["transactionFee"]
        currency            <- map["currency"]
        paypalPayerId       <- map["paypalPayerId"]
        paypalPayId         <- map["paypalPayId"]
        paypalSaleId        <- map["paypalSaleId"]
        authorizationId     <- map["authorizationId"]
        paypalPaymentDate   <- map["paypalPaymentDate"]
        createdDate         <- map["createdDate"]
    }
}
