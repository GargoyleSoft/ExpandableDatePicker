//
//  ShortTimeZoneDelegate.swift
//
//  Copyright © 2016 Gargoyle Software, LLC
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
//

import UIKit

internal class ShortTimeZoneDelegate: NSObject {
    static let identifier = "FBD2F386-DB78-4A4C-8EEE-C2232E6AE50A"

    fileprivate let searchController: UISearchController
    fileprivate let onChosen: (TimeZone) -> Void
    fileprivate let navigationController: UINavigationController?

    fileprivate var tableData = TimeZone.abbreviationDictionary.keys.sorted()

    init(searchController: UISearchController, navigationController: UINavigationController?, onChosen: @escaping (TimeZone) -> Void) {
        self.searchController = searchController
        self.onChosen = onChosen
        self.navigationController = navigationController

        super.init()
    }
}

// MARK: - UITableViewDataSource
extension ShortTimeZoneDelegate: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ShortTimeZoneDelegate.identifier, for: indexPath)
        cell.textLabel!.text = tableData[indexPath.row]

        return cell
    }
}

// MARK: - UITableViewDelegate
extension ShortTimeZoneDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tz = TimeZone(abbreviation: tableData[indexPath.row])!

        onChosen(tz)

        _ = navigationController?.popViewController(animated: true)
    }
}


// MARK: - UISearchResultsUpdating
extension ShortTimeZoneDelegate : UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {

    }
}
