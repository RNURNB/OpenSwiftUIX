  
//
//  NavigationViewController.swift
//  MarcoPolo
//
//  Created by Ondrej Rafaj on 05/06/2018.
//  Copyright © 2018 LiveUI. All rights reserved.
//


import Foundation
import UIKit
import Combine
import CoreRender




//internal let listContext=SCLContext()


/// View controller push pop animations
public struct SCLAnimation {
    
    enum Storage: Hashable {
        
        /// No animation
        case none
        
        /// Default (paralax) animation on push, previously used one on pop
        case `default`(TimeInterval)
        
        /// Paralax animation
        case paralax(TimeInterval)
        
        /// Move alongside
        case move(TimeInterval)
        
        /// Bounce on screen
        case bounce
        
        /// Go over the current view controller
        case over(TimeInterval)
        
    }
    
    /// Internal value store
    let storage: Storage
    
    /// No animation
    public static var none = SCLAnimation(storage: .none)
    
    /// Default (paralax) animation on push, previously used one on pop
    public static func `default`(_ duration: TimeInterval = 0.3) -> SCLAnimation { return SCLAnimation(storage: .default(duration)) }
    
    /// Paralax animation
    public static func paralax(_ duration: TimeInterval = 0.3) -> SCLAnimation { return SCLAnimation(storage: .paralax(duration)) }
    
    /// Move alongside
    public static func move(_ duration: TimeInterval = 0.3) -> SCLAnimation { return SCLAnimation(storage: .move(duration)) }
    
    /// Bounce on screen
    public static var bounce = SCLAnimation(storage: .bounce)
    
    /// Go over the current view controller
    public static func over(_ duration: TimeInterval = 0.3) -> SCLAnimation { return SCLAnimation(storage: .over(duration)) }
    
    // TODO: Add closure based custom animation!!!
    
}

extension SCLAnimation.Storage {
    
    /// Animation time extraction
    var animationTime: TimeInterval {
        switch self {
        case .default(let time), .paralax(let time), .move(let time), .over(let time):
            return time
        default:
            return 0.3
        }
    }
    
}

/// Label with internal text observation callback
public class SCLReportingLabel: UILabel {
    
    /// Callback
    internal var textDidChange: ((String?) -> Void)?
    
    /// Set text override
    public override var text: String? {
        get { return super.text }
        set {
            super.text = newValue
            textDidChange?(newValue)
        }
    }
    
}

/// Title view
public class SCLTitleView: UIView {
    
    /// Content data model
    public final class Content {
        
        var titleView: SCLTitleView?
        var viewController: UIViewController?
        
        public var prompt: String? {
            didSet {
                titleView?.promptLabel.text = prompt
            }
        }
        
        public var title: String? {
            didSet {
                titleView?.titleLabel.text = title
            }
        }
        
        public var subtitle: String? {
            didSet {
                titleView?.subtitleLabel.text = subtitle
            }
        }
        
        public init(prompt: String? = nil, title: String? = nil, subtitle: String? = nil) {
            self.prompt = prompt
            self.title = title
            self.subtitle = subtitle
        }
        
    }
    
    /// Prompt label (positioned on the top)
    public let promptLabel = SCLReportingLabel()
    
    /// Title label (positioned in the middle)
    public let titleLabel = SCLReportingLabel()
    
    /// Subtitle label (positioned at the bottom)
    public let subtitleLabel = SCLReportingLabel()
    
    /// Space between prompt and title (default is 6px)
    public var promptTitleMargin: CGFloat = 6 {
        didSet {
            makeSafeLayout()
        }
    }
    
    /// Space between title and subtitle (default is 6px)
    public var titleSubtitleMargin: CGFloat = 6 {
        didSet {
            makeSafeLayout()
        }
    }
    
    /// Space between prompt and subtitle (default is 6px)
    public var promptSubtitleMargin: CGFloat = 6 {
        didSet {
            makeSafeLayout()
        }
    }
    
    /// Prompt top constraint
    private var promptLabelTopConstraint: NSLayoutConstraint!
    
    /// Title top constraint
    private var titleLabelTopConstraint: NSLayoutConstraint!
    
    /// Subtitle top constraint
    private var subtitleLabelTopConstraint: NSLayoutConstraint!
    
    /// Disable layouting temporarily
    private var disableLayout: Bool = false
    
    /// Content for the title view
    public var content: Content? {
        didSet {
            disableLayout = true
            content?.titleView = self
            promptLabel.text = content?.prompt
            titleLabel.text = content?.title
            subtitleLabel.text = content?.subtitle
            disableLayout = false
            
            makeLayout()
        }
    }
    
    // MARK: Layout
    
    /// Make layout only if on superview
    private func makeSafeLayout() {
        if superview != nil {
            makeLayout()
        }
    }
    
    /// Layout based on content
    private func makeLayout() {
        // Prompt
        promptLabelTopConstraint.constant = 0
        
        // Title
        if !(titleLabel.text?.isEmpty ?? true) {
            if !(promptLabel.text?.isEmpty ?? true) {
                titleLabelTopConstraint.constant = promptTitleMargin
            } else {
                titleLabelTopConstraint.constant = 0
            }
        }

        // Subtitle
        if !(subtitleLabel.text?.isEmpty ?? true) {
            if !(titleLabel.text?.isEmpty ?? true) {
                subtitleLabelTopConstraint.constant = titleSubtitleMargin
            } else if !(promptLabel.text?.isEmpty ?? true) {
                titleLabelTopConstraint.constant = 0
                subtitleLabelTopConstraint.constant = promptSubtitleMargin
            } else {
                subtitleLabelTopConstraint.constant = 0
            }
        } else {
            subtitleLabelTopConstraint.constant = 0
        }

        layoutIfNeeded()
    }
    
    // MARK: View lifecycle
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview != nil {
            makeLayout()
        }
    }
    
    // MARK: Initialization & setup
    
    /// Setup prompt label
    private func setupPrompt() {
        promptLabel.textAlignment = .center
        promptLabel.font = UIFont.systemFont(ofSize: 12)
        promptLabel.textColor = .darkGray
        promptLabel.numberOfLines = 0
        promptLabel.textDidChange = { text in
            self.makeLayout()
        }
        addSubview(promptLabel)
        promptLabelTopConstraint = promptLabel.layout.top()
        promptLabel.layout.minSides()
        promptLabel.layout.bottomLessThanOrEqual()
    }
    
    /// Setup title label
    private func setupTitle() {
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textColor = .darkText
        titleLabel.numberOfLines = 0
        titleLabel.textDidChange = { text in
            self.makeLayout()
        }
        addSubview(titleLabel)
        titleLabelTopConstraint = titleLabel.layout.top(toBottom: promptLabel)
        titleLabel.layout.minSides()
        titleLabel.layout.bottomLessThanOrEqual()
    }
    
    /// Setup subtitle label
    private func setupSubtitle() {
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textDidChange = { text in
            self.makeLayout()
        }
        addSubview(subtitleLabel)
        subtitleLabelTopConstraint = subtitleLabel.layout.top(toBottom: titleLabel)
        subtitleLabel.layout.minSides()
        subtitleLabel.layout.bottomLessThanOrEqual()
    }
    
    /// Designated initializer
    public init() {
        super.init(frame: .zero)
        
        setupPrompt()
        setupTitle()
        setupSubtitle()
    }
    
    /// Not implemented
    @available(*, unavailable, message: "Initializer unavailable")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


public class SCLNavigationItem {
    
    /// Navigation (bar button) item animation type
    public enum Animation {
        
        /// No animation
        case none
        
        /// Basic animation (fade)
        case basic
        
    }
    
    /// Navigation bar reference
    var navigationBar: SCLNavigationBar?
    
    /// Left (bar button) items
    public var leftItems: [UIView] = []
    
    /// Right (bar button) items
    public var rightItems: [UIView] = []
    
    /// Private interface for title views content
    private var _content: SCLTitleView.Content?
    
