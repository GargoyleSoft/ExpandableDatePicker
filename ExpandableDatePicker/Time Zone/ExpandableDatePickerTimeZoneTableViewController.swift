//
//  ExpandableDatePickerTimeZoneTableViewController.swift
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

public class ExpandableDatePickerTimeZoneTableViewController : UITableViewController {
    fileprivate var onChosen: ((TimeZone) -> Void)!
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var longTimeZoneDelegate: LongTimeZoneDelegate?

    public init(onTimeZoneChosen: @escaping (TimeZone) -> Void) {
        self.onChosen = onTimeZoneChosen

        super.init(style: .plain)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let segment = UISegmentedControl(items: [
            NSLocalizedString("Full", comment: "Segment title for displaying full timezone names."),
            NSLocalizedString("Abbrev", comment: "Segment title for displaying abbreviated timezone names.")
            ])
        segment.sizeToFit()
        segment.selectedSegmentIndex = 0

        navigationItem.titleView = segment

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: LongTimeZoneDelegate.identifier)

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false

        definesPresentationContext = true

        tableView.tableHeaderView = searchController.searchBar

        longTimeZoneDelegate = LongTimeZoneDelegate(searchController: searchController, navigationController: navigationController, onChosen: onChosen)
        tableView.dataSource = longTimeZoneDelegate
        tableView.delegate = longTimeZoneDelegate
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UISearchResultsUpdating
extension ExpandableDatePickerTimeZoneTableViewController : UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {

    }
}