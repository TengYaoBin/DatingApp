//
//  DatingProfileDetailsViewModel.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/26/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class DatingProfileDetailsViewModel: ATCGenericBaseModel {
    var firstName: String?
    var age: String?
    var school: String?
    var distance: String?
    var details: String?

    var description: String {
        return firstName ?? ""
    }

    required init(jsonDict: [String: Any]) {
        fatalError()
    }
}
