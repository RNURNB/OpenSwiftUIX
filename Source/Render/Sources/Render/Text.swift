import Foundation
import CoreRender
import UIKit


public enum FontEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Font? { return nil }
}

public extension EnvironmentValues {
    public var font: Font? {
        set { self[FontEnvironmentKey.self] = newValue }
        get { self[FontEnvironmentKey.self] }
    }
}

public class AnyFontBox: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
    
    public static func ==(lhs: AnyFontBox, rhs: AnyFontBox) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    open func uifont() -> UIFont {
        return UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
    }
}

public class SystemProvider: AnyFontBox {
    public var size: CGFloat
    public var weight: Font.Weight
    public var design: Font.Design
    
    init(size: CGFloat, weight: Font.Weight, design: Font.Design) {
        self.size = size
        self.weight = weight
        self.design = design 
    }
    
    public static func ==(lhs: SystemProvider, rhs: SystemProvider) -> Bool {
        return lhs.size == rhs.size && lhs.weight == rhs.weight && lhs.design == rhs.design
    }
    
    public override func uifont() -> UIFont {
        
        if design == .monospaced {
          switch weight {
            case .ultraLight: return UIFont.monospacedDigitSystemFont(ofSize: size, weight: UIFont.Weight.ultraLight)
            case .thin: return UIFont.monospacedDigitSystemFont(ofSize: size, weight: UIFont.Weight.thin)
            case .light: return UIFont.monospacedDigitSystemFont(ofSize: size, weight: UIFont.Weight.light)
            case .regular: return UIFont.monospacedDigitSystemFont(ofSize: size, weight: UIFont.Weight.regular)
            case .medium: return UIFont.monospacedDigitSystemFont(ofSize: size, weight: UIFont.Weight.medium)
            case .semibold: return UIFont.monospacedDigitSystemFont(ofSize: size, weight: UIFont.Weight.semibold)
            case .bold: return UIFont.monospacedDigitSystemFont(ofSize: size, weight: UIFont.Weight.bold)
            case .heavy: return UIFont.monospacedDigitSystemFont(ofSize: size, weight: UIFont.Weight.heavy)
            case .black: return UIFont.monospacedDigitSystemFont(ofSize: size, weight: UIFont.Weight.black)
            default:return UIFont.monospacedDigitSystemFont(ofSize: size, weight: UIFont.Weight.regular)
          }
        }
        
        //todo design
        switch weight {
            case .ultraLight: return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.ultraLight)
            case .thin: return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.thin)
            case .light: return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.light)
            case .regular: return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.regular)
            case .medium: return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.medium)
            case .semibold: return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.semibold)
            case .bold: return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
            case .heavy: return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.heavy)
            case .black: return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.black)
            default:return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.regular)
        }
    }
}

public class TextStyleProvider: AnyFontBox {
    public var style: Font.TextStyle
    public var design: Font.Design
    
    init(style: Font.TextStyle, design: Font.Design) {
        self.style = style
        self.design = design
    }
    
    public static func ==(lhs: TextStyleProvider, rhs: TextStyleProvider) -> Bool {
        return lhs.style == rhs.style && lhs.design == rhs.design
    }
    
    public override func uifont() -> UIFont {
    
        //todo design
        switch style {
            case .largeTitle: return UIFont.preferredFont(forTextStyle: .largeTitle)
            case .title1: return UIFont.preferredFont(forTextStyle: .title1)
            case .title2: return UIFont.preferredFont(forTextStyle: .title2)
            case .title3: return UIFont.preferredFont(forTextStyle: .title3)
            case .headline: return UIFont.preferredFont(forTextStyle: .headline)
            case .subheadline: return UIFont.preferredFont(forTextStyle: .subheadline)
            case .body: return UIFont.preferredFont(forTextStyle: .body)
            case .callout: return UIFont.preferredFont(forTextStyle: .callout)
            case .footnote: return UIFont.preferredFont(forTextStyle: .footnote)
            case .caption1: return UIFont.preferredFont(forTextStyle: .caption1)
            case .caption2: return UIFont.preferredFont(forTextStyle: .caption2)
        }
    }
}

