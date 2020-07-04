//
//  ViewController.swift
//  listapp
//
//  Created by Daniel on 7/3/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let tableView = UITableView()
    var dataSource: [Show] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "UITableView - iOS 2 - Swift"

        // Setup table view
        tableView.register(ShowCell.self, forCellReuseIdentifier: ShowCell.reuseIdentifier)
        tableView.dataSource = self

        // Display table view
        tableView.frame = view.bounds
        view.addSubview(tableView)

        // Load data
        let urlString = "https://api.tvmaze.com/shows"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let data = data,
                let shows = try? JSONDecoder().decode([Show].self, from: data) else { return }

            self.dataSource = shows

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.resume()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShowCell.reuseIdentifier) as? ShowCell else { fatalError("Cannot create new cell") }

        let show = dataSource[indexPath.row]
        cell.textLabel?.text = show.name
        cell.detailTextLabel?.text = show.subtitle

        return cell
    }
}

class ShowCell: UITableViewCell {
    static let reuseIdentifier = "ShowCell"

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        setup()
    }

    func setup() {
        detailTextLabel?.numberOfLines = 4
        detailTextLabel?.textColor = .secondaryLabel
    }
}

struct Show: Codable {
    let name, status, premiered, summary: String
}

extension Show {
    var subtitle: String {
        return premiered + "\n" + status + summary
            .replacingOccurrences(of: "<p>", with: "\n")
            .replacingOccurrences(of: "</p>", with: "\n")
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "</b>", with: "")
    }
}
