//
//  MapViewController.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 11/5/2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate: AnyObject {
    func saveLocation(coordinate: CLLocationCoordinate2D)
}

class MapViewController: UIViewController, UISearchResultsUpdating, CLLocationManagerDelegate {

    let mapView = MKMapView()
    let searchVC = UISearchController(searchResultsController: MapResultViewController())
    var locationManager: CLLocationManager = CLLocationManager()
    var coordinate: CLLocationCoordinate2D?
    weak var delegate: MapViewControllerDelegate?
    var presetLocationBool: Bool = false
    weak var databaseController: DatabaseProtocol?
    var segueParent: String?


    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    @IBOutlet var longPressOutlet: UILongPressGestureRecognizer!
    
    @IBAction func saveButtonAction(_ sender: Any) {
        if self.coordinate == nil {
            self.coordinate = databaseController?.currentLocation
        }
        DispatchQueue.main.async {
            self.delegate?.saveLocation(coordinate: (self.coordinate)!)
        }
        navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        self.title = "Maps"
        let currentLocationButtonItem = MKUserTrackingBarButtonItem(mapView: mapView)
        self.navigationItem.rightBarButtonItems = [saveButtonOutlet, currentLocationButtonItem]
        self.mapView.addGestureRecognizer(self.longPressOutlet)
        view.addSubview(mapView)
        searchVC.searchBar.backgroundColor = .secondarySystemBackground
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        
        
        if self.segueParent != nil {
            if self.segueParent! == "preview" {
                self.navigationItem.searchController = .none
            }

        }
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.determineCurrentLocation()
        if self.coordinate != nil {
            self.didTapPlace(with: (self.coordinate)!)
            self.presetLocationBool = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    func determineCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let authorisationStatus = locationManager.authorizationStatus
        if authorisationStatus != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
            if locationManager.authorizationStatus == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mapView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - view.safeAreaInsets.top)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let query = searchController.searchBar.text, !query .trimmingCharacters(in: .whitespaces).isEmpty , let resultsVC = searchController.searchResultsController as? MapResultViewController else {
            return
        }
        
        resultsVC.delegate = self
        
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
    
    
    
    @IBAction func handleLongPress(_ sender: Any) {
        if presetLocationBool == false {
            let annotations = mapView.annotations
            mapView.removeAnnotations(annotations)
            
            let location = self.longPressOutlet.location(in: self.mapView)
            let coordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
            // Add annotation:
            self.didTapPlace(with: coordinate)
        }
        
        
    }


}

extension MapViewController: MapResultViewControllerDelegate {
    func didTapPlace(with coordinate: CLLocationCoordinate2D) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: true)
        // removes map pin
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        
        // Add a map pin
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        self.coordinate = coordinate
        
    }
}

