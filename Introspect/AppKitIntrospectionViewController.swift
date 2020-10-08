#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import SwiftUI
import AppKit

/// Introspection NSViewController that is inserted alongside the target view controller.
@available(macOS 10.15, *)
public class IntrospectionNSViewController: NSViewController {
    
    required init() {
        super.init(nibName: nil, bundle: nil)
        view = IntrospectionNSView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Introspection View that is injected into the UIKit hierarchy alongside the target view.
/// After `updateNSView` is called, it calls `selector` to find the target view, then `customize` when the target view is found.
@available(macOS 10.15, *)
public struct AppKitIntrospectionViewController<TargetViewControllerType: NSViewController>: NSViewControllerRepresentable {
    
//    public typealias NSViewControllerType = TargetViewControllerType
    
    /// Method that introspects the view hierarchy to find the target view.
    /// First argument is the introspection view itself, which is contained in a view host alongside the target view.
    let selector: (IntrospectionNSViewController) -> TargetViewControllerType?
    
    /// User-provided customization method for the target view.
    let customize: (TargetViewControllerType) -> Void
    
    public init(
        selector: @escaping (NSViewController) -> TargetViewControllerType?,
        customize: @escaping (TargetViewControllerType) -> Void
    ) {
        self.selector = selector
        self.customize = customize
    }
    
    public func makeNSViewController(context: Context) -> some NSViewController {
        let viewController = IntrospectionNSViewController()
        viewController.view.setAccessibilityLabel("IntrospectionNSView<\(TargetViewControllerType.self)>")
        return viewController
    }

    public func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        DispatchQueue.main.async {
            guard let controller = nsViewController as? IntrospectionNSViewController, let targetView = self.selector(controller) else {
                return
            }
            self.customize(targetView)
        }
    }
}
#endif

