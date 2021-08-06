import Foundation
import Combine
import CoreRender

public class SCLEnvironment { //:CREnvironment {
    var values:EnvironmentValues
    
    public init(values:EnvironmentValues) {
        self.values=values
        //super.init()
    }
}

public protocol EnvironmentKey {
    associatedtype Value
    static var defaultValue: Self.Value { get }
}

public struct EnvironmentValues: CustomStringConvertible {
    var values: [ObjectIdentifier: Any] = [:]
    
    public init() {
    }
    
    public subscript<K>(key: K.Type) -> K.Value where K: EnvironmentKey {
        get {
            if let value = values[ObjectIdentifier(key)] as? K.Value {
                return value
            }
            return K.defaultValue
        }
        set {
            values[ObjectIdentifier(key)] = newValue
        }
    }
    
    public var description: String {
        get {
            return "\(values)"
        }
    }
}

public protocol DynamicProperty {
    func update()
}

@propertyWrapper public class Environment<Value>: DynamicProperty {
    internal enum Content {
        case keyPath(KeyPath<EnvironmentValues, Value>)
        case value(Value)
    }
    
    internal var content: Environment<Value>.Content
    internal var key:KeyPath<EnvironmentValues, Value>
    
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        key = keyPath
        content = .keyPath(keyPath)
        Application?.registerDynamicProperty(self)
    }
    public var wrappedValue: Value {
        get {
            switch content {
            case let .value(value):
                return value
            case let .keyPath(keyPath):
                // not bound to a view, return the default value.
                return EnvironmentValues()[keyPath: keyPath]
            }
        }
    }
    
    internal func error() -> Never {
        fatalError()
    }
    
    public func update() { //DynamicProperty protocol
        //print("update dynamic prop ",self)
        if Application?.buildEnvironment != nil {
                content = .value(Application!.buildEnvironment![keyPath: key])
                return
        }
        if Application != nil {
            content = .value(Application!.environment[keyPath: key])
        }
    
        //content = .keyPath(keyPath)
    }
}

public protocol SCLEnvironmentalModifier /*: ViewModifier where Self.Body == Never*/ {
    /*associatedtype ResolvedModifier : ViewModifier*/
    func resolve(in environment: inout EnvironmentValues) -> Void //-> Self.ResolvedModifier
    
}

public struct _EnvironmentKeyWritingModifier<Value>: ViewModifier, SCLEnvironmentalModifier {
    public var keyPath: WritableKeyPath<EnvironmentValues, Value>
    public var value: Value
    public init(keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) {
        self.keyPath = keyPath
        self.value = value
    }
    public typealias Body = Never
    
    public func resolve(in environment: inout EnvironmentValues) -> Void { //-> _EnvironmentKeyWritingModifier<Value> {
        //print("resolve ",keyPath, " to ", value)
        environment[keyPath:keyPath]=value
    }
}

extension View {
    public func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V) -> some View {
        //print("environment called with ",keyPath," value ",value)
        return modifier(_EnvironmentKeyWritingModifier(keyPath: keyPath, value: value))
    }
}


@propertyWrapper public class EnvironmentObject<ObjectType:ObservableObject>: DynamicProperty {
    internal enum Content {
        case keyPath(KeyPath<EnvironmentValues, ObjectType>)
        case value(ObjectType?)
    }
    
    internal var content: EnvironmentObject<ObjectType>.Content
    
    public init(_ keyPath: KeyPath<EnvironmentValues, ObjectType>) {
        content = .keyPath(keyPath)
    }
    
    public init(wrappedValue:ObjectType) {
        content = .value(wrappedValue)
    }
    
    public init() {
        var v:ObjectType?=nil
        //print("EnvironmentObject.init build env:",Application?.buildEnvironment)
        if Application?.buildEnvironment != nil {
            v=Application!.buildEnvironment!.values[ObjectIdentifier(ObjectType.self)] as? ObjectType
        }
        if v==nil {v=Application?.environment.values[ObjectIdentifier(ObjectType.self)] as? ObjectType}
        if v==nil {
            content = .value(nil)
            Application?.registerDynamicProperty(self)
            //assertionFailure("EnvironmentObject of type \(ObjectType.self) not found")
            return
        }
        content = .value(v!)
        Application?.registerDynamicProperty(self)
    }
    
    public func update() { //DynamicProperty protocol
        //update stored value
        //print("EnvironmentObject.update build env:",Application?.buildEnvironment)
        var v:ObjectType?=nil
        if Application?.buildEnvironment != nil {
            v=Application!.buildEnvironment!.values[ObjectIdentifier(ObjectType.self)] as? ObjectType
        }
        if v==nil {v=Application?.environment.values[ObjectIdentifier(ObjectType.self)] as? ObjectType}
        if v==nil {
            content = .value(nil)
            //assertionFailure("EnvironmentObject of type \(ObjectType.self) not found")
            return
        }
        //print("found value for prop ",self)
        content = .value(v!)
    }
    
    public var wrappedValue: ObjectType {
        get {
            switch content {
            case let .value(value):
                //print("EnvironmentObject access environmentobject ",value)
                /*if value==nil {
                    if Application?.buildEnvironment != nil {
                        let v=Application!.buildEnvironment!.values[ObjectIdentifier(ObjectType.self)] as? ObjectType
                        if v != nil {content = .value(v!);return v!}
                    }
                    let v=Application?.environment.values[ObjectIdentifier(ObjectType.self)] as? ObjectType
                    if v != nil {content = .value(v!);return v!}
                }
                */
                if value==nil {assertionFailure("EnvironmentObject of type \(ObjectType.self) not found")}
                return value!
            case let .keyPath(keyPath):
                // not bound to a view, return the default value.
                return EnvironmentValues()[keyPath: keyPath]
            }
        }
    }
    
    internal func error() -> Never {
        fatalError()
    }
}

/*extension EnvironmentObject where ObjectType: ExpressibleByNilLiteral {
    
    public convenience init() {
        self.init(wrappedValue: nil) 
    }
}*/

/*extension EnvironmentObject {
    public var isPresent: Bool {
        return (Mirror(reflecting: self).children.first(where: { $0.label == "_store" })?.value as? ObjectType) != nil
    }
}*/

public struct _EnvironmentObjectKeyWritingModifier<Value>: ViewModifier, SCLEnvironmentalModifier {
    public var value: Value
    //public var keyPath: WritableKeyPath<EnvironmentValues, Value>
    
    public init(value: Value) {
        self.value = value
        //self.keyPath=WritableKeyPath<EnvironmentValues, Value>()
    }
    public typealias Body = Never
    
    public func resolve(in environment: inout EnvironmentValues) -> Void { //-> _EnvironmentKeyWritingModifier<Value> {
        //print("resolve ",Value.self, " to ", value)
        environment.values[ObjectIdentifier(Value.self)]=value
    }
}

extension View {
    public func environmentObject<V>(_ value: V) -> some View {
        //print("environmentobject called with ",value)
        return modifier(_EnvironmentObjectKeyWritingModifier(value: value))
    }
}


























