//
//  ErrorToastView.swift
//  WikiLocations
//
//  Created by Roman Churkin on 31/05/2023.
//

import UIKit


final class ErrorToastView: UIView {

    // MARK: - Public properties

    var onRetry: (() -> Void)?


    // MARK: - Private properties

    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let retryButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Try again"
        configuration.baseBackgroundColor = .white
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.foregroundColor = .systemOrange
            outgoing.font = .preferredFont(forTextStyle: .caption1)
            return outgoing
        }

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configurationUpdateHandler = { button in
            var config = button.configuration
            if button.isHighlighted || button.isSelected {
                config?.baseBackgroundColor = UIColor.white.withAlphaComponent(0.5)
            } else {
                config?.baseBackgroundColor = .white
            }
            button.configuration = config
        }

        return button
    }()


    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Private methods

    private func setupView() {
        backgroundColor = .systemOrange
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 4

        addSubview(iconImageView)
        addSubview(errorMessageLabel)
        addSubview(retryButton)

        retryButton.addTarget(self, action: #selector(tryAgainTapped), for: .touchUpInside)
        retryButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),

            errorMessageLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            errorMessageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            errorMessageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            retryButton.leadingAnchor.constraint(equalTo: errorMessageLabel.trailingAnchor, constant: 8),
            retryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            retryButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            retryButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8),
        ])
    }

    @objc private func tryAgainTapped() { onRetry?() }


    // MARK: - Public methods

    func setErrorMessage(_ message: String) { errorMessageLabel.text = message }

}
