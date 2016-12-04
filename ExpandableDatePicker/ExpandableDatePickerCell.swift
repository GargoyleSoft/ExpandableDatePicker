//
//  ExpandableDatePickerCell.swift
//  TeamKnect
//
//  Created by Scott Grosch on 11/29/16.
//  Copyright © 2016 Gargoyle Software, LLC. All rights reserved.
//

import UIKit

public class ExpandableDatePickerCell : UITableViewCell, ShowsDatePicker {
    internal static let identifier = "1D72FAC3-6D57-4D57-AF49-386E37BF0089"

    public var datePicker: UIDatePicker!
    public var onDateChanged: ((Date) -> Void)!

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: ExpandableDatePickerCell.identifier)

        datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        datePicker.addTarget(self, action: #selector(dateValueChanged(_:)), for: .valueChanged)

        contentView.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: contentView.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func dateValueChanged(_ sender: UIDatePicker) {
        precondition(onDateChanged != nil, "Must specify onDateChanged block.")

        onDateChanged(sender.date)
    }

    public static func reusableCell(for indexPath: IndexPath, in tableView: UITableView) -> ExpandableDatePickerCell {
        return tableView.dequeueReusableCell(withIdentifier: ExpandableDatePickerCell.identifier, for: indexPath) as! ExpandableDatePickerCell
    }
}
