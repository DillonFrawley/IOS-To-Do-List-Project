//
//  MapViewController.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 11/5/2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController, UISearchResultsUpdating {

    let mapView = MKMapView()
    let searchVC = UISearchController(searchResultsController: MapResultViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Maps"
        view.addSubview(mapView)
        searchVC.searchBar.backgroundColor = .secondarySystemBackground
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mapView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - view.safeAreaInsets.top)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let query = searchController.searchBar.text, !query .trimmingCharacters(in: .whitespaces).isEmpty , let resultsVC = searchController.searchResultsController as? MapResultViewController else {
            return
        }
        
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
