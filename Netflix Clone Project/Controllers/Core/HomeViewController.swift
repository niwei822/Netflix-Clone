//
//  HomeViewController.swift
//  Netflix Clone Project
//
//  Created by cecily li on 4/6/23.
//

import UIKit

enum Sections: Int {
    case TrendingMovies = 0
    case TrendingTv = 1
    case Popular = 2
    case Upcoming = 3
    case TopRated = 4
}

class HomeViewController: UIViewController {
    
    private var titles:[Movie] = []
    private var randomMovie: Movie?
    private var headerView: HeroHeaderUIView?
    
    let sectionTitles: [String] = ["Trending Movies", "Trending TV", "Popular", "Upcoming Moives", "Top rated"]
    
    //use closure to create instance of tableview
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        //registers a cell class for use in creating new table cells
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return table
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(homeFeedTable)
        //view controller will handle events and provide data for the table view
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        
        configureNavbar()
        configureHeader()
        
        headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 500))
        homeFeedTable.tableHeaderView = headerView
        headerView?.delegate = self
       
    }
    
    private func configureHeader() {
        APICaller.shared.getTrendingMovies { [weak self] result in
            switch result {
            case .success(let titles):
                let selectTitle = titles.randomElement()
                self?.randomMovie = selectTitle
                self?.headerView?.configure(with: TitleViewModel(titleName: selectTitle?.original_title ?? "", posterURL: selectTitle?.poster_path ?? ""))
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
    }
    
    private func configureNavbar() {
        var image = UIImage(named: "netflix-logo")
        //display an image as-is
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil)
        ]
        navigationController?.navigationBar.tintColor = .white
        
    }
    //called when the view's bounds change
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //view.bounds let table view takes up the entire screen
        homeFeedTable.frame = view.bounds
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //returns a reusable table view cell for the given index path
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        switch indexPath.section {
            //case 0
        case Sections.TrendingMovies.rawValue:
            APICaller.shared.getTrendingMovies { result in
                switch result {
                case .success(let movies):
                    cell.configure(with: movies)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.TrendingTv.rawValue:
            APICaller.shared.getTrendingTv { result in
                switch result {
                case .success(let tvs):
                    cell.configure(with: tvs)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.Popular.rawValue:
            APICaller.shared.getPopular { result in
                switch result {
                case .success(let movies):
                    cell.configure(with: movies)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.Upcoming.rawValue:
            APICaller.shared.getUpcomingMovies { result in
                switch result {
                case .success(let movies):
                    cell.configure(with: movies)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.TopRated.rawValue:
            APICaller.shared.getTopRated { result in
                switch result {
                case .success(let movies):
                    cell.configure(with: movies)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        default:
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    //display each section title
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {return}
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .white
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    //to custom navigation bar where the bar hides when the user scrolls down and becomes visible when they scroll up
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultoffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultoffset
        //navigation bar will only move up (i.e., become hidden)
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.name else {
            return
        }
        //The use of [weak self] means that self is an optional because it could have been deallocated by the time the closure is executed. By using self?, the code safely unwraps the optional, and ensures that the closure doesn't try to access a deallocated instance of CollectionViewTableViewCell.
        APICaller.shared.getMovie(with: titleName + "trailer") { [weak self] result in
            switch result {
            case .success(let videoElement):
                DispatchQueue.main.async {
                    let vc = TitlePreviewViewController()
                    vc.configure(with: TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: title.overview ?? ""))
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
//step2--passing in the TitlePreviewViewModel
//objectis called when the user taps on a movie or TV show poster in the collection view. When this happens, the HomeViewController creates a TitlePreviewViewController and configures it with the selected movie or TV show's data.
extension HomeViewController: CollectionViewTableViewCellDelegate, HeroHeaderUIViewDelegate {
    func HeroHeaderUIViewldidTapPlayButton() {
       // print("&&&&&&&&")
        guard let titleName = randomMovie?.original_title ?? randomMovie?.name else {
            return
        }
        //The use of [weak self] means that self is an optional because it could have been deallocated by the time the closure is executed. By using self?, the code safely unwraps the optional, and ensures that the closure doesn't try to access a deallocated instance of CollectionViewTableViewCell.
        APICaller.shared.getMovie(with: titleName + "trailer") { [weak self] result in
            switch result {
            case .success(let videoElement):
                DispatchQueue.main.async { [self] in
                    let vc = TitlePreviewViewController()
                    vc.configure(with: TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: self?.randomMovie?.overview ?? ""))
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    
    

  
    func collectionViewTableViewCelldidTapCell(_ cell: CollectionViewTableViewCell, viewModel: TitlePreviewViewModel) {
        //ensures that this operation is performed on the main thread for UI updates
        DispatchQueue.main.async { [weak self] in
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