public struct Font: Hashable {
    public var provider: AnyFontBox
    
    init(provider: AnyFontBox) {
        self.provider = provider
    }
    
    public static func system(_ style: Font.TextStyle, design: Font.Design = .default) -> Font {
        let provider = TextStyleProvider(style: style, design: design)
        return Font(provider: provider)
    }
    
    public static func system(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        let provider = SystemProvider(size: size, weight: weight, design: design)
        return Font(provider: provider)
    }
    
    public static func custom(_ name: String, size: CGFloat) -> Font {
        fatalError()
    }
    
    public static func == (lhs: Font, rhs: Font) -> Bool {
        return lhs.provider == rhs.provider
    }
    
    public func uifont() -> UIFont {
        return provider.uifont()
    }
}

public extension Font {
    public struct Weight: Hashable {
        public var value: CGFloat
        
        public static let ultraLight: Font.Weight = Weight(value: 100)
        public static let thin: Font.Weight = Weight(value: 200)
        public static let light: Font.Weight = Weight(value: 300)
        public static let regular: Font.Weight = Weight(value: 400)
        public static let medium: Font.Weight = Weight(value: 500)
        public static let semibold: Font.Weight = Weight(value: 600)
        public static let bold: Font.Weight = Weight(value: 700)
        public static let heavy: Font.Weight = Weight(value: 800)
        public static let black: Font.Weight = Weight(value: 900)
    }
}

public extension Font {
    public static let largeTitle = Font.system(Font.TextStyle.largeTitle)
    public static let title1 = Font.system(Font.TextStyle.title1)
    public static let title2 = Font.system(Font.TextStyle.title2)
    public static let title3 = Font.system(Font.TextStyle.title3)
    public static var headline = Font.system(Font.TextStyle.headline)
    public static var subheadline = Font.system(Font.TextStyle.subheadline)
    public static var body = Font.system(Font.TextStyle.body)
    public static var callout = Font.system(Font.TextStyle.callout)
    public static var footnote = Font.system(Font.TextStyle.footnote)
    public static var caption1 = Font.system(Font.TextStyle.caption1)
    public static var caption2 = Font.system(Font.TextStyle.caption2)
    
    public enum TextStyle: CaseIterable {
        case largeTitle
        case title1
        case title2
        case title3
        case headline
        case subheadline
        case body
        case callout
        case footnote
        case caption1
        case caption2
    }
    
    public enum Design: Hashable {
        case `default`
        case serif
        case rounded
        case monospaced
    }
}

public struct AnyTextStorage<Storage: StringProtocol>/*:CustomStringConvertible*/ {
    public var storage: Storage
    
    internal init(storage: Storage) {
        self.storage = storage
    }
    
    var localized: String {
        return LocalizedStringKey(String(storage)).stringValue() //try localization
    }
}

public class AnyTextModifier {
    init() {
    }
}

public class LocalizedTextStorage {
    public var storage: LocalizedStringKey
    public var bundle:Bundle?
    public var tableName:String?
    
    internal init(storage: LocalizedStringKey, bundle:Bundle?=nil, tableName:String?=nil) {
        self.storage = storage
        self.bundle=bundle
        self.tableName=tableName
    }
}

extension UITextField {
    @IBInspectable var placeholderColor: UIColor {
        get {
            return attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? .clear
        }
        set {
            guard let attributedPlaceholder = attributedPlaceholder else { return }
            let attributes: [NSAttributedString.Key: UIColor] = [.foregroundColor: newValue]
            self.attributedPlaceholder = NSAttributedString(string: attributedPlaceholder.string, attributes: attributes)
        }
    }
}

public struct TextField: UIViewRepresentable/*, Equatable*/ {
    public typealias Body = Never
    public typealias UIViewType = UITextField
    //public var context:SCLContext?=nil
    public var _storage: Storage
    public var _modifiers: [TextField.Modifier] = [Modifier]()
    internal var _layoutSpec:LayoutSpecWrapper<UIViewType>
    internal var _title: LocalizedStringKey?
    internal var _onEditingChanged: ((Bool) -> Void)?
    internal var _onCommit: (() -> Void)?
    internal var _text:Binding<String>?
    
