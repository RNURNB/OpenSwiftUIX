import Foundation
import UIKit
//import SwiftUI

public struct LocalizedStringKey: ExpressibleByStringLiteral, ExpressibleByStringInterpolation, Swift.Equatable {
    internal var key: String
    internal var hasFormatting: Bool = false
    internal var arguments: [LocalizedStringKey.FormatArgument]=[]
    
    @usableFromInline
    internal struct FormatArgument : Swift.Equatable {
        var specifier:String
        var value:String
        @usableFromInline
        internal static func == (lhs: LocalizedStringKey.FormatArgument, rhs: LocalizedStringKey.FormatArgument) -> Swift.Bool {
            return true
        }
    }
    
    public struct StringInterpolation: StringInterpolationProtocol {
        var parts: [String]
        var formats: [String]

        public init(literalCapacity: Int, interpolationCount: Int) {
          self.parts = []
          self.formats = []
          // - literalCapacity is the number of characters in literal segments (L)
          // - interpolationCount is the number of interpolation segments (I)
          // We estimate that we generally have a structure like "LILILIL"
          // — e.g. "Hello \(world, .color(.blue))!" — hence the 2n+1
          self.parts.reserveCapacity(2*interpolationCount+1)
          self.formats.reserveCapacity(2*interpolationCount+1)
        }

        public mutating func appendLiteral(_ literal: String) {
            self.parts.append(literal)
            self.formats.append("")
        }
        
        public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Foundation.Formatter? = nil) 
            where Subject : Foundation.ReferenceConvertible {
            //print("appendInterpolation ReferenceConvertible ",subject," type ",type(of:subject)," f=",formatter)
            //hasFormatting=true
            self.parts.append("\(subject)")
            if subject is Int {self.formats.append("%lld")}
            else if subject is Float {self.formats.append("%lld")}
            else if subject is Double {self.formats.append("%lld")}
            else {self.formats.append("%@")}
        }
        
        public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Foundation.Formatter? = nil) 
            where Subject : CustomStringConvertible {
            self.parts.append(subject.description)
            self.formats.append("%@")
        }
    
        /*public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Foundation.Formatter? = nil) 
            where Subject : ObjectiveC.NSObject {
            //hasFormatting=true
            print("appendInterpolation NSObject ",subject," f=",formatter)
        }*/
        
        //mutating public func appendInterpolation<T>(_ value: T) where T : SwiftUI._FormatSpecifiable
        //mutating public func appendInterpolation<T>(_ value: T, specifier: Swift.String) where T : SwiftUI._FormatSpecifiable
        
        mutating func appendInterpolation<T>(_ optional: T?) {
            appendInterpolation(String(describing: optional))
        }
        
        public typealias StringLiteralType = Swift.String
    }
    
    public typealias StringLiteralType = Swift.String
    public typealias ExtendedGraphemeClusterLiteralType = Swift.String
    public typealias UnicodeScalarLiteralType = Swift.String
    
    public static func == (a: LocalizedStringKey, b: LocalizedStringKey) -> Swift.Bool {
        return a.key == b.key && a.hasFormatting == b.hasFormatting && a.arguments==b.arguments
    }

    public init(stringInterpolation: LocalizedStringKey.StringInterpolation) {
        //print("init with interpolation ",stringInterpolation)
        //self.key = stringInterpolation.parts.joined()
        var c=0
        key=""
        for part in stringInterpolation.parts {
            let f=stringInterpolation.formats[c]
            if f=="" {
                key=key+part
            }
            else {
                hasFormatting=true
                key=key+f
                arguments.append(FormatArgument(specifier:f,value:part))
            }
            
            c=c+1
        }
        //print("key=",key," arguments=",arguments)
    }
    
    public init(_ value: String) {
        self.key = value
    }
    
    public init(stringLiteral value: String) {
        self.key = value
    }
}

extension String:Foundation.ReferenceConvertible {
    public typealias ReferenceType=NSString
    
    //public var specifier:String {get{"%@"}}
}

extension Int:Foundation.ReferenceConvertible {
    public typealias ReferenceType=NSNumber
    
    public var debugDescription:String {get{"\(self)"}}
    
    //public var specifier:String {get{"%lld"}}
}

extension Float:Foundation.ReferenceConvertible {
    public typealias ReferenceType=NSNumber
    
