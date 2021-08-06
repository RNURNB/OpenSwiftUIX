import Foundation
import UIKit
import CoreRender

/// A view representing some form of control flow.
public protocol ControlFlowView: View {
    
}

public struct _ConditionalContent<TrueContent, FalseContent>: UIViewRepresentable where TrueContent: View, FalseContent: View {
    public enum Storage {
        case trueContent(TrueContent)
        case falseContent(FalseContent)
    }
    
    public typealias Body = Never
    public typealias UIViewType=UIView
    //public var context:SCLContext? = nil
    //public typealias UIBody = UIView
    public let _storage: Storage
    
    init(storage: Storage) {
        _storage = storage
    }
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> _ConditionalContent<TrueContent, FalseContent> {return self}
    
    public func makeUIView(context:UIViewRepresentableContext<_ConditionalContent>) -> UIViewType {
        fatalError()
    }
    
    public func updateUIView(_ view:UIViewType,context:UIViewRepresentableContext<_ConditionalContent>) -> Void {
        fatalError()
    }
}

extension _ConditionalContent {
    public var body: Never {
        fatalError()
    }
}


public struct ForEach<Data, ID, Content> where Data: RandomAccessCollection, ID: Hashable {
    //public var context:SCLContext?
    internal let keyPath:KeyPath<Data.Element, ID>?        //id is keyPath for ID=KeyPath<Data.Element, ID>
    internal let idindex:Bool
    public var tags=ViewTagMapping()
    
    public var data: Data
    public var content: (Data.Element) -> Content
}

extension ForEach: _View where Content: _View {
    public var viewBuildable:UIViewBuildable? {nil}
    public var viewBuildableList:UIViewBuildableList? {nil}
}

extension ForEach: View where Content: View {
    
    public var body: Never {
        fatalError()
    }
    
    public typealias Body = Never
}

extension ForEach where ID == Data.Element.ID, Content: View, Data.Element: Identifiable {
    public init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        //print("Foreach with id:",ID.self)
        self.data = data
        self.content = content
        self.keyPath=\Data.Element.id
        self.idindex=false
    }
}

extension ForEach where Content: View {
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> Content) {
        //print("Foreach with keypath:",id)
        self.data = data
        self.content = content
        self.keyPath=id
        self.idindex=false
    }
}

extension ForEach where Data == Range<Int>, ID == Int, Content: View {
    public init(_ data: Range<Int>, @ViewBuilder content: @escaping (Int) -> Content) {
        self.data = data
        self.content = content
        self.keyPath=nil
        self.idindex=true
    }
}


extension ForEach {
    public var isEmpty: Bool {
        data.isEmpty
    }
    
    public var count: Int {
        data.count
    }
}

extension ForEach where Content: View {
    public init<_Element>(
        _ data: Data,
        @ViewBuilder content: @escaping (_Element) -> Content
    ) where Data.Element == KeyPathHashIdentifiableValue<_Element, ID> {
        self.init(data) {
            content($0.value)
        }
    }

    public init<Elements: RandomAccessCollection>(
        enumerating data: Elements,
        id: KeyPath<Elements.Element, ID>,
        @ViewBuilder rowContent: @escaping (Int, Elements.Element) -> Content
    ) where Data == [_KeyPathIdentifiableElementOffsetPair<Elements.Element, Int, ID>] {
        self.init(data.enumerated().map({ _KeyPathIdentifiableElementOffsetPair(element: $0.element, offset: $0.offset, id: id) })) {
            rowContent($0.offset, $0.element)
        }
    }
    
    public init<Elements: RandomAccessCollection>(
        enumerating data: Elements,
        @ViewBuilder rowContent: @escaping (Int, Elements.Element) -> Content
    ) where Elements.Element: Identifiable, Data == [_IdentifiableElementOffsetPair<Elements.Element, Int>], ID == Elements.Element.ID {
        self.init(data.enumerated().map({ _IdentifiableElementOffsetPair(element: $0.element, offset: $0.offset) })) {
            rowContent($0.offset, $0.element)
        }
    }

