//
//  ExpandableDatePicker.swift
//  DTS
//
//  Created by Scott Grosch on 5/5/16.
//  Copyright © 2016 Gargoyle Software, LLC. All rights reserved.
//

import UIKit

/// This protocol should be applied to the `UITableViewCell` which is *selected* to make a date picker
/// appear or disappear.
/// - note: Do not place this on the `UITableViewCell` that actually *displays* the `UIPickerView`
public protocol ShowsDatePicker: class { }


/// View controllers which contain a `UITableView` that want to display/hide an inline date picker
/// should conform to this protocol.
public protocol ExpandableDatePicker: class {
    var datePickerIndexPath: IndexPath? { get set }
    var tableView: UITableView! { get set }
}

public extension ExpandableDatePicker {
    /// Registers the two cells which will display the `UIDatePicker` and the timezone row.
    ///
    /// - note: You should call this from your `viewDidLoad()` method.
    ///
    /// - Parameter tableView: The `UITableView` which will shows the pickers.
    public static func registerCells(for tableView: UITableView) {
        tableView.register(ExpandableDatePickerCell.self, forCellReuseIdentifier: ExpandableDatePickerCell.identifier)
        tableView.register(ExpandableDatePickerTimeZoneCell.self, forCellReuseIdentifier: ExpandableDatePickerTimeZoneCell.identifier)
    }

    /// Determines whether or not an inline date picker is currently showing.
    public var showingInlineDatePicker: Bool {
        return datePickerIndexPath != nil
    }

    /// Returns an updated model row based on whether or not the date picker is displayed.  e.g. If row 3
    /// is currently showing an inline date picker, then what's displayed in row 5 is really model row 3
    /// because row 3 is the `UIDatePicker` and row 4 is the timezone picker.
    ///
    /// - parameter for: The `IndexPath` provided by the `UITableViewDataSource` or `UITableViewDelegate`
    ///
    /// - returns: The actual index into the data model to use, as opposed to `indexPath.row`
    public func updatedModelRow(for indexPath: IndexPath) -> Int {
        let row = indexPath.row

        // If they're not in the same section, don't change it
        guard let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.section == indexPath.section else {
            return row
        }

        // If the date picker is in a row above or the same as our current row, then all subsequent rows would
        // have to have their row upped by 2, meaning we have to reduce the model's row by 2 to acocunt for that.
        if datePickerIndexPath.row <= indexPath.row {
            return row - 2
        } else {
            return row
        }
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

            let previousControlCellRow = datePickerIndexPath.row - 2

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
