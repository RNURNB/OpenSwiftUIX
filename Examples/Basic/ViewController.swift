import UIKit
import CoreRender
import SwiftUIX
import Combine
  
struct DemoState {
    @State var statefulText:String="state text"
} 
 
class GlobalState:ObservableObject {
    @Published var state:String="Global State" 
}
  
struct Item:Hashable, Identifiable {  
    var name:String
    let id=UUID()  
              
    init(_ name:String) {         
        self.name=name 
    }        
}   
     
struct ListSection:Hashable, Identifiable { 
    var name:String 
    let id=UUID()
    var items:[Item]=[Item("item 1")] 
     
    init(_ name:String) { 
        self.name=name 
    }  
} 
 
class DemoClass:ObservableObject {
    @Published var testlist:[String]=["first entry"]
    @Published var age:Int=0
    @Published var sections:[ListSection]=[ListSection("Section1")]
     
    func haveBirthday() -> Int {
        age += 1
        return age  
    }    
}  
  
class Contact: ObservableObject { 
    @Published var name: String
    @Published var age: Int 

    init(name: String, age: Int) { 
        self.name = name
        self.age = age
    }  
 
    func haveBirthday() -> Int {  
        age += 1
        return age 
    } 
}

enum ShapeType {
    case capsule
    case circle
    case rectangle
    case squircle
}
 
class TMainForm: SCLFormController {
  //var hostingView: SCLUIHostingView<Demo1View.Body>?=nil
  var hostingView: SCLHostingView?=nil
  //let context = SCLContext()
  //var uiview:Demo1View?=nil
   
  public final class Demo1View:View {
    public var context:SCLContext?=nil
    //public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIView/*Self.UIBody*/>) -> Void) -> Self {return self}  
      
    @State var buildcount:Int=0 
    @Binding var text:String
    @StateObject var demo=DemoClass()
    @StateObject var demo1:Contact
    @SceneStorage var edit:String=""
    @State var listSelection:Item?
    @State var shapeType: ShapeType = .rectangle
    
    @Environment(\.scenePhase) private var phase
    @Environment(\.locale) private var envlocale
    @EnvironmentObject var state:GlobalState
    
    @State var locale = "en"
    
    public init(text:Binding<String>) {
        self._text=text 
        
        demo1=Contact(name:"john",age:24)
        
        print("Mainform initialized")
    }
      
