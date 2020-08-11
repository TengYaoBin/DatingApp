//
//  DatingServerConfiguration.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class DatingServerConfiguration: ATCOnboardingServerConfigurationProtocol {
    var appIdentifier: String = "dating-swift-ios"

    var isFirebaseAuthEnabled: Bool = true
    var isFirebaseDatabaseEnabled: Bool = true
    var isInstagramIntegrationEnabled: Bool = false
}