    public enum Storage: Equatable {
        public static func == (lhs: TextField.Storage, rhs: TextField.Storage) -> Bool {
            switch (lhs, rhs) {
            case (.verbatim(let contentA), .verbatim(let contentB)):
                return contentA == contentB
            case (.anyTextStorage(let contentA), .anyTextStorage(let contentB)):
                return contentA.storage == contentB.storage
            case (.localized(let contentA), .localized(let contentB)):
                return contentA.storage/*.key*/ == contentB.storage/*.key*/ && contentA.bundle==contentB.bundle && contentA.tableName==contentB.tableName
            default:
                return false
            }
        }
        
        case verbatim(String)
        case anyTextStorage(AnyTextStorage<String>)
        case localized(LocalizedTextStorage)
    }
    
    public enum Modifier: Equatable {
        case color(Color?)
        case font(Font?)
        // case italic
        // case weight(Font.Weight?)
        // case kerning(CGFloat)
        // case tracking(CGFloat)
        // case baseline(CGFloat)
        // case rounded
        // case anyTextModifier(AnyTextModifier)
        public static func == (lhs: TextField.Modifier, rhs: TextField.Modifier) -> Bool {
            switch (lhs, rhs) {
            case (.color(let colorA), .color(let colorB)):
                return colorA == colorB
            case (.font(let fontA), .font(let fontB)):
                return fontA == fontB
            default:
                return false
            }
        }
    }
    
    public init(_ title: LocalizedStringKey,verbatim text: String, onEditingChanged: ((Bool) -> Void)?=nil,onCommit: (() -> Void)?=nil) { //use text as is
        self._storage = .verbatim(text)
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
        self._title = title
        self._onEditingChanged=onEditingChanged
        self._onCommit=onCommit
    }
    
    public init(_ text: String, onEditingChanged: ((Bool) -> Void)?=nil,onCommit: (() -> Void)?=nil) { //use text as is
        self._storage = .verbatim(text)
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
        self._onEditingChanged=onEditingChanged
        self._onCommit=onCommit
    }    
    
    public init(verbatim text: String, onEditingChanged: ((Bool) -> Void)?=nil,onCommit: (() -> Void)?=nil) { //use text as is
        self._storage = .verbatim(text)
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
        self._onEditingChanged=onEditingChanged
        self._onCommit=onCommit
    }
    
    public init(_ title: LocalizedStringKey,text: Binding<String>, onEditingChanged: ((Bool) -> Void)?=nil,
                onCommit: (() -> Void)?=nil) { //use text as is
        //print("TextField init")
        self._storage = .verbatim(text.wrappedValue)
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
        self._title = title
        self._onEditingChanged=onEditingChanged
        self._onCommit=onCommit
        self._text=text
    }
    
    public init(_ text: Binding<String>, onEditingChanged:  ((Bool) -> Void)?=nil,onCommit:  (() -> Void)?=nil) { //use text as is
        self._storage = .verbatim(text.wrappedValue)
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
        self._onEditingChanged=onEditingChanged
        self._onCommit=onCommit
        self._text=text
    }
    
    @_disfavoredOverload //without this, the initializer below with LocalizedStringKey would never be called
    public init<S>(_ content: S, onEditingChanged:  ((Bool) -> Void)?=nil,
                   onCommit:  (() -> Void)?=nil) where S: StringProtocol { //use translated text, if available
        self._storage = .anyTextStorage(AnyTextStorage<String>(storage: String(content)))
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
        self._onEditingChanged=onEditingChanged
        self._onCommit=onCommit
    }
    
    public init(_ key: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil, 
                onEditingChanged:  ((Bool) -> Void)?=nil,onCommit:  (() -> Void)?=nil) {
        self._storage = .localized(LocalizedTextStorage(storage:key,bundle:bundle,tableName:tableName))
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
    }
    
