import UIKit
import Messages
import SwiftUI
import SwiftData

@objc(MessagesViewController)
class MessagesViewController: MSMessagesAppViewController {
    private var hostingController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        presentMessagesView()
    }

    private func presentMessagesView() {
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()

        let schema = Schema([Conversation.self, VoiceMessage.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let container: ModelContainer
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            return
        }

        let messagesView = MessagesView()
            .modelContainer(container)

        let hosting = UIHostingController(rootView: messagesView)
        hosting.view.backgroundColor = .clear

        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hosting.didMove(toParent: self)
        hostingController = hosting
    }

}
