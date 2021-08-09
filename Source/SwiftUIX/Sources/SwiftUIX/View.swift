import Foundation
import CoreRender

public protocol _View {
    var viewBuildable:UIViewBuildable? {get}
    var viewBuildableList:UIViewBuildableList? {get}
}

public protocol View:_View {
    associatedtype Body: View
    //associatedtype UIViewType: UIView
    //var context: SCLContext? {get set}
    var body: Self.Body { get }
    
    //func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<Self.UIViewType>) -> Void) -> Self
}

public extension View {
    public var viewBuildable:UIViewBuildable? {body as? UIViewBuildable}
    public var viewBuildableList:UIViewBuildableList? {body as? UIViewBuildableList}
}


extension Never {
    public typealias Body = Never
    public var body: Never {
        get {
            fatalError()
        }
    }
}

extension Never: View {
    //public var context:SCLContext? { get {fatalError()} set {fatalError()}}
    //public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIView>) -> Void) -> Never {fatalError()}
}

/*public extension View {
    //default implementation of protocol requirement
    typealias UIViewType=UIView
    func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<Self.UIViewType>) -> Void) -> Self {return self}  
}*/

extension YGFlexDirection: WritableKeyPathBoxableEnum { }
extension YGAlign: WritableKeyPathBoxableEnum { }
extension YGEdge: WritableKeyPathBoxableEnum { }
extension YGWrap: WritableKeyPathBoxableEnum { }
extension YGDisplay: WritableKeyPathBoxableEnum { } 
extension YGOverflow: WritableKeyPathBoxableEnum { }



public struct TupleView<T>: View, UIViewBuildable {
    public var value: T
    public typealias Body = Never
    //public typealias UIViewType=UIView
    //public var context:SCLContext? = nil
    //public typealias UIBody = UIView
    
    public init(_ value: T) {
        self.value = value
    }
    
    //public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> TupleView<T> {return self}
}

extension TupleView {
    public var body: Never {
        fatalError()
    }
}

public struct EmptyView: View {
    public typealias Body = Never
    public typealias UIViewType = UIView
    //public var context:SCLContext? = nil
    //public typealias UIBody = UIView
    
    public init() {
    }
    
    //public func withLayoutSpec(_ spec:(_ spec:LayoutSpec<UIBody>) -> Void) -> EmptyView {return self}
}

extension EmptyView {
    public var body: Never {
        fatalError()
    }
}

extension Optional: _View where Wrapped: _View {
    public var viewBuildable:UIViewBuildable? {nil}
    public var viewBuildableList:UIViewBuildableList? {nil}
}

extension Optional: View where Wrapped: View {
    public var body: Never {
        fatalError()
    }
    
    func unwrap<T>(_ x: Any) -> T {
        return x as! T
    }
    
    public typealias Body = Never
    
    /*public var context:SCLContext? { 
        get {
            let wrapped: Wrapped? = unwrap(self)
            return wrapped?.context
        } 
        set(newvalue) {
            var wrapped: Wrapped? = unwrap(self)
            wrapped?.context=newvalue
        }
    }*/
    //public typealias UIViewType = Wrapped.UIViewType
    
    //public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<Self.UIViewType>) -> Void) -> Self {return self}
}


@resultBuilder
public struct ViewBuilder {
    public static func buildBlock() -> EmptyView {
        return EmptyView()
    }
    
    public static func buildBlock<Content>(_ content: Content) -> Content where Content: View {
        return content
    }
    
    public static func buildIf<Content>(_ content: Content?) -> Content? where Content: View {
        return content 
    }
    
    public static func buildEither<TrueContent, FalseContent>(first: TrueContent) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent: View, FalseContent: View {
        return .init(storage: .trueContent(first))
    }
    public static func buildEither<TrueContent, FalseContent>(second: FalseContent) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent: View, FalseContent: View {
        return .init(storage: .falseContent(second))
    }
}

extension ViewBuilder {
    public static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> TupleView<(C0, C1)> where C0: View, C1: View {
        return .init((c0, c1))
    }
    
    public static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleView<(C0, C1, C2)> where C0: View, C1: View, C2: View {
        return .init((c0, c1, c2))
    }
    
