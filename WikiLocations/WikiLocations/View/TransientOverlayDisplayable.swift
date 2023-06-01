//
//  TransientOverlayDisplayable.swift
//  WikiLocations
//
//  Created by Roman Churkin on 31/05/2023.
//

import UIKit


enum TransientOverlayDisplayableConstants {
    static let bottomPadding: CGFloat = 8
}


protocol TransientOverlayDisplayable: UIViewController {
    func showOverlay(_ view: UIView, autoHide: Bool)
    func hideOverlay(_ view: UIView)
}


extension TransientOverlayDisplayable {

    func showOverlay(_ view: UIView, autoHide: Bool) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -4),
        ])

        view.layoutIfNeeded()

        let safeAreaPadding = self.view.bounds.height - self.view.safeAreaLayoutGuide.layoutFrame.maxY
        let translationY = view.bounds.height + safeAreaPadding + TransientOverlayDisplayableConstants.bottomPadding

        view.transform = CGAffineTransform(
            translationX: 0,
            y: translationY
        )

        UIView.animate(withDuration: 0.4) { view.transform = .identity }

        if autoHide {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.hideOverlay(view)
            }
        }
    }

    func hideOverlay(_ view: UIView) {
        UIView.animate(
            withDuration: 0.4,
            animations: { view.alpha = 0 },
            completion: { _ in view.removeFromSuperview() }
        )
    }

}


