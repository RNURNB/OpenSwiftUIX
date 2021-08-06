import Foundation
import Combine

internal class AnyLocationBase {
}

internal class AnyLocation<Value>: AnyLocationBase {
    
    //internal let _value = UnsafeMutablePointer<Value>.allocate(capacity: 1)
    internal var _value:Value {
        didSet {
                //state var has changed either by direct set of state var or by setting a bind var
                //alert("state value change","\(_value) Application=\(Application)");
                Application?.setNeedsBuild()
        }
    }
    
    init(value: Value) {
        //self._value.pointee = value
        self._value=value
    }
    
    /*@inline(__always) func set(value:Value) {
        self._value=value
    }*/
}

internal class AnyLocationSilent<Value>: AnyLocationBase {
    
    //internal let _value = UnsafeMutablePointer<Value>.allocate(capacity: 1)
    internal var _value:Value
    
    init(value: Value) {
        //self._value.pointee = value
        self._value=value
    }
    
    /*@inline(__always) func set(value:Value) {
        self._value=value
    }*/
}

struct WeakBox<T: AnyObject> {
    weak var value: T?
    
    init(_ value: T?) {
        self.value = value
    }
}

@propertyWrapper
@usableFromInline
final class ReferenceBox<T> {
    @usableFromInline
    var value: T
    
    @usableFromInline
    var wrappedValue: T {
        get {
            value
        } set {
            value = newValue
        }
    }
    
    @usableFromInline
    init(_ value: T) {
        self.value = value
    }
    
    @usableFromInline
    init(wrappedValue value: T) {
        self.value = value
    }
}

@propertyWrapper
@usableFromInline
final class WeakReferenceBox<T: AnyObject> {
    @usableFromInline
    weak var value: T?
    
    @usableFromInline
    var wrappedValue: T? {
        get {
            value
        } set {
            value = newValue
        }
    }

    @usableFromInline
    init(_ value: T?) {
        self.value = value
    }
    
    @usableFromInline
    init(wrappedValue value: T?) {
        self.value = value
    }
}

@usableFromInline
final class ObservableReferenceBox<T>: ObservableObject {
    @usableFromInline
    @Published var value: T
    
    @usableFromInline
    init(_ value: T) {
        self.value = value
    }
}

@usableFromInline
final class ObservableWeakReferenceBox<T: AnyObject>: ObservableObject {
    @usableFromInline
    weak var value: T? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @usableFromInline
    init(_ value: T?) {
        self.value = value
    }
}

public struct _DynamicPropertyBuffer {
}

@propertyWrapper public struct State<Value>: DynamicProperty {
    internal var _value: Value
    internal var _location: AnyLocation<Value>
    
    public init(wrappedValue value: Value) {
        self._value = value
        self._location = AnyLocation(value: value)
    }
    
    public init(initialValue value: Value) {
        self._value = value
        self._location = AnyLocation(value: value)
    }
    
    public var wrappedValue: Value {
        get { /*return _location?._value.pointee ?? _value*/return _location._value ?? _value }
        nonmutating set {/*_location?._value.pointee = newValue*/_location._value=newValue}
    }
    
    public var projectedValue: Binding<Value> {
        return Binding(get: { return self.wrappedValue }, 
                       set: { newValue in self.wrappedValue = newValue})
    }
    
    public func update() { //DynamicProperty protocol
    }
    
    /*public static func _makeProperty<V>(in buffer: inout _DynamicPropertyBuffer, container: _GraphValue<V>, fieldOffset: Int, inputs: inout _GraphInputs) {
        fatalError()
    }*/
}

extension State where Value: ExpressibleByNilLiteral {
    public init() {
        self.init(wrappedValue: nil)
    }
}


@propertyWrapper public struct StateObject<Value>: DynamicProperty where Value:ObservableObject {
    internal var _value: Value
    private var cancellable: AnyCancellable
    
    public init(wrappedValue value: Value) {
        self._value = value
        //alert("state","value init \(_value)")
        cancellable=value.objectWillChange.sink { _ in 
           Application?.setNeedsBuild()
        }
    }
    
    public init(initialValue value: Value) {
        self._value = value
        //alert("state","wrapped value init \(_value)")
        cancellable=value.objectWillChange.sink { _ in 
           Application?.setNeedsBuild()
        }
    }
    
    public func update() { //DynamicProperty protocol
    }
    
    public var wrappedValue: Value {
        get { return _value }
        set {_value=newValue}
    }
}

extension StateObject where Value: ExpressibleByNilLiteral {
    
    public init() {
        self.init(wrappedValue: nil) 
    }
}


@propertyWrapper public struct SceneStorage<Value>: DynamicProperty {
    internal var _value: Value
    internal var _location: AnyLocationSilent<Value>
    
    public init(wrappedValue value: Value) {
        self._value = value
        self._location = AnyLocationSilent(value: value)
    }
    
    public init(initialValue value: Value) {
        self._value = value
        self._location = AnyLocationSilent(value: value)
    }
    
    public var wrappedValue: Value {
        get { /*return _location?._value.pointee ?? _value*/return _location._value ?? _value }
        nonmutating set {/*_location?._value.pointee = newValue*/_location._value=newValue}
    }
    
    public var projectedValue: Binding<Value> {
        return Binding(get: { return self.wrappedValue }, 
                       set: { newValue in self.wrappedValue = newValue})
    }
    
    public func update() { //DynamicProperty protocol
    }

    
    /*public static func _makeProperty<V>(in buffer: inout _DynamicPropertyBuffer, container: _GraphValue<V>, fieldOffset: Int, inputs: inout _GraphInputs) {
        fatalError()
    }*/
}

extension SceneStorage where Value: ExpressibleByNilLiteral {
    public init() {
        self.init(wrappedValue: nil)
    }
}

















