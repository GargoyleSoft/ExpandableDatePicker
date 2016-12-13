## Usage

ExpandableDatePicker is a library written in Swift which makes the display of a drop-down `UIDatePicker` much simpler.  It also includes
a table row to select the TimeZone that should be used with the date, which is especially helpful when creating calendar items.

For the cell you want to click on that causes the two new rows to appear and disappear you simply need to add the ShowsDatePicker protocol.
There is nothing to implement from that protocol, it just needs to exist on the UITableViewCell subclass.  If you just want a simple "Right Detail" 
cell you can use the provided ExpandableDatePickerSelectionCell class.

You can use the below class as your starting point as it implements all the pieces required by the protocol.

##
```swift
import UIKit
import ExpandableDatePicker

class ViewController: UITableViewController, ExpandableDatePicker {
    // Not used directly by you, but is part of the protocol so the framework can use it.
    var datePickerIndexPath: IndexPath?

    // Whether or not the expansion should include a TimeZone row selector.
    var showTimeZoneRow = true

    fileprivate var rowThatTogglesDatePicker: Int!

    fileprivate var selectedDate = Date()
    fileprivate var selectedTimeZone = TimeZone.autoupdatingCurrent

    override func viewDidLoad() {
        super.viewDidLoad()

        // Comes from ExpandableDatePicker but you can't directly call a static method via a protocol
        // so we have to use our own class name.
        ViewController.setup(tableView)
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

        if modelIndexPath.row == rowThatExpandsToDatePicker {
            let cell = ExpandableDatePickerSelectionCell.reusableCell(for: indexPath, in: tableView)
            cell.detailTextLabel!.text = DateFormatter.localizedString(from: selectedDate, dateStyle: .short, timeStyle: .none)

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath)
        cell.textLabel!.text = tableData[modelIndexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count + datePickerRowsShowing
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

### `tableView(_:accessoryButtonTappedForRowWith:)`

Depending on your usage model you may need to duplicate the tableCellWasSelected functionality in `tableView(_:accessoryButtonTappedForRowWith:)`. 
When you call that method it handles properly showing or hiding the two extra table rows.

### Subclassing

If you wish to subclass either `ExpandableDatePickerCell` or `ExpandableDatePickerTimeZoneCell` simply register the cell yourself _after_ the
call to setup.  Both classes provide a static _identifier_ property that you can use for registering your cell.  

```swift
    override func viewDidLoad() {
        super.viewDidLoad()

        // Comes from ExpandableDatePicker but you can't directly call a static method via a protocol
        // so we have to use our own class name.
        ViewController.setup(tableView)

        tableView.register(MyCoolTimeZoneSubclassCell.self, forCellReuseIdentifier: ExpandableDatePickerTimeZoneCell.identifier)
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
