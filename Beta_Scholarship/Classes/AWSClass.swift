//
//  AWSClass.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/10/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import AWSDynamoDB
import AWSCognitoIdentityProvider

@objcMembers
class studyHours :AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    
    var Date_And_Time:String? = ""
    var NameOfUser:String? = ""
    
    //set the default values of scores, wins and losses to 0
    var Class:String? = ""
    var Hours:NSNumber? = 0
    var Location:String? = ""
    var Week:NSNumber? = 0
    var Probo_Level:String? = ""
    var SigURL:String? = ""
    
    class func dynamoDBTableName() -> String {
        return "Probo_Study_Hours"
    }
    
    class func hashKeyAttribute() -> String {
        return "Date_And_Time"
    }
    
    class func rangeKeyAttribute() -> String {
        return "NameOfUser"
    }
}

class userInformation {
    
    var sub: String?
    var house_positions: String?
    var address: String?
    var birthdate: String?
    var year: String?
    var email_verified: Bool?
    var brother_status: String?
    var contact_email: String?
    var phone_number_verified: Bool?
    var given_name: String?
    var probo_level: Int?
    var pin_number: Int?
    var major: String?
    var profile_pic_url: URL?
    var phone_number: String?
    var family_name: String?
    var email: String?
    var fullName: String?
    
    init(_ response: AWSCognitoIdentityUserGetDetailsResponse) {
        for attribute in response.userAttributes! {
            print("\(attribute.name!): \(attribute.value!)")
            if ( attribute.name! == "sub" ) { sub = attribute.value! }
            if ( attribute.name! == "custom:house_positions" ) { house_positions = attribute.value! }
            if ( attribute.name! == "address" ) { address = attribute.value! }
            if ( attribute.name! == "birthdate" ) { birthdate = attribute.value! }
            if ( attribute.name! == "custom:year" ) { year = attribute.value! }
            if ( attribute.name! == "email_verified" ) { email_verified = Bool(attribute.value!) }
            if ( attribute.name! == "custom:brother_status" ) { brother_status = attribute.value! }
            if ( attribute.name! == "custom:contact_email" ) { contact_email =  attribute.value! }
            if ( attribute.name! == "phone_number_verified" ) { phone_number_verified =  Bool(attribute.value!) }
            if ( attribute.name! == "given_name" ) { given_name = attribute.value! }
            if ( attribute.name! == "custom:probo_level" ) { probo_level =  Int(attribute.value!) }
            if ( attribute.name! == "custom:pin_number" ) { pin_number = Int(attribute.value!) }
            if ( attribute.name! == "custom:major" ) { major = attribute.value! }
            if ( attribute.name! == "custom:profile_pic_url" ) { profile_pic_url = URL(fileURLWithPath: attribute.value!) }
            if ( attribute.name! == "phone_number" ) { phone_number = attribute.value! }
            if ( attribute.name! == "family_name" ) { family_name = attribute.value! }
            if ( attribute.name! == "email" ) { email = attribute.value! }
            if self.given_name != nil && self.family_name != nil {
                fullName = "\(given_name!) \(family_name!)"
                print("full name: \(fullName!)")
            }
        }
    }
    
    init() {
        sub = String()
        house_positions = String()
        address = String()
        birthdate = String()
        year = String()
        email_verified = Bool()
        brother_status = String()
        contact_email = String()
        phone_number_verified = Bool()
        given_name = String()
        probo_level = Int()
        pin_number = Int()
        major = String()
        profile_pic_url = URL(fileURLWithPath: String())
        phone_number = String()
        family_name = String()
        email = String()
        fullName = String()
    }
    
    func getDetails() {
        print("sub: \(sub!)")
        print("house_positions: \(house_positions!)")
        print("address: \(address!)")
        print("birthdate: \(birthdate!)")
        print("email_verified: \(email_verified!)")
        print("brother_status: \(brother_status!)")
        print("contact_email: \(contact_email!)")
        print("phone_number_verified: \(phone_number_verified!)")
        print("given_name: \(given_name!)")
        print("probo_level: \(probo_level!)")
        print("pin_number: \(pin_number!)")
        print("major: \(major!)")
        print("profile_pic_url: \(profile_pic_url!)")
        print("phone_number: \(phone_number!)")
        print("family_name: \(family_name!)")
        print("email: \(email!)")
        print("fullName: \(fullName!)")
    }
    
}