    /// Content for title view
    public var content: SCLTitleView.Content {
        get {
            guard let content = _content else {
                let content = SCLTitleView.Content()
                self.content = content
                return content
            }
            return content
        }
        set { _content = newValue }
    }
    
    /// Navigation view controller
    public internal(set) var navigationController: SCLNavigationViewController?
    
    /// Activate navigation item
    func activate(_ navigationBar: SCLNavigationBar, on viewController: UIViewController) {
        if content.title == nil {
            content.title = viewController.title
        }
        navigationBar.titleView?.content = content
        self.navigationBar = navigationBar
        
        if viewController == navigationBar.navigationViewController.rootViewController {
            navigationBar.leadingItemsContentView.set(items: viewController.navigation.leftItems, animation: .none)
        } else {
            let count = navigationBar.navigationViewController.viewControllers.count
            if viewController.navigation.leftItems.isEmpty && count > 1 {
                viewController.navigation.set(backButton: .regular(), animation: .none).addTarget(navigationBar.navigationViewController, action: #selector(SCLNavigationViewController.goBack(_:)), for: .touchUpInside)
            } else {
                navigationBar.leadingItemsContentView.set(items: viewController.navigation.leftItems, animation: .none)
            }
        }
        
        navigationBar.trailingItemsContentView.set(items: viewController.navigation.rightItems, animation: .none)
    }
    
}


/// Back arrow type
public class SCLBackArrow {
    
    /// Internal storage
    enum Storage {
        
        /// Bold arrow
        case bold(UIColor?)
        
        /// Regular arrow
        case regular(UIColor?)
        
        /// Light arrow
        case light(UIColor?)
        
    }
    
    /// Internal storage
    let storage: Storage
    
    /// Initializer
    init(_ value: Storage) {
        storage = value
    }
    
    /// Bold arrow
    public static func bold(_ color: UIColor? = nil) -> SCLBackArrow { return .init(.bold(color)) }
    
    /// Regular arrow
    public static func regular(_ color: UIColor? = nil) -> SCLBackArrow { return .init(.regular(color)) }
    
    /// Light arrow
    public static func light(_ color: UIColor? = nil) -> SCLBackArrow { return .init(.light(color)) }
    
}

extension UIBezierPath {
    
    func fill(imageOfSize size: CGSize, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}

extension SCLBackArrow {
    
    /// Convert arrow type to an image button
    public func asButton(color: UIColor? = nil) -> UIButton {
        let button = UIButton()
        button.setImage(image(color: (color ?? button.tintColor)), for: .normal)
        button.sizeToFit()
        if button.bounds.size.width < 36 {
            button.bounds.size.width = 36
        }
        if button.bounds.size.height < 36 {
            button.bounds.size.height = 36
        }
        return button
    }
    
    /// Image representation of the arrow
    public func image(color: UIColor) -> UIImage? {
        let bezierPath = UIBezierPath()
        switch storage {
        case .light:
            bezierPath.move(to: CGPoint(x: 14.34, y: 24.8))
            bezierPath.addLine(to: CGPoint(x: 14.78, y: 24.41))
            bezierPath.addCurve(to: CGPoint(x: 14.78, y: 23.46), controlPoint1: CGPoint(x: 15.07, y: 24.14), controlPoint2: CGPoint(x: 15.07, y: 23.72))
            bezierPath.addLine(to: CGPoint(x: 2.67, y: 12.5))
            bezierPath.addLine(to: CGPoint(x: 14.78, y: 1.54))
            bezierPath.addCurve(to: CGPoint(x: 14.78, y: 0.59), controlPoint1: CGPoint(x: 15.07, y: 1.28), controlPoint2: CGPoint(x: 15.07, y: 0.86))
            bezierPath.addLine(to: CGPoint(x: 14.34, y: 0.2))
            bezierPath.addCurve(to: CGPoint(x: 13.29, y: 0.2), controlPoint1: CGPoint(x: 14.05, y: -0.07), controlPoint2: CGPoint(x: 13.58, y: -0.07))
            bezierPath.addLine(to: CGPoint(x: 0.22, y: 12.02))
            bezierPath.addCurve(to: CGPoint(x: 0.22, y: 12.98), controlPoint1: CGPoint(x: -0.07, y: 12.29), controlPoint2: CGPoint(x: -0.07, y: 12.71))
            bezierPath.addLine(to: CGPoint(x: 13.29, y: 24.8))
            bezierPath.addCurve(to: CGPoint(x: 14.34, y: 24.8), controlPoint1: CGPoint(x: 13.58, y: 25.07), controlPoint2: CGPoint(x: 14.05, y: 25.07))
            
        case .regular:
            bezierPath.move(to: CGPoint(x: 14.01, y: 24.8))
            bezierPath.addLine(to: CGPoint(x: 15.19, y: 23.68))
            bezierPath.addCurve(to: CGPoint(x: 15.19, y: 22.73), controlPoint1: CGPoint(x: 15.46, y: 23.42), controlPoint2: CGPoint(x: 15.46, y: 22.99))
            bezierPath.addLine(to: CGPoint(x: 4.48, y: 12.5))
            bezierPath.addLine(to: CGPoint(x: 15.19, y: 2.27))
            bezierPath.addCurve(to: CGPoint(x: 15.19, y: 1.32), controlPoint1: CGPoint(x: 15.46, y: 2.01), controlPoint2: CGPoint(x: 15.46, y: 1.58))
            bezierPath.addLine(to: CGPoint(x: 14.01, y: 0.2))
            bezierPath.addCurve(to: CGPoint(x: 13.01, y: 0.2), controlPoint1: CGPoint(x: 13.73, y: -0.07), controlPoint2: CGPoint(x: 13.28, y: -0.07))
            bezierPath.addLine(to: CGPoint(x: 0.6, y: 12.02))
            bezierPath.addCurve(to: CGPoint(x: 0.6, y: 12.98), controlPoint1: CGPoint(x: 0.32, y: 12.29), controlPoint2: CGPoint(x: 0.32, y: 12.71))
            bezierPath.addLine(to: CGPoint(x: 13.01, y: 24.8))
            bezierPath.addCurve(to: CGPoint(x: 14.01, y: 24.8), controlPoint1: CGPoint(x: 13.28, y: 25.07), controlPoint2: CGPoint(x: 13.73, y: 25.07))
        case .bold:
            bezierPath.move(to: CGPoint(x: 0.4, y: 11.53))
            bezierPath.addLine(to: CGPoint(x: 11.4, y: 0.4))
            bezierPath.addCurve(to: CGPoint(x: 13.32, y: 0.4), controlPoint1: CGPoint(x: 11.93, y: -0.13), controlPoint2: CGPoint(x: 12.79, y: -0.13))
            bezierPath.addLine(to: CGPoint(x: 14.6, y: 1.7))
            bezierPath.addCurve(to: CGPoint(x: 14.6, y: 3.64), controlPoint1: CGPoint(x: 15.13, y: 2.24), controlPoint2: CGPoint(x: 15.13, y: 3.1))
            bezierPath.addLine(to: CGPoint(x: 5.89, y: 12.5))
            bezierPath.addLine(to: CGPoint(x: 14.6, y: 21.36))
            bezierPath.addCurve(to: CGPoint(x: 14.6, y: 23.3), controlPoint1: CGPoint(x: 15.13, y: 21.9), controlPoint2: CGPoint(x: 15.13, y: 22.76))
            bezierPath.addLine(to: CGPoint(x: 13.32, y: 24.6))
            bezierPath.addCurve(to: CGPoint(x: 11.4, y: 24.6), controlPoint1: CGPoint(x: 12.79, y: 25.13), controlPoint2: CGPoint(x: 11.93, y: 25.13))
            bezierPath.addLine(to: CGPoint(x: 0.4, y: 13.47))
            bezierPath.addCurve(to: CGPoint(x: 0.4, y: 11.53), controlPoint1: CGPoint(x: -0.13, y: 12.93), controlPoint2: CGPoint(x: -0.13, y: 12.06))

        }
        bezierPath.close()
        
        return bezierPath.fill(imageOfSize: CGSize(width: 15, height: 25), color: color)
    }
    
}

// TODO: Change to leading/trailing
extension SCLNavigationItem {
    
