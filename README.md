`ExpandableDatePicker` is a library written in Swift which makes the display of a drop-down `UIDatePicker` much simpler.  It also includes
a table row to select the TimeZone that should be used with the date, which is expecially helpful when creating calendar items.


- On your UITableViewController implement the `ExpandableDatePicker` protocol.
- In your `viewDidLoad` method register the two cells the framework uses
- Implement variables to store the selected date and the timeonze.
- Set the `estimatedRowHeight` on your tableView to enable dynamically sized rows.

##
```swift
import UIKit
import ExpandableDatePicker

class ViewController: UITableViewController, ExpandableDatePicker {
    // Not used directly by you, but is part of the protocol so the framework can use it.
    var datePickerIndexPath: IndexPath?

    fileprivate var rowThatToggledDatePicker: Int!

    fileprivate var selectedDate = Date()
    fileprivate var selectedTimeZone = TimeZone.autoupdatingCurrent

    override func viewDidLoad() {
        super.viewDidLoad()

        // The UIDatePicker needs to have dynamic sized rows
        tableView.estimatedRowHeight = 44.0

        // These are the cells which the framework defines for you to use.
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
                self.tableView.reloadRows(at: [IndexPath(row: self.rowThatToggledDatePicker, section: indexPath.section)], with: .automatic)
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

	// Store whichever row was selected to use for later. 
	rowThatToggledDatePicker = indexPath.row

        // modelIndexPath is the new indexPath you use for which row was selected.
    }
}

```


