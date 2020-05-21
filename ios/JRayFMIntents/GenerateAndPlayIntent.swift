//
//  GenerateAndPlayIntent.swift
//  JRayFMIntents
//
//  Created by Jonathan Ray on 5/20/20.
//  Copyright © 2020 Jonathan Ray. All rights reserved.
//

import Intents

class GenerateAndPlayIntent : NSObject, INPlayMediaIntentHandling {
    
    func resolveMediaItems(for intent: INPlayMediaIntent,
                           with completion: @escaping ([INPlayMediaMediaItemResolutionResult]) -> Void) {
        // We always take the same action no matter what so everything is a success
        var result: [INPlayMediaMediaItemResolutionResult] = []
        if let intentMediaItems = intent.mediaItems {
            for intentMedia in intentMediaItems {
                result.append(INPlayMediaMediaItemResolutionResult.success(with: intentMedia))
            }
        }
        else {
            result.append(INPlayMediaMediaItemResolutionResult.success(with: INMediaItem(identifier: nil, title: nil, type: .music, artwork: nil)))
        }
        completion(result)
    }
    
    func handle(intent: INPlayMediaIntent, completion: @escaping (INPlayMediaIntentResponse) -> Void) {
        // Always hand execution to the full app
        let response = INPlayMediaIntentResponse(code: .handleInApp, userActivity: nil)
        completion(response)
    }
}
