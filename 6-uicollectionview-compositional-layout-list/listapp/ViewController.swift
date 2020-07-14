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
        let cellRegistration: UICollectionView.CellRegistration<ShowCell, Show> = UICollectionView.CellRegistration { cell, indexPath, show in
            cell.titleLabel.text = show.name
            cell.subtitleLabel.text = show.subtitle
        }

        return UICollectionViewDiffableDataSource<Section, Show>(collectionView: cv) { (cv, indexPath, show) -> UICollectionViewCell? in
            cv.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: show)
        }
    }

    func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)

            return section
        }
    }
}

class ShowCell: UICollectionViewCell {
    static let reuseIdentifier = "ShowCell"

    let titleLabel = UILabel ()
    let subtitleLabel = UILabel ()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    func setup() {
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .preferredFont(forTextStyle: .caption1)
        subtitleLabel.numberOfLines = 4
        subtitleLabel.textColor = .secondaryLabel

        [titleLabel, subtitleLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let inset: CGFloat = 20
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
        ])
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
