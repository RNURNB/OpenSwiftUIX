import Foundation
import CoreRender


public struct Alignment {
    public var horizontal: HorizontalAlignment
    public var vertical: VerticalAlignment
    
    public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
    
    public static var center: Alignment {
        return Alignment(horizontal: HorizontalAlignment.center, vertical: VerticalAlignment.center)
    }
    
    public static var leading: Alignment {
        return Alignment(horizontal: HorizontalAlignment.leading, vertical: VerticalAlignment.center)
    }
    
    public static var trailing: Alignment {
        return Alignment(horizontal: HorizontalAlignment.trailing, vertical: VerticalAlignment.center)
    }
    
    public static var top: Alignment {
        return Alignment(horizontal: HorizontalAlignment.center, vertical: VerticalAlignment.top)
    }
    
    public static var bottom: Alignment {
        return Alignment(horizontal: HorizontalAlignment.center, vertical: VerticalAlignment.bottom)
    }
    
    public static var topLeading: Alignment {
        return Alignment(horizontal: HorizontalAlignment.leading, vertical: VerticalAlignment.top)
    }
    
    public static var topTrailing: Alignment {
        return Alignment(horizontal: HorizontalAlignment.trailing, vertical: VerticalAlignment.top)
    }
    
    public static var bottomLeading: Alignment {
        return Alignment(horizontal: HorizontalAlignment.leading, vertical: VerticalAlignment.bottom)
    }
    
    public static var bottomTrailing: Alignment {
        return Alignment(horizontal: HorizontalAlignment.trailing, vertical: VerticalAlignment.bottom)
    }
}

public struct ViewDimensions {
    public var width: CGFloat {
        return 0
    }
    public var height: CGFloat {
        return 0
    }
    public subscript(guide: HorizontalAlignment) -> CGFloat {
        return 0
    }
    public subscript(guide: VerticalAlignment) -> CGFloat {
        return 0
    }
    public subscript(explicit guide: HorizontalAlignment) -> CGFloat? {
        return 0
    }
    public subscript(explicit guide: VerticalAlignment) -> CGFloat? {
        return 0
    }
}

extension ViewDimensions: Equatable {
    public static func == (lhs: ViewDimensions, rhs: ViewDimensions) -> Bool {
        return true
    }
}

public protocol AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat
}

struct AlignmentKey: Hashable, Comparable {
    private let bits: UInt
    internal static func < (lhs: AlignmentKey, rhs: AlignmentKey) -> Bool {
        return lhs.bits < rhs.bits
    }
}

// FIXME: This is not the actual implementation. SwiftUI does not use enums. See below
public enum HorizontalAlignment {
    case leading
    case center
    case trailing
    case spaceBetween
    case spaceAround
    case stretch
}

// FIXME: This is not the actual implementation. SwiftUI does not use enums. See below.
public enum VerticalAlignment {
    case top
    case center
    case bottom
    //case firstTextBaseline
    //case lastTextBaseline
    case spaceBetween
    case spaceAround
    case stretch
}


public struct _VStackLayout {
    public var alignment: HorizontalAlignment
    public var spacing: CGFloat?
    public var reversed: Bool
    @inlinable public init(alignment: HorizontalAlignment = .leading, spacing: CGFloat? = nil, reversed:Bool=false) {
        self.alignment = alignment
        self.spacing = spacing
        self.reversed=reversed
    }
    public typealias Body = Never
}

public class SCLVStack:UIView {
}

extension _VStackLayout: _VariadicView_UnaryViewRoot {}
extension _VStackLayout: _VariadicView_ViewRoot {}

public struct VStack<Content>: UIViewRepresentable where Content: View {
    public typealias Body = Never
    public typealias UIViewType = SCLVStack
    public var context:SCLContext? = nil
    public var _tree: _VariadicView.Tree<_VStackLayout, Content>
    private var _layoutSpec=LayoutSpecWrapper<UIViewType>()
    
    public init(alignment: HorizontalAlignment = .leading, spacing: CGFloat? = nil,reversed:Bool=false, @ViewBuilder content: () -> Content) {
        _tree = .init(
            root: _VStackLayout(alignment: alignment, spacing: spacing, reversed:reversed), content: content())
    }
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> VStack<Content> {
       _layoutSpec.add(spec)
       return self
    }
}
 
