//
//  UITableView.swift
//
//  Copyright © 2016 - 2018 Gargoyle Software, LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

public extension UITableView {
    /// Sets up the `UITableView` to support the required table cells. You should call this from `viewDidLoad`
    ///
    /// - Note: Also sets the `estimatedRowHeight` to 44 and the `rowHeight` to `UITableViewAutomaticDimension`
    ///         as the date picker needs expandable cells.
    public func registerExpandableDatePicker() {
        register(ExpandableDatePickerCell.self, forCellReuseIdentifier: ExpandableDatePickerCell.identifier)
        register(ExpandableDatePickerTimeZoneCell.self, forCellReuseIdentifier: ExpandableDatePickerTimeZoneCell.identifier)
        register(ExpandableDatePickerSelectionCell.self, forCellReuseIdentifier: ExpandableDatePickerSelectionCell.identifier)

        estimatedRowHeight = 44.0
        rowHeight = UITableViewAutomaticDimension
    }
}
