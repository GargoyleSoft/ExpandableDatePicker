//
//  ExpandableDatePickerTimeZoneCell.swift
//  TeamKnect
//
//  Created by Scott Grosch on 11/29/16.
//  Copyright © 2016 Gargoyle Software, LLC. All rights reserved.
//

import UIKit

public class ExpandableDatePickerTimeZoneCell : UITableViewCell {
    internal static let identifier = "FE12D1A9-0CC5-46BD-9BAB-81FCDA1ED7DD"

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: ExpandableDatePickerTimeZoneCell.identifier)

        textLabel!.text = NSLocalizedString("Time Zone", comment: "The time zone label for the cell below a date picker")
        detailTextLabel!.text = NSTimeZone.local.localizedName(for: NSTimeZone.NameStyle.generic, locale: nil)
        accessoryType = .disclosureIndicator
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static func reusableCell(for indexPath: IndexPath, in tableView: UITableView, timeZone: TimeZone = NSTimeZone.local) -> ExpandableDatePickerTimeZoneCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableDatePickerTimeZoneCell.identifier, for: indexPath) as! ExpandableDatePickerTimeZoneCell

        cell.detailTextLabel!.text = timeZone.localizedName(for: NSTimeZone.NameStyle.generic, locale: nil)

        return cell
    }
}