    /// Left (bar button) item
    public var leftItem: UIView? {
        get { return leftItems.first }
        set {
            guard let item = newValue else {
                set(leftItems: [])
                return
            }
            set(leftItem: item)
        }
    }
    
    /// Set left (bar button) items
    public func set(leftItems items: [UIView]?, animation: Animation = .basic) {
        guard let items = items else {
            set(leftItems: [])
            return
        }
        leftItems = items
        if let navigationBar = navigationBar {
            navigationBar.leadingItemsContentView.set(items: items, animation: animation)
        }
    }
    
    /// Set left (bar button) item
    public func set(leftItem item: UIView?, animation: Animation = .basic) {
        guard let item = item else {
            set(leftItems: [])
            return
        }
        leftItems = [item]
        if let navigationBar = navigationBar {
            navigationBar.leadingItemsContentView.set(items: leftItems, animation: animation)
        }
    }
    
    /// Add left (bar button) item
//    public func add(leftItem item: UIView, animation: Animation = .basic) {
//        leftItems.append(item)
//        if let navigationBar = navigationBar {
//            navigationBar.leadingItemsContentView.add(item: item, animation: animation)
//        }
//    }
    
    /// Add back button
    @discardableResult func set(backButton: UIButton, animation: Animation = .basic) -> UIButton {
        set(leftItem: backButton, animation: animation)
        return backButton
    }
    
    /// Add back button with arrow style
    @discardableResult func set(backButton: SCLBackArrow, color: UIColor? = nil, animation: Animation = .basic) -> UIButton {
        return set(backButton: backButton.asButton(color: color), animation: animation)
    }
    
}

extension Array where Element: UIView {
    
    /// Remove all views from their superviews
    func removeAllFromSuperview() {
        forEach { $0.removeFromSuperview() }
    }
    
    func removeAllConstraints() {
        forEach { $0.removeConstraints($0.constraints) }
    }
    
    /// Set alpha on all views
    func alpha(_ value: CGFloat) {
        forEach { $0.alpha = value }
    }
    
}

class BarItemsContentView: UIView {
    
    // TODO: Change following to leading/trailing!!!
    /// Position on the navigation bar
    enum Position {
        
        /// Left
        case left
        
        /// Right
        case right
        
    }
    
    /// Position on the navigation bar
    var position: Position
    
    /// Bar items spacing
    var spacing: CGFloat = 6.0
    
    /// Bar items spacing
    var firstItemSpacing: CGFloat = 12
    
    /// Items
    private var items: [UIView] = []
    
    /// Set items
    func set(items: [UIView], animation: SCLNavigationItem.Animation) {
        self.items.removeAllFromSuperview()
        self.items.removeAll()
        self.items = items
        layoutItems()
    }
    
    /// Set item
    func set(item: UIView, animation: SCLNavigationItem.Animation) {
        set(items: [item], animation: animation)
    }
    
    /// Add item
    func add(item: UIView, animation: SCLNavigationItem.Animation) {
        items.append(item)
    }
    
    /// Initializer
    init(_ position: Position) {
        self.position = position
        
        super.init(frame: .zero)
    }
    
    /// Not implemented
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private helpers
    
    /// Layout all items
    private func layoutItems() {
        var previousView: UIView?
        var x: Int = 1
        items.forEach { view in
            addSubview(view)
            view.layout.centerY()
            layout.match(minHeight: view)
            
            // Place next to the previous view
            if let previousView = previousView {
                switch position {
                case .left:
                    view.layout.next(previousView, margin: spacing)
                case .right:
                    view.layout.before(previousView, margin: -spacing)
                }
            } else {
                switch position {
                case .left:
                    view.layout.leading(margin: firstItemSpacing)
                case .right:
                    view.layout.trailing(margin: -firstItemSpacing)
                }
            }
            
            // Manage last item
            if x == items.count {
                switch position {
                case .left:
                    view.layout.trailing()
                case .right:
                    view.layout.leading()
                }
            }
            
            setSizeIfNeccessary(view)
            previousView = view
            x += 1
        }
    }
    
    /// Set size of the bar button item if neccessary
    private func setSizeIfNeccessary(_ view: UIView) {
        if view.constraints.count == 0 {
            // Set height if neccessary
            if view.bounds.size.height == 0 {
                view.layout.height(36)
            } else {
                view.layout.match(maxHeight: self)
            }
            
            // Set height if neccessary
            if view.bounds.size.width == 0 {
                view.layout.width(36)
            }
        }
    }
    
}

/// Shadow for navigation bar
public final class SCLNavigationBarShadow: UIView {
    
    /// Main gradient layer
    let gradient = CAGradientLayer()
    
    /// Main color of the shadow gradient (top side, bottom is always `.clear`)
    public var topGradientColor = UIColor.lightGray.withAlphaComponent(0.13) {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    /// Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        gradient.colors = [topGradientColor.cgColor, UIColor.clear.cgColor]
        gradient.frame = bounds
    }
    
    /// Initializer
    public init() {
        super.init(frame: .zero)
        
        isUserInteractionEnabled = false
        
        layer.insertSublayer(gradient, at: 0)
    }
    
    /// Not implemented
    @available(*, unavailable, message: "Initializer unavailable")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/// Navigation bar view
open class SCLNavigationBar: UIView {
    
    /// Leading (left bar button) items content view
    let leadingItemsContentView = BarItemsContentView(.left)
    
    /// Trailing (right bar button) items content view
    let trailingItemsContentView = BarItemsContentView(.right)
    
    /// Leading (left bar button) items spacing
    public var leftItemsSpacing: CGFloat {
        get { return leadingItemsContentView.spacing }
        set { leadingItemsContentView.spacing = newValue }
    }
    
    /// Trailing (right bar button) items spacing
    public var trailingFirstItemSpacing: CGFloat {
        get { return trailingItemsContentView.firstItemSpacing }
        set { trailingItemsContentView.firstItemSpacing = newValue }
    }
    
    /// Leading (left bar button) items spacing
    public var leftFirstItemSpacing: CGFloat {
        get { return leadingItemsContentView.firstItemSpacing }
        set { leadingItemsContentView.firstItemSpacing = newValue }
    }
    
    /// Trailing (right bar button) items spacing
    public var trailingItemsSpacing: CGFloat {
        get { return trailingItemsContentView.spacing }
        set { trailingItemsContentView.spacing = newValue }
    }
    
    /// Top margin below status bar safe area
    public var topMargin: CGFloat {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    /// Top constraint of the content view
    var topConstraint: NSLayoutConstraint?
    
    /// Navigation bar min height
    var minHeightConstraint: NSLayoutConstraint?
    
    /// Minimum height of the navigation bar
    public var minHeight: CGFloat? {
        didSet {
            minHeightConstraint?.constant = minHeight!
        }
    }
    
    /// Navigation view controller reference
    var navigationViewController: SCLNavigationViewController!
    
    /// Background view, always on the bottom
    public var backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    /// Title view (you can override with customTitleView)
    public var titleView: SCLTitleView? {
        get {
            return customTitleView as? SCLTitleView
        }
    }
    
    /// Private storage for `customTitleView`
    private var _customTitleView: UIView?
    
    /// By setting `customTitleView` you override `titleView`
    public var customTitleView: UIView? {
        get { return _customTitleView }
        set {
            if _customTitleView === newValue { return }
            _customTitleView?.removeFromSuperview()
            guard let view = newValue else {
                _customTitleView?.removeFromSuperview()
                _customTitleView = nil
                return
            }
            _customTitleView = view
            
            view.layout.centerY()
            view.layout.centerX().priority = .defaultLow
            // TODO: Finish leading/trailing transformation so that the back button appears on the right place!!!
            //  (probably just by switching the two views below?) :)
            view.layout.next(leadingItemsContentView, margin: 6)
            view.layout.before(trailingItemsContentView, margin: -6)
            view.layout.bottomLessThanOrEqual(margin: -6)
        }
    }
    
    /// Content view
    public var contentView = UIView()
    
    /// Shadow
    public let shadowView = SCLNavigationBarShadow()
    
    /// Toggle shadow
    public var hasShadow: Bool {
        set { clipsToBounds = !newValue }
        get { return !clipsToBounds }
    }
    
    // MARK: Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if #available(iOS 11, *) {
            topConstraint?.constant = (safeAreaInsets.top + topMargin)
        } else {
            topConstraint?.constant = topMargin
        }
    }
    