    public var body: some View {
        VStack(/*alignment:.center,*//*spacing:4*/) {
            Spacer().height(20)
            
            PassthroughView {
              HStack(/*alignment:.center,*/spacing:4) {
                Button(action: {
                    //loadPreset=true
                    alert("load preset","pressed")

                }) {
                    Image(systemName: "tray.and.arrow.up")
                    //.renderingMode(.original)
                }
                
                Spacer().width(5)
                
                Button(action: {
                    //loadPreset=true
                    alert("trash","pressed")

                }) {
                    Image(systemName: "trash")
                    //.renderingMode(.original)
                }
                
                Spacer().width(5)
                Button(action: {
                    //loadPreset=true
                    print("Application state is : ",self.state.state)
                    self.state.state=LocalizedStringKey("Global State builds \(Application!.buildCount)").stringValue()
                    alert("button","pressed")

                }) {
                    Text(LocalizedStringKey("\(state.state)"))
                    .foregroundColor(.link)
                }
                
                Spacer().width(5)
                Button(action: {
                    //loadPreset=true
                    Application!.debugMsgs=""
                    if self.locale=="en" {self.locale="de"}
                    else {self.locale="en"}

                }) {
                    Text("Locale \(locale) env:\(envlocale)")
                    .foregroundColor(.link)
                }
                
                Spacer(minLength:10)
                
                Text("App builds: \(Application!.buildCount)").text(color:.red)
                
                Spacer().frame(width:4)
              }
              //.minWidth(10)
              .background(color:.systemGray4)
              .alignItems(.center)
            }
            //.background(color:.systemGray4)
            .height(40)
            //.maxHeight(40)
            //.minHeight(40)
            .matchHostingViewWidth(withMargin: 0)
            
            TextField("Enter Text here",text:$edit,onEditingChanged:{ editing in print("editmode .\(editing)")},
                                         onCommit:{print("Edit commit val= \(self.edit)")}
            )
            //.padding(insets:UIEdgeInsets(top:40,left:0,bottom:0,right:0))
            .width(200)
            .background(color:.white)
            .foregroundColor(.black)
            .placeholder(color:.lightGray)
             
            if buildcount>4 {
                Text("label buildcount \(buildcount)") 
                .background(color:.green)
                Text("label hij") 
            } 
            
            Button("click me phase \(phase)") {
                self.buildcount=self.buildcount+1
                //hostingView?.setNeedsBuild()
            }
            .width(200)
            
            Button(verbatim:"ObservableObject age \(self.demo1.age) current list sel=\(self.listSelection)") {
                //self.demo.testlist.append("xyz")
                //self.demo.testlist.removeAll()
                Application!.debugMsgs=""
                self.demo.testlist.append("abc \(self.demo.age)")
                var section=ListSection("abc \(self.demo.age)")
                section.items.append(Item("abc \(self.demo.age) 1"))
                section.items.append(Item("abc \(self.demo.age) 2"))
                if self.demo.sections.count > 10 {
                    self.demo.sections.insert(section,at:1)
                }
                else {
                    self.demo.sections.append(section)
                }
                self.demo.age=self.demo.age+1
                //alert("testlist","\(self.demo.testlist)")
                
                self.demo1.haveBirthday()
            }
            
            switch shapeType {
                case .capsule:
                   Text("Capsule ?!")
                case .circle:
                    Text("Circle ?!")
                case .rectangle:
                    Text("Rectangle!")
                case .squircle:
                    Text("Whoa!")
            }
            
            /*SwitchOver(shapeType)
                .case(.capsule) {
                    //Capsule().frame(width: 50, height: 100)
                    Text("Capsule ?!")
                }
                .case(.circle) {
                    //Circle().frame(width: 50, height: 50)
                    Text("Circle ?!")
                    Text("ok!")
                }
                .case(.rectangle) {
                    //Rectangle().frame(width: 50, height: 50)
                    Text("Rectangle ⬛!")
                }
                .default {
                    Text("Whoa!")
                }
            */
            
            TextView(isDebugHost:true)
            .height(350)
            .matchHostingViewWidth(withMargin: 0)
            .background(color:.black)
            .foregroundColor(.white)
            .font(Font.system(size: 10, weight: .regular, design: .monospaced))
            
            /*
            HStack(spacing:2) { 
                Text("label xyz") 
                .background(color:.black)
                Text(" and label 123") 
                Text(" middle")
                
                //PassthroughView {
                //VStack { 
                  List(selection:$listSelection) {
                    ForEach(self.demo.sections/*, id: \.self*/) { section in
                        //Text(section.name)
                        Section(header: Text("\(section.name)")
                                        .text(color:.red).height(60), footer:Text("footer \(section.name)").text(color:.black).height(40)) {
                            //Text(section.name)
                            ForEach(section.items, id: \.self) { item in
                                //NavigationLink(destination: ItemDetail(item: item)) {
                                
                              //PassthroughView {
                                HStack/*(alignment:.bottom)*/ {
                                    //ItemRow(item: item)
                                    Spacer(width:20)
                                    Text(item.name) //.height(60)
                                    Spacer(minLength:10)
                                    Text(">")
                                }
                                //.justifyContent(.center)
                                .height(70)
                                .alignItems(.center)
                
                                //.tag(item.id) 
                              //}.height(80)
                            } //ForEach
                        } //section
                        //.header(height:40)
                    }
                  } //List
                  .width(700)
                  .height(400)
                  //.flexGrow(1) 
                  .background(color:.systemGray2)
                /*}
                .matchParentHeight(withMargin: 0)
                .flex()
                .flexGrow(1)
                .background(color:.systemGray3)*/
                /*}
                .width(700)
                .matchParentHeight(withMargin: 0)*/
                
                Spacer(minLength:10)
                Text("App builds: \(Application!.buildCount)").text(color:.red)
            }
            .background(color:.lightGray)
            .alignItems(.center)
            //.justifyContent(.center)
            //.matchHostingViewHeight(withMargin: 0)
            //.matchHostingViewWidth(withMargin: 0)
            //.matchParentWidth(withMargin: 0)
            //.matchParentHeight(withMargin: 0)
            */
            
            
            //NavigationView {
                