    private init(content: Storage, modifiers: [Modifier] = [], layoutSpec:LayoutSpecWrapper<UIViewType>=LayoutSpecWrapper<UIViewType>(),
                 title: LocalizedStringKey?=nil, onEditingChanged:  ((Bool) -> Void)?=nil,onCommit:  (() -> Void)?=nil,text:Binding<String>?) {
        self._storage = content
        self._modifiers = modifiers
        self._layoutSpec = layoutSpec
        self._title=title
        self._onEditingChanged=onEditingChanged
        self._onCommit=onCommit
        self._text=text
    }
    
    public static func == (lhs: TextField, rhs: TextField) -> Bool {
        return lhs._storage == rhs._storage && lhs._modifiers == rhs._modifiers //&& lhs._title==rhs._title
    }
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> TextField {
        _layoutSpec.add(spec)
        return self
    }
}

public extension TextField {
    public func foregroundColor(_ color: Color?) -> TextField {
        textWithModifier(TextField.Modifier.color(color))
    }
    
    public func font(_ font: Font?) -> TextField {
        textWithModifier(TextField.Modifier.font(font))
    }
    
    private func textWithModifier(_ modifier: Modifier) -> TextField {
        let modifiers = _modifiers + [modifier]
        return TextField(content:_storage, modifiers: modifiers, layoutSpec:_layoutSpec, title:_title,onEditingChanged:_onEditingChanged,
                         onCommit:_onCommit,text:_text)
    }
}

public extension TextField {
    public var body: Never {
        fatalError()
    }
}

public extension TextField /*where Label == Text*/ {
    public init(
        _ title: LocalizedStringKey,
        text: Binding<String>,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            title,
            text: text,
            onEditingChanged: { isEditing.wrappedValue = $0 },
            onCommit: onCommit
        )
    }
    
    public init(
        _ title: LocalizedStringKey,
        text: Binding<String?>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            title,
            text: text.withDefaultValue(""),
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
    }
    
    public init(
        _ title: LocalizedStringKey,
        text: Binding<String?>,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            title,
            text: text,
            onEditingChanged: { isEditing.wrappedValue = $0 },
            onCommit: onCommit
        )
    }
}

extension TextField {
    
    public func makeUIView(context:UIViewRepresentableContext<TextField>) -> UIViewType {
        let v=UIViewType(frame:CGRect(x:0,y:0,width:0,height:0))
        v.delegate=context.coordinator
        return v
    }
    
    public func updateUIView(_ view:UIViewType,context:UIViewRepresentableContext<TextField>) -> Void {
        //print("list updateUIView for ",view)
        view.delegate=context.coordinator
    }
    
    func setLayouts(_ view:UIViewType,spec:LayoutSpec<UIViewType>) {
        //view.textAlignment = .center
        for m in self._modifiers {
            switch m {
                case .color(let c):
                    if (c != nil) {view.textColor=c!.uicolor()}
                        //alert("color value","\(c!)")
                case .font(let f):
                    if (f != nil) {view.font=f!.uifont()}
            }
        }
        self._layoutSpec.layoutSpec?(spec)
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        switch _storage {
        case .verbatim(let content):
            let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"TextField",key:nil,layoutSpec: { spec, context in
                guard let view = spec.view as? UIViewType else { return }
                if self._text != nil {view.text=self._text!.wrappedValue}
                else {view.text = content}
                //print("Textfield locale:",env?.values.locale)
                let localizedtitle:String?=self._title != nil ? self._title!.stringValue(locale:context.environment.values.locale ?? .current) : nil
                view.placeholder=localizedtitle
                self.setLayouts(view,spec:spec)
              }
              ,controller:defaultController
            )
            let vnode = ViewNode(value: node)
            parent.addChild(node: vnode)
            return vnode
        case .anyTextStorage(let content):
            let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"TextField",key:nil,layoutSpec: { spec, context in
                guard let view = spec.view as? UIViewType else { return }
                view.text = content.storage 
                //print("Textfield locale:",env?.values.locale)
                let localizedtitle:String?=self._title != nil ? self._title!.stringValue(locale:context.environment.values.locale ?? .current) : nil
                view.placeholder=localizedtitle
                self.setLayouts(view,spec:spec)
              }
              ,controller:defaultController
            )
            let vnode = ViewNode(value: node)
            parent.addChild(node: vnode)
            return vnode
        case .localized(let content):
            let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"TextField",key:nil,layoutSpec: { spec, context in
                guard let view = spec.view as? UIViewType else { return }
                view.text = content.storage.stringValue(locale:context.environment.values.locale ?? .current,bundle:content.bundle,tableName:content.tableName)
                let localizedtitle:String?=self._title != nil ? self._title!.stringValue(locale:context.environment.values.locale ?? .current) : nil
                view.placeholder=localizedtitle
                self.setLayouts(view,spec:spec)
              }
              ,controller:defaultController
            )
            let vnode = ViewNode(value: node)
            parent.addChild(node: vnode)
            return vnode
        }
    }
    
    public func makeCoordinator() -> Coordinator { 
        return Coordinator(self)
    }
    
    public class Coordinator:NSObject, UITextFieldDelegate {
        let textfield:TextField
    
        public init(_ textfield:TextField) {
            self.textfield=textfield
        }
        
        public func textFieldDidBeginEditing(_ textField: UITextField) {
            //print("textfield textFieldDidBeginEditing")
            self.textfield._onEditingChanged?(true)
        }
    
        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            //print("textfield textFieldDidEndEditing val=\(textField.text) _text=\(self.textfield._text)")
            self.textfield._text?.wrappedValue=textField.text ?? ""
            self.textfield._onCommit?()
            self.textfield._onEditingChanged?(false)
        }
    }
}


