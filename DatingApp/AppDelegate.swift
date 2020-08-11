//
//  AppDelegate.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Firebase
import FirebaseMessaging
import UIKit
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Configure google map
        GMSServices.provideAPIKey("AIzaSyCQAjcEVG2d18AcsYdGlKdx31rhcRyB76Y")
        GMSPlacesClient.provideAPIKey("AIzaSyCQAjcEVG2d18AcsYdGlKdx31rhcRyB76Y")
        
        // Configure the UI
        let config = DatingUIConfiguration()
        config.configureUI()

        let serverConfig = DatingServerConfiguration()

        if (serverConfig.isFirebaseAuthEnabled || serverConfig.isFirebaseDatabaseEnabled) {
            FirebaseApp.configure()
        }

        let datingDataSource: ATCDatingFeedDataSource = (serverConfig.isFirebaseDatabaseEnabled ?
            ATCDatingFeedFirebaseDataSource() :
            ATCDatingFeedMockDataSource())

        let swipeManager: ATCDatingSwipeManager? = (serverConfig.isFirebaseDatabaseEnabled ?
            ATCDatingFirebaseSwipeManager() :
            nil
        )

        let editProfileManager: ATCDatingProfileEditManager? = (serverConfig.isFirebaseDatabaseEnabled ?
            ATCDatingFirebaseProfileEditManager() :
            nil
        )

        let profileUpdater: ATCProfileUpdaterProtocol? = (serverConfig.isFirebaseDatabaseEnabled ?
            ATCProfileFirebaseUpdater(usersTable: "users") :
            nil)
        
        let userManager: ATCSocialFirebaseUserManager? = (serverConfig.isFirebaseDatabaseEnabled ?
            ATCSocialFirebaseUserManager() :
            nil)
        
        let instagramConfig: ATCInstagramConfig? =  (serverConfig.isInstagramIntegrationEnabled ?
            ATCInstagramConfig(clientID: "bd6324b5644146debf482287f00e5be2",
                               redirectURL: "https://www.iosapptemplates.com/redirect") :
            nil)

        let reportingManager = ATCFirebaseUserReporter()
        let viewer: ATCDatingProfile? = (serverConfig.isFirebaseDatabaseEnabled) ? nil : ATCDatingFeedMockDataSource.mockProfiles[0]
        
        // Window setup
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = DatingHostViewController(uiConfig: config,
                                                              serverConfig: serverConfig,
                                                              datingFeedDataSource: datingDataSource,
                                                              swipeManager: swipeManager,
                                                              editProfileManager: editProfileManager,
                                                              profileUpdater: profileUpdater,
                                                              instagramConfig: instagramConfig,
                                                              reportingManager: reportingManager,
                                                              userManager: userManager,
                                                              viewer: viewer)
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    //
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

