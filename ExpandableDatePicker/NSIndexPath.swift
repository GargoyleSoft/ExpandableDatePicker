//
//  NSIndexPath.swift
//  DTS
//
//  Created by Scott Grosch on 5/5/16.
//  Copyright © 2016 Gargoyle Software, LLC. All rights reserved.
//

import Foundation

internal extension IndexPath {
    /// Gets the row after the current row in the same section.
    func nextRow() -> IndexPath {
        return IndexPath(row: row + 1, section: section)
    }

    /// Gets the row before the current row in the same section.
    func previousRow() -> IndexPath {
        return IndexPath(row: row - 1, section: section)
    }
}
