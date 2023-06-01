//
//  CustomLocationViewController.swift
//  WikiLocations
//
//  Created by Roman Churkin on 01/06/2023.
//

import UIKit
import MapKit


final class CustomLocationViewController: UIViewController {

    // MARK: - Private properties

    private let mapView = MKMapView()
    private let coordinator: MainCoordinator


    // MARK: - Initialization

    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupMapView()
        setupChooseLocationGesture()
    }


    // MARK: - Private Lifecycle helpers

    private func setupNavigationBar() {
        title = "Custom location"
        navigationItem.prompt = "long tap to select"
        let appearance = navigationController?.navigationBar.standardAppearance.copy()
        navigationItem.scrollEdgeAppearance = appearance
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupChooseLocationGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPress.minimumPressDuration = 0.3
        mapView.addGestureRecognizer(longPress)
    }


    // MARK: - Private helpers

    private func addAnnotation(at point: CGPoint) {
        mapView.removeAnnotations(mapView.annotations)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        fetchTitle(for: coordinate) { annotation.title = $0 }

        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
    }

    private func fetchTitle(
        for coordinate: CLLocationCoordinate2D,
        completion: @escaping (String) -> Void
    ) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placeMarks, error) in
            let title: String
            if let placeMark = placeMarks?.first {
                title = placeMark.name ?? placeMark.locality ?? "Unknown location"
            } else {
                title = "Unknown location"
            }
            completion(title)
        }
    }


    // MARK: - Actions

    @objc private func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        addAnnotation(at: gesture.location(in: mapView))
    }

}


// MARK: - MKMapViewDelegate

extension CustomLocationViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }

    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
        guard let coordinate = view.annotation?.coordinate else { return }
        coordinator.showWiki(at: coordinate)
    }

}
