//
//  ExpandableDatePicker.swift
//
//  Copyright © 2016 Gargoyle Software, LLC
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

/// This protocol should be applied to the `UITableViewCell` which is *selected* to make a date picker
/// appear or disappear.
/// - note: Do not place this on the `UITableViewCell` that actually *displays* the `UIDatePicker`
public protocol ShowsDatePicker: class { }


/// View controllers which contain a `UITableView` that want to display/hide an inline date picker
/// should conform to this protocol.
public protocol ExpandableDatePicker: class {
    var datePickerIndexPath: IndexPath? { get set }
    var tableView: UITableView! { get set }
}

public extension ExpandableDatePicker {
    /// Determines whether or not an inline date picker is currently showing.
    public var showingInlineDatePicker: Bool {
        return datePickerIndexPath != nil
    }

    /// Returns an updated `IndexPath` based on whether or not the date picker is displayed.  e.g. If row 3
    /// is currently showing an inline date picker, then what's displayed in row 5 is really model row 3
    /// because row 3 is the `UIDatePicker` and row 4 is the timezone picker.
    ///
    /// - parameter for: The `IndexPath` provided by the `UITableViewDataSource` or `UITableViewDelegate`
    ///
    /// - returns: The actual index into the data model to use, as opposed to `indexPath.row`
    public func updatedModelIndexPath(for indexPath: IndexPath) -> IndexPath {
        var row = indexPath.row

        // If they're not in the same section, don't change it
        guard let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.section == indexPath.section else {
            return IndexPath(row: row, section: indexPath.section)
        }

        // If the date picker is in a row above or the same as our current row, then all subsequent rows would
        // have to have their row upped by 2, meaning we have to reduce the model's row by 2 to acocunt for that.
        if datePickerIndexPath.row <= indexPath.row {
            row -= 2
        }

        return IndexPath(row: row, section: indexPath.section)
    }

    /// Determines whether or not the indicated `indexPath` is the row that should currently be displaying
    /// the inline date picker.  You should call this from `tableView(_:cellForRowAt)` before doing your other
    /// work as you don't really have a model row for the `UIDatePicker`
    ///
    /// - parameter indexPath: The `IndexPath` provided by the `UITableViewDataSource` or `UITableViewDelegate`
    ///
    /// - returns: `true` or `false`
    ///
    /// ```Swift
    /// override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    ///    if shouldShowDatePicker(at: indexPath) {
    ///        return ExpandableDatePickerCell.reusableCell(for: indexPath, in: tableView)
    ///    } else if shouldShowTimeZoneRow(at: indexPath) {
    ///        return ExpandableDatePickerTimeZoneCell.reusableCell(for: indexPath, in: tableView)
    ///    }
    public func shouldShowDatePicker(at indexPath: IndexPath) -> Bool {
        return datePickerIndexPath == indexPath
    }

    /// Determne whether or not the indicated `indexPath` is the row that should currently be displaying
    /// the timezone picker.  You should call this from `tableView(_:cellForRowAt)` before doing your other
    /// work as you don't really have a model row for the timezone row.
    ///
    /// - Parameter indexPath: The `IndexPath` provided by the `UITableViewDataSource` or `UITableViewDelegate`
    ///
    /// - Returns: `true` or `false`
    ///
    /// ```Swift
    /// override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    ///    if shouldShowDatePicker(at: indexPath) {
    ///        return ExpandableDatePickerCell.reusableCell(for: indexPath, in: tableView)
    ///    } else if shouldShowTimeZoneRow(at: indexPath) {
    ///        return ExpandableDatePickerTimeZoneCell.reusableCell(for: indexPath, in: tableView)
    ///    }
    public func shouldShowTimeZoneRow(at indexPath: IndexPath) -> Bool {
        return datePickerIndexPath?.nextRow() == indexPath
    }

    /// This method should be called whenever a row in the `UITableView` has been selected.  This will control
    /// making sure that the date picker row appears and disappears properly.
    ///
    /// - parameter at: The `IndexPath` provided by the `UITableViewDataSource` or `UITableViewDelegate`
    ///
    /// - note: You most likely need to also call this on `tableView(_:accessoryButtonTappedForRowWith:)`.
    ///
    /// - returns: An updated `IndexPath` that accounts for whether or not the date picker is displayed.  If
    ///            they picked the Time Zone row, then we return `nil` to signal that.
    ///
    /// ```Swift
    /// guard let modelIndexPath = tableCellWasSelected(at: indexPath) else {
    ///     let vc = ExpandableDatePickerTimeZoneTableViewController {
    ///         timeZone in
    ///         self.selectedTimeZone = timeZone
    ///     }
    ///
    ///     navigationController!.pushViewController(vc, animated: true)
    ///
    ///     return
    /// }
    public func tableCellWasSelected(at indexPath: IndexPath) -> IndexPath? {
        tableView.beginUpdates()
        defer {
            tableView.endUpdates()
            tableView.deselectRow(at: indexPath, animated: true)
        }

        var updatedIndexPath = indexPath

        // TODO: What happens when the sections are different.
        if let datePickerIndexPath = datePickerIndexPath {
            let timeZoneIndexPath = datePickerIndexPath.nextRow()

            if timeZoneIndexPath == indexPath {
                // They selected the timezone row.   
                return nil
            }

            if datePickerIndexPath.row < indexPath.row {
                updatedIndexPath = updatedIndexPath.previousRow().previousRow()
            }

            // Get rid of the currently visible inline date picker
            tableView.deleteRows(at: [datePickerIndexPath, timeZoneIndexPath], with: .automatic)

            let previousControlCellRow = datePickerIndexPath.row - 1

            self.datePickerIndexPath = nil

            // If they tapped the cell that controls the date picker which was displayed, we're done.
            if previousControlCellRow == indexPath.row {
                return updatedIndexPath
            }
        }

        guard let _ = tableView.cellForRow(at: indexPath) as? ShowsDatePicker else {
            return updatedIndexPath
        }

        // They tapped a different row that also wants to show a date picker, so insert it now.
        let indexPathToReveal = updatedIndexPath.nextRow()
        tableView.insertRows(at: [indexPathToReveal, indexPathToReveal.nextRow()], with: .automatic)
        datePickerIndexPath = indexPathToReveal

        return updatedIndexPath
    }
}
