//
//  Helper.swift
//  Skatebud
//
//  Created by JAROD SMITH on 1/8/21.
//

import Foundation
import Network
import SystemConfiguration
import UIKit
import FirebaseAuth


class Helper{
    
    static func checkInternetConnection() -> Bool{
        var result: Bool = true

        let networkMonitor = NWPathMonitor()
        let queue = DispatchQueue.global(qos: .background)
        networkMonitor.pathUpdateHandler = {path in
            if path.status == .satisfied {
                result = true
            } else {
                result = false
            }
        }
        networkMonitor.start(queue: queue)
        networkMonitor.cancel()
        
        print(result)
        return result
    }
    
    static func levelsForSpecificTrick(successAttempts:Int) -> Int{
        //Grab the successful attempts and assign a level
        
        let attempts = successAttempts
        var result = 0
        let lev1Max = 10
        let lev2Max = lev1Max * 2 + lev1Max
        let lev3Max = lev2Max * 2 + lev2Max
        let lev4Max = lev3Max * 2 + lev3Max
        if attempts < 1 {
            result = 0
        }
        if attempts > 0 && attempts <= lev1Max{
            result = 1
        }
        if attempts > lev1Max && attempts <= lev2Max{
            result = 2
        }
        if attempts > lev2Max && attempts <= lev3Max{
            result = 3
        }
        if attempts > lev3Max && attempts <= lev4Max{
            result = 4
        }
        if attempts > lev4Max{
            result = 5
        }
        
        return result
    }
    static func levelsForUser(countOfTrickTypes: Int, successAttempts: Int) -> Int{
        //Grab the count of the tricks to figure out where the levels start
        //Grab the success attempts from all of the tricks
        
        let attempts = successAttempts
        var result = 0
        let lev1Max = 10 * attempts
        let lev2Max = lev1Max * 2 + lev1Max
        let lev3Max = lev2Max * 2 + lev2Max
        let lev4Max = lev3Max * 2 + lev3Max
        print(attempts)
        if attempts < 1 {
            result = 0
            print("lvl 0")
        }
        if attempts > 0 && attempts <= lev1Max{
            result = 1
            print("lvl 1")

        }
        if attempts > lev1Max && attempts <= lev2Max{
            result = 2
            print("lvl 2")

        }
        if attempts > lev2Max && attempts <= lev3Max{
            result = 3
            print("lvl 3")

        }
        if attempts > lev3Max && attempts <= lev4Max{
            result = 4
            print("lvl 4")

        }
        if attempts > lev4Max{
            result = 5
            print("lvl 5")

        }
        
        return result
    }
    
    static func checkFirebaseLogin() -> Bool {
        var loggedIn = false
        if Auth.auth().currentUser != nil {
            print("Logged In")
            loggedIn = true
        } else {
            print("logged out")
        }
        return loggedIn
    }
}
