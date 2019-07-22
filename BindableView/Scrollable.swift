//
//  Scrollable.swift
//  BindableViews
//
//  Created by Nathan Hosselton on 8/23/19.
//  Copyright © 2019 Nathan Hosselton. All rights reserved.
//

import UIKit.UIScrollView

/// A declarative interface for a  `UIScrollView` which takes a single `StackView` for its content.
final class Scrollable: UIScrollView, DeclarativeView {

    /// Creates a scrollable `StackView`. Assumes the scroll direction matches the stack view's axis if
    /// not specified.
    init(_ direction: NSLayoutConstraint.Axis? = nil, contentView: StackView) {
        super.init(frame: .zero)

        addSubview(contentView)
        translatesAutoresizingMaskIntoConstraints = false

        let direction = direction ?? contentView.axis
        switch direction {
        case .vertical:
            contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            showsHorizontalScrollIndicator = false
        case .horizontal:
            contentView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            showsVerticalScrollIndicator = false
        @unknown default: break
        }

        NSLayoutConstraint.activate([
          contentView.topAnchor.constraint(equalTo: topAnchor),
          contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
          contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
          contentView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }

    /// Sets the indicator style of the scroll view.
    func indicatorStyle(_ style: UIScrollView.IndicatorStyle) -> Self {
        indicatorStyle = style
        return self
    }

    func styleProvider(_ provider: (_ stylable: UIScrollView) -> Void) -> Self {
        provider(self)
        return self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder = .empty) {
        fatalError("init(coder:) has not been implemented")
    }
}
