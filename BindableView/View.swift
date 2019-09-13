//
//  View.swift
//  BindableViews
//
//  Created by Nathan Hosselton on 8/23/19.
//  Copyright © 2019 Nathan Hosselton. All rights reserved.
//

import UIKit.UIView

/// A generic `DeclarativeView` which can be used to wrap and manage other `UIView` objects.
///
/// Use this for simple `UIView` types such as `UIImageView` rather than subclassing and
/// conforming to `DeclarativeView`.
class View: UIView, DeclarativeView {

    /// Initializes a new view with the provided subview constrained to all sides and using the
    /// optional margin value.
    /// - Parameters:
    ///     - subview: The view to add as a subview of this view. Omitting returns an empty view.
    ///     - margin: The margin of empty space to use between the subview and this view.
    init(_ subview: UIView? = nil, margin: CGFloat = 0.0) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        guard let subview = subview else { return }

        subview.translatesAutoresizingMaskIntoConstraints = false

        addSubview(subview)

        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin)
        ])
    }

    func styleProvider(_ provider: (UIView) -> Void) -> Self {
        provider(self)
        return self
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
