//
//  MainCoordinator.swift
//  WikiLocations
//
//  Created by Roman Churkin on 01/06/2023.
//

import UIKit
import CoreLocation.CLLocation


final class MainCoordinator: Coordinator {

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let locationsViewModel = LocationsViewModel(
            dependencies: DefaultLocationsViewModelDependencies()
        )

        let locationsViewController = LocationsViewController(
            coordinator: self,
            viewModel: locationsViewModel
        )
        navigationController.pushViewController(locationsViewController, animated: false)
    }

    func presentSelectCustomLocation() {
        let customLocationViewController = CustomLocationViewController(coordinator: self)
        let navigationController = UINavigationController(rootViewController: customLocationViewController)
        self.navigationController.present(navigationController, animated: true)
    }

    func showWiki(at coordinate: CLLocationCoordinate2D) {
        if let url = WikiUrl(coordinate: coordinate),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}