    public init<Elements: MutableCollection & RandomAccessCollection>(
        _ data: Binding<Elements>,
        @ViewBuilder rowContent: @escaping (Binding<Elements.Element>) -> Content
    ) where Data == AnyRandomAccessCollection<_IdentifiableElementOffsetPair<Elements.Element, Elements.Index>>, ID == Elements.Element.ID {
        self.init(AnyRandomAccessCollection(data.wrappedValue.indices.lazy.map({ _IdentifiableElementOffsetPair(element: data.wrappedValue[$0], offset: $0) }))) { pair in
            rowContent(
                Binding(
                    get: { data.wrappedValue[pair.offset] },
                    set: { data.wrappedValue[pair.offset] = $0 }
                )
            )
        }
    }
}

extension ForEach where Data.Element: Identifiable, Content: View, ID == Data.Element.ID {
    public func interleave<Separator: View>(with separator: Separator) -> some View {
        let data = self.data.enumerated().map({ _IdentifiableElementOffsetPair(element: $0.element, offset: $0.offset) })
        
        return ForEach<[_IdentifiableElementOffsetPair<Data.Element, Int>], Data.Element.ID,  Group<TupleView<(Content, Separator?)>>>(data) { pair in
            Group {
                self.content(pair.element)
                
                if pair.offset != (data.count - 1) {
                    separator
                }
            }
        }
    }
}

extension ForEach where Data.Element: Identifiable, Content: View, ID == Data.Element.ID {
    public func interdivided() -> some View {
        let data = self.data.enumerated().map({ _IdentifiableElementOffsetPair(element: $0.element, offset: $0.offset) })
        
        return ForEach<[_IdentifiableElementOffsetPair<Data.Element, Int>], Data.Element.ID,  Group<TupleView<(Content, Divider?)>>>(data) { pair in
            Group {
                self.content(pair.element)
                
                if pair.offset != (data.count - 1) {
                    Divider()
                }
            }
        }
    }
}