    // MARK: Initialization & setup
    
    /// Setup background view
    private func setupBackground() {
        backgroundColor = .clear
        
        backgroundView.tintColor = .white
        addSubview(backgroundView)
        backgroundView.layout.fill()
    }
    
    /// Setup content view
    private func setupContentViews() {
        // Main content
        addSubview(contentView)
        /*topConstraint = contentView.layout.top()
        contentView.layout.sides()
        if minHeight != nil {minHeightConstraint = contentView.layout.min(height: minHeight!)}
        contentView.layout.bottomLessThanOrEqual()*/
        contentView.translatesAutoresizingMaskIntoConstraints=false
        contentView.leftAnchor.constraint(equalTo: self.leftAnchor,constant:0).isActive = true
        contentView.topAnchor.constraint(equalTo: self.topAnchor,constant:0).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant:44).isActive = true
        contentView.rightAnchor.constraint(equalTo: self.rightAnchor,constant:0).isActive = true
        
        
        // Left items
        contentView.addSubview(leadingItemsContentView)
        leadingItemsContentView.layout.leading()
//        leadingItemsContentView.layout.matchHeightToSuperview()
        leadingItemsContentView.layout.centerY()
        
        // Right items
        contentView.addSubview(trailingItemsContentView)
        trailingItemsContentView.layout.trailing()
//        trailingItemsContentView.layout.matchHeightToSuperview()
        trailingItemsContentView.layout.centerY()
    }
    
    /// Setup title view
    private func setupTitleView() {
        let titleView = SCLTitleView()
        contentView.addSubview(titleView)
        customTitleView = titleView
    }
    
    /// Setup shadow
    private func setupShadowView() {
        addSubview(shadowView)
        shadowView.layout.top(toBottom: self)
        shadowView.layout.sides()
        shadowView.layout.height(6)
    }
    
    /// Designated initializer
    public init(minHeight: CGFloat? = 44) {
        self.minHeight = minHeight
        
        // TODO: Check on older devices/iOS!!!!
        if #available(iOS 11, *) {
            topMargin = 6
        } else {
            topMargin = 28
        }
        //RN
        topMargin=0
        
        super.init(frame: .zero)
        
        setupBackground()
        setupContentViews()
        setupTitleView()
        setupShadowView()
    }
    
    /// Not implemented
    @available(*, unavailable, message: "Initializer unavailable")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public class SCLNavigationManager {
    
    var leftConstraint: NSLayoutConstraint?
    
    var animation: SCLAnimation = .default()
    
    var navigationItem: SCLNavigationItem!
    
}

private var NavigationViewControllerAssociatedObjectHandle: UInt8 = 0
private var NavigationItemAssociatedObjectHandle: UInt8 = 1


extension UIViewController {
    
    /// [MarcoPolo] Navigation item (details)
    public internal(set) var navigation: SCLNavigationItem {
        get {
            guard let item = objc_getAssociatedObject(self, &NavigationItemAssociatedObjectHandle) as? SCLNavigationItem else {
                let item = SCLNavigationItem()
                item.content.title = title
                item.content.viewController = self
                self.navigation = item
                return item
            }
            return item
        }
        set {
            objc_setAssociatedObject(self, &NavigationItemAssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// [MarcoPolo] Navigation manager (only available to pushed view controllers)
    var navigationManager: SCLNavigationManager? {
        return navigation.navigationController?.navigationManagers[ObjectIdentifier(self)]
    }
}

open class SCLNavigationViewController: UIViewController {
    
    /// Navigation bar
    public internal(set) var navigationBar: SCLNavigationBar?
    
    /// Root view controller
    public var rootViewController: UIViewController?
    
    /// Private view controller stack
    var _viewControllers: [UIViewController] = []
    
    /// Navigation managers
    var navigationManagers: [ObjectIdentifier: SCLNavigationManager] = [:]
    
    /// Is animating
    var isAnimating: Bool = false
    
    ///has a navigation bar
    public var hasNavigationBar:Bool=false
    
    // MARK: View lifecycle
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateSafeArea()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.backgroundColor = .white
        
        //print("SCLNavigationViewController view did load")
        
        // Navigation bar
        if hasNavigationBar && navigationBar==nil {
            navigationBar = SCLNavigationBar(minHeight: 44)
            navigationBar!.navigationViewController = self
            view.addSubview(navigationBar!)
            navigationBar!.layout.sides()
            navigationBar!.layout.top()
        }
        
        // Add the root view controller onto the scene
        if rootViewController != nil {
            register(managerFor: rootViewController!, animation: .none)
            add(childViewController: rootViewController!)
            change(navigationItemFrom: rootViewController!, animationTime: 0.0)
        }
    }
    
    func clear() {
        for view in view.subviews {
            view.removeFromSuperview()
        }
        for controller in children {
            //print("remove zstackview vc:",vc)
            controller.willMove(toParent:nil)
            controller.removeFromParent()
            controller.didMove(toParent:nil)
        }
        _viewControllers=[]
    }
    
    /// Change navigation item
    func change(navigationItemFrom viewController: UIViewController, animationTime: TimeInterval) {
        if navigationBar != nil {viewController.navigation.activate(navigationBar!, on: viewController)}
    }
    
    // MARK: Initialization
    
    /// Designated initializer
    public init(rootViewController: UIViewController?=nil) {
        self.rootViewController = rootViewController
        
        super.init(nibName: nil, bundle: nil)
        
        rootViewController?.navigation.navigationController = self
    }
    
    /// Not implemented
    @available(*, unavailable, message: "Initializer unavailable")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Animate a new view controller over an old one (push)
    @discardableResult func animate(upperViewController: UIViewController, to lowerViewController: UIViewController?, finished: @escaping (() -> Void)) -> TimeInterval {
        guard
            let upperManager = upperViewController.navigationManager,
            let lowerManager:SCLNavigationManager? = lowerViewController?.navigationManager,
            upperManager.animation.storage != SCLAnimation.Storage.none,
            let lowerLeftConstraint = lowerManager?.leftConstraint,
            let upperLeftConstraint = upperManager.leftConstraint else {
                finished()
                return 0.0
        }
        
        // TODO: Add shadow on lower screen!!!
        if upperManager.animation.storage == .bounce {
            lowerLeftConstraint.constant = -(view.bounds.size.width / 2)
            upperLeftConstraint.constant = 0
            view.layoutIfNeeded()
            
            upperLeftConstraint.constant = -12
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                lowerLeftConstraint.constant = 0
                upperLeftConstraint.constant = self.view.bounds.size.width
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                }) { _ in
                    finished()
                }
            }
            return 0.35
        } else {
            // Set starting position
            upperLeftConstraint.constant = 0
            switch upperManager.animation.storage {
            case .move:
                lowerLeftConstraint.constant = -view.bounds.size.width
            case .over:
                lowerLeftConstraint.constant = 0
            default:
                lowerLeftConstraint.constant = -(view.bounds.size.width / 2)
            }
            view.layoutIfNeeded()
            
            // Animate top out
            lowerLeftConstraint.constant = 0
            upperLeftConstraint.constant = view.bounds.size.width
            UIView.animate(withDuration: upperManager.animation.storage.animationTime, delay: 0.0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                finished()
            }
            return upperManager.animation.storage.animationTime
        }
    }
    
