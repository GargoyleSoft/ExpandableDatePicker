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

internal class ShortTimeZoneCellData: NSObject {
    let abbrev: String
    let full: String

    init(abbrev: String, full: String) {
        self.abbrev = abbrev
        self.full = full

        super.init()
    }

    func displayName() -> String {
        return "\(abbrev) (\(full))"
    }
}

internal class ShortTimeZoneDelegate: NSObject {
    static let identifier = "FBD2F386-DB78-4A4C-8EEE-C2232E6AE50A"

    fileprivate let searchController: UISearchController
    fileprivate let onChosen: (TimeZone) -> Void
    fileprivate let navigationController: UINavigationController?
    fileprivate let collation = UILocalizedIndexedCollation.current()
    fileprivate let tableView: UITableView

    fileprivate var tableData: [[ShortTimeZoneCellData]]!
    fileprivate var filteredTableData: [ShortTimeZoneCellData] = []

    var sectionTitles: [String] = []
    var sectionTitleToSectionNumber: [String : Int] = [:]

    init(tableView: UITableView, searchController: UISearchController, navigationController: UINavigationController?, onChosen: @escaping (TimeZone) -> Void) {
        self.searchController = searchController
        self.onChosen = onChosen
        self.navigationController = navigationController
        self.tableView = tableView

        super.init()

        buildTableData()
    }

    private func buildTableData() {
        let dict = TimeZone.abbreviationDictionary

        // First we have to put everything into the proper section
        var sections = [[ShortTimeZoneCellData]](repeating: [], count: collation.sectionTitles.count)

        for abbrev in dict.keys.sorted() {
            let data = ShortTimeZoneCellData(abbrev: abbrev, full: dict[abbrev]!)

            let sectionNumber = collation.section(for: data, collationStringSelector: #selector(ShortTimeZoneCellData.displayName))

            sections[sectionNumber].append(data)
        }

        // Then we want to go through and only keep sections that have items.  To do that we have
        // to have a "section title to new section index" value stored.
        var sectionsWithData: [[ShortTimeZoneCellData]] = []

        for (sectionNumber, sections) in sections.enumerated() {
            let title = collation.sectionTitles[sectionNumber]

            if sections.isEmpty == false {
                sectionTitles.append(title)
                sectionsWithData.append(sections)
            }

            sectionTitleToSectionNumber[title] = max(sectionsWithData.count - 1, 0)
        }

        tableData = sectionsWithData
    }

    fileprivate var usingSearch: Bool {
        return searchController.isActive
    }
}

// MARK: - UITableViewDataSource
extension ShortTimeZoneDelegate: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return usingSearch ? 1 : tableData.count
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return usingSearch ? nil : [UITableViewIndexSearch] + collation.sectionIndexTitles
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ShortTimeZoneDelegate.identifier, for: indexPath)

        let data = usingSearch ? filteredTableData[indexPath.row] : tableData[indexPath.section][indexPath.row]
        cell.textLabel!.text = data.displayName()

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usingSearch ? filteredTableData.count : tableData[section].count
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if index == 0 {
            let searchBarFrame = searchController.searchBar.frame
            tableView.scrollRectToVisible(searchBarFrame, animated: true)

            return NSNotFound
        }

        return sectionTitleToSectionNumber[title]!
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return usingSearch ? nil : sectionTitles[section]
    }
}

// MARK: - UITableViewDelegate
extension ShortTimeZoneDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = usingSearch ? filteredTableData[indexPath.row] : tableData[indexPath.section][indexPath.row]
        let tz = TimeZone(abbreviation: data.abbrev)!

        onChosen(tz)

        _ = navigationController?.popViewController(animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension ShortTimeZoneDelegate : UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        defer { tableView.reloadData() }

        guard let text = searchController.searchBar.text?.localizedLowercase, !text.isEmpty else {
            filteredTableData = tableData.flatMap { $0 }
            return
        }

        filteredTableData = tableData.flatMap { $0 }.filter { $0.abbrev.localizedLowercase.contains(text) }
    }
}