    public var debugDescription:String {get{"\(self)"}}
    
    //public var specifier:String {get{"%lld"}}
}

extension Double:Foundation.ReferenceConvertible {
    public typealias ReferenceType=NSNumber
    
    public var debugDescription:String {get{"\(self)"}}
    
    //public var specifier:String {get{"%lld"}}
}

extension CGFloat:Foundation.ReferenceConvertible {
    public typealias ReferenceType=NSNumber
    
    public var debugDescription:String {get{"\(self)"}}
    
    //public var specifier:String {get{"%lld"}}
}

/*
public protocol _FormatSpecifiable : Swift.Equatable {
  associatedtype _Arg : Swift.CVarArg
  var _arg: Self._Arg { get }
  var _specifier: Swift.String { get }
}

extension Int : _FormatSpecifiable {
  public var _arg: Swift.Int64 {
    get {Int64(self)}
  }
  public var _specifier: Swift.String {
    get {"%lld"}
  }
  public typealias _Arg = Swift.Int64
}


extension Int8 : SwiftUI._FormatSpecifiable {
  public var _arg: Swift.Int32 {
    get
  }
  public var _specifier: Swift.String {
    get
  }
  public typealias _Arg = Swift.Int32
}

extension Int16 : SwiftUI._FormatSpecifiable {
  public var _arg: Swift.Int32 {
    get
  }
  public var _specifier: Swift.String {
    get
  }
  public typealias _Arg = Swift.Int32
}

extension Int32 : SwiftUI._FormatSpecifiable {
  public var _arg: Swift.Int32 {
    get
  }
  public var _specifier: Swift.String {
    get
  }
  public typealias _Arg = Swift.Int32
}

extension Int64 : SwiftUI._FormatSpecifiable {
  public var _arg: Swift.Int64 {
    get
  }
  public var _specifier: Swift.String {
    get
  }
  public typealias _Arg = Swift.Int64
}

extension UInt : SwiftUI._FormatSpecifiable {
  public var _arg: Swift.UInt64 {
    get
  }
  public var _specifier: Swift.String {
    get
  }
  public typealias _Arg = Swift.UInt64
}

extension UInt8 : SwiftUI._FormatSpecifiable {
  public var _arg: Swift.UInt32 {
    get
  }
  public var _specifier: Swift.String {
    get
  }
  public typealias _Arg = Swift.UInt32
}

extension UInt16 : SwiftUI._FormatSpecifiable {
  public var _arg: Swift.UInt32 {
    get
  }
  public var _specifier: Swift.String {
    get
  }
  public typealias _Arg = Swift.UInt32
}

extension UInt32 : SwiftUI._FormatSpecifiable {
  public var _arg: Swift.UInt32 {
    get
  }
  public var _specifier: Swift.String {
    get
  }
  public typealias _Arg = Swift.UInt32
}

extension UInt64 : SwiftUI._FormatSpecifiable {
  public var _arg: Swift.UInt64 {
    get
  }
  public var _specifier: Swift.String {
    get
  }
  public typealias _Arg = Swift.UInt64
}

extension Float : SwiftUI._FormatSpecifiable {
  public var _arg: Swift.Float {
    get
  }
  public var _specifier: Swift.String {
    get
  }
  public typealias _Arg = Swift.Float
}

extension Double : SwiftUI._FormatSpecifiable {
  public var _arg: Swift.Double {
    get
  }
  public var _specifier: Swift.String {
    get
  }
  public typealias _Arg = Swift.Double
}

extension CGFloat : SwiftUI._FormatSpecifiable {
  public var _arg: CoreGraphics.CGFloat {
    get
  }
  public var _specifier: Swift.String {
    get
  }
  public typealias _Arg = CoreGraphics.CGFloat
}
*/

extension String {
    static func localizedString(for key: LocalizedStringKey,
                                locale: Locale = .current,bundle:Bundle?=nil, tableName:String?=nil) -> String {
        
        let language = locale.languageCode
        //print("get translation for ",key," for language ",language)
        
        var b:Bundle?=bundle
        if b==nil {
            if let path = Bundle.main.path(forResource: language, ofType: "lproj") {
                if let bundle = Bundle(path: path) {
                    b=bundle
                }
            }
        }
        
        var result:String
        if b == nil {
            result = key.key
        } //no localization
        else {
            result = NSLocalizedString(key.key, tableName: tableName, bundle: b!, comment: "")
        }
        
        if key.hasFormatting {
            for a in key.arguments {
                var v=a.value
                if b != nil {v=NSLocalizedString(v, tableName: tableName, bundle: b!, comment: "")}
                result=result.replaceFirst(of:a.specifier,with:v)
            }
        }
        
        return result
    }
} 