    /// Animate a new view controller over an old one (push)
    @discardableResult func animate(_ viewController: UIViewController, over previousViewController: UIViewController?, finished: @escaping (() -> Void)) -> TimeInterval {
        guard
            let previousManager:SCLNavigationManager? = previousViewController?.navigationManager,
            let newManager = viewController.navigationManager,
            newManager.animation.storage != SCLAnimation.Storage.none,
            let newLeftConstraint = newManager.leftConstraint,
            let previousLeftConstraint = previousManager?.leftConstraint else {
                finished()
                return 0.0
        }
        newLeftConstraint.constant = view.bounds.size.width
        view.layoutIfNeeded()
        
        // TODO: Add shadow on lower screen!!!
        if newManager.animation.storage == .bounce {
            newLeftConstraint.constant = -12
            previousLeftConstraint.constant = -(view.bounds.size.width / 2)
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                newLeftConstraint.constant = 6
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                }) { _ in
                    newLeftConstraint.constant = 0
                    UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
                        self.view.layoutIfNeeded()
                    }) { _ in
                        finished()
                    }
                }
            }
            return 0.5
        } else {
            newLeftConstraint.constant = 0
            switch newManager.animation.storage {
            case .move:
                previousLeftConstraint.constant = -view.bounds.size.width
            case .over:
                break
            default:
                previousLeftConstraint.constant = -(view.bounds.size.width / 2)
            }
            UIView.animate(withDuration: newManager.animation.storage.animationTime, delay: 0.0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                finished()
            }
            return newManager.animation.storage.animationTime
        }
    }
    
    /// Pops and returns the popped controller.
    @discardableResult public func popViewController(animation: SCLAnimation = .default()) -> UIViewController? {
        guard /*viewControllers.count > 1,*/ let upperViewController = viewControllers.last else {
            return nil
        }
        
        // Update animation if neccessary
        switch animation.storage {
        case .default, .none:
            break
        default:
            upperViewController.navigationManager?.animation = animation
        }
        
        let previousViewController:UIViewController? = viewControllers.count > 1 ? viewControllers[viewControllers.count - 2] : nil
        
        // Add previous view controller back on
        if previousViewController != nil {add(childViewController: previousViewController!)}
        view.bringSubviewToFront(upperViewController.view)
        if navigationBar != nil {view.bringSubviewToFront(navigationBar!)}
        
        // Animate
        let time = animate(upperViewController: upperViewController, to: previousViewController) {
            self.remove(childViewController: upperViewController)
        }
        if previousViewController != nil {change(navigationItemFrom: previousViewController!, animationTime: time)}
        remove(managerFor: upperViewController)
        return viewControllers.removeLast()
    }
    
    /// Pops view controllers until the one specified is on top. Returns the popped controllers.
    /*@discardableResult public func pop(to viewController: UIViewController, animation: SCLAnimation = .default()) -> [UIViewController]? {
        guard viewControllers.count > 1 else {
            return nil
        }
        fatalError("Not implemented")
    }
    
    /// Pops until there's only a single view controller left on the stack. Returns the popped controllers.
    @discardableResult public func popToRootViewController(animation: SCLAnimation = .default()) -> [UIViewController]? {
        if rootViewController != nil {return pop(to: rootViewController!, animation: animation)}
        else {return nil}
    }
    */
    
    // MARK: Actions
    
    @objc public func goBack(_ sender: Any) {
        popViewController()
    }
    
    public func pop(skipAnimation:Bool=false) {
        popViewController(animation:skipAnimation ? .none : .default())
    }
    
    /// Register new manager for a view controller
    func register(managerFor viewController: UIViewController, animation: SCLAnimation) {
        let manager = SCLNavigationManager()
        manager.animation = animation
        navigationManagers[ObjectIdentifier(viewController)] = manager
    }
    
    /// Remove navigation manager
    func remove(managerFor viewController: UIViewController) {
        navigationManagers.removeValue(forKey: ObjectIdentifier(viewController))
    }
    
    /// Return view controller that has been pushed latest
    open var topViewController: UIViewController? {
        guard let c = viewControllers.last else {
            return rootViewController
        }
        return c
    }
    
    /// View controller stack
    public var viewControllers: [UIViewController] {
        get {
            if _viewControllers.count == 0 {
                if rootViewController != nil {_viewControllers.append(rootViewController!)}
            }
            return _viewControllers
        }
        set {
            _viewControllers = newValue
            // TODO: Clean managers registry!!!
        }
    }
    
    /// Push a new view controller (default animation is `.paralax()`)
    public func push(viewController: UIViewController, animation: SCLAnimation = .default(),skipAnimation:Bool=false) {
        /*guard let previous = viewControllers.last else {
            fatalError("This should never happen")
        }*/
        let previous = viewControllers.last
        isAnimating = true
        
        register(managerFor: viewController, animation: animation)
        
        viewController.navigation.navigationController = self
        viewControllers.append(viewController)
        
        add(childViewController: viewController)
        
        if !skipAnimation && previous != nil {
            let time = animate(viewController, over: previous!) {
                self.remove(childViewController: previous!)
            
                self.isAnimating = false
            }
            change(navigationItemFrom: viewController, animationTime: time)
        }
        else {change(navigationItemFrom: viewController,animationTime: 0);self.isAnimating = false}
    }
    
    /// Set save area on all involved view controllers
    internal func updateSafeArea() {
        if #available(iOS 11.0, *) {
          if navigationBar != nil {
            for c in viewControllers {
                // TODO: Update only active view controllers!
                c.additionalSafeAreaInsets.top = navigationBar!.bounds.height - view.safeAreaInsets.top
            }
          }
        }
    }
    
    /// Set constraints to satisfy a view
    func setConstraints(on viewController: UIViewController) -> NSLayoutConstraint {
        viewController.view.layout.vertical()
        viewController.view.layout.matchWidthToSuperview()
        return viewController.view.layout.leading()
    }
    
    /// Remove view controller from the stack
    func remove(childViewController: UIViewController) {
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
    }
    
    /// Adds child view controller onto the topn of the screen (below nav bar)
    func add(childViewController: UIViewController) {
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
        if navigationBar != nil {view.bringSubviewToFront(navigationBar!)}
        childViewController.navigationManager?.leftConstraint = setConstraints(on: childViewController)
        
        updateSafeArea()
    }
}

public class _NavigationViewLayout {
    var navigation:ViewNode?
    var navBar:SCLUINavigationBar?
    var navBarContent:ViewNode?
    
    @inlinable public init() {
    }
    
    public typealias Body = Never
}

extension _NavigationViewLayout: _VariadicView_UnaryViewRoot {}
extension _NavigationViewLayout: _VariadicView_ViewRoot {}

public class SCLNavigationViewContainer:UIView {
}

class SCLNavigationViewNavigator {
    internal var node:SCLNavigationViewController?=nil 
    internal var context:SCLContext?=nil
    internal var children:[ViewNode]=[]
    public var count:Int {get {children.count}}
    public var current:Int {
        get {children.count-1}
        set(newvalue) {
            if newvalue<0 {clear()}
            else {
                while children.count-1 > newvalue {pop(animations:false)}
            }
        }
    }
    
    public init() {}
    
    public func update(context:SCLContext) {
        self.context=context
        for c in children {c.value!.setContext(context)}
    }
    
    public func push<Content>(@ViewBuilder _ content: () -> Content) where Content: View {
        let viewcontent=content()
        
        //create a dummy node for content
        let content=ViewNode(value: ConcreteNode(type:UIView.self, layoutSpec:{spec, context in 
            //fatalError()
            print("navigationview content layoutspec")
            spec.view?.clipsToBounds=true
            //if minLength>0 {yoga.width=minLength}
        }))
        content.value!.setContext(context!) //this will also specify environment
    
        ViewExtractor.extractViews(contents: viewcontent).forEach { 
                //print("build list node ",$0)
                if let n=$0.buildTree(parent: content, in:content.runtimeenvironment) 
                {
                    //elements.append(n)
                    //print("got list view node ",n)
                }
            }
        
        children.append(content)
        
        addContent(content,animations:true)
    }
    
    public func pop(animations:Bool=true) {
        if children.count==0 {return}
        children.removeLast()
        node?.pop(skipAnimation:!animations)
    }
    
    public func clear() {
        while children.count > 0 {pop(animations:false)}
    }
    
