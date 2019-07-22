//
//  Layout.swift
//  BindableViews
//
//  Created by Nathan Hosselton on 7/3/19.
//  Copyright © 2019 Nathan Hosselton. All rights reserved.
//

import UIKit.UIViewController

protocol DeclarativeViewProviding: UIViewController {
    var layout: Layout { get }
}

class DeclarativeViewController: UIViewController, DeclarativeViewProviding {
    var layout: Layout {
        fatalError("computed property `\(#function)` must be overridden by the subclass")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layout.activate()
        _view = view
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // If the view no longer has a window then this controller was dismissed.
        guard _view?.window == .none else { return }

        // Since `BindableControl`s create retain cycles with their controllers when
        // `self` is passed into their event observers, we need to ensure that the view
        // hierarchy is released when the controller is released, breaking the cycle.
        //
        // In the unlikely event that this controller is again presented, the view
        // will be automatically recreated and configured when the window asks for it.
        func removeFromSuperview(_ view: UIView) {
            view.subviews.forEach(removeFromSuperview)
            view.removeFromSuperview()
        }
        _view?.subviews.forEach(removeFromSuperview)
    }

    /// Weak reference to the view so we don't inadvertently kickoff `loadView()` by accessing
    /// `self.view` at the end of the view lifecycle (probably wouldn't happen).
    private weak var _view: UIView?
}


class Layout {
    private let view: UIView
    private var constraints: [NSLayoutConstraint] = []

    init(in superview: UIView, _ view: UIView) {
        self.view = view

        view.removeFromSuperview()
        superview.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Pins to superview's margins
    func pinned(_ edges: [Edge] = Edge.allCases, padding length: CGFloat = 0.0) -> Layout {
        constraints.append(contentsOf: edges.map {
            NSLayoutConstraint(item: view, attribute: $0.firstAttribute, relatedBy: .equal, toItem: view.superview, attribute: $0.secondAttribute, multiplier: 1.0, constant: $0.absolute(length))
        })
        return self
    }

    /// Pins to superview's margins
    func pinned(_ edges: [Edge] = Edge.allCases, minimumPadding length: CGFloat) -> Layout {
        constraints.append(contentsOf: edges.map { edge in
            return NSLayoutConstraint(item: view, attribute: edge.firstAttribute, relatedBy: edge.variableRelationship, toItem: view.superview, attribute: edge.secondAttribute, multiplier: 1.0, constant: edge.absolute(length))
        })
        return self
    }

    /// Pins to superview's edges
    func pinnedToEdges(_ edges: [Edge] = Edge.allCases, padding length: CGFloat = 0.0) -> Layout {
        constraints.append(contentsOf: edges.map {
            NSLayoutConstraint(item: view, attribute: $0.firstAttribute, relatedBy: .equal, toItem: view.superview, attribute: $0.firstAttribute, multiplier: 1.0, constant: $0.absolute(length))
        })
        return self
    }

    /// Pins to  superview's edges
    func pinnedToEdges(_ edges: [Edge] = Edge.allCases, minimumPadding length: CGFloat) -> Layout {
        constraints.append(contentsOf: edges.map { edge in
            return NSLayoutConstraint(item: view, attribute: edge.firstAttribute, relatedBy: edge.variableRelationship, toItem: view.superview, attribute: edge.firstAttribute, multiplier: 1.0, constant: edge.absolute(length))
        })
        return self
    }

    func centered() -> Layout {
        constraints.append(view.centerXAnchor.constraint(equalTo: view.superview!.layoutMarginsGuide.centerXAnchor))
        constraints.append(view.centerYAnchor.constraint(equalTo: view.superview!.layoutMarginsGuide.centerYAnchor))
        return self
    }

    func centered(_ axis: NSLayoutConstraint.Axis) -> Layout {
        switch axis {
        case .horizontal:
            constraints.append(view.centerXAnchor.constraint(equalTo: view.superview!.layoutMarginsGuide.centerXAnchor))
        case .vertical:
            constraints.append(view.centerYAnchor.constraint(equalTo: view.superview!.layoutMarginsGuide.centerYAnchor))
        @unknown default:
            return centered()
        }

        return self
    }

    func equalWidths() -> Layout {
        constraints.append(view.widthAnchor.constraint(equalTo: view.superview!.widthAnchor))
        return self
    }

    func equalHeights() -> Layout {
        constraints.append(view.heightAnchor.constraint(equalTo: view.superview!.heightAnchor))
        return self
    }

    fileprivate func activate() {
        NSLayoutConstraint.activate(constraints)
    }

    enum Edge: CaseIterable {
        case top, trailing, bottom, leading

        var firstAttribute: NSLayoutConstraint.Attribute {
            switch self {
            case .top: return .top
            case .trailing: return .trailing
            case .bottom: return .bottom
            case .leading: return .leading
            }
        }

        var variableRelationship: NSLayoutConstraint.Relation {
            switch self {
            case .leading, .top: return .greaterThanOrEqual
            case .trailing, .bottom: return .lessThanOrEqual
            }
        }

        var secondAttribute: NSLayoutConstraint.Attribute {
            switch self {
            case .top: return .topMargin
            case .trailing: return .trailingMargin
            case .bottom: return .bottomMargin
            case .leading: return .leadingMargin
            }
        }

        func absolute(_ length: CGFloat) -> CGFloat {
            switch self {
            case .leading, .top: return length
            case .trailing, .bottom: return -length
            }
        }
    }
}
