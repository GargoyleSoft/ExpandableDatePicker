//
//  ViewController.swift
//  Example
//
//  Created by Scott Grosch on 12/3/16.
//  Copyright © 2016 Gargoyle Software, LLC. All rights reserved.
//

import UIKit
import ExpandableDatePicker

class ViewController: UITableViewController, ExpandableDatePicker {
    fileprivate let tableData = ["One", "Two", "Three", "Four"]
    fileprivate let rowThatExpandsToDatePicker = 2

    var datePickerIndexPath: IndexPath?

    fileprivate var selectedDate = Date()
    fileprivate var selectedTimeZone = TimeZone.autoupdatingCurrent

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 44.0

        tableView.register(ExpandableDatePickerCell.self, forCellReuseIdentifier: ExpandableDatePickerCell.identifier)
        tableView.register(ExpandableDatePickerTimeZoneCell.self, forCellReuseIdentifier: ExpandableDatePickerTimeZoneCell.identifier)
    }
}

// MARK: - UITableViewDataSource
extension ViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldShowDatePicker(at: indexPath) {
            let cell = ExpandableDatePickerCell.reusableCell(for: indexPath, in: tableView)
            cell.onDateChanged = {
                [unowned self] date in
                self.selectedDate = date
                self.tableView.reloadRows(at: [IndexPath(row: self.rowThatExpandsToDatePicker, section: indexPath.section)], with: .automatic)
            }

            cell.datePicker.date = selectedDate

            return cell
        } else if shouldShowTimeZoneRow(at: indexPath) {
            return ExpandableDatePickerTimeZoneCell.reusableCell(for: indexPath, in: tableView, timeZone: selectedTimeZone)
        }

        let modelIndexPath = updatedModelIndexPath(for: indexPath)

        if modelIndexPath.row == rowThatExpandsToDatePicker {
            let cell = DateDisplayCell.reusableCell(for: indexPath, in: tableView)
            cell.textLabel!.text = "Date:"
            cell.detailTextLabel?.text = DateFormatter.localizedString(from: selectedDate, dateStyle: .short, timeStyle: .none)

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath)
        cell.textLabel!.text = tableData[modelIndexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = tableData.count
        return showingInlineDatePicker ? rows + 2 : rows
    }
}

// MARK: - UITableViewDelegate {
extension ViewController {
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let modelIndexPath = tableCellWasSelected(at: indexPath) else {
            let vc = ExpandableDatePickerTimeZoneTableViewController {
                [weak self] timeZone in
                self?.selectedTimeZone = timeZone
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }

            navigationController!.pushViewController(vc, animated: true)

            return
        }

        // modelIndexPath is the new indexPath you use for which row was selected.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let modelIndexPath = tableCellWasSelected(at: indexPath) else {
            let vc = ExpandableDatePickerTimeZoneTableViewController {
                [weak self] timeZone in
                self?.selectedTimeZone = timeZone
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }

            navigationController!.pushViewController(vc, animated: true)

            return
        }

        // modelIndexPath is the new indexPath you use for which row was selected.
    }
}
