import Foundation
import CoreRender

public protocol _VariadicView_Root {
    static var _viewListOptions: Int { get }
}

extension _VariadicView_Root {
    public static var _viewListOptions: Int {
        get {
            fatalError()
        }
    }
}

public struct _VariadicView_Children {
    public var context:SCLContext?=nil
}

extension _VariadicView_Children : View {
    public var body: Never {
        fatalError()
    }
    
    public typealias Body = Never
    
    //public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIView/*Self.UIBody*/>) -> Void) -> _VariadicView_Children {return self}
}

public protocol _ViewTraitKey {
    associatedtype Value
    static var defaultValue: Self.Value { get }
}

extension _VariadicView_Children: RandomAccessCollection {
    public struct Element : View, Identifiable {
        public var body: Never
        
        public var id: AnyHashable {
            get {
                fatalError()
            }
        }
        public func id<ID>(as _: ID.Type = ID.self) -> ID? where ID : Hashable {
            fatalError()
        }
        public subscript<Trait>(key: Trait.Type) -> Trait.Value where Trait : _ViewTraitKey {
            get {
                fatalError()
            }
            set {
                fatalError()
            }
        }
        /*public static func _makeView(view: _GraphValue<_VariadicView_Children.Element>, inputs: _ViewInputs) -> _ViewOutputs {
            fatalError()
        }*/
        public typealias ID = AnyHashable
        public typealias Body = Never
        public var context:SCLContext? = nil
        
        //public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIView/*Self.UIBody*/>) -> Void) -> Element {return self}
    }
    public var startIndex: Int {
        get {
            fatalError()
        }
    }
    public var endIndex: Int {
        get {
            fatalError()
        }
    }
    public subscript(index: Int) -> _VariadicView_Children.Element {
        get {
            fatalError()
        }
    }
    public typealias Index = Int
    public typealias Iterator = IndexingIterator<_VariadicView_Children>
    public typealias SubSequence = Slice<_VariadicView_Children>
    public typealias Indices = Range<Int>
}

public protocol _VariadicView_ViewRoot: _VariadicView_Root {
    //static func _makeView(root: _GraphValue<Self>, inputs: _ViewInputs, body: (_Graph, _ViewInputs) -> _ViewListOutputs) -> _ViewOutputs
    //static func _makeViewList(root: _GraphValue<Self>, inputs: _ViewListInputs, body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs) -> _ViewListOutputs
    associatedtype Body: View
    func body(children: _VariadicView.Children) -> Self.Body
}

extension _VariadicView_ViewRoot where Self.Body == Never {
    public func body(children: _VariadicView.Children) -> Never {
        fatalError()
    }
}

/*extension _VariadicView_ViewRoot {
    public static func _makeView(root: _GraphValue<Self>, inputs: _ViewInputs, body: (_Graph, _ViewInputs) -> _ViewListOutputs) -> _ViewOutputs {
        fatalError()
    }
    public static func _makeViewList(root: _GraphValue<Self>, inputs: _ViewListInputs, body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs) -> _ViewListOutputs {
        fatalError()
    }
}*/

public protocol _VariadicView_UnaryViewRoot: _VariadicView_ViewRoot {
}

extension _VariadicView_UnaryViewRoot {
    /*public static func _makeViewList(root: _GraphValue<Self>, inputs: _ViewListInputs, body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs) -> _ViewListOutputs {
        fatalError()
    }*/
}

public protocol _VariadicView_MultiViewRoot: _VariadicView_ViewRoot {
}

extension _VariadicView_MultiViewRoot {
    /*public static func _makeView(root: _GraphValue<Self>, inputs: _ViewInputs, body: (_Graph, _ViewInputs) -> _ViewListOutputs) -> _ViewOutputs {
        fatalError()
    }*/
}

public enum _VariadicView {
    public typealias Root = _VariadicView_Root
    public typealias ViewRoot = _VariadicView_ViewRoot
    public typealias Children = _VariadicView_Children
    public typealias UnaryViewRoot = _VariadicView_UnaryViewRoot
    public typealias MultiViewRoot = _VariadicView_MultiViewRoot
    public class Tree<Root, Content> where Root: _VariadicView_Root {
        public var root: Root
        public var content: Content
        //public var context:SCLContext?=nil
        internal init(root: Root, content: Content) {
            self.root = root
            self.content = content
        }
        public init(_ root: Root, @ViewBuilder content: () -> Content) {
            self.root = root
            self.content = content()
        }
    }
}

extension _VariadicView.Tree: _View where Root: _VariadicView_ViewRoot, Content: _View {
    public var viewBuildable:UIViewBuildable? {nil}
    public var viewBuildableList:UIViewBuildableList? {nil}
}

extension _VariadicView.Tree: View where Root: _VariadicView_ViewRoot, Content: View {
    public var body: Never {
        fatalError()
    }
    
    public typealias Body = Never
    
    //public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIView/*Self.UIBody*/>) -> Void) -> _VariadicView.Tree<Root, Content> {return self}
}
