extension VStack {
    public var body: Never {
        fatalError()
    }
}

public struct _HStackLayout {
    public var alignment: VerticalAlignment
    public var spacing: CGFloat?
    public var reversed: Bool
    @inlinable public init(alignment: VerticalAlignment = .top, spacing: CGFloat? = nil, reversed:Bool=false) {
        self.alignment = alignment
        self.spacing = spacing
        self.reversed=reversed
    }
    public typealias Body = Never
}

public class SCLHStack:UIView {
}

extension _HStackLayout: _VariadicView_UnaryViewRoot {}

public struct HStack<Content>: UIViewRepresentable where Content: View {
    public typealias Body = Never
    public typealias UIViewType = SCLHStack
    public var context:SCLContext? = nil
    public var _tree: _VariadicView.Tree<_HStackLayout, Content>
    private var _layoutSpec=LayoutSpecWrapper<UIViewType>()
    
    public init(alignment: VerticalAlignment = . top, spacing: CGFloat? = nil, reversed:Bool=false, @ViewBuilder content: () -> Content) {
        _tree = .init(
            root: _HStackLayout(alignment: alignment, spacing: spacing,reversed:reversed), content: content())
    }
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> HStack<Content> {
       //print("HStackwithLayoutSpec \(spec)")
       _layoutSpec.add(spec)
       return self
    }
}

extension HStack {
    public var body: Never {
        fatalError()
    }
}

/*
public struct _ZStackLayout {
    public var alignment: Alignment
    public init(alignment: Alignment = .center) {
        self.alignment = alignment
    }
    public typealias Body = Never
}

extension _ZStackLayout: _VariadicView_UnaryViewRoot {}

public struct ZStack<Content>: View where Content: View {
    public typealias Body = Never
    public var _tree: _VariadicView.Tree<_ZStackLayout, Content>
    public var _layoutSpec=LayoutSpecWrapper()
    
    public init(alignment: Alignment = .center, @ViewBuilder content: () -> Content) {
        _tree = .init(
            root: _ZStackLayout(alignment: alignment), content: content())
    }
    
    //public typealias UIBody = UIView
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIView/*Self.UIBody*/>) -> Void) -> ZStack<Content> {
       _layoutSpec.add(spec)
       return self
    }
}

extension ZStack {
    public var body: Never {
        fatalError()
    }
}
*/


extension HStack {
    
    public func makeUIView(context:UIViewRepresentableContext<HStack>) -> UIViewType {
        UIViewType(frame:CGRect(x:0,y:0,width:0,height:0))
    }
    
    public func updateUIView(_ view:UIViewType,context:UIViewRepresentableContext<HStack>) -> Void {
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        
        let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"HStack",key:nil,layoutSpec: { spec, context in
                guard let yoga = spec.view?.yoga else { return }
                spec.view!.clipsToBounds=true
                yoga.flexDirection = _tree.root.reversed ? .rowReverse : .row 
                if _tree.root.alignment == .center {yoga.justifyContent = .center}
                else if _tree.root.alignment == .bottom {yoga.justifyContent = .flexEnd}
                else if _tree.root.alignment == .spaceBetween {yoga.justifyContent = .spaceBetween}
                else if _tree.root.alignment == .spaceAround {yoga.justifyContent = .spaceAround}
                else {yoga.justifyContent = .flexStart}
                yoga.alignItems = .flexStart
                yoga.flex()
                //print("HStack spec layout=\(self._layoutSpec) align=\(yoga.alignItems.rawValue)")
                self._layoutSpec.layoutSpec?(spec)
                //print("HStack spec end 2 align=\(yoga.alignItems.rawValue)")
                //yoga.alignItems = .center
                //yoga.justifyContent = .center
                //print("HStack dimensions:",spec.view!.frame)
            }
            ,controller:defaultController
        )
        
        let vnode = ViewNode(value: node)
        parent.addChild(node: vnode)
        
        ViewExtractor.extractViews(contents: _tree.content).forEach {
            if let n=$0.buildTree(parent: vnode, in:vnode.runtimeenvironment) 
            {
                //print("n=\(type(of:n))")
                n.addLayoutSpec { spec in
                    guard let yoga = spec.view?.yoga else { return }
                    if let s=_tree.root.spacing {yoga.marginLeft=s}
                }
            }
        }
        
