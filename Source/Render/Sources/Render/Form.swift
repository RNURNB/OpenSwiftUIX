import Foundation
import CoreRender
import UIKit

/*public func SCLForm<V:SCLView> (context:SCLContext,with:CRNodeLayoutOptions,view:V) -> SCLHostingView<V> {
    let hostingView=SCLHostingView<V>(context: context, with: with,view:view)
    return hostingView
}
*/


open class SCLFormController: SCLRootViewController {
    override public init()
    {
        super.init()
    }
    
    public required init?(coder: NSCoder) 
    {
        super.init(coder:coder)
    }
}

public class SCLSection:UIView {
}

public struct _SectionLayout<HeaderContent,FooterContent> where HeaderContent: View, FooterContent: View {
    var header:HeaderContent?=nil
    var footer:FooterContent?=nil
    
    @inlinable public init() {
    }
    public typealias Body = Never
}

extension _SectionLayout: _VariadicView_UnaryViewRoot {}
extension _SectionLayout: _VariadicView_ViewRoot {}

public struct Section<Content,HeaderContent,FooterContent>: UIViewRepresentable where Content: View, HeaderContent: View, FooterContent: View {
    public typealias Body = Never
    public typealias UIViewType = SCLSection
    //public var context:SCLContext? = nil
    public var _tree: _VariadicView.Tree<_SectionLayout<HeaderContent,FooterContent>, Content>
    private var _layoutSpec=LayoutSpecWrapper<UIViewType>()
    
    public init(header:HeaderContent/*@ViewBuilder header: () -> Content*/, footer:FooterContent/*@ViewBuilder footer: () -> Content*/, @ViewBuilder content: () -> Content) {
        _tree = .init(
            root: _SectionLayout<HeaderContent,FooterContent>() , content: content())
        if !(header is EmptyView) {_tree.root.header=header}
        if !(footer is EmptyView) {_tree.root.footer=footer}
    }
    
    /*public init(@ViewBuilder content: () -> Content) {
        _tree = .init(
            root: _SectionLayout<HeaderContent,FooterContent>() , content: content())
    }*/
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> Section<Content,HeaderContent,FooterContent> {
       //print("section add layoutspec")
       _layoutSpec.add(spec)
       return self
    }
}

extension Section {
    public var body: Never {
        fatalError()
    }
}

extension Section where FooterContent==EmptyView {
    public init(header:HeaderContent, @ViewBuilder content: () -> Content) {
        self.init(header:header, footer: EmptyView(), content:content)
    }
}

extension Section where HeaderContent==EmptyView {
    public init(footer:FooterContent, @ViewBuilder content: () -> Content) {
        self.init(header:EmptyView(), footer: footer, content:content)
    }
}

extension Section where HeaderContent==EmptyView, FooterContent==EmptyView {
    public init(@ViewBuilder content: () -> Content) {
        self.init(header:EmptyView(), footer: EmptyView(), content:content)
    }
}

extension Section where HeaderContent==Text, FooterContent==EmptyView {
    public init(_ title:LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.init(header:Text(title), footer: EmptyView(), content:content)
    }
}


extension Section {
    
    public func makeUIView(context:UIViewRepresentableContext<Section>) -> UIViewType {
        UIViewType(frame:CGRect(x:0,y:0,width:0,height:0))
    }
    
