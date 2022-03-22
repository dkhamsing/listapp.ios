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
            .navigationBarTitle("SwiftUI - iOS 15", displayMode: .inline)
            .task {
                await loadData()
            }
            .refreshable {
                await loadData()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    @MainActor
    func loadData() async {
        guard let url = URL(string: "https://api.tvmaze.com/shows"),
              let (data, _) = try? await URLSession.shared.data(for: URLRequest(url: url)),
              let shows = try? JSONDecoder().decode([Show].self, from: data) else { return }
        self.shows = shows
    }
}

struct Show: Codable, Identifiable {
    let id: Int
    let name, status, premiered, summary: String
}

extension Show {
    var subtitle: String {
        premiered + "\n" + status + summary
            .replacingOccurrences(of: "<p>", with: "\n")
            .replacingOccurrences(of: "</p>", with: "\n")
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "</b>", with: "")
    }
}