    internal func addContent(_ node:ViewNode,animations:Bool) {
        if let vc=self.node {
            for c in node.children {
                var vc1:UIViewController?
                    
                if c.value?.isControllerNode == true {
                    c.value?.build(in:nil,parent:nil,candidate:nil,constrainedTo:vc.view.frame.size,with:[],forceLayout:false)
                    //print("zstack content is a controller:",primary.children[0].value?.viewController)
                                                    
                    //toUpdate.append(c)
                        
                    vc1=c.value?.viewController!
                }
                else {
                    vc1=SCLZStackContentController()
                    vc1!.view.backgroundColor = .clear
                        
                    if c.value?.renderedView != nil {
                        //reuse
                        //print("zstackviewcreconcile reuse ",c.value!.renderedView!)
                        c.value!.renderedView!.removeFromSuperview()
                        vc1!.view.addSubview(c.value!.renderedView!)
                    }
                    else {
                        //print("prev default views:",previousViews)
                        //print("reconcile ",primary.children[0].value?.renderedView,"parent ",primary.children[0].value?.renderedView?.superview)
                        c.value?.build(in:vc1!.view,parent:nil,candidate:nil, constrainedTo:vc.view.frame.size,with:[],forceLayout:false)
                    }
                
                    //print("controller build done. controller layout start")
                
                    //print("")
                    //print("view=",view," parent of root=",primary.children[0].value?.renderedView?.superview)
                
                    c.value?.renderedView?.frame=CGRect.init(x: 0, y: 0,width: vc.view.frame.width,height: vc.view.frame.size.height)
                    //print("primary frame:",c.value?.renderedView?.frame)
                            
                    c.value?.reconcile(in:vc1!.view,constrainedTo:vc.view.frame.size,with:[])
                        
                    //toUpdate.append(c)
                }
                    
                vc.push(viewController:vc1!,animation:.over(),skipAnimation:!animations)
            } //for
        }
    }
    
    open func addDefaultContent() {
        if let vc=node {
            for c in children {addContent(c,animations:false)}
        }
    }
}

class NavigationDataSource {
    private var _dataSource:[DataSourceWrapper]=[]
    
    func clear() {
        for d in _dataSource {
            d.dataSource?.universalSplitController.detachParentController()
            d.dataSource?.universalSplitController.detachParentController()
            d.dataSource?.universalSplitController.detachDetailController()
        }
        _dataSource=[]
    }
    
    func append(_ d:DataSourceWrapper) {_dataSource.append(d)}
}

open class NavigationViewController {
    internal var _barparent:ViewNode?
    open var navigationBarSize:CGFloat {get {44}} //return 0 to hide navigation bar
    open var statusBarSize:CGFloat {get {0}} //return 0 to hide status bar
    
    public func rebuild() {
        var oldView=_barparent!.value!.renderedView!
        var parentView=_barparent!.value!.renderedView!.superview!
        let sz=parentView.frame.size
        oldView.removeFromSuperview()
        
        _barparent!.children=[]
        for c in _barparent!.value!.children {
            c.setParent(nil)
        }
        _barparent!.value!.clearChildren()
        makeNavigationBarContent(parent:_barparent!)
        
        _barparent!.value?.build(in:parentView,parent:nil,candidate:oldView,constrainedTo:sz,with:[],forceLayout:false)
        
        _barparent!.value?.renderedView?.frame=CGRect.init(x: 0, y: 0, width: sz.width, height: sz.height)
                            
        _barparent!.value?.reconcile(in:parentView,constrainedTo:sz,with:[])
    }
    
    open func makeNavigationBarContent(parent:ViewNode) {}
}

public class NavigationViewDefaultController:NavigationViewController {
    var backArrow=SCLBackArrow.regular(.link)
    var showBackButton:Bool=false
    
    var navigationBarContents:some View { get {
      PassthroughView {
        HStack {
            Spacer().width(4)
            
            Button(action: {
                    //alert("hide detail","pressed")
                    self.showBackButton = !self.showBackButton
                    self.rebuild()

            }) {
                Image(systemName: "list.triangle"/*"list.dash.header.rectangle"*/)
            }
            .minHeight(22)
            .minWidth(22)
            
            Spacer().width(4)
            
            if showBackButton {
                Button(action: {
                    alert("back","pressed")

                }) {
                    HStack {
                        Image(image: backArrow.image(color:.link)!)
                        Spacer().width(4).userInteractionEnabled(false)
                        Text("Back").foregroundColor(.link)
                    }
                    .userInteractionEnabled(false)
                }
            }
            
            Spacer().width(4)
            
            PassthroughView {
                VStack(alignment:.center) {
                    Text("Main Title").foregroundColor(.link)
                    Text("Sub Title").foregroundColor(.link)
                }
                .alignItems(.center)
            }
            .userInteractionEnabled(false)
            
            .flexGrow(1)
            .flex()
            
            Spacer().width(4)
            
            Button(action: {
                    alert("edit","pressed")

            }) {
                Text("Edit").foregroundColor(.link)
            }
            
            Spacer().width(4)
        }
        .alignItems(.center)
      }
      .height(navigationBarSize)
      .matchHostingViewWidth(withMargin:0)
    }}
    
    override public var navigationBarSize:CGFloat {get {44}} //return 0 to hide navigation bar
    override public var statusBarSize:CGFloat {get {30}} //return 0 to hide status bar
    
    override public func makeNavigationBarContent(parent:ViewNode) {
        ViewExtractor.extractViews(contents: self.navigationBarContents).forEach { 
            _=$0.buildTree(parent: parent, in:parent.runtimeenvironment) 
        }
    }
    
    override public init() {}
}

public struct NavigationView<Content>:UIViewControllerRepresentable where Content: View {
    public typealias UIViewControllerType=SCLNavigationViewController
    public typealias Body = Never
    public typealias UIContainerType = SCLNavigationViewContainer
    private let _navigator=SCLNavigationViewNavigator()
    private var _dataSource=NavigationDataSource()
    public var controller:NavigationViewController
    
    public var _tree: _VariadicView.Tree<_NavigationViewLayout, Content>
    private var _layoutSpec=LayoutSpecWrapper<UIViewType>()
    
    public init(controller:NavigationViewController,@ViewBuilder content: () -> Content) {
        self.controller=controller
        _tree = .init(
            root: _NavigationViewLayout() , content: content())
    }
    
    public func makeUIViewController(context:Context) -> UIViewControllerType {
        //print("make navigation viewcontroller")
        let vc=UIViewControllerType()
        vc.node=_tree.root.navigation!
        let v=UIContainerType()
        v.node=_tree.root.navigation!
        vc.view=v
        _navigator.node=vc
        _navigator.update(context:context)
        
        return vc
    }
    
    public func updateUIViewController(_ view:UIViewControllerType,context:Context) -> Void {
        _navigator.node=view
        _navigator.update(context:context)
    }
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> NavigationView<Content> {
       _layoutSpec.add(spec)
       return self
    }
}

extension NavigationView {
    public var body: Never {
        fatalError()
    }
}

extension NavigationView {
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        var env=parent.runtimeenvironment
            
        //print("create navigation node")
        let node=SCLNode(environment:env, host:self,reuseIdentifier:"NavigationView",key:nil,layoutSpec: { spec, context in
                guard let yoga = spec.view?.yoga else { return }
                spec.view!.clipsToBounds=true
                //init width and height, else crash for empty list
                if let parent:UIView=spec.view?.superview {
                    spec.set("yoga.width",value:parent.frame.size.width-spec.view!.frame.origin.x)
                    spec.set("yoga.height",value:parent.frame.size.height-spec.view!.frame.origin.y)
                }
                else {
                    //spec.set("yoga.width",value:spec.size.width)
                    //spec.set("yoga.height",value:spec.size.height)
                }
                
                yoga.flex() 

                //print("HStack spec layout=\(self._layoutSpec) align=\(yoga.alignItems.rawValue)")
                self._layoutSpec.layoutSpec?(spec)
                //print("HStack spec end 2 align=\(yoga.alignItems.rawValue)")
                //yoga.alignItems = .center
                //yoga.justifyContent = .center
                
                if let navigationView=spec.view as? UIViewType {
                    //print("list reloaddata")
                    //list.reloadData()
                }
            },
            controller:self
        )
        
