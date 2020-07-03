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

        title = "Diffable Data Source - iOS 13"

        // Setup collection view
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .white
        cv.register(ShowCell.self, forCellWithReuseIdentifier: ShowCell.reuseIdentifier)

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
        return UICollectionViewDiffableDataSource<Section, Show>(collectionView: cv) { (cview, indexPath, show) -> UICollectionViewCell? in
            guard let cell = cv.dequeueReusableCell(withReuseIdentifier: ShowCell.reuseIdentifier, for: indexPath) as? ShowCell else { fatalError("Cannot create new cell") }

            cell.titleLabel.text = show.name
            cell.subtitleLabel.text = show.subtitle

            return cell
        }
    }

    func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .absolute(210/2))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
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
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
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