public struct Text: UIViewRepresentable/*, Equatable*/ {
    public typealias Body = Never
    public typealias UIViewType = UILabel
    //public var context:SCLContext?=nil
    public var _storage: Storage
    public var _modifiers: [Text.Modifier] = [Modifier]()
    internal var _layoutSpec:LayoutSpecWrapper<UIViewType>
    
    public enum Storage: Equatable {
        public static func == (lhs: Text.Storage, rhs: Text.Storage) -> Bool {
            switch (lhs, rhs) {
            case (.verbatim(let contentA), .verbatim(let contentB)):
                return contentA == contentB
            case (.anyTextStorage(let contentA), .anyTextStorage(let contentB)):
                return contentA.storage == contentB.storage
            case (.localized(let contentA), .localized(let contentB)):
                return contentA.storage/*.key*/ == contentB.storage/*.key*/ && contentA.bundle==contentB.bundle && contentA.tableName==contentB.tableName
            default:
                return false
            }
        }
        
        case verbatim(String)
        case anyTextStorage(AnyTextStorage<String>)
        case localized(LocalizedTextStorage)
    }
    
    public enum Modifier: Equatable {
        case color(Color?)
        case font(Font?)
        // case italic
        // case weight(Font.Weight?)
        // case kerning(CGFloat)
        // case tracking(CGFloat)
        // case baseline(CGFloat)
        // case rounded
        // case anyTextModifier(AnyTextModifier)
        public static func == (lhs: Text.Modifier, rhs: Text.Modifier) -> Bool {
            switch (lhs, rhs) {
            case (.color(let colorA), .color(let colorB)):
                return colorA == colorB
            case (.font(let fontA), .font(let fontB)):
                return fontA == fontB
            default:
                return false
            }
        }
    }
    
    /*public var text:String { get {
                                switch _storage {
                                    case .verbatim(let content):
                                        return content 
                                    case .anyTextStorage(let content):
                                        return content.storage 
                                }
                           }
    }*/
    
    public init(verbatim content: String) { //use text as is
        self._storage = .verbatim(content)
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
    }
    
    public init(_ content: LocalizedStringKey) { //use translated text, if available
        //print("text with LocalizedStringKey ",content," called")
        self._storage = .localized(LocalizedTextStorage(storage:content,bundle:nil,tableName:nil))
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
    }
    
    @_disfavoredOverload //without this, the initializer below with LocalizedStringKey would never be called
    public init<S>(_ content: S) where S: StringProtocol { //use text as is
        //print("text with StringProtocol called")
        self._storage = .anyTextStorage(AnyTextStorage<String>(storage: String(content)))
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
    }
     