        let vnode = ViewNode(value: node)
        _tree.root.navigation=vnode
        
        parent.addChild(node: vnode)
        
        if controller.navigationBarSize>0 {
            _tree.root.navBar=SCLUINavigationBar(controller:controller)
            let content=ViewNode(value: ConcreteNode(type:UIView.self, layoutSpec:{spec, context in 
                //fatalError()
                print("zstackview content layoutspec")
                spec.view?.clipsToBounds=true
                //if minLength>0 {yoga.width=minLength}
            }))
            _tree.root.navBarContent=_tree.root.navBar!.buildTree(parent:content,in:env)
        }
        
        //create a dummy node for content
        let content=ViewNode(value: ConcreteNode(type:UIView.self, layoutSpec:{spec, context in 
            //fatalError()
            print("zstackview content layoutspec")
            spec.view?.clipsToBounds=true
            //if minLength>0 {yoga.width=minLength}
        }))
        content.value!.setContext(_tree.root.navigation!.value!.context!) //this will also specify environment
        vnode.children.append(content)
            
        content.value!.setContext(_tree.root.navigation!.value!.context!) //this will also specify environment

        ViewExtractor.extractViews(contents: _tree.content).forEach { 
            //print("build list node ",$0)
            if let n=$0.buildTree(parent: content, in:content.runtimeenvironment) 
            {
                //elements.append(n)
                //print("got list view node ",n)
            }
        }
        
        //list.canReuseNodes=oldlist==nil || oldlist!.value==nil || list.node.structureMatches(to:oldlist!.value!)
        
        //  print("got list with tags ",_tree.root.list!.tags?.tagMapping ?? "nil")
        return vnode
    }
    
    public func makeCoordinator() -> Coordinator { 
        return Coordinator(self)
    }
    
    public class Coordinator:NSObject {
        let navigationView:NavigationView
        
        public init(_ navigationView:NavigationView) {
            self.navigationView=navigationView
        }
    }
}

class SCLNavigationBarHolder:UIView {
}

struct SCLUINavigationBar: UIViewRepresentable {
    internal var _layoutSpec=LayoutSpecWrapper<UIViewType>()
    var controller:NavigationViewController
    
    public init(controller:NavigationViewController) {self.controller=controller}
    
    public typealias Body = Never
    public typealias UIViewType = SCLNavigationBarHolder
    //public var context:SCLContext? = nil
    public var body: Never {
        fatalError()
    }
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> SCLUINavigationBar {_layoutSpec.add(spec);return self}
}

extension SCLUINavigationBar {
    
    public func makeUIView(context:UIViewRepresentableContext<SCLUINavigationBar>) -> UIViewType {
        return UIViewType(frame:CGRect(x:0,y:0,width:0,height:0))
    }
    
    public func updateUIView(_ view:UIViewType,context:UIViewRepresentableContext<SCLUINavigationBar>) -> Void {
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        
        let node=SCLNode(environment:env, host:self/*,type:UIView.self*/, reuseIdentifier:"SCLUINavigationBar",key:nil,layoutSpec: { spec, context in
                guard let yoga = spec.view?.yoga else { return }
                spec.view!.clipsToBounds=true
                self._layoutSpec.layoutSpec?(spec)
            }
            ,controller:defaultController
        )
        
        let vnode = ViewNode(value: node)
        parent.addChild(node: vnode)
        
        controller._barparent=vnode
        controller.makeNavigationBarContent(parent:vnode)
        
        return vnode
    }
}

class SCLNavigationStatusBarHolder:UIView {
}

class SCLNavigationDetailHolder:UIView {
}

extension NavigationView {
    public func makeUIView(context:Context) -> UIViewType {
        //print("make navigation controller view for \(context._viewController)")
        return context.viewController!.view 
    }
    
    public func updateUIView(_ view:UIViewType,context:Context) -> Void {
    }
    
