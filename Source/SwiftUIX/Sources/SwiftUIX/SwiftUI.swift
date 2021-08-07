//#if canImport(SwiftUI)

import UIKit
import SwiftUI
import CoreRender

/*extension Context {
  /// The context used for SwiftUI bridged views.
  public static let swiftUISharedContext = SCLContext()
}*/

@available(iOS 13.0, *)
public struct CoreRenderBridgeView<Content>: SwiftUI.UIViewRepresentable where Content: View {
  /// The node hiearchy.
  public let nodeHierarchy: SCLNodeHierarchy<Content>

  public init(_ nodeHierarchy: SCLNodeHierarchy<Content>) {
    self.nodeHierarchy = nodeHierarchy
  }

  /// Creates a `UIView` instance to be presented.
  public func makeUIView(context: SwiftUI.UIViewRepresentableContext<CoreRenderBridgeView>) -> SCLHostingView {
    let hostingView=SCLHostingView(with:[],hierarchy:nodeHierarchy)
    return hostingView
  }

  /// Updates the presented `UIView` (and coordinator) to the latest configuration.
  public func updateUIView(
    _ uiView: SCLHostingView,
    context: SwiftUI.UIViewRepresentableContext<CoreRenderBridgeView>
  ) -> Void {
    uiView.setNeedsReconcile()
    //uiView.setNeedsBuild()
  } 
}

// MARK: - Auxiliary Implementation -
/*extension EnvironmentBuilder {
    struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static let defaultValue = EnvironmentBuilder()
    }
}
*/

//#endif