//
//  GenerateAndPlayIntent.swift
//  JRayFMIntents
//
//  Created by Jonathan Ray on 5/20/20.
//  Copyright © 2020 Jonathan Ray. All rights reserved.
//

import Intents

class GenerateAndPlayIntent : NSObject, INPlayMediaIntentHandling {
    
    func handle(intent: INPlayMediaIntent, completion: @escaping (INPlayMediaIntentResponse) -> Void) {
        // Always hand execution to the full app
        let response = INPlayMediaIntentResponse(code: .handleInApp, userActivity: nil)
        completion(response)
    }
}
