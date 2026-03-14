import UIKit

final class DialogHandler: AsyncHandler {
    let namespace = "dialog"

    var onAsyncCallback: ((String, Any?) -> Void)?

    func handle(method: String, args: [String: Any]) -> Any? {
        switch method {
        case "alert":
            let ref = args["_callbackRef"] as? String
            let title = args["title"] as? String ?? ""
            let message = args["message"] as? String ?? ""
            let buttonText = args["button"] as? String ?? "OK"

            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: buttonText, style: .default) { _ in
                    self.onAsyncCallback?(ref ?? "", ["dismissed": true])
                })
                self.present(alert)
            }
            return ["status": "presenting"]

        case "confirm":
            let ref = args["_callbackRef"] as? String
            let title = args["title"] as? String ?? ""
            let message = args["message"] as? String ?? ""
            let confirmText = args["confirmText"] as? String ?? "OK"
            let cancelText = args["cancelText"] as? String ?? "Cancel"
            let destructive = args["destructive"] as? Bool ?? false

            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: cancelText, style: .cancel) { _ in
                    self.onAsyncCallback?(ref ?? "", ["confirmed": false])
                })
                alert.addAction(UIAlertAction(title: confirmText, style: destructive ? .destructive : .default) { _ in
                    self.onAsyncCallback?(ref ?? "", ["confirmed": true])
                })
                self.present(alert)
            }
            return ["status": "presenting"]

        case "prompt":
            let ref = args["_callbackRef"] as? String
            let title = args["title"] as? String ?? ""
            let message = args["message"] as? String ?? ""
            let placeholder = args["placeholder"] as? String ?? ""
            let defaultValue = args["defaultValue"] as? String ?? ""
            let confirmText = args["confirmText"] as? String ?? "OK"
            let cancelText = args["cancelText"] as? String ?? "Cancel"

            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addTextField { field in
                    field.placeholder = placeholder
                    field.text = defaultValue
                }
                alert.addAction(UIAlertAction(title: cancelText, style: .cancel) { _ in
                    self.onAsyncCallback?(ref ?? "", ["cancelled": true])
                })
                alert.addAction(UIAlertAction(title: confirmText, style: .default) { _ in
                    let text = alert.textFields?.first?.text ?? ""
                    self.onAsyncCallback?(ref ?? "", ["value": text])
                })
                self.present(alert)
            }
            return ["status": "presenting"]

        case "actionSheet":
            let ref = args["_callbackRef"] as? String
            let title = args["title"] as? String
            let message = args["message"] as? String
            let options = args["options"] as? [String] ?? []
            let destructiveIndex = args["destructiveIndex"] as? Int
            let cancelText = args["cancelText"] as? String ?? "Cancel"

            DispatchQueue.main.async {
                let sheet = UIAlertController(
                    title: title,
                    message: message,
                    preferredStyle: .actionSheet
                )
                for (index, option) in options.enumerated() {
                    let style: UIAlertAction.Style = (index == destructiveIndex) ? .destructive : .default
                    sheet.addAction(UIAlertAction(title: option, style: style) { _ in
                        self.onAsyncCallback?(ref ?? "", ["index": index, "value": option])
                    })
                }
                sheet.addAction(UIAlertAction(title: cancelText, style: .cancel) { _ in
                    self.onAsyncCallback?(ref ?? "", ["cancelled": true])
                })
                self.present(sheet)
            }
            return ["status": "presenting"]

        default:
            return ["error": "Unknown method: \(method)"]
        }
    }

    private func present(_ controller: UIAlertController) {
        guard let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController else { return }

        var presenter: UIViewController = topVC
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        presenter.present(controller, animated: true)
    }
}
