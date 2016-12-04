## Usage

ExpandableDatePicker is a library written in Swift which makes the display of a drop-down `UIDatePicker` much simpler.  It also includes
a table row to select the TimeZone that should be used with the date, which is especially helpful when creating calendar items.

You can use the below class as your starting point as it implements all the pieces required by the protocol.

##
```swift
import UIKit
import ExpandableDatePicker

class ViewController: UITableViewController, ExpandableDatePicker {
    // Not used directly by you, but is part of the protocol so the framework can use it.
    var datePickerIndexPath: IndexPath?

    fileprivate var rowThatTogglesDatePicker: Int!

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
                self.tableView.reloadRows(at: [IndexPath(row: self.rowThatTogglesDatePicker, section: indexPath.section)], with: .automatic)
            }

            cell.datePicker.date = selectedDate

            return cell
        } else if shouldShowTimeZoneRow(at: indexPath) {
            return ExpandableDatePickerTimeZoneCell.reusableCell(for: indexPath, in: tableView, timeZone: selectedTimeZone)
        }

        let modelIndexPath = updatedModelIndexPath(for: indexPath)

        if modelIndexPath.row == rowThatTogglesDatePicker {
            // DateDisplayCell is a custom UITableViewCell that implements the ShowsDatePicker protocol.  See the Example project
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

// MARK: - UITableViewDelegate
extension ViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let modelIndexPath = tableCellWasSelected(at: indexPath) else {
            // If tableCellWasSelected(at:) returns nil, they clicked on the time zone selector row.
            let vc = ExpandableDatePickerTimeZoneTableViewController {
                [unowned self] timeZone in
                self.selectedTimeZone = timeZone
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }

            navigationController!.pushViewController(vc, animated: true)

            return
        }

        // modelIndexPath is the new indexPath you use for which row was selected.
    }
}

```

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate ExpandableDatePicker into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'ExpandableDatePicker'
end
```

Then, run the following command:

```bash
$ pod install
```
