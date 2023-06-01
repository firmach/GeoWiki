//
//  LoadingCircleView.swift
//  WikiLocations
//
//  Created by Roman Churkin on 31/05/2023.
//

import UIKit


final class LoadingCircleView: UIView {

    // MARK: - Private properties

    private let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 4
        return view
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        return indicator
    }()


    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - UIView

    override func layoutSubviews() {
        super.layoutSubviews()
        circleView.layer.cornerRadius = circleView.bounds.height / 2
    }


    // MARK: - Private methods

    private func setupView() {
        addSubview(circleView)
        circleView.addSubview(loadingIndicator)

        circleView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            circleView.topAnchor.constraint(equalTo: topAnchor),
            circleView.bottomAnchor.constraint(equalTo: bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            loadingIndicator.leadingAnchor.constraint(equalTo: circleView.leadingAnchor, constant: 8),
            loadingIndicator.topAnchor.constraint(equalTo: circleView.topAnchor, constant: 8)
        ])
    }

}
