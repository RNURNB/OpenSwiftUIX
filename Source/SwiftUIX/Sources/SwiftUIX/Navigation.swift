  
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
    //var navigationBar: NavigationBar?
    
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
    /*
    func activate(_ navigationBar: NavigationBar, on viewController: UIViewController) {
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
                viewController.navigation.set(backButton: .regular(), animation: .none).addTarget(navigationBar.navigationViewController, action: #selector(NavigationViewController.goBack(_:)), for: .touchUpInside)
            } else {
                navigationBar.leadingItemsContentView.set(items: viewController.navigation.leftItems, animation: .none)
            }
        }
        
        navigationBar.trailingItemsContentView.set(items: viewController.navigation.rightItems, animation: .none)
    }
    */
    
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
    //public internal(set) var navigationBar: NavigationBar!
    
    /// Root view controller
    public let rootViewController: UIViewController?
    
    /// Private view controller stack
    var _viewControllers: [UIViewController] = []
    
    /// Navigation managers
    var navigationManagers: [ObjectIdentifier: SCLNavigationManager] = [:]
    
    /// Is animating
    var isAnimating: Bool = false
    
    // MARK: View lifecycle
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateSafeArea()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Navigation bar
        /*navigationBar = NavigationBar(minHeight: 44)
        navigationBar.navigationViewController = self
        view.addSubview(navigationBar)
        navigationBar.layout.sides()
        navigationBar.layout.top()*/
        
        // Add the root view controller onto the scene
        if rootViewController != nil {
            register(managerFor: rootViewController!, animation: .none)
            add(childViewController: rootViewController!)
            change(navigationItemFrom: rootViewController!, animationTime: 0.0)
        }
    }
    
    /// Change navigation item
    func change(navigationItemFrom viewController: UIViewController, animationTime: TimeInterval) {
        //viewController.navigation.activate(navigationBar, on: viewController)
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
    @discardableResult func animate(upperViewController: UIViewController, to lowerViewController: UIViewController, finished: @escaping (() -> Void)) -> TimeInterval {
        guard
            let upperManager = upperViewController.navigationManager,
            let lowerManager = lowerViewController.navigationManager,
            upperManager.animation.storage != SCLAnimation.Storage.none,
            let lowerLeftConstraint = lowerManager.leftConstraint,
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
    @discardableResult func animate(_ viewController: UIViewController, over previousViewController: UIViewController, finished: @escaping (() -> Void)) -> TimeInterval {
        guard
            let previousManager = previousViewController.navigationManager,
            let newManager = viewController.navigationManager,
            newManager.animation.storage != SCLAnimation.Storage.none,
            let newLeftConstraint = newManager.leftConstraint,
            let previousLeftConstraint = previousManager.leftConstraint else {
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
        guard viewControllers.count > 1, let upperViewController = viewControllers.last else {
            return nil
        }
        
        // Update animation if neccessary
        switch animation.storage {
        case .default, .none:
            break
        default:
            upperViewController.navigationManager?.animation = animation
        }
        
        let previousViewController = viewControllers[viewControllers.count - 2]
        
        // Add previous view controller back on
        add(childViewController: previousViewController)
        view.bringSubviewToFront(upperViewController.view)
        //view.bringSubviewToFront(navigationBar)
        
        // Animate
        let time = animate(upperViewController: upperViewController, to: previousViewController) {
            self.remove(childViewController: upperViewController)
        }
        change(navigationItemFrom: previousViewController, animationTime: time)
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
    public func push(viewController: UIViewController, animation: SCLAnimation = .default()) {
        guard let previous = viewControllers.last else {
            fatalError("This should never happen")
        }
        isAnimating = true
        
        register(managerFor: viewController, animation: animation)
        
        viewController.navigation.navigationController = self
        viewControllers.append(viewController)
        
        add(childViewController: viewController)
        
        let time = animate(viewController, over: previous) {
            self.remove(childViewController: previous)
            
            self.isAnimating = false
        }
        change(navigationItemFrom: viewController, animationTime: time)
    }
    
    /// Set save area on all involved view controllers
    internal func updateSafeArea() {
        if #available(iOS 11.0, *) {
            for c in viewControllers {
                // TODO: Update only active view controllers!
                //c.additionalSafeAreaInsets.top = navigationBar.bounds.height - view.safeAreaInsets.top
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
        //view.bringSubview(toFront: navigationBar)
        childViewController.navigationManager?.leftConstraint = setConstraints(on: childViewController)
        
        updateSafeArea()
    }
}

public struct _NavigationViewLayout {
    var list:ViewNode?
    
    @inlinable public init() {
    }
    
    public typealias Body = Never
}

extension _NavigationViewLayout: _VariadicView_UnaryViewRoot {}
extension _NavigationViewLayout: _VariadicView_ViewRoot {}

public class SCLNavigationViewContainer:UIView {
}

public struct NavigationView<Content>:UIViewControllerRepresentable where Content: View {
    public typealias UIViewControllerType=SCLNavigationViewController
    public typealias Body = Never
    public typealias UIContainerType = SCLNavigationViewContainer
    
    public var _tree: _VariadicView.Tree<_NavigationViewLayout, Content>
    private var _layoutSpec=LayoutSpecWrapper<UIViewType>()
    
    public init(@ViewBuilder content: () -> Content) {
        _tree = .init(
            root: _NavigationViewLayout() , content: content())
    }
    
    public func makeUIViewController(context:Context) -> UIViewControllerType {
        //print("make navigation viewcontroller")
        let vc=UIViewControllerType()
        //print("NavigationBar frame=",vc.navigationBar.frame)
        //vc.isNavigationBarHidden=true
        let v=UIContainerType()
        vc.view=v
        
        return vc
    }
    
    public func updateUIViewController(_ view:UIViewControllerType,context:Context) -> Void {
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

        /*let oldlist=_tree.root.list
        let list=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"list",key:nil,layoutSpec: {spec in
            //print("called list root layout")
        })
        _tree.root.list=ViewNode(value: list)*/
            
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
        _tree.root.list=vnode
        
        parent.addChild(node: vnode)

        ViewExtractor.extractViews(contents: _tree.content).forEach { 
            //print("build list node ",$0)
            if let n=$0.buildTree(parent: _tree.root.list!, in:_tree.root.list!.runtimeenvironment) 
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

extension NavigationView {
    public func makeUIView(context:Context) -> UIViewType {
        //print("make navigation controller view for \(context._viewController)")
        return context.viewController!.view 
    }
    
    public func updateUIView(_ view:UIViewType,context:Context) -> Void {
    }
    
    public func reconcileUIView(_ view:UIViewType,context:Context, constrainedTo size:CGSize, with parentView:UIView?,previousViews:[UIView]) -> [ViewNode] {
        //todo
        return []
    }
}

























