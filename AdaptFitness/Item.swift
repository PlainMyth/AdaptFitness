//
//  Item.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/15/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
