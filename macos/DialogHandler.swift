import AppKit

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
                let alert = NSAlert()
                alert.messageText = title
                alert.informativeText = message
                alert.addButton(withTitle: buttonText)
                alert.alertStyle = .informational
                alert.runModal()
                self.onAsyncCallback?(ref ?? "", ["dismissed": true])
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
                let alert = NSAlert()
                alert.messageText = title
                alert.informativeText = message
                alert.alertStyle = destructive ? .critical : .informational
                alert.addButton(withTitle: confirmText)
                alert.addButton(withTitle: cancelText)
                let response = alert.runModal()
                let confirmed = response == .alertFirstButtonReturn
                self.onAsyncCallback?(ref ?? "", ["confirmed": confirmed])
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
                let alert = NSAlert()
                alert.messageText = title
                alert.informativeText = message
                alert.addButton(withTitle: confirmText)
                alert.addButton(withTitle: cancelText)

                let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
                input.placeholderString = placeholder
                input.stringValue = defaultValue
                alert.accessoryView = input
                alert.window.initialFirstResponder = input

                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    self.onAsyncCallback?(ref ?? "", ["value": input.stringValue])
                } else {
                    self.onAsyncCallback?(ref ?? "", ["cancelled": true])
                }
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
                // macOS: action sheets become alerts with multiple buttons
                let alert = NSAlert()
                alert.messageText = title ?? ""
                alert.informativeText = message ?? ""
                alert.alertStyle = .informational

                for (index, option) in options.enumerated() {
                    let button = alert.addButton(withTitle: option)
                    if index == destructiveIndex {
                        button.hasDestructiveAction = true
                    }
                }
                alert.addButton(withTitle: cancelText)

                let response = alert.runModal()
                let buttonIndex = response.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue

                if buttonIndex < options.count {
                    self.onAsyncCallback?(ref ?? "", ["index": buttonIndex, "value": options[buttonIndex]])
                } else {
                    self.onAsyncCallback?(ref ?? "", ["cancelled": true])
                }
            }
            return ["status": "presenting"]

        default:
            return ["error": "Unknown method: \(method)"]
        }
    }
}
