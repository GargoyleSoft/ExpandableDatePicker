//
//  ExpandableDatePickerTimeZoneTableViewController.swift
//  TeamKnect
//
//  Created by Scott Grosch on 12/2/16.
//  Copyright © 2016 Gargoyle Software, LLC. All rights reserved.
//

import UIKit

fileprivate let identifier = "E8C5B426-A9F6-4EEA-B080-601C5892C38D"

internal class ExpandableDatePickerTimeZoneCellData {
    let name: String
    let fullName: String?
    let indentationLevel: Int
    var isExpanded = false
    var children: [ExpandableDatePickerTimeZoneCellData]?

    init(name: String, indentationLevel: Int, fullName: String? = nil) {
        self.name = name
        self.fullName = fullName
        self.indentationLevel = indentationLevel
    }
}

public class ExpandableDatePickerTimeZoneTableViewController : UITableViewController {
    fileprivate var onChosen: ((TimeZone) -> Void)!
    fileprivate var tableData: [ExpandableDatePickerTimeZoneCellData] = []
    fileprivate var nodes: [ExpandableDatePickerTimeZoneCellData] = []

    init(onTimeZoneChosen: @escaping (TimeZone) -> Void) {
        self.onChosen = onTimeZoneChosen

        super.init(style: .plain)

        for name in TimeZone.knownTimeZoneIdentifiers {
            buildTimeZoneData(items: &nodes, fullName: name, parts: name.components(separatedBy: "/"), indentationLevel: 0)
        }

        for node in nodes {
            tableData.append(node)
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func collapseAndCount(_ data: ExpandableDatePickerTimeZoneCellData) -> Int {
        var count = 1

        guard data.isExpanded, let children = data.children else { return count }

        data.isExpanded = false

        for child in children {
            count += collapseAndCount(child)
        }

        return count
    }

    private func buildTimeZoneData(items: inout [ExpandableDatePickerTimeZoneCellData], fullName: String, parts: [String], indentationLevel: Int) {
        guard let name = parts.first else { return }

        let rest = parts[1..<parts.count]

        for item in items {
            guard item.name == name else { continue }
            guard rest.count > 0 else { return }

            if item.children == nil {
                item.children = [ExpandableDatePickerTimeZoneCellData(name: name, indentationLevel: indentationLevel + 2, fullName: fullName)]
            }

            buildTimeZoneData(items: &item.children!, fullName: fullName, parts: rest + [], indentationLevel: indentationLevel + 2)

            return
        }

        let new = ExpandableDatePickerTimeZoneCellData(name: name, indentationLevel: indentationLevel, fullName: fullName)
        items.append(new)
        
        guard rest.count > 0 else { return }
        
        new.children = []
        buildTimeZoneData(items: &new.children!, fullName: fullName, parts: rest + [], indentationLevel: indentationLevel + 2)
    }
}

// MARK: - UITableViewDataSource
public extension ExpandableDatePickerTimeZoneTableViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableData[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.indentationLevel = data.indentationLevel

        if data.children == nil {
            cell.textLabel?.text = data.name
        } else if data.isExpanded {
            cell.textLabel!.text = "➖ \(data.name)"
        } else {
            cell.textLabel!.text = "➕ \(data.name)"
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
public extension ExpandableDatePickerTimeZoneTableViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        precondition(onChosen != nil, "Must specify the onChosen block.")

        let data = tableData[indexPath.row]

        if let children = data.children {
            // There are children, so it's togglable
            tableView.beginUpdates()
            defer {
                tableView.endUpdates()

                // Have to do this as we need to change the image displayed now.
                tableView.reloadRows(at: [indexPath], with: .none)
            }

            var indexPaths: [IndexPath] = []
            var ip = indexPath

            if data.isExpanded {
                // We don't actually want to remove the row that we clicked on as it will just
                // turn into a row with a +.  For that same reason the for() loop next starts
                // with 1 instead of 0 so we skip a row.
                ip = ip.nextRow()

                // Since we're deleting from top to bottom, we have to always remove the same
                // row.  If we're deleting 3 rows, and we delete(at: 0) then what was row indexes
                // 1 and 2 now become 0 and 1 as they slide up.
                let rowToRemove = ip.row

                for _ in 1 ..< collapseAndCount(data) {
                    indexPaths.append(ip)

                    tableData.remove(at: rowToRemove)

                    ip = ip.nextRow()
                }

                tableView.deleteRows(at: indexPaths, with: .automatic)

                // We don't need to set isExpanded to false because collapseAndCount did so.
            } else {
                for child in children {
                    ip = ip.nextRow()
                    indexPaths.append(ip)
                    tableData.insert(child, at: ip.row)
                }

                tableView.insertRows(at: indexPaths, with: .automatic)
                data.isExpanded = true
            }
        } else {
            let tz = TimeZone(identifier: data.fullName!)!

            onChosen(tz)

            _ = navigationController?.popViewController(animated: true)
        }
    }
}