    public static func buildBlock<C0, C1, C2, C3>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> TupleView<(C0, C1, C2, C3)> where C0: View, C1: View, C2: View, C3: View {
        return .init((c0, c1, c2, c3))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleView<(C0, C1, C2, C3, C4)> where C0: View, C1: View, C2: View, C3: View, C4: View {
        return .init((c0, c1, c2, c3, c4))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> TupleView<(C0, C1, C2, C3, C4, C5)> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View {
        return .init((c0, c1, c2, c3, c4, c5))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> TupleView<(C0, C1, C2, C3, C4, C5, C6)> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View {
        return .init((c0, c1, c2, c3, c4, c5, c6))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7)> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View {
        return .init((c0, c1, c2, c3, c4, c5, c6, c7))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8)> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View {
        return .init((c0, c1, c2, c3, c4, c5, c6, c7, c8))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View {
        return .init((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9))
    }
}

@resultBuilder
public class ArrayBuilder<Element> {
    @inlinable
    public static func buildBlock() -> [Element] {
        return []
    }
    
    @inlinable
    public static func buildBlock(_ element: Element) -> [Element] {
        return [element]
    }
    
    @inlinable
    public static func buildBlock(_ elements: Element...) -> [Element] {
        return elements
    }
}

public class AnyViewStorageBase {
    
}

public class AnyViewStorage<V: View>: AnyViewStorageBase {
    public var _view: V
    
    init(_ view: V) {
        self._view = view
    }
}

public struct AnyView: View, UIViewBuildable {
    public var _storage: AnyViewStorageBase
    private var _layoutSpec=LayoutSpecWrapper()
    
    public init<V>(_ view: V) where V: View {
        _storage = AnyViewStorage<V>(view)
    }
    
    /*public init?(_fromValue value: Any) {
        print("called anyview init from any")
        fatalError()
    }*/
    
    public typealias Body = Never
    //public typealias UITypeName = UIView
    //public var context:SCLContext? = nil
    public var body: Never {
        fatalError()
    }
    
    //public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIBody>) -> Void) -> AnyView {_layoutSpec.add(spec);return self}
}

public struct _PassthroughViewLayout {
    @inlinable public init() {
    }
    public typealias Body = Never
}

public class SCLPassthroughView:UIView {
}

extension _PassthroughViewLayout: _VariadicView_UnaryViewRoot {}
extension _PassthroughViewLayout: _VariadicView_ViewRoot {}

public struct PassthroughView<Content>:UIViewRepresentable  where Content: View {
    public typealias Body = Never
    public typealias UIViewType = SCLPassthroughView
    //public var context:SCLContext? = nil
    public var _tree: _VariadicView.Tree<_PassthroughViewLayout, Content>
    private var _layoutSpec=LayoutSpecWrapper<UIViewType>()
    
    public init(@ViewBuilder content: () -> Content) {
        _tree = .init(
            root: _PassthroughViewLayout(), content: content())
    }
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> PassthroughView<Content> {
       _layoutSpec.add(spec)
       return self
    }
}
 
extension PassthroughView {
    public var body: Never {
        fatalError()
    }
}

extension PassthroughView {
    
    public func makeUIView(context:UIViewRepresentableContext<PassthroughView>) -> UIViewType {
        UIViewType(frame:CGRect(x:0,y:0,width:0,height:0))
    }
    
    public func updateUIView(_ view:UIViewType,context:UIViewRepresentableContext<PassthroughView>) -> Void {
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        
        let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"PassthroughView",key:nil,layoutSpec: { spec, context in
                guard let yoga = spec.view?.yoga else { return }
                spec.view!.clipsToBounds=true
                yoga.flex()
                self._layoutSpec.layoutSpec?(spec)
            },
            controller:defaultController
        )
        
        let vnode = ViewNode(value: node)
        parent.addChild(node: vnode)
        
        ViewExtractor.extractViews(contents: _tree.content).forEach {
            if let n=$0.buildTree(parent: vnode, in:vnode.runtimeenvironment) 
            {
            }
        }
        
        return vnode
    }
}



public class AnyColorBox {
    open func uicolor () -> UIColor {
        return .clear
    }
}

extension AnyColorBox: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}

extension AnyColorBox: Equatable {
    public static func == (lhs: AnyColorBox, rhs: AnyColorBox) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

public class SystemColorType: AnyColorBox {
    public enum SystemColor: String {
        case clear
        case black
        case white
        case gray
        case red
        case green
        case blue
        case orange
        case yellow
        //case pink
        case purple
        //case primary
        //case secondary
        //case accentColor
    }
    
    public let value: SystemColor
    
    internal init(value: SystemColorType.SystemColor) {
        self.value = value
    }
    
    public var description: String {
        return value.rawValue
    }
    
    public override func uicolor () -> UIColor {
        switch value {
            case .clear: return UIColor.clear
            case .black: return UIColor.black
            case .white: return UIColor.white
            case .gray: return UIColor.gray
            case .red: return UIColor.red
            case .green: return UIColor.green
            case .blue: return UIColor.blue
            case .orange: return UIColor.orange
            case .yellow: return UIColor.yellow
            //case .pink: return UIColor.pink
            case .purple: return UIColor.purple
            //case .primary: return UIColor.primary
            //case .secondary: return UIColor.secondary
            //case .accentColor: return UIColor.accentColor
        }
    }
}

public class DisplayP3: AnyColorBox {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let opacity: Double
    
    internal init(red: Double, green: Double, blue: Double, opacity: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }
    
    public override func uicolor () -> UIColor {
        return UIColor(
            red: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(opacity)
        )
    }
}

extension Double {
    fileprivate var hexString: String {
        return String(format: "%02X", Int((self * 255).rounded()))
    }
}

public class _Resolved: AnyColorBox {
    public let linearRed: Double
    public let linearGreen: Double
    public let linearBlue: Double
    public let opacity: Double
    
    internal init(linearRed: Double, linearGreen: Double, linearBlue: Double, opacity: Double) {
        self.linearRed = linearRed
        self.linearGreen = linearGreen
        self.linearBlue = linearBlue
        self.opacity = opacity
    }
    
    public var description: String {
        return "#\(linearRed.hexString)\(linearGreen.hexString)\(linearBlue.hexString)\(opacity.hexString)"
    }
    
    public override func uicolor () -> UIColor {
        return UIColor(
            red: CGFloat(linearRed),
            green: CGFloat(linearGreen),
            blue: CGFloat(linearBlue),
            alpha: CGFloat(opacity)
        )
    }
}

extension UIColor {
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
}

public extension UIColor {
    
    public static var flatBlackColor=UIColor(hue:0.0/360.0,saturation:0.0/100.0,brightness:17.0/100.0,alpha:1)
    public static var flatBlueColor=UIColor(hue:224.0/360.0,saturation:50.0/100.0,brightness:63.0/100.0,alpha:1)
    public static var flatBrownColor=UIColor(hue:24.0/360.0,saturation:45.0/100.0,brightness:37.0/100.0,alpha:1)
    public static var flatCoffeeColor=UIColor(hue:25.0/360.0,saturation:31.0/100.0,brightness:64.0/100.0,alpha:1)
    public static var flatForestGreenColor=UIColor(hue:138.0/360.0,saturation:45.0/100.0,brightness:37.0/100.0,alpha:1)
    public static var flatGrayColor=UIColor(hue:184.0/360.0,saturation:10.0/100.0,brightness:65.0/100.0,alpha:1)
    public static var flatGreenColor=UIColor(hue:145.0/360.0,saturation:77.0/100.0,brightness:80.0/100.0,alpha:1)
    public static var flatLimeColor=UIColor(hue:74.0/360.0,saturation:70.0/100.0,brightness:78.0/100.0,alpha:1)
    public static var flatMagentaColor=UIColor(hue:283.0/360.0,saturation:51.0/100.0,brightness:71.0/100.0,alpha:1)
    public static var flatMaroonColor=UIColor(hue:5.0/360.0,saturation:65.0/100.0,brightness:47.0/100.0,alpha:1)
    public static var flatMintColor=UIColor(hue:168.0/360.0,saturation:86.0/100.0,brightness:74.0/100.0,alpha:1)
    public static var flatNavyBlueColor=UIColor(hue:210.0/360.0,saturation:45.0/100.0,brightness:37.0/100.0,alpha:1)
    public static var flatOrangeColor=UIColor(hue:28.0/360.0,saturation:85.0/100.0,brightness:90.0/100.0,alpha:1)
    public static var flatPinkColor=UIColor(hue:324.0/360.0,saturation:49.0/100.0,brightness:96.0/100.0,alpha:1)
    public static var flatPlumColor=UIColor(hue:300.0/360.0,saturation:45.0/100.0,brightness:37.0/100.0,alpha:1)
    public static var flatPowderBlueColor=UIColor(hue:222.0/360.0,saturation:24.0/100.0,brightness:95.0/100.0,alpha:1)
    public static var flatPurpleColor=UIColor(hue:253.0/360.0,saturation:52.0/100.0,brightness:77.0/100.0,alpha:1)
    public static var flatRedColor=UIColor(hue:6.0/360.0,saturation:74.0/100.0,brightness:91.0/100.0,alpha:1)
    public static var flatSandColor=UIColor(hue:42.0/360.0,saturation:25.0/100.0,brightness:94.0/100.0,alpha:1)
    public static var flatSkyBlueColor=UIColor(hue:204.0/360.0,saturation:76.0/100.0,brightness:86.0/100.0,alpha:1)
    public static var flatTealColor=UIColor(hue:195.0/360.0,saturation:55.0/100.0,brightness:51.0/100.0,alpha:1)
    public static var flatWatermelonColor=UIColor(hue:356.0/360.0,saturation:53.0/100.0,brightness:94.0/100.0,alpha:1)
    public static var flatWhiteColor=UIColor(hue:192.0/360.0,saturation:2.0/100.0,brightness:95.0/100.0,alpha:1)
    public static var flatYellowColor=UIColor(hue:48.0/360.0,saturation:99.0/100.0,brightness:100.0/100.0,alpha:1)
    
    public static var flatBlackDarkColor=UIColor(hue:0.0/360.0,saturation:0.0/100.0,brightness:15.0/100.0,alpha:1)
    public static var flatBlueDarkColor=UIColor(hue:224.0/360.0,saturation:56.0/100.0,brightness:51.0/100.0,alpha:1)
    public static var flatBrownDarkColor=UIColor(hue:25.0/360.0,saturation:45.0/100.0,brightness:31.0/100.0,alpha:1)
    public static var flatCoffeeDarkColor=UIColor(hue:25.0/360.0,saturation:34.0/100.0,brightness:56.0/100.0,alpha:1)
    public static var flatForestGreenDarkColor=UIColor(hue:135.0/360.0,saturation:44.0/100.0,brightness:31.0/100.0,alpha:1)
    public static var flatGrayDarkColor=UIColor(hue:184.0/360.0,saturation:10.0/100.0,brightness:55.0/100.0,alpha:1)
    public static var flatGreenDarkColor=UIColor(hue:145.0/360.0,saturation:78.0/100.0,brightness:68.0/100.0,alpha:1)
    public static var flatLimeDarkColor=UIColor(hue:74.0/360.0,saturation:81.0/100.0,brightness:69.0/100.0,alpha:1)
    public static var flatMagentaDarkColor=UIColor(hue:282.0/360.0,saturation:61.0/100.0,brightness:68.0/100.0,alpha:1)
    public static var flatMaroonDarkColor=UIColor(hue:4.0/360.0,saturation:68.0/100.0,brightness:40.0/100.0,alpha:1)
    public static var flatMintDarkColor=UIColor(hue:168.0/360.0,saturation:86.0/100.0,brightness:63.0/100.0,alpha:1)
    public static var flatNavyBlueDarkColor=UIColor(hue:210.0/360.0,saturation:45.0/100.0,brightness:31.0/100.0,alpha:1)
    public static var flatOrangeDarkColor=UIColor(hue:24.0/360.0,saturation:100.0/100.0,brightness:83.0/100.0,alpha:1)
    public static var flatPinkDarkColor=UIColor(hue:327.0/360.0,saturation:57.0/100.0,brightness:83.0/100.0,alpha:1)
    public static var flatPlumDarkColor=UIColor(hue:300.0/360.0,saturation:46.0/100.0,brightness:31.0/100.0,alpha:1)
    public static var flatPowderBlueDarkColor=UIColor(hue:222.0/360.0,saturation:28.0/100.0,brightness:84.0/100.0,alpha:1)
    public static var flatPurpleDarkColor=UIColor(hue:253.0/360.0,saturation:56.0/100.0,brightness:64.0/100.0,alpha:1)
    public static var flatRedDarkColor=UIColor(hue:6.0/360.0,saturation:78.0/100.0,brightness:75.0/100.0,alpha:1)
    public static var flatSandDarkColor=UIColor(hue:42.0/360.0,saturation:30.0/100.0,brightness:84.0/100.0,alpha:1)
    public static var flatSkyBlueDarkColor=UIColor(hue:204.0/360.0,saturation:78.0/100.0,brightness:73.0/100.0,alpha:1)
    public static var flatTealDarkColor=UIColor(hue:196.0/360.0,saturation:54.0/100.0,brightness:45.0/100.0,alpha:1)
    public static var flatWatermelonDarkColor=UIColor(hue:358.0/360.0,saturation:61.0/100.0,brightness:85.0/100.0,alpha:1)
    public static var flatWhiteDarkColor=UIColor(hue:204.0/360.0,saturation:5.0/100.0,brightness:78.0/100.0,alpha:1)
    public static var flatYellowDarkColor=UIColor(hue:40.0/360.0,saturation:100.0/100.0,brightness:100.0/100.0,alpha:1)
    
     /**
     Checks for visual equality of two colors regardless of their color space.
     - parameter    color:  The other color for comparison.
     - returns:     A boolean representing whether the colors are visually the same color.
     */
    public func isVisuallyEqualTo(_ color: UIColor) -> Bool {
        return rgbaComponents == color.rgbaComponents
    }

    public var rgbaComponents: [CGFloat] {
        var data = [CUnsignedChar](repeating: 0, count: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &data,
                                width: 1, height: 1,
                                bitsPerComponent: 8, bytesPerRow: 4,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        context?.setFillColor(cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        return data.map { CGFloat($0) / 255.0 }
    }

    
}

public struct Color: View, Hashable, CustomStringConvertible {
    public typealias Body = Never
    //public var context:SCLContext? = nil
    
    public let provider: AnyColorBox
    
    public enum RGBColorSpace: Equatable {
        case sRGB
        case sRGBLinear
        case displayP3
    }
    
    public init(_ colorSpace: Color.RGBColorSpace = .sRGB, red: Double, green: Double, blue: Double, opacity: Double = 1) {
        switch colorSpace {
        case .sRGB:
            self.provider = _Resolved(linearRed: red, linearGreen: green, linearBlue: blue, opacity: opacity)
        case .sRGBLinear:
            self.provider = _Resolved(linearRed: red, linearGreen: green, linearBlue: blue, opacity: opacity)
        case .displayP3:
            self.provider = DisplayP3(red: red, green: green, blue: blue, opacity: opacity)
        }
    }
    
    public init(_ colorSpace: Color.RGBColorSpace = .sRGB, white: Double, opacity: Double = 1) {
        switch colorSpace {
        case .sRGB:
            self.provider = _Resolved(linearRed: white, linearGreen: white, linearBlue: white, opacity: opacity)
        case .sRGBLinear:
            self.provider = _Resolved(linearRed: white, linearGreen: white, linearBlue: white, opacity: opacity)
        case .displayP3:
            self.provider = DisplayP3(red: white, green: white, blue: white, opacity: opacity)
        }
    }
    
    public init(hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
        let rgb = Color.hsbToRGB(hue: hue, saturation: saturation, brightness: brightness)
        self.provider = _Resolved(linearRed: rgb.red, linearGreen: rgb.green, linearBlue: rgb.blue, opacity: opacity)
    }
    
    fileprivate init(_ systemColor: SystemColorType.SystemColor) {
        self.provider = SystemColorType(value: systemColor)
    }
    
    fileprivate init(_ color: UIColor) {
        self.provider = _Resolved(linearRed: Double(color.redValue), linearGreen: Double(color.greenValue), 
                                  linearBlue: Double(color.blueValue), opacity: Double(color.alphaValue))
    }
    
    public var body: Never {
        fatalError()
    }
    
    public var description: String {
        return "\(provider)"
    }
    
    public func uicolor () -> UIColor {
        return provider.uicolor();
    }
    
    //public func withLayoutSpec(_ spec:(_ spec:LayoutSpec<UIView/*Self.UIBody*/>) -> Void) -> Color {return self}
}

extension Color {
    public static let clear: Color = Color(SystemColorType.SystemColor.clear)
    public static let black: Color = Color(SystemColorType.SystemColor.black)
    public static let white: Color = Color(SystemColorType.SystemColor.white)
    public static let gray: Color = Color(SystemColorType.SystemColor.gray)
    public static let red: Color = Color(SystemColorType.SystemColor.red)
    public static let green: Color = Color(SystemColorType.SystemColor.green)
    public static let blue: Color = Color(SystemColorType.SystemColor.blue)
    public static let orange: Color = Color(SystemColorType.SystemColor.orange)
    public static let yellow: Color = Color(SystemColorType.SystemColor.yellow)
    //public static let pink: Color = Color(SystemColorType.SystemColor.pink)
    public static let purple: Color = Color(SystemColorType.SystemColor.purple)
    /*public static let primary: Color = Color(SystemColorType.SystemColor.primary)
    public static let secondary: Color = Color(SystemColorType.SystemColor.secondary)
    public static let accentColor: Color = Color(SystemColorType.SystemColor.accentColor)*/
    
    public static let link: Color = Color(UIColor.link)
    public static let label: Color = Color(UIColor.label)
    public static let secondaryLabel: Color = Color(UIColor.secondaryLabel)
    public static let tertiaryLabel: Color = Color(UIColor.tertiaryLabel)
    public static let quaternaryLabel: Color = Color(UIColor.quaternaryLabel)
    public static let placeholderText: Color = Color(UIColor.placeholderText)
    public static let separator: Color = Color(UIColor.separator)
    public static let opaqueSeparator: Color = Color(UIColor.opaqueSeparator)
    public static let systemFill: Color = Color(UIColor.systemFill)
    public static let secondarySystemFill: Color = Color(UIColor.secondarySystemFill)
    public static let tertiarySystemFill: Color = Color(UIColor.tertiarySystemFill)
    public static let quaternarySystemFill: Color = Color(UIColor.quaternarySystemFill)
    public static let systemBackground: Color = Color(UIColor.systemBackground)
    public static let secondarySystemBackground: Color = Color(UIColor.secondarySystemBackground)
    public static let tertiarySystemBackground: Color = Color(UIColor.tertiarySystemBackground)
    public static let systemGroupedBackground: Color = Color(UIColor.systemGroupedBackground)
    public static let secondarySystemGroupedBackground: Color = Color(UIColor.secondarySystemGroupedBackground)
    public static let tertiarySystemGroupedBackground: Color = Color(UIColor.tertiarySystemGroupedBackground)
    
    public static let systemRed: Color = Color(UIColor.systemRed)
    public static let systemYellow: Color = Color(UIColor.systemYellow)
    public static let systemOrange: Color = Color(UIColor.systemOrange)
    public static let systemGreen: Color = Color(UIColor.systemGreen)
    public static let systemTeal: Color = Color(UIColor.systemTeal)
    public static let systemBlue: Color = Color(UIColor.systemBlue)
    public static let systemIndigo: Color = Color(UIColor.systemIndigo)
    public static let systemPurple: Color = Color(UIColor.systemPurple)
    public static let systemPink: Color = Color(UIColor.systemPink)
    public static let systemGray: Color = Color(UIColor.systemGray)
    public static let systemGray2: Color = Color(UIColor.systemGray2)
    public static let systemGray3: Color = Color(UIColor.systemGray3)
    public static let systemGray4: Color = Color(UIColor.systemGray4)
    public static let systemGray5: Color = Color(UIColor.systemGray5)
    public static let systemGray6: Color = Color(UIColor.systemGray6)
    
    public static let flatBlackColor: Color = Color(UIColor.flatBlackColor)
    public static let flatBlueColor: Color = Color(UIColor.flatBlueColor)
    public static let flatBrownColor: Color = Color(UIColor.flatBrownColor)
    public static let flatCoffeeColor: Color = Color(UIColor.flatCoffeeColor)
    public static let flatForestGreenColor: Color = Color(UIColor.flatForestGreenColor)
    public static let flatGrayColor: Color = Color(UIColor.flatGrayColor)
    public static let flatGreenColor: Color = Color(UIColor.flatGreenColor)
    public static let flatLimeColor: Color = Color(UIColor.flatLimeColor)
    public static let flatMagentaColor: Color = Color(UIColor.flatMagentaColor)
    public static let flatMaroonColor: Color = Color(UIColor.flatMaroonColor)
    public static let flatMintColor: Color = Color(UIColor.flatMintColor)
    public static let flatNavyBlueColor: Color = Color(UIColor.flatNavyBlueColor)
    public static let flatOrangeColor: Color = Color(UIColor.flatOrangeColor)
    public static let flatPinkColor: Color = Color(UIColor.flatPinkColor)
    public static let flatPlumColor: Color = Color(UIColor.flatPlumColor)
    public static let flatPowderBlueColor: Color = Color(UIColor.flatPowderBlueColor)
    public static let flatPurpleColor: Color = Color(UIColor.flatPurpleColor)
    public static let flatRedColor: Color = Color(UIColor.flatRedColor)
    public static let flatSandColor: Color = Color(UIColor.flatSandColor)
    public static let flatSkyBlueColor: Color = Color(UIColor.flatSkyBlueColor)
    public static let flatTealColor: Color = Color(UIColor.flatTealColor)
    public static let flatWatermelonColor: Color = Color(UIColor.flatWatermelonColor)
    public static let flatWhiteColor: Color = Color(UIColor.flatWhiteColor)
    public static let flatYellowColor: Color = Color(UIColor.flatYellowColor)
    
    public static let flatBlackDarkColor: Color = Color(UIColor.flatBlackDarkColor)
    public static let flatBlueDarkColor: Color = Color(UIColor.flatBlueDarkColor)
    public static let flatBrownDarkColor: Color = Color(UIColor.flatBrownDarkColor)
    public static let flatCoffeeDarkColor: Color = Color(UIColor.flatCoffeeDarkColor)
    public static let flatForestGreenDarkColor: Color = Color(UIColor.flatForestGreenDarkColor)
    public static let flatGrayDarkColor: Color = Color(UIColor.flatGrayDarkColor)
    public static let flatGreenDarkColor: Color = Color(UIColor.flatGreenDarkColor)
    public static let flatLimeDarkColor: Color = Color(UIColor.flatLimeDarkColor)
    public static let flatMagentaDarkColor: Color = Color(UIColor.flatMagentaDarkColor)
    public static let flatMaroonDarkColor: Color = Color(UIColor.flatMaroonDarkColor)
    public static let flatMintDarkColor: Color = Color(UIColor.flatMintDarkColor)
    public static let flatNavyBlueDarkColor: Color = Color(UIColor.flatNavyBlueDarkColor)
    public static let flatOrangeDarkColor: Color = Color(UIColor.flatOrangeDarkColor)
    public static let flatPinkDarkColor: Color = Color(UIColor.flatPinkDarkColor)
    public static let flatPlumDarkColor: Color = Color(UIColor.flatPlumDarkColor)
    public static let flatPowderBlueDarkColor: Color = Color(UIColor.flatPowderBlueDarkColor)
    public static let flatPurpleDarkColor: Color = Color(UIColor.flatPurpleDarkColor)
    public static let flatRedDarkColor: Color = Color(UIColor.flatRedDarkColor)
    public static let flatSandDarkColor: Color = Color(UIColor.flatSandDarkColor)
    public static let flatSkyBlueDarkColor: Color = Color(UIColor.flatSkyBlueDarkColor)
    public static let flatTealDarkColor: Color = Color(UIColor.flatTealDarkColor)
    public static let flatWatermelonDarkColor: Color = Color(UIColor.flatWatermelonDarkColor)
    public static let flatWhiteDarkColor: Color = Color(UIColor.flatWhiteDarkColor)
    public static let flatYellowDarkColor: Color = Color(UIColor.flatYellowDarkColor)
}

extension View {
    public func foregroundColor(_ color: Color?) -> some View {
        return environment(\.foregroundColor, color)
    }
}

enum ForegroundColorEnvironmentKey: EnvironmentKey {
    static var defaultValue: Color? { return nil }
}

extension EnvironmentValues {
    public var foregroundColor: Color? {
        set { self[ForegroundColorEnvironmentKey.self] = newValue }
        get { self[ForegroundColorEnvironmentKey.self] }
    }
}


extension Color {
    internal static func hsbToRGB(hue: Double, saturation: Double, brightness: Double) -> (red: Double, green: Double, blue: Double) {
        // Based on:
        // http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript
        
        var red: Double = 0
        var green: Double = 0
        var blue: Double = 0
        
        let i = floor(hue * 6)
        let f = hue * 6 - i
        let p = brightness * (1 - saturation)
        let q = brightness * (1 - f * saturation)
        let t = brightness * (1 - (1 - f) * saturation)
        
        switch(i.truncatingRemainder(dividingBy: 6)) {
        case 0:
            red = brightness
            green = t
            blue = p
        case 1:
            red = q
            green = brightness
            blue = p
        case 2:
            red = p
            green = brightness
            blue = t
        case 3:
            red = p
            green = q
            blue = brightness
        case 4:
            red = t
            green = p
            blue = brightness
        case 5:
            red = brightness
            green = p
            blue = q
        default:
            break
        }
        
        return (red, green, blue)
    }
}

public enum ColorScheme: CaseIterable {
    case light
    case dark
}



enum ColorSchemeEnvironmentKey: EnvironmentKey {
    static var defaultValue: ColorScheme { return ColorScheme.dark }
}

extension EnvironmentValues {
    public var colorScheme: ColorScheme {
        set { self[ColorSchemeEnvironmentKey.self] = newValue }
        get { self[ColorSchemeEnvironmentKey.self] }
    }
}

public struct Image: UIViewRepresentable {
    public typealias Body = Never
    public typealias UIViewType = UIImageView
    //public var context:SCLContext? = nil
    private let systemName:String?
    private let image:UIImage?
    private var _layoutSpec=LayoutSpecWrapper<UIViewType>()
    
    public init(systemName:String) {
        self.systemName=systemName
        self.image=nil
    }
    
    public init(image:UIImage) {
        self.image=image
        self.systemName=nil
    }
    
    public var body: Never {
        fatalError()
    }
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> Image {_layoutSpec.add(spec);return self}
}

extension Image {
    
    public func makeUIView(context:UIViewRepresentableContext<Image>) -> UIViewType {
        UIViewType(frame:CGRect(x:0,y:0,width:0,height:0))
    }
    
    public func updateUIView(_ view:UIViewType,context:UIViewRepresentableContext<Image>) -> Void {
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        
        let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:nil,key:nil,layoutSpec: { spec, context in
                if let image=spec.view as? UIViewType {
                    if self.systemName != nil {image.image=UIImage(systemName:self.systemName!)}
                    if self.image != nil {image.image=self.image!}
                    image.isUserInteractionEnabled=false
                    spec.view!.clipsToBounds=true
                    //if minLength>0 {yoga.width=minLength}
                    self._layoutSpec.layoutSpec?(spec)
                }
            },
            controller:defaultController
        )
        //node.canReuse=false
        
        let vnode = ViewNode(value: node)
        
        parent.addChild(node: vnode)
        
        return vnode
    }
}

public struct Divider: View {
    //public var context:SCLContext? = nil
    
    public init() {
        
    }
    
    public typealias Body = Never
}

extension Divider {
    public var body: Never {
        fatalError()
    }
}

/// Internal layout helper
struct Layout {
    
    let element: UIView
    
    init(_ element: UIView) {
        self.element = element
    }
    
    // MARK: Layout
    
    @discardableResult func sides(left: CGFloat = 0, right: CGFloat = 0) -> [NSLayoutConstraint] {
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[view]-(right)-|",
                                                         options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                         metrics: ["left": left, "right": right],
                                                         views: ["view": element])
        safeSuperview().addConstraints(constraints)
        return constraints
    }
    
    func minSides(left: CGFloat = 0, right: CGFloat = 0) {
        element.layout.centerX()
        element.layout.minLeading()
        element.layout.minTrailing()
    }
    
    @discardableResult func vertical(top: CGFloat = 0, bottom: CGFloat = 0) -> [NSLayoutConstraint] {
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[view]-(bottom)-|",
                                                         options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                        metrics: ["top": top, "bottom": bottom],
                                                        views: ["view": element])
        safeSuperview().addConstraints(constraints)
        return constraints
    }
    
    @discardableResult func centerX() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .centerX,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .centerX,
                                            multiplier: 1.0, constant: 0)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func centerY() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .centerY,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .centerY,
                                            multiplier: 1.0, constant: 0)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func min(width constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .width,
                                            relatedBy: .greaterThanOrEqual,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func min(height constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .height,
                                            relatedBy: .greaterThanOrEqual,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func match(maxWidth view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .width,
                                            relatedBy: .lessThanOrEqual,
                                            toItem: view,
                                            attribute: .width,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func match(maxHeight view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .height,
                                            relatedBy: .lessThanOrEqual,
                                            toItem: view,
                                            attribute: .height,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func match(minWidth view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .width,
                                            relatedBy: .greaterThanOrEqual,
                                            toItem: view,
                                            attribute: .width,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func match(minHeight view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .height,
                                            relatedBy: .greaterThanOrEqual,
                                            toItem: view,
                                            attribute: .height,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func width(_ constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func height(_ constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func matchWidthToSuperview(width constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .width,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func matchHeightToSuperview(width constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .height,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func leading(margin constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .leading,
                                            multiplier: 1, constant: constant)
        
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func trailing(margin constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .trailing,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .trailing,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func minLeading(margin constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .leading,
                                            relatedBy: .greaterThanOrEqual,
                                            toItem: safeSuperview(),
                                            attribute: .leading,
                                            multiplier: 1, constant: constant)
        
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func minTrailing(margin constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .trailing,
                                            relatedBy: .greaterThanOrEqual,
                                            toItem: safeSuperview(),
                                            attribute: .trailing,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func next(_ view: UIView, margin constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .trailing,
                                            multiplier: 1, constant: constant)
        
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func before(_ view: UIView, margin constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .trailing,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .leading,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func top(margin constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .top,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func top(toView view: UIView, margin constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .top,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func top(toBottom view: UIView, margin constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .bottom,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func match(bottomTo view: UIView, margin constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .bottom,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func bottomLessThanOrEqual(margin constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .bottom,
                                            relatedBy: .lessThanOrEqual,
                                            toItem: safeSuperview(),
                                            attribute: .bottom,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func bottomGreaterThanOrEqual(margin constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .bottom,
                                            relatedBy: .greaterThanOrEqual,
                                            toItem: safeSuperview(),
                                            attribute: .bottom,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    /// Fill the whole view
    func fill(_ padding: CGFloat) {
        fill(top: padding, left: padding, right: padding, bottom: padding)
    }
    
    func fill(top: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0) {
        safeSuperview()
        sides(left: left, right: right)
        vertical(top: top, bottom: bottom)
    }
    
    /// Configures superview for autolayout and returns it
    @discardableResult private func safeSuperview() -> UIView {
        element.translatesAutoresizingMaskIntoConstraints = false
        guard let view = element.superview else {
            fatalError("You need to have a superview before you can add contraints")
        }
        return view
    }
    
    /// Print the `safeAreaInsets` into the console
    func printSafeInsets() {
        if #available(iOS 11, *) {
            print(element.safeAreaInsets)
        }
    }
    
}


extension UIView {
    
    /// Internal custom autolayout helper
    var layout: Layout {
        return Layout(self)
    }
    
}

private var ViewAssociatedObjectHandle: UInt8 = 2

extension UIView {
    
    /// [MarcoPolo] Navigation item (details)
    public internal(set) var node: ViewNode? {
        get {
            guard let item = objc_getAssociatedObject(self, &ViewAssociatedObjectHandle) as? ViewNode else {
                return nil
            }
            return item
        }
        set {
            if newValue==nil {
                objc_setAssociatedObject(self, &ViewAssociatedObjectHandle, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return
            }
            objc_setAssociatedObject(self, &ViewAssociatedObjectHandle, newValue!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}