    public init(_ key: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil) { //use translation
        self._storage = .localized(LocalizedTextStorage(storage:key,bundle:bundle,tableName:tableName))
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
    }
    
    /*private init(verbatim content: String, modifiers: [Modifier] = [], layoutSpec:LayoutSpecWrapper<UIViewType>=LayoutSpecWrapper<UIViewType>()) {
        self._storage = .verbatim(content)
        self._modifiers = modifiers
        self._layoutSpec = layoutSpec
    }*/
    
    private init(content: Storage, modifiers: [Modifier] = [], layoutSpec:LayoutSpecWrapper<UIViewType>=LayoutSpecWrapper<UIViewType>()) {
        self._storage = content
        self._modifiers = modifiers
        self._layoutSpec = layoutSpec
    }
    
    public static func == (lhs: Text, rhs: Text) -> Bool {
        return lhs._storage == rhs._storage && lhs._modifiers == rhs._modifiers
    }
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> Text {
       _layoutSpec.add(spec)
       return self
    }
}

extension Text {
    public var body: Never {
        fatalError()
    }
}




public extension Text {
    public func foregroundColor(_ color: Color?) -> Text {
        labelWithModifier(Text.Modifier.color(color))
    }
    
    public func font(_ font: Font?) -> Text {
        labelWithModifier(Text.Modifier.font(font))
    }
    
    private func labelWithModifier(_ modifier: Modifier) -> Text {
        let modifiers = _modifiers + [modifier]
        return Text(content:_storage, modifiers: modifiers, layoutSpec:_layoutSpec)
    }
    
    /*public static func + (lhs: Text, rhs: Text) -> Text {
        let modifiers = lhs._modifiers //+ rhs._modifiers
        let layoutSpec=lhs.layoutSpec
        
        switch lhs._storage {
            case .verbatim(let content):
            case .anyTextStorage(let content):
            case .localized(let content):
                switch rhs._storage {
                    case .verbatim(let content):
                    case .anyTextStorage(let content):
                    case .localized(let content):
                        let storage=LocalizedTextStorage(key:lhs.key,bundle:lhs.bundle,tableName:lhs.tableName)
                        return Text(content:_storage, modifiers: modifiers, layoutSpec:layoutSpec)
                }
        }
    }*/
}


//var buildcount=0

extension Text {
    public func makeUIView(context:UIViewRepresentableContext<Text>) -> UIViewType {
        return UIViewType(frame:CGRect(x:0,y:0,width:0,height:0))
    }
    
    public func updateUIView(_ view:UIViewType,context:UIViewRepresentableContext<Text>) -> Void {
    }
    
    func setLayouts(_ view:UIViewType,spec:LayoutSpec<UIViewType>) {
        //view.textAlignment = .center
        for m in self._modifiers {
            switch m {
                case .color(let c):
                    if (c != nil) {view.textColor=c!.uicolor()}
                        //alert("color value","\(c!)")
                case .font(let f):
                    if (f != nil) {view.font=f!.uifont()}
            }
        }
        self._layoutSpec.layoutSpec?(spec)
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        
        switch _storage {
        case .verbatim(let content):
            let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"Text",key:nil,layoutSpec: { spec, context in
                guard let view = spec.view as? UIViewType else { return }
                view.text = content //+ " BUILD \(buildcount)"
                self.setLayouts(view,spec:spec)
              }
              ,controller:defaultController
            )
            let vnode = ViewNode(value: node)
            parent.addChild(node: vnode)
            return vnode
        case .anyTextStorage(let content):
            let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"Text",key:nil,layoutSpec: { spec, context in
                guard let view = spec.view as? UIViewType else { return }
                //print("text storage:",content.storage)
                view.text = content.storage //+ " BUILD \(buildcount)"
                self.setLayouts(view,spec:spec)
              }
              ,controller:defaultController
            )
            let vnode = ViewNode(value: node)
            parent.addChild(node: vnode)
            return vnode
        case .localized(let content):
            let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"Text",key:nil,layoutSpec: { spec, context in
                guard let view = spec.view as? UIViewType else { return }
                view.text = content.storage.stringValue(locale:context.environment.values.locale ?? .current,bundle:content.bundle,tableName:content.tableName)
                //print("")
                //print("view text=",view.text," for env ",context.environment.values," stored env:",env.values)
                self.setLayouts(view,spec:spec)
              }
              ,controller:defaultController
            )
            //print("text context env is:",env?.values," Locale is:",env?.values.locale)
            let vnode = ViewNode(value: node)
            parent.addChild(node: vnode)
            return vnode
        }
    }
    
    public func makeCoordinator() -> Coordinator { 
        return Coordinator(self)
    }
    
    public class Coordinator:NSObject {
        let text:Text
    
        public init(_ text:Text) {
            self.text=text
        }
    }
}


