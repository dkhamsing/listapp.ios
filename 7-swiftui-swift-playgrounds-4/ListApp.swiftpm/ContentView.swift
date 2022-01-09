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
        let urlString = "https://api.tvmaze.com/shows"
        guard let url = URL(string: urlString) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
            shows = try JSONDecoder().decode([Show].self, from: data)
        } catch { }
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
