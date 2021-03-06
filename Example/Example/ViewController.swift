//
//  ViewController.swift
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
import ExpandableDatePicker

class ViewController: UITableViewController, ExpandableDatePicker {
    var edpShowTimeZoneRow = true
    var edpIndexPath: IndexPath?

    fileprivate let tableData = ["Some Row", "Start Date", "End Date", "Some Other Row"]

    fileprivate var startDate = Date()
    fileprivate var endDate = Date()

    fileprivate var selectedTimeZone = TimeZone.autoupdatingCurrent

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerExpandableDatePicker()
    }
}

// MARK: - UITableViewDataSource
extension ViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if edpShouldShowDatePicker(at: indexPath) {
            let cell = ExpandableDatePickerCell.reusableCell(for: indexPath, in: tableView)
            cell.datePicker.datePickerMode = .date
            cell.onDateChanged = {
                [unowned self] date in

                // We know the date picker is showing, so we can just ask for the label's index path directly
                if self.edpLabelIndexPath!.row == 1 {
                    self.startDate = date
                } else {
                    self.endDate = date
                }

                self.tableView.reloadRows(at: [self.edpLabelIndexPath!], with: .automatic)
            }

            if self.edpLabelIndexPath!.row == 1 {
                cell.datePicker.date = self.startDate
            } else {
                cell.datePicker.date = self.endDate
            }

            return cell
        } else if edpShouldShowTimeZoneRow(at: indexPath) {
            return ExpandableDatePickerTimeZoneCell.reusableCell(for: indexPath, in: tableView, timeZone: selectedTimeZone)
        }

        let modelIndexPath = edpUpdatedModelIndexPath(for: indexPath)

        if modelIndexPath.row == 1 || modelIndexPath.row == 2 {
            let cell = ExpandableDatePickerSelectionCell.reusableCell(for: indexPath, in: tableView)

            let date = modelIndexPath.row == 1 ? startDate : endDate
            cell.detailTextLabel!.text = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath)
        cell.textLabel!.text = tableData[modelIndexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count + edpDatePickerRowsShowing
    }
}

// MARK: - UITableViewDelegate {
extension ViewController {
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let modelIndexPath = edpTableCellWasSelected(at: indexPath) else {
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
        guard let modelIndexPath = edpTableCellWasSelected(at: indexPath) else {
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