public struct TextView: UIViewRepresentable/*, Equatable*/ {
    public typealias Body = Never
    public typealias UIViewType = UITextView
    //public var context:SCLContext?=nil
    public var _storage: Storage
    public var _modifiers: [TextView.Modifier] = [Modifier]()
    internal var _layoutSpec:LayoutSpecWrapper<UIViewType>
    internal var isDebugHost:Bool
    
    public enum Storage: Equatable {
        public static func == (lhs: TextView.Storage, rhs: TextView.Storage) -> Bool {
            switch (lhs, rhs) {
            case (.verbatim(let contentA), .verbatim(let contentB)):
                return contentA == contentB
            case (.anyTextStorage(let contentA), .anyTextStorage(let contentB)):
                return contentA.storage == contentB.storage
            case (.localized(let contentA), .localized(let contentB)):
                return contentA.storage/*.key*/ == contentB.storage/*.key*/ && contentA.bundle==contentB.bundle && contentA.tableName==contentB.tableName
            default:
                return false
            }
        }
        
        case verbatim(String)
        case anyTextStorage(AnyTextStorage<String>)
        case localized(LocalizedTextStorage)
    }
    
    public enum Modifier: Equatable {
        case color(Color?)
        case font(Font?)
        // case italic
        // case weight(Font.Weight?)
        // case kerning(CGFloat)
        // case tracking(CGFloat)
        // case baseline(CGFloat)
        // case rounded
        // case anyTextModifier(AnyTextModifier)
        public static func == (lhs: TextView.Modifier, rhs: TextView.Modifier) -> Bool {
            switch (lhs, rhs) {
            case (.color(let colorA), .color(let colorB)):
                return colorA == colorB
            case (.font(let fontA), .font(let fontB)):
                return fontA == fontB
            default:
                return false
            }
        }
    }
    
    public init(isDebugHost:Bool=false) {
        self._storage = .verbatim("")
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
        self.isDebugHost=isDebugHost
    }
    
    public init(verbatim content: String) { //use text as is
        self._storage = .verbatim(content)
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
        self.isDebugHost=false
    }
    
    @_disfavoredOverload //without this, the initializer below with LocalizedStringKey would never be called
    public init<S:StringProtocol>(_ content: S) { //use text as is
        self._storage = .anyTextStorage(AnyTextStorage<String>(storage: String(content)))
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
        self.isDebugHost=false
    }
     
    public init(_ key: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil) { //use translations
        self._storage = .localized(LocalizedTextStorage(storage:key,bundle:bundle,tableName:tableName))
        self._layoutSpec=LayoutSpecWrapper<UIViewType>()
        self.isDebugHost=false
    }
    
    private init(content: Storage, modifiers: [Modifier] = [], layoutSpec:LayoutSpecWrapper<UIViewType>=LayoutSpecWrapper<UIViewType>(), isDebugHost:Bool=false) {
        self._storage = content
        self._modifiers = modifiers
        self._layoutSpec = layoutSpec
        self.isDebugHost=isDebugHost
    }
    
    public static func == (lhs: TextView, rhs: TextView) -> Bool {
        return lhs._storage == rhs._storage && lhs._modifiers == rhs._modifiers
    }
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> TextView {
       self._layoutSpec.add(spec)
       //alert("textview withLayoutspec called","for \(_tlayoutSpec) value after:\(_tlayoutSpec.layoutSpec)")
       return self
    }
}

public extension TextView {
    public func foregroundColor(_ color: Color?) -> TextView {
        textWithModifier(TextView.Modifier.color(color))
    }
    
