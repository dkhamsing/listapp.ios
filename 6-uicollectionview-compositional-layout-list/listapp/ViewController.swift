//
//  ViewController.swift
//  listapp
//
//  Created by Daniel on 7/3/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var collectionView: UICollectionView?
    var dataSource: UICollectionViewDiffableDataSource<Section, Show>?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "UICollectionViewComp..Layout - List - iOS 14"

        // Setup collection view
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .white

        let ds = makeDataSource(cv: cv)
        self.dataSource = ds
        cv.dataSource = ds

        // Display collection view
        cv.frame = view.bounds
        view.addSubview(cv)

        collectionView = cv

        // Load data
        let urlString = "https://api.tvmaze.com/shows"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let data = data,
                let shows = try? JSONDecoder().decode([Show].self, from: data) else { return }

            // create snapshot
            var snapshot = NSDiffableDataSourceSnapshot<Section, Show>()
            snapshot.appendSections([.main])
            snapshot.appendItems(shows, toSection: .main)
            self.dataSource?.apply(snapshot, animatingDifferences: false)

            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }.resume()
    }

    func makeDataSource(cv: UICollectionView) -> UICollectionViewDiffableDataSource<Section, Show> {
        let cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Show> = UICollectionView.CellRegistration { cell, indexPath, show in
            var config = cell.defaultContentConfiguration()
            config.text = show.name
            config.secondaryText = show.subtitle
            config.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = config
        }

        return UICollectionViewDiffableDataSource<Section, Show>(collectionView: cv) { (cv, indexPath, show) -> UICollectionViewCell? in
            cv.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: show)
        }
    }

    func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .absolute(110))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

enum Section: CaseIterable {
    case main
}

struct Show: Codable, Identifiable, Hashable {
    let id: Int
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
