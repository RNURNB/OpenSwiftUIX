import Foundation
import UIKit
import CoreRender

// MARK: - Props
public protocol AnyProp {
  /// Setup the coordinator with the given prop.
  func apply(coordinator: Coordinator)
}

/// Any custom-defined property in the coordinator, that is not internal state.
public struct Prop<C: Coordinator, V>: AnyProp {
  public typealias CoordinatorType = C
  public let keyPath: ReferenceWritableKeyPath<C, V>
  public let value: V

  public init(_ keyPath: ReferenceWritableKeyPath<C, V>, _ value: V) {
    self.keyPath = keyPath
    self.value = value
  }
  /// Setup the coordinator with the given prop.
  public func apply(coordinator: Coordinator) {
    guard let coordinator = coordinator as? C else { return }
    coordinator[keyPath: keyPath] = value
  }
}

/// Any custom-defined configuration closure for the coordinator.
public struct BlockProp<C: Coordinator, V> {
  public let block: (C) -> Void

  public init(_ block: @escaping (C) -> Void) {
    self.block = block
  }
  /// Setup the coordinator with the given prop.
  public func apply(coordinator: Coordinator) {
    guard let coordinator = coordinator as? C else { return }
    block(coordinator)
  }
}

// MARK: - Property setters

/// Sets the value of a desired keypath using typesafe writable reference keypaths.
/// - parameter spec: The *LayoutSpec* object that is currently handling the view configuration.
/// - parameter keyPath: The target keypath.
/// - parameter value: The new desired value.
/// - parameter animator: Optional property animator for this change.
public func withProperty<V: UIView, T>(
  in spec: LayoutSpec<V>,
  keyPath: ReferenceWritableKeyPath<V, T>,
  value: T,
  animator: UIViewPropertyAnimator? = nil
) -> Void {
  guard let kvc = keyPath._kvcKeyPathString else {
    print("\(keyPath) is not a KVC property.")
    return
  }
  spec.set(kvc, value: value, animator: animator);
}

public func withProperty<V: UIView, T: WritableKeyPathBoxableEnum>(
  in spec: LayoutSpec<V>,
  keyPath: ReferenceWritableKeyPath<V, T>,
  value: T,
  animator: UIViewPropertyAnimator? = nil
) -> Void {
  guard let kvc = keyPath._kvcKeyPathString else {
    print("\(keyPath) is not a KVC property.")
    return
  }
  let nsValue = NSNumber(value: value.rawValue)
  spec.set(kvc, value: nsValue, animator: animator)
}

// MARK: - Alias types

// Drops the YG prefix.
public typealias FlexDirection = YGFlexDirection
public typealias Align = YGAlign
public typealias Edge = YGEdge
public typealias Wrap = YGWrap
public typealias Display = YGDisplay
public typealias Overflow = YGOverflow

public typealias LayoutOptions = CRNodeLayoutOptions

// Ensure that Yoga's C-enums are accessibly through KeyPathRefs.
public protocol WritableKeyPathBoxableEnum {
  var rawValue: Int32 { get }
}










