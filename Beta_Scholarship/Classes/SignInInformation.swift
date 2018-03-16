//
//  SignInInformation.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/15/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import Foundation
import UIKit

class signInInformation {

    // Vars
    struct Name {
        var first: String?
        var last: String?
    }

    struct Address {
        var street: String?
        var city: String?
        var state: String?
        var zip: String?
    }

    struct Contact {
        var phone: String?
        var contactEmail: String?
        var appEmail: String?
    }

    struct School {
        var year: String?
        var major: String?
    }

    struct Beta {
        var brotherStatus: String?
        var pin: String?
        var proboLevel: String?
        var housePositions: String?
    }

    struct Other {
        var birthdate: String?
        var username: String?
        var profilePicURL: String?
    }

    var name: Name
    var address: Address
    var contact: Contact
    var school: School
    var beta: Beta
    var other: Other

    init() {
        name = Name()
        address = Address()
        contact = Contact()
        school = School()
        beta = Beta()
        other = Other()
    }
}