extension ForEach where Data.Element: Identifiable, Content: View, ID == Data.Element.ID {
    public func interspaced() -> some View {
        let data = self.data.enumerated().map({ _IdentifiableElementOffsetPair(element: $0.element, offset: $0.offset) })
        
        return ForEach<[_IdentifiableElementOffsetPair<Data.Element, Int>], Data.Element.ID,  Group<TupleView<(Content, Spacer?)>>>(data) { pair in
            Group {
                self.content(pair.element)
                
                if pair.offset != (data.count - 1) {
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Helpers -
extension RandomAccessCollection {
    public func elements<ID>(
        identifiedBy id: KeyPath<Element, ID>
    ) -> AnyRandomAccessCollection<KeyPathHashIdentifiableValue<Element, ID>> {
        .init(lazy.map({ KeyPathHashIdentifiableValue(value: $0, keyPath: id) }))
    }
}

public struct _IdentifiableElementOffsetPair<Element: Identifiable, Offset>: Identifiable {
    let element: Element
    let offset: Offset
    
    public var id: Element.ID {
        element.id
    }
    
    init(element: Element, offset: Offset) {
        self.element = element
        self.offset = offset
    }
}

public protocol HashIdentifiable: Hashable, Identifiable where Self.ID == Int {
    
}

// MARK: - Implementation -
extension HashIdentifiable {
    @inlinable
    public var id: Int {
        hashValue
    }
}

// MARK: - API -
extension Hashable {
    @inlinable
    public var hashIdentifiable: HashIdentifiableValue<Self> {
        return .init(self)
    }
}

public struct HashIdentifiableValue<Value: Hashable>: CustomStringConvertible, HashIdentifiable {
    public let value: Value
    
    public var description: String {
        .init(describing: value)
    }

    @inlinable
    public init(_ value: Value) {
        self.value = value
    }
}

public struct KeyPathHashIdentifiableValue<Value, ID: Hashable>: CustomStringConvertible, Identifiable {
    public let value: Value
    public let keyPath: KeyPath<Value, ID>
    
    public var description: String {
        .init(describing: value)
    }
    
    public var id: ID {
        value[keyPath: keyPath]
    }

    public init(value: Value, keyPath: KeyPath<Value, ID>) {
        self.value = value
        self.keyPath = keyPath
    }
}

extension KeyPathHashIdentifiableValue: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}

extension KeyPathHashIdentifiableValue: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

public struct _KeyPathIdentifiableElementOffsetPair<Element, Offset, ID: Hashable>: Identifiable {
    let element: Element
    let offset: Offset
    let keyPathToID: KeyPath<Element, ID>
    
    public var id: ID {
        element[keyPath: keyPathToID]
    }
    
    init(element: Element, offset: Offset, id: KeyPath<Element, ID>) {
        self.element = element
        self.offset = offset
        self.keyPathToID = id
    }
}

public typealias AnyForEachData = AnyRandomAccessCollection<AnyForEachElement>
public typealias AnyForEach<Content> = ForEach<AnyForEachData, AnyHashable, Content>

public struct AnyForEachElement: Identifiable {
    public let index: AnyIndex
    public let value: Any
    public let id: AnyHashable
}

extension ForEach where Content: View, Data == AnyForEachData, ID == AnyHashable {
    @_disfavoredOverload
    public init<Data: RandomAccessCollection, ID: Hashable>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        let collection = AnyRandomAccessCollection(data.indices.lazy.map({ AnyForEachElement(index: AnyIndex($0), value: data[$0], id: data[$0][keyPath: id]) }))
        
        self.init(collection, id: \.id) { (element: AnyForEachElement) in
            content(collection[element.index].value as! Data.Element)
        }
    }
    
    public init<Data: RandomAccessCollection, ID: Hashable>(
        _ data: ForEach<Data, ID, Content>
    ) where Data.Element: Identifiable {
        self.init(data.data, id: \.id, content: data.content)
    }
    
    public init<Data: RandomAccessCollection, ID: Hashable>(
        _ content: ForEach<Data, ID, Content>
    ) {
        let data = content.data
        let content = content.content
        
        self.init(data.lazy.indices.map({ data.distance(from: data.startIndex, to: $0) }), id: \.self, content: { content(data[data.index(data.startIndex, offsetBy: $0)]) }) // FIXME! - This is a poor hack until `id` is exposed publicly by `ForEach`
    }
}


extension ForEach: UIViewBuildable, UIViewBuildableList {
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //fatalError() //use buildTree from ViewBuildableList instrad
        let r:[ViewNode]?=buildTree(parent:parent, in:parent.runtimeenvironment)
        return nil //would be a list instead of a single ViewNode
    }
    
    /*public func makeUIView(context:SCLContext,reusedView:UIView?) -> UIView {
        fatalError() //use buildTree from ViewBuildableList instrad
    }
    
    public func updateUIView(context:SCLContext,view:UIView?) -> Void {
        fatalError() //use buildTree from ViewBuildableList instrad
    }*/
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> [ViewNode]? {

        var index:Int64=0 
        
        //print("forEach buildTree data=\(data)")
        var c:[ViewNode]?=nil
        for i in data {
            //print("element:",i)
            //print("content:",content(i))
            let content=self.content(i)
            
            //get id
            var id:Int64
            if keyPath != nil {
                //print("KeyPath is:",keyPath!)
                let id1=i[keyPath:keyPath!]
                //print("id1 is:",id1)
                //if let h=id1 as? Hashable {id=h.hashValue}
                id=Int64(id1.hashValue)
                tags.tagMapping[Int(id)]=id1
            }
            else /*if idindex*/ {
                id=index
                tags.tagMapping[Int(id)]=Int(id)
            }
            
            //}
            
            //print("foreach id:",id," for ",i)
            
            if let element = content as? UIViewBuildable {
                if let viewBuildable1 = content as? UIViewBuildableList {
                    //print("build list \(viewBuildable1)")
                    if let l=viewBuildable1.buildTree(parent: parent, in:parent.runtimeenvironment) {
                        for n in l {
                            if c == nil {c=[]}
                            c!.append(n)
                        }
                    }
                }
                else {
                    let n=element.buildTree(parent: parent, in:parent.runtimeenvironment)
                    if n != nil {
                        n!.value?.tag=id
                        if c == nil {c=[]}
                        c!.append(n!)
                    }
                }
            }
            /*else if let element = content.body as? ViewBuildable {
                // Custom View
                if let viewBuildable1 = content as? ViewBuildableList {
                    //print("build optional \(viewBuildable)")
                    if let l=viewBuildable1.buildTree(context:context,parent: parent) {
                        for n in l {
                            if c == nil {c=[]}
                            c!.append(n)
                        }
                    }
                }
                else {
                    let n=element.buildTree(context:context,parent: parent)
                    if n != nil {
                        if c == nil {c=[]}
                        c!.append(n!)
                    }
                }
            } */ else {
                print("No Idea what's inside.")
                print(content)
            }
            
            index=index+1
        } //for
        
        parent.tags=self.tags
        
        //print("foreach result ",c)
        return c
    }
}

/// A view representing the start of a `switch` control flow.
public struct SwitchOver<Data>: View/*, UIViewBuildable*/ {
    public let comparator: Data
    
    public init(_ comparator: Data) {
        self.comparator = comparator
    }
    
    public var body: some View {
        return EmptyView()
    }
    
    /*public func buildTree(parent: ViewNode) -> ViewNode? {
        //todo
        return nil
    }*/
}

// MARK: - Extensions -
extension SwitchOver {
    /// Handles a case in a `switch` control flow.
    public func `case`<Content: View>(
        predicate: @escaping (Data) -> Bool,
        @ViewBuilder content: () -> Content
    ) -> SwitchOverCaseFirstView<Data, Content> {
        return .init(
            comparator: comparator,
            predicate: predicate,
            content: content
        )
    }
    
    /// Handles a case in a `switch` control flow.
    public func `case`<Content: View>(
        _ comparate: Data,
        @ViewBuilder content: () -> Content
    ) -> SwitchOverCaseFirstView<Data, Content> where Data: Equatable {
        return .init(
            comparator: comparator,
            comparate: comparate,
            content: content
        )
    }
}

/// A view representing a `case` statement in a `switch` control flow.
public protocol SwitchOverCaseView: ControlFlowView {
    /// The type of data being compared in the control flow.
    associatedtype Data
    
    /// The data being compared against in the control flow.
    var comparator: Data { get }
    
    /// The predicate being used for matching in the control flow.
    var predicate: (Data) -> Bool { get }
    
    /// Whether `self` represents a match in the control flow.
    var isAMatch: Bool { get }
    
    /// Whether any cases prior to `self` represent a match in the control flow.
    var hasMatchedPreviously: Bool? { get }
}

/// A view representing first `case` statement in a `switch` control flow.
public struct SwitchOverCaseFirstView<Data, Content: View>: SwitchOverCaseView, UIViewBuildable {
    public let comparator: Data
    public let predicate: (Data) -> Bool
    
    public let body: Content?
    
    public var isAMatch: Bool {
        return predicate(comparator)
    }
    
    public var hasMatchedPreviously: Bool? {
        return nil
    }
    
    public init(
        comparator: Data,
        predicate: @escaping (Data) -> Bool,
        content: () -> Content
    ) {
        self.comparator = comparator
        self.predicate = predicate
        
        body = predicate(comparator) ? content() : nil
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //return body.buildtree(parent:parent)
        
        if let viewBuildable = body as? UIViewBuildable {
            //print("build normal \(viewBuildable)")
            if let viewBuildable1 = body as? UIViewBuildableList {
                //print("build normal \(viewBuildable)")
                if let l=viewBuildable1.buildTree(parent: parent, in:parent.runtimeenvironment) {
                    return nil //need to return list
                }
            }
            else if let n=viewBuildable.buildTree(parent: parent, in:parent.runtimeenvironment) {
                //childlist.append(n)
                return n
            }
        }
        
        
        print("SwitchOverCaseDefaultView: ViewBuildable: Can't render custom views \(body) (\(type(of:body))), yet.")
        return nil
    }
}

extension SwitchOverCaseFirstView where Data: Equatable {
    public init(
        comparator: Data,
        comparate: Data,
        content: () -> Content
    )  {
        self.init(
            comparator: comparator,
            predicate: { $0 == comparate },
            content: content
        )
    }
}

/// A view representing a noninitial `case` statement in a `switch` control flow.
public struct SwitchOverCaseNextView<PreviousCase: SwitchOverCaseView, Content: View>: SwitchOverCaseView,UIViewBuildable  {
    public typealias Data = PreviousCase.Data
    
    public let previous: PreviousCase
    public let predicate: (Data) -> Bool
    public let body: _ConditionalContent<PreviousCase, Content?>
    
    public var comparator: Data {
        return previous.comparator
    }
    
    public var isAMatch: Bool {
        return predicate(comparator)
    }
    
    public var hasMatchedPreviously: Bool? {
        if previous.isAMatch {
            return true
        } else {
            return previous.hasMatchedPreviously
        }
    }
    
    public init(
        previous: PreviousCase,
        predicate: @escaping (Data) -> Bool,
        content: () -> Content
    ) {
        self.previous = previous
        self.predicate = predicate
        
        if (previous.isAMatch || (previous.hasMatchedPreviously ?? false)) {
            self.body = ViewBuilder.buildEither(first: previous)
        } else if predicate(previous.comparator) {
            self.body = ViewBuilder.buildEither(second: content())
        } else {
            self.body = ViewBuilder.buildEither(second: nil)
        }
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //return body.buildtree(parent:parent)
        
        if let viewBuildable = body as? UIViewBuildable {
            //print("build normal \(viewBuildable)")
            if let viewBuildable1 = body as? UIViewBuildableList {
                //print("build normal \(viewBuildable)")
                if let l=viewBuildable1.buildTree(parent: parent, in:parent.runtimeenvironment) {
                    return nil //need to return list...
                }
            }
            else if let n=viewBuildable.buildTree(parent: parent, in:parent.runtimeenvironment) {
                //childlist.append(n)
                return n
            }
        }
        
        
        print("SwitchOverCaseNextView: ViewBuildable: Can't render custom views \(body) (\(type(of:body))), yet.")
        return nil
    }
}

extension SwitchOverCaseNextView where Data: Equatable {
    public init(
        previous: PreviousCase,
        comparate: Data,
        content: () -> Content
    )  {
        self.init(
            previous: previous,
            predicate: { $0 == comparate },
            content: content
        )
    }
}

/// A view representing a `default` statement in a `switch` control flow.
public struct SwitchOverCaseDefaultView<PreviousCase: SwitchOverCaseView, Content: View>: View, UIViewBuildable {
    public typealias Data = PreviousCase.Data
    
    public let previous: PreviousCase
    public let body: _ConditionalContent<PreviousCase, Content>
    
    public init(previous: PreviousCase, content: () -> Content) {
        self.previous = previous
        
        if previous.isAMatch || (previous.hasMatchedPreviously ?? false)  {
            self.body = ViewBuilder.buildEither(first: previous)
        } else {
            self.body = ViewBuilder.buildEither(second: content())
        }
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //return body.buildtree(parent:parent)
        
        if let viewBuildable = body as? UIViewBuildable {
            //print("build normal \(viewBuildable)")
            if let viewBuildable1 = body as? UIViewBuildableList {
                //print("build normal \(viewBuildable)")
                if let l=viewBuildable1.buildTree(parent: parent, in:parent.runtimeenvironment) {
                    return nil //need to return list
                }
            }
            else if let n=viewBuildable.buildTree(parent: parent, in:parent.runtimeenvironment) {
                //childlist.append(n)
                return n
            }
        }
        
        
        print("SwitchOverCaseDefaultView: ViewBuildable: Can't render custom views \(body) (\(type(of:body))), yet.")
        return nil
    }
}

// MARK: - Extensions -
extension SwitchOverCaseView {
    /// Handles a case in a `switch` control flow.
    public func `case`<Content: View>(
        predicate: @escaping (Data) -> Bool,
        @ViewBuilder content: () -> Content
    ) -> SwitchOverCaseNextView<Self, Content> {
        return .init(
            previous: self,
            predicate: predicate,
            content: content
        )
    }

    /// Handles a case in a `switch` control flow.
    public func `case`<Content: View>(
        _ comparate: Data,
        predicate: @escaping (Data) -> Bool,
        @ViewBuilder content: () -> Content
    ) -> SwitchOverCaseNextView<Self, Content> {
        .init(
            previous: self,
            predicate: predicate,
            content: content
        )
    }
    
    /// Handles a case in a `switch` control flow.
    public func `case`<Content: View>(
        _ comparate: Data,
        @ViewBuilder content: () -> Content
    ) -> SwitchOverCaseNextView<Self, Content> where Data: Equatable {
        .init(
            previous: self,
            comparate: comparate,
            content: content
        )
    }
    
    public func `default`<Content: View>(@ViewBuilder content: () -> Content) -> SwitchOverCaseDefaultView<Self, Content> {
        return .init(previous: self, content: content)
    }
}