    public func font(_ font: Font?) -> TextView {
        textWithModifier(TextView.Modifier.font(font))
    }
    
    private func textWithModifier(_ modifier: Modifier) -> TextView {
        let modifiers = _modifiers + [modifier]
        return TextView(content:_storage, modifiers: modifiers, layoutSpec:_layoutSpec,isDebugHost:isDebugHost)
    }
}

public extension TextView {
    public var body: Never {
        fatalError()
    }
}


/*public class SCLTextView:UITextView {
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var s=super.sizeThatFits(size)
        let yoga = self.yoga //else { return s}
        //alert("size","sizethatfits with input \(size) super \(s) yoga w=\(yoga.width) yoga h=\(yoga.height)")
        return CGSize(width:100,height:100)
    }
}*/

extension TextView {
    
    public func makeUIView(context:UIViewRepresentableContext<TextView>) -> UIViewType {
        //if reusedView==nil {dbg("Application controls rebuild")}
        return UIViewType(frame:CGRect(x:0,y:0,width:0,height:0),textContainer:nil)
    }
    
    public func updateUIView(_ view:UIViewType, context:UIViewRepresentableContext<TextView>) -> Void {
        /*switch _storage {
            case .localized(let content):
                view.text=content.storage.stringValue(locale:context.environment.values.locale ?? .current,
                                                      bundle:content.bundle,tableName:content.tableName)
                print("UpdateText ",view.text," for env ",context.environment.values)
                                                
            default:
                return
        }*/
    }
    
    func setLayouts(_ view:UIViewType,spec:LayoutSpec<UIViewType>) {
        //view.textAlignment = .center
        for m in self._modifiers {
            switch m {
                case .color(let c):
                    if (c != nil) {view.textColor=c!.uicolor()}
                        //alert("color value","\(c!)")
                case .font(let f):
                    if (f != nil) {view.font=f!.uifont()}
            }
        }
        self._layoutSpec.layoutSpec?(spec)
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        
        if isDebugHost{
            let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"TextView",key:nil,layoutSpec: { spec, context in
                guard let view = spec.view as? UIViewType else { return }
                //alert("debughost init",Application?.debugMsgs ?? "")
                if Application != nil {view.text = Application!.debugMsgs}
                Application?.debugHost=view 
                self.setLayouts(view,spec:spec)
              }
              ,controller:defaultController
            )
            let vnode = ViewNode(value: node)
            parent.addChild(node: vnode)
            return vnode
        }
        
        switch _storage {
        case .verbatim(let content):
            //alert("textview build called","for \(_tlayoutSpec) layoutspec:\(_tlayoutSpec.layoutSpec)")
            let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"TextView",key:nil,layoutSpec: { spec, context in
                guard let view = spec.view as? UIViewType else { return }
                view.text = content 
                self.setLayouts(view,spec:spec)
              }
              ,controller:defaultController
            )
            let vnode = ViewNode(value: node)
            parent.addChild(node: vnode)
            return vnode
        case .anyTextStorage(let content):
            let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"TextView",key:nil,layoutSpec: { spec, context in
                guard let view = spec.view as? UIViewType else { return }
                view.text = content.storage 
                self.setLayouts(view,spec:spec)
              }
              ,controller:defaultController
            )
            let vnode = ViewNode(value: node)
            parent.addChild(node: vnode)
            return vnode
        case .localized(let content):
            let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"TextView",key:nil,layoutSpec: { spec, context in
                guard let view = spec.view as? UIViewType else { return }
                view.text = content.storage.stringValue(locale:context.environment.values.locale ?? .current,bundle:content.bundle,tableName:content.tableName)
                self.setLayouts(view,spec:spec)
              }
              ,controller:defaultController
            )
            let vnode = ViewNode(value: node)
            parent.addChild(node: vnode)
            return vnode
        }
    }
    
    public func makeCoordinator() -> Coordinator { 
        return Coordinator(self)
    }
    
    public class Coordinator:NSObject {
        let textview:TextView
    
        public init(_ textview:TextView) {
            self.textview=textview
        }
    }
}















