//
//  Item.swift
//  tandm
//
//  Created by Tarik Marshall on 06.04.25.
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
