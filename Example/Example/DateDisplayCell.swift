//
//  DateDisplayCell.swift
//  Example
//
//  Created by Scott Grosch on 12/3/16.
//  Copyright © 2016 Gargoyle Software, LLC. All rights reserved.
//

import Foundation
import ExpandableDatePicker

final class DateDisplayCell: UITableViewCell, ShowsDatePicker {
    static func reusableCell(for indexPath: IndexPath, in tableView: UITableView) -> DateDisplayCell {
        return tableView.dequeueReusableCell(withIdentifier: "dateDisplay", for: indexPath) as! DateDisplayCell
    }
}
