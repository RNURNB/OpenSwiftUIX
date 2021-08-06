import Foundation
import UIKit
import CoreRender

public class SCLButton: UIButton {
  func setChildrenStatus(_ touchInside:Bool) {
      for v in subviews {
            if !v.isHidden && !v.isUserInteractionEnabled /*&& v.point(inside: self.convert(point, to: v), with: event)*/ {
                v.alpha = touchInside ? 0.4 : 1.0
                //alert("button","point \(ok)")
                break
            }
      }
  }  
    
  /*public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    var ok=super.point(inside:point,with:event)
    setChildrenStatus(ok)
    return ok
  }*/
  
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches,with:event)
    //print("finger touched the screen...")
    setChildrenStatus(true)
  }
  
  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches,with:event)
    //print("finger touched the screen...")
    if let touch = touches.first as? UITouch {
        let point = touch.location(in:self)
        setChildrenStatus((self.bounds.contains(point)))
    }
  }
  
  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches,with:event)
    //print("finger touched the screen...")
    //alert("button","touch end")
    setChildrenStatus(false)
  }
}

public struct Button<Content>: UIViewRepresentable where Content: View {
    public typealias Body = Content
    public typealias UIViewType=SCLButton
    //public var context:SCLContext?=nil
    private var _layoutSpec=LayoutSpecWrapper<SCLButton>()
    
    public let _content: Content
    public let _action: () -> Void
    public let _text : String?
    public let _localized : LocalizedStringKey?
    
    public var body: Content {
        return _content
    }
    
    public init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self._action = action
        self._content = content()
        self._text=nil
        self._localized=nil
    }
    
    @_disfavoredOverload //without this, the initializer below with LocalizedStringKey would never be called
    init<S>(_ text:S,action: @escaping () -> Void, @ViewBuilder content: () -> Content) where S: StringProtocol {
        self._text=String(text)
        self._localized=nil
        self._action=action
        self._content=content()
    }
    
    init(verbatim text:String,action: @escaping () -> Void, @ViewBuilder content: () -> Content)  {
        self._text=text
        self._localized=nil
        self._action=action
        self._content=content()
    }

    init(_ text:LocalizedStringKey,action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        //print("localizedbutton:",text)
        self._localized=text
        self._text=nil
        self._action=action
        self._content=content()
    }
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> Button<Content> {_layoutSpec.add(spec);return self}
    
    public func makeCoordinator() -> Coordinator { 
        return Coordinator(self)
    }
    
    public class Coordinator:NSObject {
        let button:Button
        
        @objc func pressed() {
        //alert("button","pressed")
            button._action()
        }
        
        init(_ button:Button) {
            //print("uibutton coordinator created")
            self.button=button
        }
    }
}

extension Button where Content == EmptyView {
    @_disfavoredOverload //without this, the initializer below with LocalizedStringKey would never be called
    public init<S: StringProtocol>(_ title: S, action: @escaping () -> Void) {
        //self._action = action
        //self._label = Text(title)
        //self.init(action:action) {Label(title)}
        self.init(String(title),action:action) {EmptyView()}
    }
    
    public init(_ title: LocalizedStringKey, action: @escaping () -> Void) {
        //self._action = action
        //self._label = Text(title)
        //self.init(action:action) {Label(title)}
        self.init(title,action:action) {EmptyView()}
    }
    
    public init(verbatim title: String, action: @escaping () -> Void) {
        //self._action = action
        //self._label = Text(title)
        //self.init(action:action) {Label(title)}
        self.init(verbatim:title,action:action) {EmptyView()}
    }
}


public protocol ButtonStyle {
    associatedtype Body: View
    func makeBody(configuration: Self.Configuration) -> Self.Body
    typealias Configuration = ButtonStyleConfiguration
}

public struct ButtonStyleConfiguration {
    public struct Label: View {
        public typealias Body = Never
        //public var _layoutSpec=LayoutSpecWrapper()
        public var context:SCLContext?=nil
        public var body: Never {
            fatalError()
        }
        public var _storage: Any
        
        init(_ storage: Any) {
            self._storage = storage
        }
        
        //public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIView/*Self.UIBody*/>) -> Void) -> ButtonStyleConfiguration.Label {_layoutSpec.add(spec);return self}
    }
    public let label: Label
    public let isPressed: Bool
}

public extension Button {
    public func buttonStyle<S>(_ style: S) -> some View where S: ButtonStyle {
        let label = ButtonStyleConfiguration.Label(self)
        let configuration = ButtonStyleConfiguration(label: label, isPressed: false)
        return style.makeBody(configuration: configuration)
    }
}


extension Button {
    
    public func makeUIView(context:UIViewRepresentableContext<Button>) -> UIViewType {
        let button = UIViewType(type:.system)
        button.addTarget(context.coordinator, action: #selector(context.coordinator.pressed), for: .touchUpInside)
        return button
    }
    
    public func updateUIView(_ view:UIViewType,context:UIViewRepresentableContext<Button>) -> Void {
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        
        let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"Button",key:nil,layoutSpec: { spec, context in
                if let button=spec.view as? UIViewType {
                    if self._text != nil {button.setTitle(self._text,for:.normal)}
                    if self._localized != nil {button.setTitle(self._localized!.stringValue(locale:env.values.locale ?? .current),for:.normal)} 
                    guard let yoga = spec.view?.yoga else { return }
                    spec.view!.clipsToBounds=true
                    //if minLength>0 {yoga.width=minLength}
                    self._layoutSpec.layoutSpec?(spec)
                }
            },
            controller:defaultController
        )
        //node.canReuse=false
        
        let vnode = ViewNode(value: node)
        
        if let c=self._content as? UIViewBuildable {
            if let n=c.buildTree(parent: vnode, in: vnode.runtimeenvironment) {
                //let the button content react on button presses
            }
        }
        
        parent.addChild(node: vnode)
        
        return vnode
    }
}