        return vnode
    }
}

extension VStack {
    
    public func makeUIView(context:UIViewRepresentableContext<VStack>) -> UIViewType {
        UIViewType(frame:CGRect(x:0,y:0,width:0,height:0))
    }
    
    public func updateUIView(_ view:UIViewType, context:UIViewRepresentableContext<VStack>) -> Void {
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        
        //print("VStack build tree")
        
        let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"VStack",key:nil,layoutSpec: { spec, context in
                //print("vstack for layout=\(spec) view ",spec.view)
                guard let yoga = spec.view?.yoga else { return }
                spec.view!.clipsToBounds=true
                yoga.flexDirection = _tree.root.reversed ? .columnReverse : .column 
                if _tree.root.alignment == .center {yoga.justifyContent = .center}
                else if _tree.root.alignment == .trailing {yoga.justifyContent = .flexEnd}
                else if _tree.root.alignment == .spaceBetween {yoga.justifyContent = .spaceBetween}
                else if _tree.root.alignment == .spaceAround {yoga.justifyContent = .spaceAround}
                else {yoga.justifyContent = .flexStart}
                yoga.alignItems = .flexStart
                //yoga.padding=100
                yoga.flex()
                //print("calling layoutspec \(self._layoutSpec.layoutSpec)")
                self._layoutSpec.layoutSpec?(spec)
                //yoga.alignItems = .center
                //yoga.justifyContent = .center
                //print("frame is ",spec.view?.frame," yoga height is ",yoga.height)
            },
            controller:defaultController
        )
        
        let vnode = ViewNode(value: node)
        parent.addChild(node: vnode)
        
        ViewExtractor.extractViews(contents: _tree.content).forEach {
            //$0.buildTree(parent: vnode)
            if let n=$0.buildTree(parent: vnode, in:vnode.runtimeenvironment) 
            {
                //print("n=\(type(of:n))")
                n.addLayoutSpec { spec in
                    guard let yoga = spec.view?.yoga else { return }
                    if let s=_tree.root.spacing {yoga.marginTop=s}
                }
            }
        }
        
        return vnode
    }
}

/*
extension ZStack: ViewBuildable {
    public func buildTree(parent: ViewNode) -> ViewNode? {
        let node=SCLNode(type:UIView.self,layoutSpec: { spec in
                /*guard let yoga = spec.view?.yoga else { return }
                yoga.flexDirection = .column
                yoga.justifyContent = .flexStart
                yoga.alignItems = .flexStart
                yoga.flex()*/
                self._layoutSpec.layoutSpec?(spec)
            }
        )
        
        let vnode = ViewNode(value: node)
        parent.addChild(node: vnode)
        
        ViewExtractor.extractViews(contents: _tree.content).forEach {
            $0.buildTree(parent: vnode)
        }
        
        return vnode
    }
}

*/


public struct _ZStackViewLayout {
    var zstack:ViewNode?
    
    @inlinable public init() {
    }
    
    public typealias Body = Never
}

extension _ZStackViewLayout: _VariadicView_UnaryViewRoot {}
extension _ZStackViewLayout: _VariadicView_ViewRoot {}


public struct ZStackView<Content>:UIViewControllerRepresentable where Content: View {
    public typealias UIViewControllerType=SCLNavigationViewController
    public typealias Body = Never
    public typealias UIContainerType = SCLZStackViewContainer
    
    public var _tree: _VariadicView.Tree<_ZStackViewLayout, Content>
    private var _layoutSpec=LayoutSpecWrapper<UIViewType>()
    
    public init(@ViewBuilder content: () -> Content) {
        _tree = .init(
            root: _ZStackViewLayout() , content: content())
    }
    
    public func makeUIViewController(context:Context) -> UIViewControllerType {
        let vc=UIViewControllerType()
        vc.node=_tree.root.zstack!
        let v=UIContainerType()
        vc.view=v
        
        return vc
    }
    
    public func updateUIViewController(_ view:UIViewControllerType,context:Context) -> Void {
    }
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> ZStackView<Content> {
       _layoutSpec.add(spec)
       return self
    }
}