extension LocalizedStringKey {
    public func stringValue(locale: Locale = .current, bundle:Bundle?=nil, tableName:String?=nil) -> String {
        if locale==Locale.current { //check for locale in current env
            if Application?.buildEnvironment != nil {
                return .localizedString(for: self, locale: Application!.buildEnvironment!.locale, bundle:bundle, tableName:tableName)
            }
            if Application != nil {return .localizedString(for: self, locale: Application!.environment.locale, bundle:bundle, tableName:tableName)}
        }
        return .localizedString(for: self, locale: locale, bundle:bundle, tableName:tableName)
    }
}

struct LocaleEnvironmentKey: EnvironmentKey {
    static let defaultValue: Locale = Locale.current
}

extension EnvironmentValues {
    public var locale: Locale {
        get { self[LocaleEnvironmentKey.self] }
        set { 
            //print("set locale to ", newValue)
            self[LocaleEnvironmentKey.self] = newValue 
        }
    }
}

extension View {
    public func locale(_ value: Locale) -> some View {
        environment(\.locale, value)
    }
}

extension String {
  
  public func replaceFirst(of pattern:String,
                           with replacement:String) -> String {
    if let range = self.range(of: pattern){
      return self.replacingCharacters(in: range, with: replacement)
    }else{
      return self
    }
  }
  
  public func replaceAll(of pattern:String,
                         with replacement:String,
                         options: NSRegularExpression.Options = []) -> String{
    do{
      let regex = try NSRegularExpression(pattern: pattern, options: [])
      let range = NSRange(0..<self.utf16.count)
      return regex.stringByReplacingMatches(in: self, options: [],
                                            range: range, withTemplate: replacement)
    }catch{
      NSLog("replaceAll error: \(error)")
      return self
    }
  }
  
}

struct LocalizedString {
    var key: String

    init(_ key: String) {
        self.key = key
    }

    func resolve(locale: Locale = .current,bundle:Bundle?=nil, tableName:String?=nil) -> String {
        let language = locale.languageCode
        //print("get translation for ",key," for language ",language)
        if let bundle=bundle {
            let localizedString = NSLocalizedString(key, tableName: tableName, bundle: bundle, comment: "")
        
            return localizedString
        }
        else if let path = Bundle.main.path(forResource: language, ofType: "lproj") {
            if let bundle = Bundle(path: path) {
                let localizedString = NSLocalizedString(key, tableName: tableName, bundle: bundle, comment: "")
        
                return localizedString
            }
        }
        return key //no localization available
    }
}

extension LocalizedString: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        key = value
    }
}

private extension LocalizedString {
    func render<T>(
        into initialResult: T,
        handler: (inout T, String, _ isBold: Bool) -> Void
    ) -> T {
        let components = resolve().components(separatedBy: "**")
        let sequence = components.enumerated()

        return sequence.reduce(into: initialResult) { result, pair in
            let isBold = !pair.offset.isMultiple(of: 2)
            handler(&result, pair.element, isBold)
        }
    }
}

extension LocalizedString {
    typealias Fonts = (default: UIFont, bold: UIFont)

    static func defaultFonts() -> Fonts {
        let font = UIFont.preferredFont(forTextStyle: .body)
        return (font, .boldSystemFont(ofSize: font.pointSize))
    }

    func attributedString(
        withFonts fonts: Fonts = defaultFonts()
    ) -> NSAttributedString {
        render(
            into: NSMutableAttributedString(),
            handler: { fullString, string, isBold in
                let font = isBold ? fonts.bold : fonts.default

                fullString.append(NSAttributedString(
                    string: string,
                    attributes: [.font: font]
                ))
            }
        )
    }
}

/*extension LocalizedString {
    func styledText() -> Text {
        render(into: Text("")) { fullText, string, isBold in
            var text = Text(string)

            if isBold {
                text = text.bold()
            }

            fullText = fullText + text
        }
    }
}*/















