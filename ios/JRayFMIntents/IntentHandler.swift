//
//  IntentHandler.swift
//  JRayFMIntents
//
//  Created by Jonathan Ray on 5/20/20.
//  Copyright © 2020 Jonathan Ray. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any? {
        if intent is INPlayMediaIntent {
            return GenerateAndPlayIntent()
        }
        return nil
    }
    
}
