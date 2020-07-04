//
//  ContentView.swift
//  listapp
//
//  Created by Daniel on 7/3/20.
//  Copyright © 2020 dk. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var shows: [Show] = []

    var body: some View {
        NavigationView {
            List(shows) { show in
                VStack(alignment: .leading) {
                    Text(show.name)
                    Text(show.subtitle)
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .lineLimit(4)
                }
            }
            .navigationBarTitle("SwiftUI - iOS 13", displayMode: .inline)
            .onAppear {
                self.loadData()
            }
        }
    }

    func loadData() {
        let urlString = "https://api.tvmaze.com/shows"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let data = data,
                let shows = try? JSONDecoder().decode([Show].self, from: data) else { return }

            DispatchQueue.main.async {
                self.shows = shows
            }
        }.resume()
    }
}

struct Show: Codable, Identifiable {
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
