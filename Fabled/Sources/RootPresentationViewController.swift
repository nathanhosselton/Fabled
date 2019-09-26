import UIKit
import Model
import PMKFoundation

protocol RootPresentationViewControllerDelegate: UIViewController {
    func presentationShouldTransition(to next: UIViewController)
    func presentationShouldDisplayAlert(for error: Swift.Error)
}

extension RootPresentationViewControllerDelegate {
    func presentationShouldTransition(to next: UIViewController) {
        guard let presentationVC = parent as? RootPresentationViewController,
                  presentationVC.children.contains(self)
            else { return }

        presentationVC.transition(from: self, to: next)
    }

    func presentationShouldDisplayAlert(for error: Swift.Error) {
        guard let presentationVC = parent as? RootPresentationViewController else { return }
        presentationVC.displayAlert(for: error)
    }
}

final class RootPresentationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG && UIPREVIEW
        display(DebugUIViewController())
        #else
        if let cachedPlayer = UserDefaults.fabled().lastPlayerSearchResult {
            display(LoadingViewController(fetching: cachedPlayer))
        } else {
            display(PlayerSearchViewController())
        }
        #endif
    }

    fileprivate func transition(from current: UIViewController?, to next: UIViewController) {
        guard let current = current else { return display(next) }

        current.willMove(toParent: nil)
        addChild(next)

        view.removeConstraints(view.constraints)

        transition(from: current, to: next, duration: 0.5, options: [.transitionCrossDissolve, .curveEaseInOut], animations: {
            NSLayoutConstraint.activate(self.pin(next.view))
        }, completion: { finished in
            guard finished else { return }
            current.removeFromParent()
            next.didMove(toParent: self)
        })
    }

    fileprivate func displayAlert(for error: Swift.Error) {
        let displayError: PresentableError

        switch error {
        case is Fabled.Error:
            displayError = error as! Fabled.Error
        case is Bungie.Error:
            displayError = error as! Bungie.Error
        case is DecodingError:
            displayError = Fabled.Error.modelDecodingFailed
        case is PMKHTTPError:
            displayError = Fabled.Error.badHTTPResponse
        default:
            displayError = Fabled.Error.genericUserFacing
        }

        present(displayError.alert(), animated: true)
    }

    private func display(_ vc: UIViewController) {
        addChild(vc)

        view.removeConstraints(view.constraints)
        view.subviews.forEach { $0.removeFromSuperview() }

        view.addSubview(vc.view)

        NSLayoutConstraint.activate(pin(vc.view))

        vc.didMove(toParent: self)
    }

    private func pin(_ view: UIView) -> [NSLayoutConstraint] {
        view.preservesSuperviewLayoutMargins = true

        return [
            view.topAnchor.constraint(equalTo: self.view.topAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        ]
    }
}
