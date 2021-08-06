import Foundation
import CoreRender
import UIKit

public struct _ViewModifier_Content<Modifier> where Modifier: ViewModifier {
    public typealias Body = Never
    public var context:SCLContext?=nil
}

extension _ViewModifier_Content: View { 
    public var body: Never {
        fatalError()
    }
    
    //public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIView/*Self.UIBody*/>) -> Void) -> _ViewModifier_Content {return self}
}

public protocol ViewModifier {
    associatedtype Body: View
    typealias Content = _ViewModifier_Content<Self>
    //func body(content: Self.Content) -> Self.Body
}

/*extension ViewModifier where Self.Body == Never {
    public func body(content: Self.Content) -> Self.Body {
        fatalError()
    }
}*/

public struct ModifiedContent<Content, Modifier>: View where Content: View, Modifier: ViewModifier {
    public typealias Body = Never //Content 
    public typealias UIViewType=UIView
    public typealias CoordinatorClass=Coordinator
    
    public var content: Content
    public var modifier: Modifier
    //public var context:SCLContext?=nil
    public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }
    
    public var body: Never //ModifiedContent<Content, Modifier>.Body 
    {
        //print("called modifedcontent body return ",content," modifier=",modifier)
        fatalError()
        //return content
    }
    
    //public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> ModifiedContent<Content, Modifier> {return self}
}


extension View {
    public func modifier<T>(_ modifier: T) -> ModifiedContent<Self, T> {
        return .init(content: self, modifier: modifier)
    }
}

extension ModifiedContent:UIViewBuildable {
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        let parentenv:SCLEnvironment=parent.buildenvironment ?? SCLEnvironment(values:EnvironmentValues())
        
        //print("modifiedcontent build tree modifier=",modifier)
        
        //copy and modify environment
        var env=SCLEnvironment(values:parentenv.values ?? EnvironmentValues()) 
        if let m=modifier as? SCLEnvironmentalModifier {
            m.resolve(in:&env.values)
        }
        
        //print("env values:",env.values)
        
        let oldenv=Application?.buildEnvironment
        Application?.buildEnvironment=env.values
        
        parent.buildenvironment=env //pointer copy, will  e reset below
        //parent.runtimeenvironment=SCLEnvironment(values:env.values ?? EnvironmentValues()) //deep copy, childs may modify it
        
        //print("updating props before ",Application?._dynamicProperties)
        //print("build env ",Application?.buildEnvironment)
        
        //print("updating props ",Application?._dynamicProperties)
        Application?.updateDynamicProperties()
        
        //print("*****ModifiedContent build locale for ",type(of:content)," is ",Application?.buildEnvironment?[LocaleEnvironmentKey.self])
        
        if let c=content as? UIViewBuildable {
            if let c1=content as? UIViewBuildableList {
                c1.buildTree(parent: parent, in:parent.runtimeenvironment)
            }
            else {
                //print("environment before build of ",c,":",parent.environment?.values)
                
                let v=c.buildTree(parent: parent, in:env)
                Application?.buildEnvironment=oldenv
                
                //print("environment after build of ",c,":",parent.environment?.values)
                
                parent.buildenvironment=parentenv
                //print("*****ModifiedContent end build")
                return v
            }
        }
        else {
            //print("environment before extract of ",content,":",parent.environment?.values)
            
            ViewExtractor.extractViews(contents: content.body).forEach {
                $0.buildTree(parent: parent, in:env)
            }
            //print("content)",content," type:\(type(of:content))")
            
            //print("environment after extract of ",content,":",parent.environment?.values)
        }
        
        //print("updating props after ",Application?._dynamicProperties)
        //print("parentenv after modified:",parent.environment?.values)
        
        Application?.buildEnvironment=oldenv
        parent.buildenvironment=parentenv
        //print("*****ModifiedContent end build")
        return nil
    }
}

/*extension ModifiedContent {
    public var body: Never {
        fatalError()
    }
}*/

extension ViewModifier {
    public func concat<T>(_ modifier: T) -> ModifiedContent<Self, T> {
        return .init(content: self, modifier: modifier)
    }
}


extension View {
    public func colorScheme(_ colorScheme: ColorScheme) -> some View {
        return environment(\.colorScheme, colorScheme)
    }
}


public extension UIViewRepresentable {
    
