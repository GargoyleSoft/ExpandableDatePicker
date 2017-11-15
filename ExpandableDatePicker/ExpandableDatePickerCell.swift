//
//  ExpandableDatePickerCell.swift
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

import UIKit

/// A custom `UITableViewCell` which is used to show the `UIDatePicker`
open class ExpandableDatePickerCell : UITableViewCell {
    /// The identifier for the cell.  Only necessary if you are overriding registration with a subclass.
    public static let identifier = "1D72FAC3-6D57-4D57-AF49-386E37BF0089"

    /// The `UIDatePicker` contained in the cell.
    public var datePicker: UIDatePicker!

    /// The method to call when the date is changed.
    public var onDateChanged: ((Date) -> Void)!


    /// :nodoc:
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: ExpandableDatePickerCell.identifier)

        datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        datePicker.addTarget(self, action: #selector(dateValueChanged(_:)), for: .valueChanged)

        contentView.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: contentView.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func dateValueChanged(_ sender: UIDatePicker) {
        precondition(onDateChanged != nil, "Must specify onDateChanged block.")

        onDateChanged(sender.date)
    }

    /// Returns a reusable cell to display the date picker.
    ///
    /// - Parameters:
    ///   - indexPath: The `IndexPath` where the cell will be displayed.
    ///   - tableView: The `UITableView` being used.
    /// - Returns: An `ExpandableDatePickerCell`
    open class func reusableCell(for indexPath: IndexPath, in tableView: UITableView) -> ExpandableDatePickerCell {
        return tableView.dequeueReusableCell(withIdentifier: ExpandableDatePickerCell.identifier, for: indexPath) as! ExpandableDatePickerCell
    }
}
