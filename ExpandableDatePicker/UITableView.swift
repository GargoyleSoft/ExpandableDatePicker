//
//  UITableView.swift
//  ExpandableDatePicker
//
//  Created by Scott Grosch on 12/21/16.
//  Copyright © 2016 Gargoyle Software, LLC. All rights reserved.
//

import UIKit

public extension UITableView {
    /// Sets up the `UITableView` to support the required table cells.  Also sets the `estimatedRowHeight`
    /// to 44 as the date picker needs expandable cells.  You should call this from `viewDidLoad`
    public func registerExpandableDatePicker() {
        register(ExpandableDatePickerCell.self, forCellReuseIdentifier: ExpandableDatePickerCell.identifier)
        register(ExpandableDatePickerTimeZoneCell.self, forCellReuseIdentifier: ExpandableDatePickerTimeZoneCell.identifier)
        register(ExpandableDatePickerSelectionCell.self, forCellReuseIdentifier: ExpandableDatePickerSelectionCell.identifier)

        estimatedRowHeight = 44.0
    }
}