                /*ZStackView {
                    VStack {
                        TextField("edit me") //.margin(top:-50)
                        Text("abcdef") //.margin(top:-50)
                    }
                }*/
                
            
            SplitView(primary: {
                List(selection:$listSelection) {
                    ForEach(self.demo.sections/*, id: \.self*/) { section in
                        //Text(section.name)
                        Section(header: Text("\(section.name)")
                                        .text(color:.red).height(60), footer:Text("footer \(section.name)").text(color:.black).height(40)) {
                            //Text(section.name)
                            ForEach(section.items, id: \.self) { item in
                                //NavigationLink(destination: ItemDetail(item: item)) {
                                
                              //PassthroughView {
                                HStack/*(alignment:.bottom)*/ {
                                    //ItemRow(item: item)
                                    Spacer().width(20)
                                    Text(item.name) //.height(60)
                                    Spacer(minLength:10) 
                                    Text(">")
                                    Spacer().width(2)
                                }
                                //.justifyContent(.center)
                                .height(70)
                                .alignItems(.center)
                
                                //.tag(item.id) 
                              //}.height(80)
                            } //ForEach
                        } //section
                        //.header(height:40)
                    }
                } //List
                //.width(400)
                //.matchParentWidth(withMargin: 0)
                //.matchParentHeight(withMargin: 0)
            } //NavigationView
            ,secondary: {
                ZStackView {
                    VStack {
                        TextField("edit me") //.margin(top:-50)
                        Text("abcdef") //.margin(top:-50)
                    }
                }
            })
            .matchParentWidth(withMargin: 0)
            //.flexGrow(1)
            //.minHeight(100)
            //.matchParentHeight(withMargin: 0)
            
            
            
             
            /*Button("click me 2") {
                self.buildcount=self.buildcount+1
            }*/
            
        }
        .background(color:.darkGray)
        //.width(800).height(600)
        //.alignItems(.center)
        //.alignItems(.stretch)
        .matchHostingViewWidth(withMargin: 0)
        .matchHostingViewHeight(withMargin: 0)
        .environment(\.locale, .init(identifier: locale))
        
    
        
        //Label("out of vstack") 
    }
}

  
  /*override func viewDidLoad() {
      super.viewDidLoad()
      
      let v=UIView(frame:CGRect(x:0,y:0,width:100,height:100))
        v.backgroundColor = .red
        self.view=v
  }*/ 
  
  @Binding var btext:String
  
  let state=DemoState()
  @StateObject var globalstate=GlobalState()
  
  public override init() {
      //super.init()
      state.statefulText="a stateful text"
      self._btext=state.$statefulText
      super.init()
  }
  
  override required init?(coder:NSCoder) {
      self._btext=state.$statefulText
      //_btext=0
      super.init(coder:coder)
      //self._btext=self.$statefulText
  }
  
  override func orientationChanged() {
      super.orientationChanged()
      //alert("orientation changed","\(view.frame)")
      //uiview?.buildcount=uiview!.buildcount+1
      
      //hostingView?.setNeedsBuild()
      //hostingView?.setNeedsLayout()
  }
   
  override func loadView() {
    //statefulText=2
    //_statefulText.modify(value:2)
    btext=btext+" after widget"
    
    //hostingView=SCLHostingView(context: context, with: [.useSafeAreaInsets],view:DemoView(text:self.$btext))
    /*hostingView=SCLForm(context: context, with: [.useSafeAreaInsets],view:DemoView(text:self.$btext))
    hostingView?.backgroundColor = .darkGray
    self.view = hostingView*/
    
    //uiview!.buildcount=0
    /*let body=view.body
    var parent=ViewNode(value:ConcreteNode(type:UIView.self,layoutSpec:{spec in}))
    ViewExtractor.extractViews(contents: body).forEach {
        $0.buildTree(parent: parent)
    }
    */
    //self.view=UIView()
    //self.view?.backgroundColor = .yellow
    
    let nodeHierarchy=SCLNodeHierarchy(content:Demo1View(text:$btext)
        .environmentObject(globalstate)
        //.environment(\.locale, .init(identifier: "en"))
    )
    //self.hostingView=SCLUIHostingView(context:context,with:[.useSafeAreaInsets], body:nodeHierarchy)
    hostingView=SCLHostingView(with:[/*.useSafeAreaInsets*/],hierarchy:nodeHierarchy)
    hostingView?.backgroundColor = .darkGray
    self.view=self.hostingView
    
    btext="end of loadView()"
    
    //alert("state text",state.statefulText)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    hostingView?.setNeedsLayout()
  }
}


















