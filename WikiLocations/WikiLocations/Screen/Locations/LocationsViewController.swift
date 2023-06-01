//
//  LocationsViewController.swift
//  WikiLocations
//
//  Created by Roman Churkin on 31/05/2023.
//

import UIKit
import Combine
import CoreLocation



@MainActor
final class LocationsViewController: UICollectionViewController, TransientOverlayDisplayable {

    // MARK: - Internal types declaration

    enum Section { case main }

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Location>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Location>


    // MARK: - Private properties

    private let viewModel: LocationsViewModel
    private lazy var dataSource = makeDataSource()
    private var cancellables = Set<AnyCancellable>()

    private var loadingView: UIView? = nil
    private var errorView: UIView? = nil


    // MARK: - Initialization

    init(viewModel: LocationsViewModel) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: UICollectionViewLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupCollectionView()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchLocations()
    }


    // MARK: - UICollectionView Lifecycle

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let location = viewModel.locations[indexPath.row]
        let coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.long)

        if let url = WikiUrl(coordinate: coordinate),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}


private extension LocationsViewController {

    // MARK: - Setup helpers

    func setupCollectionView() {
        collectionView.showsVerticalScrollIndicator = false

        collectionView.register(
            LocationCell.self,
            forCellWithReuseIdentifier: "LocationCell"
        )

        setupLayout()
    }

    func setupNavigationItem() {
        title = "Locations"
        navigationItem.largeTitleDisplayMode = .always
        let showMapButton = UIBarButtonItem(
            image: UIImage(systemName: "map"),
            style: .plain,
            target: self,
            action: #selector(showMapTapped)
        )
        navigationItem.rightBarButtonItem = showMapButton
    }

    func setupBindings() {
        viewModel.$locations
            .sink { [weak self] in self?.updateDatasource(with: $0) }
            .store(in: &cancellables)

        viewModel.$isLoading
            .sink { [weak self] in
                if $0 { self?.showLoadingIndicator() }
                else { self?.hideLoadingIndicator() }
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .sink { [weak self] in
                if let errorMessage = $0 {
                    self?.showErrorView(with: errorMessage)
                } else {
                    self?.hideErrorView()
                }
            }
            .store(in: &cancellables)
    }

    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, location) -> UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "LocationCell",
                    for: indexPath
                ) as? LocationCell
                cell?.configure(with: location)
                return cell
            })

        return dataSource
    }

    func setupLayout() {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        ))
        item.contentInsets = NSDirectionalEdgeInsets.zero

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(50)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)

        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }


    // MARK: - Lifecycle helpers

    private func updateDatasource(with locations: [Location]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(locations)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func showLoadingIndicator() {
        guard loadingView == nil else { return }
        self.loadingView = LoadingCircleView()
        showOverlay(loadingView!, autoHide: false)
    }

    func hideLoadingIndicator() {
        if let loadingView = loadingView {
            hideOverlay(loadingView)
            self.loadingView = nil
        }
    }

    func showErrorView(with message: String) {
        guard errorView == nil else { return }

        let errorView = ErrorToastView()
        errorView.setErrorMessage(message)
        errorView.onRetry = { [weak self] in self?.viewModel.fetchLocations() }
        showOverlay(errorView, autoHide: false)
        self.errorView = errorView

        collectionView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: errorView.bounds.height + TransientOverlayDisplayableConstants.bottomPadding,
            right: 0
        )
    }

    func hideErrorView() {
        if let errorView = errorView {
            hideOverlay(errorView)
            self.errorView = nil

            let bottomEdge = collectionView.contentOffset.y + collectionView.frame.size.height
            if bottomEdge >= collectionView.contentSize.height {
                let offsetY = collectionView.contentOffset.y - errorView.frame.minY + self.view.safeAreaLayoutGuide.layoutFrame.maxY
                UIView.animate(withDuration: 0.3) {
                    self.collectionView.setContentOffset(
                        CGPoint(x: 0, y: offsetY),
                        animated: false
                    )
                    self.collectionView.contentInset = .zero
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.collectionView.contentInset = .zero
                }
            }
        }
    }

    @objc func showMapTapped() {
        // TODO: implement map screen
    }

}
