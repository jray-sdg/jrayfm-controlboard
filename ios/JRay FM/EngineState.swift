//
//  EngineState.swift
//  JRay FM
//
//  Created by Jonathan Ray on 4/21/16.
//  Copyright © 2016 Jonathan Ray. All rights reserved.
//

import Foundation
import UIKit

class EngineState: NSObject, NSCoding {

    let library : [UInt64]
    
    private static let libraryKey = "library"
    
    init?(libraryState: [UInt64]) {
        library = libraryState
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        var count = 0
        let pointer = aDecoder.decodeBytesForKey(EngineState.libraryKey, returnedLength: &count)
        let buffer = UnsafeBufferPointer<UInt64>(start: UnsafePointer(pointer), count: count/sizeof(UInt64))
        self.init(libraryState: Array(buffer))
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeBytes(UnsafePointer(library), length: library.count * sizeof(UInt64), forKey: EngineState.libraryKey)
    }
}
