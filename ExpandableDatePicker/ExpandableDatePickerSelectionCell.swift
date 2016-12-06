//
//  ExpandableDatePickerSelectionCell.swift
//  ExpandableDatePicker
//
//  Created by Scott Grosch on 12/5/16.
//  Copyright © 2016 Gargoyle Software, LLC. All rights reserved.
//

import UIKit

open class ExpandableDatePickerSelectionCell : UITableViewCell, ShowsDatePicker {
    public static let identifier = "0DB89E55-CAB1-4EFB-8D47-01C86D52B106"

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: ExpandableDatePickerSelectionCell.identifier)

        textLabel!.text = NSLocalizedString("Date:", comment: "The date label for a table cell that selects the date")
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open class func reusableCell(for indexPath: IndexPath, in tableView: UITableView) -> ExpandableDatePickerSelectionCell {
        return tableView.dequeueReusableCell(withIdentifier: ExpandableDatePickerSelectionCell.identifier, for: indexPath) as! ExpandableDatePickerSelectionCell
    }
}
