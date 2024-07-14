import UIKit
import Combine

class SearchTableViewController: UITableViewController {
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a stock name or symbol"
        sc.searchBar.tintColor = .white
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    var allbestMatches: [BestMatch] = []
    @Published private var searchQuery = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        observeForm()
        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
    }
    
    private func observeForm() {
        $searchQuery
            .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .sink { [unowned self] (searchQuery) in
                print("Search query: \(searchQuery)")
                guard !searchQuery.isEmpty else {
                    DispatchQueue.main.async {
                        self.allbestMatches = []
                        self.tableView.reloadData()
                    }
                    return
                }
                self.apiService.fetchStockFullName(symbol: searchQuery).sink { (completion) in
                    switch completion {
                    case .failure(let error):
                        print("API call failed: \(error.localizedDescription)")
                    case .finished: break
                    }
                } receiveValue: { (bestMatch) in
                    print("Received BestMatch: \(bestMatch)")
                    DispatchQueue.main.async {
                        self.allbestMatches = [bestMatch]
                        self.tableView.reloadData()
                    }
                }.store(in: &self.subscribers)
            }.store(in: &subscribers)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allbestMatches.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! SearchTableViewCell
        let bestMatch = allbestMatches[indexPath.row]
        cell.configure(with: bestMatch)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowStockDetail" {
            if let destinationVC = segue.destination as? StockDetailViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let selectedBestMatch = allbestMatches[indexPath.row]
                    destinationVC.stockSymbol = selectedBestMatch.symbol
                }
            }
        }
    }
    
    private func fetchStockDetails(for symbol: String, completion: @escaping (SearchResult) -> Void) {
        apiService.fetchStockDetails(symbol: symbol).sink { (completionResult) in
            switch completionResult {
            case .failure(let error):
                print("API call failed: \(error.localizedDescription)")
            case .finished: break
            }
        } receiveValue: { (result: SearchResult) in
            completion(result)
        }.store(in: &subscribers)
    }
}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            self.allbestMatches = []
            self.tableView.reloadData()
            return
        }
        self.searchQuery = query
    }
}
