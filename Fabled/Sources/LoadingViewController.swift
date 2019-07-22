import UIKit
import Model

final class LoadingViewController: UIViewController, RootPresentationViewControllerDelegate {
    private let player: State<Player>

    private let image = UIImageView(image: #imageLiteral(resourceName: "fabled-alpha"))
    private let spinner = UIActivityIndicatorView(style: .white)

    override func viewDidLoad() {
        super.viewDidLoad()

        image.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.backgroundColor = .clear

        view.addSubviews(image, spinner)

        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60.0),
            image.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60.0),
            image.heightAnchor.constraint(equalTo: image.widthAnchor),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -1),
            spinner.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 8)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        spinner.startAnimating()

        Bungie.getProfile(for: player.snapshot)
            .done { self.presentationShouldTransition(to: GloryProfileViewController(profile: $0)) }
            .catch { _ in self.presentationShouldTransition(to: PlayerSearchViewController()) }
    }

    override func viewWillDisappear(_ animated: Bool) {
        spinner.stopAnimating()
        super.viewWillDisappear(animated)
    }

    init(fetching player: Player) {
        self.player = State(initialValue: player)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