    public func matchHostingViewWidth(withMargin margin:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.width to :\(spec.size.width - 2 * margin)")
            spec.set("yoga.width",value:spec.size.width - 2 * margin)
        }
    }
    
    public func matchHostingViewHeight(withMargin margin:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            spec.set("yoga.height",value:spec.size.height - 2 * margin)
        }
    }
    
    public func matchParentWidth(withMargin margin:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.width to :\(spec.size.width - 2 * margin)")
            if let parent:UIView=spec.view?.superview {
                spec.set("yoga.width",value:parent.frame.size.width - 2 * margin)
            }
            else {spec.set("yoga.width",value:spec.size.width - 2 * margin)}
        }
    }
    
    public func matchParentHeight(withMargin margin:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            if let parent:UIView=spec.view?.superview {
                spec.set("yoga.height",value:parent.frame.size.height - 2 * margin)
            }
            else {spec.set("yoga.height",value:spec.size.height - 2 * margin)}
        }
    }
    
    public func padding(_ padding:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            spec.set("yoga.padding",value:padding)
        }
    }
    
    public func padding(insets padding:UIEdgeInsets) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            spec.set("yoga.paddingTop",value:padding.top)
            spec.set("yoga.paddingBottom",value:padding.bottom)
            spec.set("yoga.paddingLeft",value:padding.left)
            spec.set("yoga.paddingRight",value:padding.right)
        }
    }
    
    public func margin(_ margin:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            spec.set("yoga.margin",value:margin)
        }
    }
    
    public func margin(top:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            spec.set("yoga.marginTop",value:top)
        }
    }
    
    public func margin(left:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            spec.set("yoga.marginLeft",value:left)
        }
    }

    public func margin(insets margin:UIEdgeInsets) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            spec.set("yoga.marginTop",value:margin.top)
            spec.set("yoga.marginBottom",value:margin.bottom)
            spec.set("yoga.marginLeft",value:margin.left)
            spec.set("yoga.marginRight",value:margin.right)
        }
    }
    
    public func border(_ border:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            spec.set("yoga.borderTopWidth",value:border)
            spec.set("yoga.borderBottomWidth",value:border)
            spec.set("yoga.borderLeftWidth",value:border)
            spec.set("yoga.borderRightWidth",value:border)
        }
    }
    
    public func border(insets border:UIEdgeInsets) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            spec.set("yoga.borderTopWidth",value:border.top)
            spec.set("yoga.borderBottomWidth",value:border.bottom)
            spec.set("yoga.borderLeftWidth",value:border.left)
            spec.set("yoga.borderRightWidth",value:border.right)
        }
    }
   
    public func background(color:UIColor) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //spec.view?.backgroundColor=color
            spec.set("backgroundColor",value:color)
        }
    }
    
    public func backgroundColor(_ color:UIColor) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //spec.view?.backgroundColor=color
            spec.set("backgroundColor",value:color)
        }
    }
    
    public func cornerRadius(_ value:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //spec.view?.backgroundColor=color
            spec.set("clipsToBounds",value:true)
            spec.set("layer.cornerRadius",value:value)
        }
    }
    
    public func clipped(_ value:Bool) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //spec.view?.backgroundColor=color
            spec.set("clipsToBounds",value:value)
        }
    }
    
    public func hidden(_ value:Bool) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //spec.view?.backgroundColor=color
            spec.set("hidden",value:value)
        }
    }
    
    public func opacity(_ value:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //spec.view?.backgroundColor=color
            spec.set("alpha",value:value)
        }
    }
    
    public func flexDirection(_ value:YGFlexDirection) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //spec.view?.backgroundColor=color
            spec.set("yoga.flexDirection",value:value.rawValue)
        }
    }
    
    public func justifyContent(_ value:YGJustify) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //spec.view?.backgroundColor=color
            spec.set("yoga.justifyContent",value:value.rawValue)
        }
    }
    
    public func alignContent(_ value:YGAlign) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //spec.view?.backgroundColor=color
            spec.set("yoga.alignContent",value:value.rawValue)
        }
    }
    
    public func alignItems(_ value:YGAlign) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value.rawValue) for \(spec)")
            spec.set("yoga.alignItems",value:value.rawValue)
            //yoga.alignItems = .center
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func alignSelf(_ value:YGAlign) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("yoga.alignSelf",value:value.rawValue)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func position(_ value:YGPositionType) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("yoga.position",value:value.rawValue)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func flexWrap(_ value:YGWrap) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("yoga.flexWrap",value:value.rawValue)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func overflow(_ value:YGOverflow) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("yoga.overflow",value:value.rawValue)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func flex() -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.view?.yoga.flex()
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func flexGrow(_ value:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("yoga.flexGrow",value:value)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func flexShrink(_ value:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("yoga.flexShrink",value:value)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }

    public func flexBasis(_ value:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("yoga.flexBasis",value:value)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func width(_ value:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("yoga.width",value:value)
            //the value passed is fixed
            spec.set("yoga.minWidth",value:value)
            spec.set("yoga.maxWidth",value:value)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    

    public func height(_ value:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("yoga.height",value:value)
            //the value passed is fixed
            spec.set("yoga.minHeight",value:value)
            spec.set("yoga.maxHeight",value:value)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func minWidth(_ value:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("yoga.minWidth",value:value)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func minHeight(_ value:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("yoga.minHeight",value:value)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func maxWidth(_ value:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("yoga.maxWidth",value:value)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func maxHeight(_ value:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("yoga.maxHeight",value:value)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func frame(width:CGFloat,height:CGFloat?=nil) -> Self {
        return self.withLayoutSpec { spec in 
            spec.set("yoga.width",value:width)
            if height != nil {spec.set("yoga.height",value:height!)}
        }
    }
    
    public func frame(height:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            spec.set("yoga.height",value:height)
        }
    }
    
    public func frame(minWidth:CGFloat,minHeight:CGFloat?=nil) -> Self {
        return self.withLayoutSpec { spec in 
            spec.set("yoga.minWidth",value:minWidth)
            if minHeight != nil {spec.set("yoga.minHeight",value:minHeight!)}
        }
    }
    
    public func frame(minHeight:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            spec.set("yoga.minHeight",value:minHeight)
        }
    }
    
    public func frame(maxWidth:CGFloat,maxHeight:CGFloat?=nil) -> Self {
        return self.withLayoutSpec { spec in 
            spec.set("yoga.maxWidth",value:maxWidth)
            if maxHeight != nil {spec.set("yoga.maxHeight",value:maxHeight!)}
        }
    }
    
    public func frame(maxHeight:CGFloat) -> Self {
        return self.withLayoutSpec { spec in 
            spec.set("yoga.maxHeight",value:maxHeight)
        }
    }
    
    public func userInteractionEnabled(_ value:Bool) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("userInteractionEnabled",value:value)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func transform(_ value:CGAffineTransform, animator:UIViewPropertyAnimator?=nil) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.set("transform",value:value, animator:animator)
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }
    
    public func layoutAnimator(_ value:UIViewPropertyAnimator) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //print("spec set yoga.alignItems to :\(value) for \(yoga)")
            spec.context?.layoutAnimator = value
            //withProperty(in:spec,keyPath:ReferenceWritableKeyPath<Self.UIBody,YGAlign>(),value:value)
        }
    }

    public func font(_ font: Font?) -> some View {
        return environment(\.font, font)
    }
    
    /*public func text(color:UIColor) -> Self {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //spec.view?.backgroundColor=color
            spec.set("textColor",value:color)
        }
    }*/
    
    public func tag<V>(_ tag: V) -> some View where V : Hashable {
        print("calling tag ",tag.hashValue)
        return self.withLayoutSpec { spec in 
            spec.set("tag",value:tag.hashValue)
        }
    }
}


public extension Text {
    public func text(color:UIColor) -> Text {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //spec.view?.backgroundColor=color
            spec.set("textColor",value:color)
        }
    }
}

public extension TextField {
    public func placeholder(color:UIColor) -> TextField {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            spec.view?.placeholderColor=color
            
        }
    }
}

/*public extension Section {
    public func header(height:CGFloat) -> Section {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //spec.view?.backgroundColor=color
            spec.set("header.height",value:height)
        }
    }
    
    public func footer(height:CGFloat) -> Section {
        return self.withLayoutSpec { spec in 
            //guard let yoga = spec.view?.yoga else { return }
            //spec.view?.backgroundColor=color
            spec.set("footer.height",value:height)
        }
    }
}*/



