    public func updateUIView(_ view:UIViewType,context:UIViewRepresentableContext<Section>) -> Void {
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        var env=parent.runtimeenvironment
        
        let node=SCLNode(environment:env, host:self,reuseIdentifier:"Section",key:nil,layoutSpec: { spec, context in
                print("section for layout=\(spec)")
                guard let yoga = spec.view?.yoga else { return }
                spec.view!.clipsToBounds=true
                
                self._layoutSpec.layoutSpec?(spec)
            },
            controller:defaultController
        )
        //node.node.header=_tree.root.header?.text
        //node.node.footer=_tree.root.footer?.text
        
        let vnode = ViewNode(value: node)
        parent.addChild(node: vnode)
        
        ViewExtractor.extractViews(contents: _tree.content).forEach {
            //$0.buildTree(parent: vnode)
            if let n=$0.buildTree(parent: vnode, in: vnode.runtimeenvironment) 
            {
               //
            }
        }
        
        if _tree.root.header != nil {
            var env=parent.runtimeenvironment
            
            let hnode=SCLNode(environment:env, host:self/*,type:UIView.self*/,
                              reuseIdentifier:"SectionHeader",key:nil,layoutSpec: { spec, context in
                //print("vstack for layout=\(spec)")
                guard let yoga = spec.view?.yoga else { return }
                spec.view!.clipsToBounds=true
              }
              ,controller:defaultController
            )
            node.node?.header=hnode.node?.viewnode()
            let vhnode = ViewNode(value: hnode)
            
            //vnode.addChild(node: vhnode)
            
            ViewExtractor.extractViews(contents: _tree.root.header!).forEach {
                if let n=$0.buildTree(parent: vhnode, in:vhnode.runtimeenvironment) 
                {
                   //
                }
            }
        }
        
        if _tree.root.footer != nil {
            var env=parent.runtimeenvironment
            
            let fnode=SCLNode(environment:env, host:self/*,type:UIView.self*/,
                              reuseIdentifier:"SectionFooter",key:nil,layoutSpec: { spec, context in
                //print("vstack for layout=\(spec)")
                guard let yoga = spec.view?.yoga else { return }
                spec.view!.clipsToBounds=true
              }
              ,controller:defaultController
            )
            node.node?.footer=fnode.node?.viewnode()
            let vfnode = ViewNode(value: fnode)
            
            //vnode.addChild(node: vfnode)
            
            ViewExtractor.extractViews(contents: _tree.root.footer!).forEach {
                if let n=$0.buildTree(parent: vfnode, in:vfnode.runtimeenvironment) 
                {
                   //
                }
            }
        }
        
        return vnode
    }
}

public struct Group<Content> {
    public var context:SCLContext?
    
    public var _content: Content
}

extension Group: _View where Content: _View {
    public var viewBuildable:UIViewBuildable? {nil}
    public var viewBuildableList:UIViewBuildableList? {nil}
}

extension Group: View where Content: View {
    
    public typealias Body = Never
    
    public init(@ViewBuilder content: () -> Content) {
        self._content = content()
    }
    
    public var body: Never {
        fatalError()
    }
}

public class SCLSpacer:UIView {
}

public struct Spacer: UIViewRepresentable {
    internal var _layoutSpec=LayoutSpecWrapper<UIViewType>()
    var minLength:CGFloat
    
    public init(minLength:CGFloat=0.0) {
        self.minLength=minLength
    }
    
    public typealias Body = Never
    public typealias UIViewType = SCLSpacer
    //public var context:SCLContext? = nil
    public var body: Never {
        fatalError()
    }
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> Spacer {_layoutSpec.add(spec);return self}
}

extension Spacer {
    
    public func makeUIView(context:UIViewRepresentableContext<Spacer>) -> UIViewType {
        return UIViewType(frame:CGRect(x:0,y:0,width:0,height:0))
    }
    
    public func updateUIView(_ view:UIViewType,context:UIViewRepresentableContext<Spacer>) -> Void {
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        
        let node=SCLNode(environment:env, host:self/*,type:UIView.self*/, reuseIdentifier:"Spacer",key:nil,layoutSpec: { spec, context in
                guard let yoga = spec.view?.yoga else { return }
                spec.view!.clipsToBounds=true
                //if minLength>0 {yoga.width=minLength}
                if self.minLength>0 {
                   yoga.flexGrow=1.0
                   yoga.flex()
                }
                self._layoutSpec.layoutSpec?(spec)
            }
            ,controller:defaultController
        )
        
        let vnode = ViewNode(value: node)
        parent.addChild(node: vnode)
        
        return vnode
    }
}