    func addLayer(to vc:UIViewControllerType,node:ViewNode?,previousViews:[UIView]) -> DataSourceWrapper {
        let _dataSource=DataSourceWrapper()
        self._dataSource.append(_dataSource)
        
        let splitview=SCLUniversalSplitController()
        let vcv=SCLSplitViewContainer()
        splitview.view=vcv
        splitview.view.frame=CGRect.init(x: 0, y: 0, width: vc.view.frame.width, height: vc.view.frame.size.height)
        
        vc.push(viewController:splitview,animation:.none)
        
        _dataSource.masterController = SCLSplitMasterController()
        _dataSource.masterController!.view=SCLSplitContentView()
        _dataSource.masterController!.view.backgroundColor = .clear
        
        if let secondary=node {
            _dataSource.dataSource?.universalSplitController.detachDetailController()
            
            if secondary.children.count == 1 && secondary.children[0].value?.isControllerNode == true {
                //build view controller
                secondary.children[0].value?.build(in:nil,parent:nil,candidate:nil,
                                                   constrainedTo:vc.view.frame.size,with:[],forceLayout:false)
                //print("secondary is a controller:",secondary.children[0].value?.viewController," childcount:",secondary.children[0].value?.children.count)
                                                     
                _dataSource.detailController = secondary.children[0].value!.viewController!
                //_dataSource.detailController!.view.backgroundColor = .red
            }
            else {
                if _dataSource.detailController != nil {
                    _dataSource.detailController = SCLSplitDetailController()
                    _dataSource.detailController!.view=SCLSplitContentView()
                    _dataSource.detailController!.view.backgroundColor = .clear
                }
                else {
                    _dataSource.detailController = SCLSplitDetailController()
                    _dataSource.detailController!.view=SCLSplitContentView()
                    _dataSource.detailController!.view.backgroundColor = .clear
                }
                _dataSource.detailController!.view.frame=CGRect(x:0,y:0,width:vc.view.frame.size.width,height:vc.view.frame.size.height)
            }
            _dataSource.detailController!.node=secondary
        }
        else {
            _dataSource.detailController = SCLSplitDetailController()
            _dataSource.detailController!.view=SCLSplitContentView()
            _dataSource.detailController!.view.backgroundColor = .clear
        }
        
        _dataSource.dataSource = USCDataSource.Builder(parentController: splitview)
                  .setMasterController(_dataSource.masterController!, embedInNavController: false)
                  .setDetailController(_dataSource.detailController!, embedInNavController: false)
                  .setAppearance(.visibleInit)
                  //.setDirection(.trailing) //detail on right
                  .setDirection(.leading) //detail on left
                  //.showBlockerOnMaster(color: .black, opacity: 0.1, allowInteractions: true)
                  .swipeable()
                  .invokeAppearanceMethods()
                  .portraitAnimationProperties(duration: 0.35, forwardDampingRatio: 0.5)
                  .landscapeAnimationProperties(duration: 0.35, forwardDampingRatio: 0.5)
                  //.portraitCustomWidth(100.0)
                  .portraitCustomWidth(30,inPercentage:true) //detail width portrait
                  //.landscapeCustomWidth(100.0)
                  .landscapeCustomWidth(30,inPercentage:true) //detail width landscape
                  .visibilityChangesListener(willStartBlock: { (targetVisibility) in
                        //print("SplitView targetVisibility:\(targetVisibility)")
                  })
                  .build() 
                  
        //print("vc view:")
        //dumpView(view:vc.view)
    
        var navbar:SCLNavigationBarHolder?=nil
        if controller.navigationBarSize>0 {
            navbar=SCLNavigationBarHolder()
            navbar!.backgroundColor = .systemGray4
            _dataSource.detailController!.view.addSubview(navbar!)
    
            navbar!.translatesAutoresizingMaskIntoConstraints=false
            navbar!.leftAnchor.constraint(equalTo: _dataSource.detailController!.view.leftAnchor,constant:0).isActive = true
            navbar!.topAnchor.constraint(equalTo: _dataSource.detailController!.view.topAnchor,constant:0).isActive = true
            navbar!.rightAnchor.constraint(equalTo: _dataSource.detailController!.view.rightAnchor,constant:0).isActive = true
            navbar!.bottomAnchor.constraint(equalTo: _dataSource.detailController!.view.topAnchor,constant:controller.navigationBarSize).isActive = true
            
            var sz=_dataSource.detailController!.view.frame.size
            sz.height=controller.navigationBarSize
            
            if _tree.root.navBarContent!.value?.renderedView != nil {
                //reuse
                    
                _tree.root.navBarContent!.value!.renderedView!.removeFromSuperview()
                navbar!.addSubview(_tree.root.navBarContent!.value!.renderedView!)
            }
            else {
                _tree.root.navBarContent!.value?.build(in:navbar!,parent:nil,candidate:nil,constrainedTo:sz,with:[],forceLayout:false)
            }
            
            _tree.root.navBarContent!.value?.renderedView?.frame=CGRect.init(x: 0, y: 0, width: sz.width, height: sz.height)
                            
            _tree.root.navBarContent!.value?.reconcile(in:navbar!,constrainedTo:sz,with:[])
        }
        
        var sz=_dataSource.detailController!.view.frame.size
        sz.height=sz.height-controller.navigationBarSize-controller.statusBarSize
        
        let v=SCLNavigationDetailHolder()
        //v.backgroundColor = .green
        _dataSource.detailController!.view.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints=false
        v.leftAnchor.constraint(equalTo: _dataSource.detailController!.view.leftAnchor,constant:0).isActive = true
        v.topAnchor.constraint(equalTo: navbar?.bottomAnchor ?? _dataSource.detailController!.view.topAnchor,constant:0).isActive = true
        v.rightAnchor.constraint(equalTo: _dataSource.detailController!.view.rightAnchor,constant:0).isActive = true
        v.bottomAnchor.constraint(equalTo: _dataSource.detailController!.view.bottomAnchor,constant:-controller.statusBarSize).isActive = true
        
        _dataSource.detailController!.view.layoutIfNeeded()
        
        //print("detail dump:")
        //dumpView(view:_dataSource.detailController!.view)
        
        if let secondary=node {
            if secondary.children.count == 1 && secondary.children[0].value?.isControllerNode == true {
                secondary.children[0].value?.build(in:v,parent:nil,candidate:secondary.children[0].value!.viewController!.view,
                                                  constrainedTo:sz,with:[],forceLayout:false)
                
            }
            else {
                if secondary.children.count==1 {
                    //print("secondary=",secondary.children[0].value?.viewType)
                    if secondary.children[0].value?.renderedView != nil {
                        //reuse
                        //print("navigationview reuse ",secondary.children[0].value!.renderedView!)
                        //print("")
                        //print("reuse secondary split view")
                        secondary.children[0].value!.renderedView!.removeFromSuperview()
                        _dataSource.detailController!.view.addSubview(secondary.children[0].value!.renderedView!)
                    }
                    else {
                        //print("prev views:",previousViews)
                        if previousViews.count==1 {
                            var prev=previousViews[0];
                            //print("prev:",prev," sz=",sz)
                            //print("prev subviews:",prev.subviews)
                            if prev is SCLSplitViewContainer && prev.subviews.count==1 {
                                prev=prev.subviews[0]
                                //print("prev subviews:",prev.subviews)
                                //print("prev:",prev," sz=",sz)
                                if prev.subviews.count==2 {
                                    prev=prev.subviews[1]
                                    //print("here prev:",prev)
                                    if prev is SCLUniversalSplitControllerDetailHolder {
                                        prev=prev.subviews[0]
                                        //print("here prev:",prev)
                                        if prev is SCLUniversalSplitControllerDetailInnerHolder {
                                            prev=prev.subviews[0]
                                            if prev is SCLSplitContentView {
                                                secondary.children[0].value?.origCandidate=prev.subviews[0]
                                                if secondary.children[0].value?.origCandidate is SCLNavigationBarHolder { //has a navbar
                                                    secondary.children[0].value?.origCandidate=prev.subviews[1]
                                                }
                                                if secondary.children[0].value?.origCandidate is SCLNavigationDetailHolder {
                                                    secondary.children[0].value?.origCandidate=secondary.children[0].value?.origCandidate!.subviews[0]
                                                }
                                            }
                                            //print("final orig candidate:",secondary.children[0].value?.origCandidate)
                                        }
                                    }
                                }
                            }
                        }
                        
                        //print("")
                        //print("build secondary splitview orig candidate:",secondary.children[0].value?.origCandidate)
                        secondary.children[0].value?.build(in:v,parent:nil,candidate:secondary.children[0].value?.origCandidate,
                                                           constrainedTo:sz,with:[],forceLayout:false)
                    }
                    
                    //print("scondary view do layout")
                    //dumpView(view:_dataSource.detailController!.view)
                    
                    secondary.children[0].value?.renderedView?.frame=CGRect.init(x: 0, y: 0, width: sz.width, height: sz.height)
                    //print("secondary frame:",secondary.children[0].value?.renderedView?.frame)
                            
                    secondary.children[0].value?.reconcile(in:v,constrainedTo:sz,with:[])
                                                         
                    //toUpdate.append(secondary.children[0])
                    
                    //print("scondary view did layout")
                    //dumpView(view:_dataSource.detailController!.view)
                }
                else {
                    print("Secondary node of NavigationView has none or multiple children. Cannot build")
                }
            }
        }          
        
        if controller.statusBarSize>0 {
            let statusbar=SCLNavigationStatusBarHolder()
            statusbar.backgroundColor = .systemGray5
            _dataSource.detailController!.view.addSubview(statusbar)
    
            statusbar.translatesAutoresizingMaskIntoConstraints=false
            statusbar.leftAnchor.constraint(equalTo: _dataSource.detailController!.view.leftAnchor,constant:0).isActive = true
            statusbar.topAnchor.constraint(equalTo: _dataSource.detailController!.view.bottomAnchor,constant:-controller.statusBarSize).isActive = true
            statusbar.rightAnchor.constraint(equalTo: _dataSource.detailController!.view.rightAnchor,constant:0).isActive = true
            statusbar.bottomAnchor.constraint(equalTo: _dataSource.detailController!.view.bottomAnchor,constant:0).isActive = true
        }
        
        //print("addLayer End")
        //dumpView(view:_dataSource.detailController!.view)
        
        return _dataSource
    }
    
    public func reconcileUIView(_ view:UIViewType,context:Context, constrainedTo size:CGSize, with parentView:UIView?,previousViews:[UIView]) -> [ViewNode] {
        
        if let vc=context.viewController as? UIViewControllerType {
            //vc.rootViewController=parentView?.superview?.findViewController() ?? Application?.rootViewController
            //print("parent:",parentView)
            //print("navigationview root:",vc.rootViewController)
            
            vc.clear()
            self._dataSource.clear()
            //print("NavigationView reconcile"
            //for v in previousViews {dumpView(view:v)}
            //dumpView(view:view)
            //dumpView(controller:vc)
            
            let _dataSource=addLayer(to:vc,node:_tree.root.navigation!.children[0],previousViews:previousViews)
            var toUpdate:[ViewNode]=[]
            let secondary=_tree.root.navigation!.children[0]
            
            _dataSource.masterController!.view.backgroundColor = .blue
            _dataSource.detailController!.view.backgroundColor = .clear
            
            if secondary.children.count>0 && secondary.children[0].value != nil {toUpdate.append(secondary.children[0])}
            
            //print("NavigationView reconcile end")
            //dumpView(view:view)
            //dumpView(controller:vc)
            
            return toUpdate
        }
        else {fatalError()}
    }
    
    public func structureMatches(to:ViewNode) -> Bool {
        if to.value==nil {return false}
        
        //print("navigationview structurematches for self=",self," to=",to)
        
        if _tree.root.navigation?.value==nil {return false}
        
        if !_tree.root.navigation!.structureMatches(to:to) {return false}
        
        //print("structure matches")
        return true
    }
}

























