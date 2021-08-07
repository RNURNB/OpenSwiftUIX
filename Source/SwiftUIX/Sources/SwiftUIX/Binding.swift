import Foundation


internal struct PropertyList: CustomStringConvertible {
    internal var elements: PropertyList.Element?
    init() { elements = nil }
    var description: String {
        return ""
    }
}
extension PropertyList {
    class Tracker {
    }
}
extension PropertyList {
    internal class Element: CustomStringConvertible {
        internal var description: String {
            return ""
        }
    }
}

/*public struct Transaction {
    var plist: PropertyList
    public init() {
        plist = PropertyList()
    }
}*/

@propertyWrapper @dynamicMemberLookup public struct Binding<Value> {
    //public var transaction: Transaction
    //internal var location: AnyLocation<Value>
    //fileprivate var _value: Value
    let get:() -> Value
    let set:(Value) -> Void
    
    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        //self.transaction = Transaction()
        //self.location = AnyLocation(value: get())
        //self._value = get()
        //set(_value)
        self.get=get
        self.set=set
    }
    
    /*public init(get: @escaping () -> Value, set: @escaping (Value, Transaction) -> Void) {
        self.transaction = Transaction()
        self.location = AnyLocation(value: get())
        self._value = get()
        //set(_value, self.transaction)
    }*/
    
    public static func constant(_ value: Value) -> Binding<Value> {
        fatalError()
    }
    
    public var wrappedValue: Value {
        get { /*return location._value*/return get() }
        nonmutating set {/*location._value=newValue*/set(newValue)}
    }
    
    public var projectedValue: Binding<Value> {
        self
    }
    
    public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> Binding<Subject> {
        fatalError()
    }
}

class StoredLocation<Value>: AnyLocation<Value> {
    
}

/*
extension Binding {
    public func transaction(_ transaction: Transaction) -> Binding<Value> {
        fatalError()
    }
    
//    public func animation(_ animation: Animation? = .default) -> Binding<Value> {
//
//    }
}
*/

extension Binding: DynamicProperty {
    
    public func update() { //DynamicProperty protocol
    }
}

extension Binding {
    public init<V>(_ base: Binding<V>) where Value == V? {
        fatalError()
    }
    
    public init?(_ base: Binding<Value?>) {
        fatalError()
    }
    
    public init<V>(_ base: Binding<V>) where Value == AnyHashable, V : Hashable {
        fatalError()
    }
}


extension Binding {
    @inlinable
    public func map<T>(_ keyPath: WritableKeyPath<Value, T>) -> Binding<T> {
        .init(
            get: { wrappedValue[keyPath: keyPath] },
            set: { wrappedValue[keyPath: keyPath] = $0 }
        )
    }
}

extension Binding {
    @inlinable
    public func mirror(to other: Binding) -> Self {
        .init(
            get: { wrappedValue },
            set: {
                wrappedValue = $0
                other.wrappedValue = $0
            }
        )
    }
}

extension Binding {
    @inlinable
    public func onSet(_ body: @escaping (Value) -> ()) -> Self {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0; body($0) }
        )
    }
    
    public func printOnSet() -> Self {
        onSet {
            print("Set value: \($0)")
        }
    }
}

extension Binding {
    @inlinable
    public func onChange(perform action: @escaping (Value) -> ()) -> Self where Value: Equatable {
        return .init(
            get: { self.wrappedValue },
            set: { newValue in
                let oldValue = self.wrappedValue
                
                self.wrappedValue = newValue
                
                if newValue != oldValue  {
                    action(newValue)
                }
            }
        )
    }
    
    @inlinable
    public func onChange(toggle value: Binding<Bool>) -> Self where Value: Equatable {
        onChange { _ in
            value.wrappedValue.toggle()
        }
    }
}

extension Binding {
    public func removeDuplicates() -> Self where Value: Equatable {
        return .init(
            get: { self.wrappedValue },
            set: { newValue in
                let oldValue = self.wrappedValue
                
                guard newValue != oldValue else {
                    return
                }
                
                self.wrappedValue = newValue
            }
        )
    }
}

extension Binding {
    @inlinable
    public func withDefaultValue<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
        return .init(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    @inlinable
    public func isNil<Wrapped>() -> Binding<Bool> where Optional<Wrapped> == Value {
        .init(
            get: { self.wrappedValue == nil },
            set: { isNil in self.wrappedValue = isNil ? nil : self.wrappedValue  }
        )
    }
    
    @inlinable
    public func isNotNil<Wrapped>() -> Binding<Bool> where Optional<Wrapped> == Value {
        .init(
            get: { self.wrappedValue != nil },
            set: { isNotNil in self.wrappedValue = isNotNil ? self.wrappedValue : nil  }
        )
    }
    
    public func nilIfEmpty<T: Collection>() -> Binding where Value == Optional<T> {
        Binding(
            get: {
                guard let wrappedValue = self.wrappedValue, !wrappedValue.isEmpty else {
                    return nil
                }
                
                return wrappedValue
            },
            set: { newValue in
                if let newValue = newValue {
                    self.wrappedValue = newValue.isEmpty ? nil : newValue
                } else {
                    self.wrappedValue = nil
                }
            }
        )
    }
    
    public static func boolean<T: Equatable>(_ value: Binding<T?>, equals some: T) -> Binding<Bool> where Value == Bool {
        .init(
            get: { value.wrappedValue == some },
            set: { newValue in
                if newValue {
                    value.wrappedValue = some
                } else {
                    value.wrappedValue = nil
                }
            }
        )
    }
}

extension Binding {
    @inlinable
    public static func && (lhs: Binding, rhs: Bool) -> Binding where Value == Bool {
        .init(
            get: { lhs.wrappedValue && rhs },
            set: { lhs.wrappedValue = $0 }
        )
    }
    
    @inlinable
    public static func && (lhs: Binding, rhs: Bool) -> Binding where Value == Bool? {
        .init(
            get: { lhs.wrappedValue.map({ $0 && rhs }) },
            set: { lhs.wrappedValue = $0 }
        )
    }
}

extension Binding {
    @inlinable
    public func takePrefix(_ count: Int) -> Self where Value == String {
        .init(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                self.wrappedValue = .init($0.prefix(count))
            }
        )
    }
    
    @inlinable
    public func takeSuffix(_ count: Int) -> Self where Value == String {
        .init(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                self.wrappedValue = .init($0.suffix(count))
            }
        )
    }
    
    @inlinable
    public func takePrefix(_ count: Int) -> Self where Value == String? {
        .init(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                self.wrappedValue = $0.map({ .init($0.prefix(count)) })
            }
        )
    }
    
    @inlinable
    public func takeSuffix(_ count: Int) -> Self where Value == String? {
        .init(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                self.wrappedValue = $0.map({ .init($0.suffix(count)) })
            }
        )
    }
}





















