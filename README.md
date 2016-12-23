## Usage

ExpandableDatePicker is a library written in Swift which makes the display of a drop-down `UIDatePicker` much simpler.  It also includes
a table row to select the TimeZone that should be used with the date, which is especially helpful when creating calendar items.

For the cell you want to click on that causes the two new rows to appear and disappear you simply need to add the ShowsDatePicker protocol.
There is nothing to implement from that protocol, it just needs to exist on the UITableViewCell subclass.  If you just want a simple "Right Detail" 
cell you can use the provided ExpandableDatePickerSelectionCell class.

![Demo](https://github.com/GargoyleSoft/ExpandableDatePicker/demo.gif "Demo")

## Adding To An Existing View Controller

* Import the ExpandableDatePicker module
* Add the ExpandableDatePicker protocol to your view controller
* Add the three variables defined by the protocol
* Replace all instances of *indexPath* in your *UITableViewDelegate* and *UITableViewDataSource* with *updatedModelIndexPath(for:)*

### viewDidLoad()

Call *tableView.registerExpandableDatePicker()*.  This registers the cells used internally and **sets the *estimatedRowHeight* of the *UITableView* to 44.0** as the *UIDatePicker* requires expandable cells.

### tableView(_:cellForRowAt:)
 
The very start of this method should check *shouldShowDatePicker(at:)* and *shouldShowTimeZoneRow(at:)* before doing anything else, and taking the appropriate action based on the return values.  See the example below for full details.

For the row which is supposed to return the current value of the date, and the one which is tapped on to expand into the date picker and time zone picker rows, you should return an *ExpandableDatePickerSelectionCell* unless you need something more custom.  Simply grab a reusable cell, set the *detailTextLabel* and return the cell.  See below for an example.

### tableView(_:accessoryButtonTappedForRowWith:)

You'll might need to call *tableCellWasSelected(at:)* first and examine the output, depending on your usage model. If you've used the provided *ExpandableDatePickerSelectionCell* then there's no need to do this.

### tableView(_:didSelectRowAt:)

You definitely need to call *tableCellWasSelected(at:)* first and examine the output.  You'll either get back *nil* or an updated *IndexPath* value.  If it's *nil* then they tapped on the row which is used to pick a time zone.  You simply push an *ExpandableDatePickerTimeZoneTableViewController* (whew!) onto your *UINavigationController*.  Your callback will be given a *TimeZone* object which you should store in your local data model and then update your *UITableView*

### tableView(_:numberOfRowsInSection)

Add *datePickerRowsShowing* to your output.  This will either be 0, 1, or 2 depending on whether the extra rows are showing or not.
## Example Implementation
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

        tableView.registerExpandableDatePicker()
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

### Subclassing

If you wish to subclass either `ExpandableDatePickerCell` or `ExpandableDatePickerTimeZoneCell` simply register the cell yourself _after_ the
call to *registerExpandableDatePicker()*.  Both classes provide a static _identifier_ property that you can use for registering your cell.  

```swift
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerExpandableDatePicker()

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