extension ZStackView {
    public var body: Never {
        fatalError()
    }
}

extension ZStackView {
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context

        /*let oldlist=_tree.root.list
        let list=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"list",key:nil,layoutSpec: {spec, context in
            //print("called list root layout")
        })
        _tree.root.list=ViewNode(value: list)*/
            
        //print("create navigation node")
        let node=SCLNode(environment:env, host:self,reuseIdentifier:"ZStackView",key:nil,layoutSpec: { spec, context in
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
        _tree.root.zstack=vnode
        
        //create a dummy node for primary
        let primary=ViewNode(value: ConcreteNode(type:UIView.self, layoutSpec:{spec, context in 
            //fatalError()
            print("zstackview primary layoutspec")
            spec.view?.clipsToBounds=true
            //if minLength>0 {yoga.width=minLength}
        }))
        primary.value!.setContext(_tree.root.zstack!.value!.context!) //this will also specify environment
        vnode.children.append(primary)
        
        parent.addChild(node: vnode)

        ViewExtractor.extractViews(contents: _tree.content).forEach { 
            //print("build list node ",$0)
            if let n=$0.buildTree(parent: primary, in:primary.runtimeenvironment) 
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
        let zstackView:ZStackView
        
        public init(_ zstackView:ZStackView) {
            self.zstackView=zstackView
        }
    }
}

public class SCLZStackViewContainer:UIView {
}

extension ZStackView {
    public func makeUIView(context:Context) -> UIViewType {
        context.viewController?.view.backgroundColor = .clear
        return context.viewController!.view
    }
    
    //update all controller children
    public func reconcileUIView(_ view:UIViewType,context:Context, constrainedTo size:CGSize, with parentView:UIView?,previousViews:[UIView]) -> [ViewNode] {
        //print("reconcile zstackview ",view," controller=",context.viewController?.view)
        
        if let vc=context.viewController as? UIViewControllerType {
            let primary=_tree.root.zstack!.children[0]
            
            if primary.children.count == 1 && primary.children[0].value?.isControllerNode == true {
                if primary.children.count==1 {
                    primary.children[0].value?.build(in:nil,parent:nil,candidate:nil,constrainedTo:vc.view.frame.size,with:[],forceLayout:false)
                    print("zstack primary is a controller:",primary.children[0].value?.viewController)
                                                    
                    return [primary.children[0]]
                }
                else {
                    print("Primary node of ZStackView has none or multiple children. Cannot build")
                    return []
                }
            }
            
            if primary.children.count==1 {
                if primary.children[0].value?.renderedView != nil {
                    //reuse
                    //print("zstackviewcreconcile reuse ",primary.children[0].value!.renderedView!)
                    primary.children[0].value!.renderedView!.removeFromSuperview()
                    vc.view.addSubview(primary.children[0].value!.renderedView!)
                }
                else {
                    //print("reconcile ",primary.children[0].value?.renderedView,"parent ",primary.children[0].value?.renderedView?.superview)
                    primary.children[0].value?.build(in:vc.view,parent:nil,candidate:nil, constrainedTo:vc.view.frame.size,with:[],forceLayout:false)
                }
                
                //print("controller build done. controller layout start")
                
                //print("")
                //print("view=",view," parent of root=",primary.children[0].value?.renderedView?.superview)
                
                primary.children[0].value?.renderedView?.frame=CGRect.init(x: 0, y: 0,width: vc.view.frame.width,height: vc.view.frame.size.height)
                //print("primary frame:",primary.children[0].value?.renderedView?.frame)
                            
                primary.children[0].value?.reconcile(in:vc.view,constrainedTo:vc.view.frame.size,with:[])
                
                //print("controller layout done")
                                                         
                return [primary.children[0]]
            }
            else {
                print("Primary node of ZStackView has none or multiple children. Cannot build")
            }
            
            return []
        }
        else {fatalError()}
    }
    
    public func updateUIView(_ view:UIViewType,context:Context) -> Void {
    }
    
    public func structureMatches(to:ViewNode) -> Bool {
        if to.value==nil {return false}
        if _tree.root.zstack?.value==nil {return false}
        
        if !_tree.root.zstack!.structureMatches(to:to) {return false}
        
        //print("structure matches")
        return true
    }
}








