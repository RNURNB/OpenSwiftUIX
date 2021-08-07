import Foundation
import UIKit
import CoreRender
import SwiftUIX


open class SCLTableViewCell: UITableViewCell {
    public var editActions:[UITableViewRowAction]?
    //internal var content:UIView?
    
    public override init(style:UITableViewCell.CellStyle,reuseIdentifier:String?=nil) {
        super.init(style:style,reuseIdentifier:reuseIdentifier)
        //contentView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    public init(reuseIdentifier:String?) {
        super.init(style:.default,reuseIdentifier:reuseIdentifier)
        //contentView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    public required init?(coder: NSCoder) 
    {
        super.init(coder:coder)
        //contentView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /*public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sz=size
        if sz.width == CGFloat.max {sz.width=100}
        if sz.width == 0 {sz.width=100}
        if sz.height == CGFloat.max {sz.height=100}
        if sz.height == 0 {sz.height=100}
        print("sizethatfits for ",sz)
        sz = super.sizeThatFits(sz)
        print("sizethatfits return ",sz)
        return sz
    }*/
}

public class SCLOnValueParam
{
    public var param: AnyObject?
    public var indexPath:IndexPath?
    public var index: Int
    public var index2: Int
    public var id:String?
    public var header: UIView?
    public var footer: UIView?
    public var result: AnyObject?
    public var result2: AnyObject?
    public var ok: Bool
    public var pt: CGPoint?
    public var sz: CGSize?
    public var list : [String]?
    
    public init (_ param: AnyObject?, _ index: Int = 0)
    {
        self.param=param
        self.index=index
        self.ok=true
        self.result=nil
        self.result2=nil
        self.index2=0
        self.indexPath=nil
        self.header=nil
        self.footer=nil
        self.sz=nil
    }
}

public protocol SCLTableViewProtocol {
    func onGetValue(sender:SCLTableView,param:SCLOnValueParam,_ view:UIView)
    func onValueChanging(sender:SCLTableView,param:SCLOnValueParam,_ view:UIView)
    func onValueChanged(sender:SCLTableView,param:SCLOnValueParam,_ view:UIView)
    func onClick(sender:SCLTableView,param:SCLOnValueParam,_ view:UIView)
}

public extension Double {

    /// Max double value.
    static var max: Double {
        return Double(greatestFiniteMagnitude)
    }

    /// Min double value.
    static var min: Double {
        return Double(-greatestFiniteMagnitude)
    }
}

public extension Float {

    /// Max double value.
    static var max: Float {
        return Float(greatestFiniteMagnitude)
    }

    /// Min double value.
    static var min: Float {
        return Float(-greatestFiniteMagnitude)
    }
}

public extension CGFloat {

    /// Max double value.
    static var max: CGFloat {
        return CGFloat(greatestFiniteMagnitude)
    }

    /// Min double value.
    static var min: CGFloat {
        return CGFloat(-greatestFiniteMagnitude)
    }
}

public class SCLTableView:UITableView {
    public var root:SCLRootViewController?=Application?.rootViewController
    public var headerheight:CGFloat=32;
    public var footerheight:CGFloat=32;
    public var headercolor:UIColor=UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
    public var footercolor:UIColor=UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
    public var headertextcolor:UIColor = .black
    public var footertextcolor:UIColor = .black
    public var selectedBackgroundColor:UIColor?
    internal var data:SCLTableViewProtocol?
    internal var indexCellMapping:[IndexPath:UITableViewCell]=[:]
    internal var tagCellMapping:[Int:UITableViewCell]=[:]
    
    /*public override var bounds: CGRect {
        didSet {
           print("tableview bounds changed to ",bounds)
        }
    }*/
    
    public override init(frame: CGRect, style:UITableView.Style)
    { 
        super.init(frame:frame,style:style)
        self.delegate = self
        self.dataSource = self
        //print("init rowheight:",self.rowHeight)
        //if self.rowHeight<=0 {self.rowHeight=32}
        
        self.register(SCLTableViewCell.self,forCellReuseIdentifier:"listdefault")
    }
    
    public required init?(coder: NSCoder) 
    {
        super.init(coder:coder)
        self.delegate = self
        self.dataSource = self
        
        self.register(SCLTableViewCell.self,forCellReuseIdentifier:"listdefault")
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sz=size
        if sz.width == CGFloat.max {sz.width=100}
        if sz.width == 0 {sz.width=100}
        if sz.height == CGFloat.max {sz.height=100}
        if sz.height == 0 {sz.height=100}
        //print("tableview sizethatfits for ",sz)
        sz = super.sizeThatFits(sz)
        //print("tableview sizethatfits result ",sz)
        return sz
    }
    
    /*public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var ok=super.point(inside:point,with:event)
        print("tableview point in:",ok)
        return ok
    }*/
    
    /*public override func layoutSubviews() {
        //self.estimatedRowHeight = 120
        //self.frame=CGRect(x:213,y:0,width:700,height:500)
        print("tableview layoutsubviews frame=\(frame), parentframe:",self.superview!.frame)
        super.layoutSubviews()
    }*/
    
    public override func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell
    {
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,Int.min) //return cell by identifier
            data.id=identifier
            data.indexPath=indexPath
            self.data!.onGetValue(sender:self,param:data,self)
            if (data.result != nil) {
                return data.result as! UITableViewCell
            }
            else {
                //search local reusable identifer list ?
                return super.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            }
        }
        else {
            return super.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        }
    }
    
    public func selectRow(row: Int, section: Int = 0) {
        let sizeTable = self.numberOfRows(inSection: section)
        guard row >= 0 && row < sizeTable else { return }
        let indexPath = IndexPath(row: row, section: section)
        self.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        
        if (selectedBackgroundColor != nil) {
            if let cell = self.cellForRow(at: indexPath) {
                UIView.animate(withDuration: 0.3, animations: {
                    cell.contentView.backgroundColor = self.selectedBackgroundColor!
                })
            }
        }
    }
    
    public override func reloadData() {
        indexCellMapping=[:]
        tagCellMapping=[:]
        super.reloadData()
    }
}

extension SCLTableView: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,section) //return headers and footers
            data.index2 = -2 //header only
            self.data!.onGetValue(sender:self,param:data,self)
            return data.header
        }
        else {
            return nil
        } 
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,section) //return headers and footers
            data.index2 = -3 //footer only
            self.data!.onGetValue(sender:self,param:data,self)
            return data.footer
        }
        else {
            return nil
        } 
    }

    /*public func tableView(_ tableView:UITableView, willDisplayHeaderView view:UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView

        //header?.backgroundColor=self.headercolor
        header?.tintColor=self.headercolor
        header?.textLabel?.textColor = self.headertextcolor
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as? UITableViewHeaderFooterView

        //footer?.backgroundColor=self.footercolor
        footer?.tintColor=self.footercolor
        footer?.textLabel?.textColor = self.footertextcolor
    }*/
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,section) //return headers and footers
            data.index2 = -4 //header only
            self.data!.onGetValue(sender:self,param:data,self)
            if data.sz != nil {return data.sz!.width}
            return 0
        }
        else {
            return self.headerheight;
        } 
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,section) //return headers and footers
            data.index2 = -5 //footer only
            self.data!.onGetValue(sender:self,param:data,self)
            if data.sz != nil {return data.sz!.height}
            return 0
        }
        else {
            return self.footerheight;
        } 
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        //dbg("tableview numberOfSections")
        
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,Int.max) //return section count
            self.data!.onGetValue(sender:self,param:data,self)
            return data.index == Int.max ? 0 : data.index
        }
        else {
            return 0;
        }
    }
    
    /*public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        //dbg("tableview titleHeaderForSection")
        
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,section) //return headers and footers
            data.index2 = -1
            self.data!.onGetValue(sender:self,param:data,self)
            return data.title
        }
        else {
            return nil;
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        //dbg("tableview titleFooterForSection")
        
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,section) //return headers and footers
            data.index2 = -1
            self.data!.onGetValue(sender:self,param:data,self)
            return data.footer
        }
        else {
            return nil;
        }
    }*/
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //dbg("tableview numberOfRowsInSection")
        
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,section) //return rows in section count
            data.index2 = Int.max
            self.data!.onGetValue(sender:self,param:data,self)
            return data.index2 == Int.max ? 0 : data.index2
        }
        else {
            return 0;
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /*if indexPath.section == 0 {
            return UITableView.automaticDimension //auto sizing
        } else {
            return 40
        }*/
        
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,indexPath.section) //return row
            data.index2 = indexPath.row
            self.data!.onGetValue(sender:self,param:data,self)
            //print("data return")
            if (data.sz != nil) {
                return data.sz!.height
            }
        }

        return self.rowHeight; //default
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        /*if indexPath.section == 0 {
            return UITableView.automaticDimension //auto sizing
        } else {
            return 40
        }*/
        
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,indexPath.section) //return row
            data.index2 = indexPath.row
            self.data!.onGetValue(sender:self,param:data,self)
            if (data.sz != nil) {
                return data.sz!.height
            }
        }

        return self.rowHeight; //default
    }

    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //dbg("tableview cellForRowAt")
        
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,indexPath.section) //return row
            data.index2=indexPath.row
            data.indexPath=indexPath
            self.data!.onGetValue(sender:self,param:data,self)
            return data.result != nil ? (data.result as! UITableViewCell) : SCLTableViewCell(style:.default,reuseIdentifier:nil)
        }
        else {
            return SCLTableViewCell(style:.default,reuseIdentifier:nil)
        }
    }
    
    /*override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {i
        //return super.
    }*/
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    {
        //dbg("tableview willSelectRow At")
        
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,indexPath.section) //return index
            data.index2=indexPath.row
            data.indexPath=indexPath;
            data.ok=true //select
            self.data!.onValueChanging(sender:self,param:data,self)
            return data.indexPath!
        }
        else {
            return indexPath
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //dbg("tableview didSelectRow At")
        
        if (selectedBackgroundColor != nil) {
            if let cell = tableView.cellForRow(at: indexPath) {
                UIView.animate(withDuration: 0.3, animations: {
                    cell.contentView.backgroundColor = self.selectedBackgroundColor!
                })
            }
        }
        
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,indexPath.section)
            data.index2=indexPath.row
            data.indexPath=indexPath;
            data.ok=true //select
            self.data!.onValueChanged(sender:self,param:data,self)
        }
    }
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath?
    {
        //dbg("tableview willDeselect Row At")

        if (selectedBackgroundColor != nil) {
            if let cell = tableView.cellForRow(at: indexPath) {
                UIView.animate(withDuration: 0.3, animations: {
                    cell.contentView.backgroundColor = self.backgroundColor!
                })
            }
        }
        
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,indexPath.section) //return index
            data.index2=indexPath.row
            data.indexPath=indexPath;
            data.ok=false //deselect
            self.data!.onValueChanging(sender:self,param:data,self)
            return data.indexPath!
        }
        else {
            return indexPath
        }
    }
    
    public override func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        if let cell=cellFromIndexPath(indexPath) {return cell}
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        //dbg("tableview didDeselect Row At")
        /*if let cell=self.cellForRow(at: indexPath) {
            for v in cell.subviews {dump(v)}
        }
        else {
            print("*****no cell for indexPath ",indexPath)
        }*/
        
        //only in edit mode otherwise onclick is doubled
        if (/*(self.isEditing)&&*/(data != nil))
        {
            let data = SCLOnValueParam(nil,indexPath.section) //return index
            data.index2=indexPath.row
            data.indexPath=indexPath;
            data.ok=false //deselect
          
            self.data!.onValueChanged(sender:self,param:data,self)
        }
    }

    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        //dbg("accessory button tapped")
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,indexPath.section) //return index
            data.index2=indexPath.row
            data.indexPath=indexPath;
            self.data!.onClick(sender:self,param:data,self)
        }
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?          
    {
        //dbg("dircell editActionsForRowAt")
        //alert("editActionsForRowAt","editActionsForRowAt")
        if let cell = self.cellForRow(at: indexPath) {
            if let dcell=cell as? SCLTableViewCell {
                return dcell.editActions
            }
        }
      
        return nil
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //dbg("dircell caneditrow")
        if let cell = self.cellFromIndexPath(indexPath) { // self.cellForRow(at: indexPath) {
            if let dcell=cell as? SCLTableViewCell {return dcell.editActions?.count ?? 0 > 0 }
        }
        
        return false
    }
    
    public func cellFromIndexPath(_ indexPath: IndexPath) -> SCLTableViewCell? {
        return indexCellMapping[indexPath] as? SCLTableViewCell
    }
    
    public func cellFromHashValue(_ hashValue:Int) -> SCLTableViewCell? {
        return tagCellMapping[hashValue] as? SCLTableViewCell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        indexCellMapping[indexPath]=cell
        tagCellMapping[cell.tag]=cell

        //print("will display cell ",cell," at ",indexPath)
        if (data != nil)
        {
            let data = SCLOnValueParam(nil,indexPath.section) //return section count
            data.index2=indexPath.row
            data.indexPath=indexPath
            data.result=cell
            self.data!.onGetValue(sender:self,param:data,self)
        }
    }

    /*public func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

    }*/
}

public struct _ListLayout {
    var list:ViewNode?
    
    @inlinable public init() {
    }
    public typealias Body = Never
}

//internal let listContext=SCLContext()

extension _ListLayout: _VariadicView_UnaryViewRoot {}
extension _ListLayout: _VariadicView_ViewRoot {}

public struct List<Content>: UIViewRepresentable where Content: View {
    public typealias Body = Never
    public typealias UIViewType = SCLTableView
    //internal var elements:[ViewNode]=[]
    internal var tagMapping:[Int:Any]=[:]
    internal var _getSelection:(()->[AnyHashable]?)?=nil
    internal var _addSelection:((_ sel:AnyHashable?)->Void)?=nil
    internal var _removeSelection:((_ sel:AnyHashable?)->Void)?=nil
    
    //public var context:SCLContext? = nil
    public var _tree: _VariadicView.Tree<_ListLayout, Content>
    private var _layoutSpec=LayoutSpecWrapper<UIViewType>()
    
    
    public init(@ViewBuilder content: () -> Content) {
        _tree = .init(
            root: _ListLayout() , content: content())
    }
    
    public init<SelectionValue>(selection: Binding<SelectionValue?>?,content: () -> Content) where SelectionValue:Hashable {
        //SelectionValueType=SelectionValue
        _tree = .init(
            root: _ListLayout() , content: content())
        _getSelection={
            if selection?.wrappedValue == nil {return nil}
            return [selection!.wrappedValue!]
        }
        _addSelection={ sel in
            if let sel = sel as? SelectionValue {
                if selection?.wrappedValue == nil || selection?.wrappedValue.hashValue != sel.hashValue {
                    selection?.wrappedValue=sel
                }
            }
            else {
                if selection?.wrappedValue != nil {selection?.wrappedValue=nil}
            }
        }
        _removeSelection={ sel in
            selection?.wrappedValue=nil
        }
        
        /*let list=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"list",key:nil,layoutSpec: {spec in
            //print("called list root layout")
        })
        _tree.root.list=ViewNode(value: list)*/
        
    }

    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> List<Content> {
       _layoutSpec.add(spec)
       return self
    }
}

extension List {
    public var body: Never {
        fatalError()
    }
}

class SCLCellContentView:UIView {
}

//public var debuglist:SCLTableView?=nil

class ListViewNode:ViewNode {
    let isHost:Bool
    
    public init<Representable,Controller>(value:SCLNode<Representable,Controller>,isHost:Bool) 
            where Representable:UIViewRepresentable, Controller:UIViewControllerRepresentable {
        self.isHost=isHost
        super.init(value:value)
    }
    
    public override func structureMatches(to:ViewNode?,deep:Bool=true) -> Bool {
        //print("Listviewnode structureMatches")
        if let to=to as? ListViewNode { 
            if self==to {return true}
            var match:Bool=true
            
            var list1:ViewNode = self.isHost ? self.children[0] : self
            var list2:ViewNode = to.isHost ? to.children[0] : to
            
            if !self.isHost {
                if !super.structureMatches(to:list2,deep:false/*do not match UIView children (cells)*/) {
                    match=false
                }
            }
            else if !list1.structureMatches(to:list2) {match=false}
            
            //print("compare list node ",self," host=",self.isHost," to ",to," host=",to.isHost)
            /*if match==false {
                print("list structurematch false host=",self.isHost," view=",self.value?.renderedView)
                print("to host=",to.isHost," view=",to.value?.renderedView)
                if to.isHost {
                    if let v=to.value?.renderedView as? SCLTableView {
                        print("content offset:",v.contentOffset.y)
                    }
                }
            }*/
            
            return match
        }
        else {return false}
        
        //return super.structureMatches(to:to,deep:false/*do not match UIView children (cells)*/)
        return true
    }
    
    /*public override func dismantleNode() {
        if let v=value?.renderedView {
            //print("list dismantle node=",v)
            value?._dismantleNode(v) //forward to List object
        }
        super.dismantleNode()
    }*/
}

extension List {
    
    public func makeUIView(context:UIViewRepresentableContext<List>) -> UIViewType {
        /*print("list makeUIView env=",context.environment)
        for s in context.coordinator._sections {
            print("section env ",(s.context as! SCLContext).environment)
        }*/
        let list=UIViewType(frame:CGRect(x:0,y:0,width:0,height:0))
        list.node=_tree.root.list
        list.data=context.coordinator
        return list
    }
    
    public func updateUIView(_ view:UIViewType, context:UIViewRepresentableContext<List>) -> Void {
        //print("list updateUIView for ",view
        view.data=context.coordinator
        //print("List updateUIView contentOffset:",view.contentOffset)
        /*print("list updateUIView ",view," with env ",(_tree.root.list!.value?.context as! SCLContext).environment.values)
        print("list updateUIView with context env ",context.environment.values)
        print("list updateUIView with coordinator env ",(context.coordinator.list._tree.root.list!.value?.context as! SCLContext).environment.values)
        for n in context.coordinator._sections {
            print("list updateUIView section env ",(n.context as! SCLContext).environment.values)
            for i in n.children {
                print("list updateUIView section child ",i," env ",(i.context as! SCLContext).environment.values)
            }
        }*/
        view.reloadData()
    }
    
    /*public func reuseUIView(_ view:UIViewType, context:UIViewRepresentableContext<List>) -> Void {
        print("List reuseUIView contentOffset:",view.contentOffset)
        print("List reuseUIView coordinator:",context.coordinator)
        print("List reuseUIView coordinator.contentOffset:",context.coordinator._initialContentOffset)
        print("List reuseUIView previouscoordinator:",context.previousCoordinator)
        print("List reuseUIView previouscoordinator.contentOffset:",context.previousCoordinator?._initialContentOffset)
        //context.coordinator._initialContentOffset=view.contentOffset.y
    }*/
    
    static public func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator, context:Context) {
        //print("")
        //print("List dismantleUIView ",uiView)
        uiView.data=nil
        if let nextCoordinator=context.nextCoordinator {
            //print("List dismantleUIView contentOffset:",uiView.contentOffset)
            nextCoordinator._initialContentOffset=uiView.contentOffset.y //store scroll offset for next UIView
            //print("offset:",nextCoordinator._initialContentOffset)
        }
    }
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        
        //print("list buildtree env=",env)

        //let oldlist=_tree.root.list
        let list=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"list",key:nil,layoutSpec: {spec, context in
            //print("called list root layout")
           }
           ,controller:defaultController
        )
        _tree.root.list=ListViewNode(value: list, isHost: false)
            
        let node=SCLNode(environment:env, host:self/*,type:UIViewType.self*/,reuseIdentifier:"List",key:nil,layoutSpec: { spec, context in
                guard let yoga = spec.view?.yoga else { return }
                spec.view!.clipsToBounds=true
                //init width and height, else crash for empty list
                if let parent:UIView=spec.view?.superview {
                    spec.set("yoga.width",value:parent.frame.size.width-spec.view!.frame.origin.x)
                    spec.set("yoga.height",value:parent.frame.size.height-spec.view!.frame.origin.y)
                }
                else {
                    //spec.set("yoga.width",value:spec.size.width)
                    //spec.set("yoga.height",value:spec.size.height)
                }
                
                //yoga.flex() //with flex width strange cell errors occur

                //print("HStack spec layout=\(self._layoutSpec) align=\(yoga.alignItems.rawValue)")
                self._layoutSpec.layoutSpec?(spec)
                //print("HStack spec end 2 align=\(yoga.alignItems.rawValue)")
                //yoga.alignItems = .center
                //yoga.justifyContent = .center
                
                if let list=spec.view as? UIViewType {
                    //print("list reloaddata")
                    //list.reloadData()
                }
                
                //print("created list:",spec.view)
                //debuglist=spec.view
            }
            ,controller:defaultController
            /*,dismantleNode: {view,context in 
                //print("list dismantleNode ",view)
                context.coordinator._initialContentOffset=view.contentOffset.y
                print("dismantleNode coordinator:",context.coordinator)
                print("dismantleNode coordinator.initialContentOffset:",context.coordinator._initialContentOffset)
            }*/
        )
        
        let vnode = ListViewNode(value: node, isHost:true)
        
        parent.addChild(node: vnode)
        
        //add fake root to node
        vnode.children=[_tree.root.list!]

        ViewExtractor.extractViews(contents: _tree.content).forEach { 
            //print("build list node ",$0)
            if let n=$0.buildTree(parent: _tree.root.list!, in:_tree.root.list!.runtimeenvironment) 
            {
                //elements.append(n)
                //print("got list view node ",n)
            }
        }
        
        //transform to tree
        node.context.coordinator.setup()
        //print("list context env is:",node.context.environment)
        
        //list.canReuseNodes=oldlist==nil || oldlist!.value==nil || list.node.structureMatches(to:oldlist!.value!)
        
        //  print("got list with tags ",_tree.root.list!.tags?.tagMapping ?? "nil")
        return vnode
    }
    
    
    
    public func makeCoordinator() -> Coordinator { 
        return Coordinator(self)
    }
    
    public class Coordinator:NSObject, SCLTableViewProtocol {
        let list:List
        internal var _sections:[ConcreteNode<UIView>]=[]
        internal var _0sections:[ConcreteNode<UIView>]=[]
        internal var _0sectionstag:Int=0
        internal var _hiddenSections = Set<Int>()
        internal var _initialContentOffset:CGFloat?=nil
    
        public init(_ list:List) {
            self.list=list
        }
        
        func setup() { 
            _sections=[]
            _0sections=[]
            var c=0
            for child in list._tree.root.list!.value?.children ?? [] {
                    
                if child.viewType is SCLSection.Type {
                    if child.tag == 0 {child.tag=Int64(c)} //todo tag (hash) for section
                    _sections.append(child)
                }
                else {
                    _0sections.append(child)
                    _0sectionstag=c //todo tag (hash) for section
                }
                c=c+1
            }
            //print("setup offset:",_initialContentOffset)
        }
        
        public func cellHashableFromIndexPath(tableView:SCLTableView,indexPath:IndexPath?) -> AnyHashable? {
            if indexPath==nil {return nil}
        
            if let cell = tableView.cellFromIndexPath(indexPath!) {
                //print("selected cell ",cell," tags=",_tree.root.list!.tags?.tagMapping)
                return cellHashableFromCell(cell)
            }
        
            return nil
        }
    
        public func cellHashableFromCell(_ cell:SCLTableViewCell?) -> AnyHashable? {
            if cell==nil {return nil}
        
            if let data=list._tree.root.list!.tags?.tagMapping[cell!.tag] {
                //print("selected data ",data)
                return data
            }
            
            //search sections
            for section in list._tree.root.list!.children {
                if let data=section.tags?.tagMapping[cell!.tag] {
                    //print("selected data ",data)
                    return data
                }
            }
        
            return nil
        }
        
        func populateCell(_ container:UIView,cell:UITableViewCell?,sender:UITableView,section:Int,row:Int,reconcileOnly:Bool=false) -> CGSize? {
            //return nil
            //if let c=cell as? SCLTableViewCell {
                var n:ConcreteNode?=nil
                if section<_sections.count {
                    let s=_sections[section]
                    if row<s.children.count {n=s.children[row]}
                }
                else {
                    if row<_0sections.count {n=_0sections[row]}
                }
                            
                if n != nil {
                    //n!.parent=nil
                
                    var sz=cell?.bounds.size ?? container.bounds.size
                    sz.width=sender.bounds.size.width
                    sz.height=sender.rowHeight //sender.heightForRowAtIndexPath(IndexPath(section:section,row:row))
                    //if cell != nil {cell!.frame=CGRect(x:0,y:0,width:sz.width,height:sz.height)}
                    container.frame=CGRect(x:0,y:0,width:sz.width,height:sz.height)
                    
                    //print("building list element with parent ",container," self bounds \(sender.bounds)")
                    //return nil
                                
                    //let container:UIView=c.contentView
                
                    if !reconcileOnly {
                        var canReuse=true //reusing does not work reliable
                    
                        if canReuse && n!.renderedView != container.subviews.first {
                            canReuse=false
                            //print("creating new view for \(section):\(row)")
                        }
                        /*else {
                            print("reusing view for \(section):\(row)")
                        }*/
                
                        if !canReuse {
                            container.subviews.forEach { $0.removeFromSuperview() }
                        }
                
                        /*print("")
                        print("populatecell")
                        print("list item for ",sender," item ",n," with env ",(n!.context as! SCLContext).environment.values)*/
                        n!.build(in:container,parent:nil,candidate:canReuse ? container.subviews.first : nil,constrainedTo:sz,with:[],forceLayout:true)
                        
                        container.frame=CGRect.init(x: 0, y: 0, width: sender.frame.width, height: n!.renderedView!.frame.size.height)
                        sz=container.frame.size
                        //cell?.frame=CGRect(x:0,y:0,width:sz.width,height:sz.height)
                        container.frame=CGRect(x:0,y:0,width:sz.width,height:sz.height)                        
                    }
                
                    //n!.renderedView?.frame=CGRect(x:0,y:0,width:sz.width,height:sz.height)
                    n!.reconcile(in:container,constrainedTo:sz,with:[])
                
                    //print("build node after with child count ",container.subviews.count," bounds ",container.subviews[0].bounds," sz=",sz)
                                
                    //print("cell with tag ",n!.tag," self tag ",c.tag)
                    container.tag=Int(n!.tag)
                    //c.content?.frame=CGRect(x:0,y:0,width:sz.width,height:sz.height)
                                
                    //print("got content ",c.content)
                    //dump(c.content)
                    //print("end self bounds \(sender.bounds)")
                    
                    return sz
                }
            /*}
            else {
                print("cell ",cell," is no SCLTableViewCell")
            }*/
            
            return nil
        }
    
        func indexPathsForSection(_ section:Int) -> [IndexPath] {
            var indexPaths = [IndexPath]()
    
            var c=self._0sections.count
            if section<self._sections.count {c=self._sections[section].children.count}
            for row in 0..<c {
                indexPaths.append(IndexPath(row: row,section: section))
            }
    
            return indexPaths
        }
    
        public func hideSection(sender:SCLTableView,section:Int) {
            var sectionHash=_0sectionstag
            if section<self._sections.count {
                let s=self._sections[section]
                sectionHash=Int(s.tag)
            }
        
            if self._hiddenSections.contains(sectionHash) {
                self._hiddenSections.remove(sectionHash)
                sender.insertRows(at: indexPathsForSection(section),with: .fade)
            } else {
                self._hiddenSections.insert(sectionHash)
                sender.deleteRows(at: indexPathsForSection(section),with: .fade)
            }
        }
        
        public func onGetValue(sender:SCLTableView,param:SCLOnValueParam,_ view:UIView) {
            if param.param == nil {
                if param.index == Int.max {
                    //get section count
                    //print("get section count for \(_tree.root.list!.value?.children)")
                    param.index=_sections.count
                    if _0sections.count>0 {param.index=param.index+1}
                }
                else if param.index == Int.min {
                    //return cell by identifier
                    let identifier=param.id
                    param.result=nil //let super handle this UITableViewCell creation
                
                    /*if param.indexPath != nil {
                        if let cell=sender.cellFromIndexPath(param.indexPath!) {
                            print("return cached cell ",cell," for ",param.indexPath!)
                            param.result=cell
                        }
                    }*/
                }
                else {
                    //get section info
                    let section=param.index
                
                    if param.index2==Int.max {
                        //return rows in section count
                    
                        if section<self._sections.count {
                            let s=self._sections[section]
                            if self._hiddenSections.contains(Int(s.tag)) {param.index2=0}
                            else {param.index2=s.children.count}
                        }
                        else {
                            if self._hiddenSections.contains(_0sectionstag) {param.index2=0}
                            else {param.index2=self._0sections.count}
                        }
                    }
                    else if param.index2 < 0 {
                        //headers and footers
                        param.header=nil
                        param.footer=nil
                        param.sz=nil //cell height sender.rowHeight
                        
                        //return
                    
                        if section<_sections.count {
                            let s=_sections[section]
                            if s.header != nil {
                                param.sz=CGSize(width:sender.headerheight,height:param.sz?.height ?? 0)
                                
                                /*if param.index2 == -4 { //header size only
                                    var n=s.header!
                                    /*if n.children.count==1 {
                                        n=n.children[0]
                                    }*/
                                
                                    let celldummy = n.rawView()//UIView.init(frame: CGRect.init(x: 0, y: 0, width: sender.frame.width, height: param.sz!.width))
                                    celldummy.frame=CGRect.init(x: 0, y: 0, width: sender.frame.width, height: param.sz!.width)
                                    let spec=TestLayoutSpec(node:n,view:celldummy,constrainedTo:celldummy.bounds.size,testList:["yoga.height"])
                                    //print("getting height for view ",spec.view," layoutspec=",n.layoutSpec," id ",n.reuseIdentifier)
                                    spec.set("yoga.height",value:param.sz!.width)
                                    //print("test header layout")
                                    spec.test()
                                    //print("node with \(n.children.count) children height=",celldummy.yoga.height)
                                
                                    if let h=spec.floatValue("yoga.height") {
                                        param.sz=CGSize(width:CGFloat(h),height:param.sz?.height ?? 0)
                                    }
                                    //print("header sz:",param.sz)
                                }
                                else*/ if param.index2 != -3 && param.index2 != -5 //header only, footer only
                                {
                                    let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: sender.frame.width, height: param.sz!.width))
                                    headerView.autoresizingMask = [/*.flexibleWidth,*/ .flexibleHeight]
                                    headerView.backgroundColor=sender.headercolor
                                    param.header=headerView
                                    //print("header build with candidate ",s.header!.renderedView)
                                    //print("list header with env ",(s.header!.context as! SCLContext).environment.values)
                                    s.header!.build(in:headerView,parent:nil,candidate:s.header!.renderedView,
                                                    constrainedTo:headerView.frame.size,with:[],forceLayout:true)
                                    //print("header view now ",s.header!.renderedView)
                                    
                                    headerView.frame=CGRect.init(x: 0, y: 0, width: sender.frame.width, height: s.header!.renderedView!.frame.size.height)
                            
                                    //s.header!.renderedView?.frame=CGRect(x:0,y:0,width:sz.width,height:sz.height)
                                    s.header!.reconcile(in:headerView,constrainedTo:headerView.frame.size,with:[])
                            
                                    //print("header rendered view frame:",s.header!.renderedView!.frame," for section ",section," parent:",headerView.frame)
                                    param.sz=CGSize(width:s.header!.renderedView!.frame.size.height/*headerView.frame.size.height*/,height:param.sz?.height ?? 0)
                                }
                            }
                        
                            if s.footer != nil {
                                param.sz=CGSize(width:param.sz?.width ?? 0,height:sender.footerheight)
                                
                                /*if param.index2 == -5 { //footer size only
                                    var n=s.footer!
                                    
                                    let celldummy = n.rawView()//UIView.init(frame: CGRect.init(x: 0, y: 0, width: sender.frame.width, height: param.sz!.height))
                                    celldummy.frame=CGRect.init(x: 0, y: 0, width: sender.frame.width, height: param.sz!.height)
                                    let spec=TestLayoutSpec(node:n,view:celldummy,constrainedTo:celldummy.bounds.size,testList:["yoga.height"])
                                    //print("getting height for view ",spec.view," layoutspec=",n!.layoutSpec)
                                    spec.set("yoga.height",value:param.sz!.height)
                                    spec.test()
                                    //print("node with \(n!.children.count) children height=",celldummy.yoga.height)
                                
                                    if let h=spec.floatValue("yoga.height") {
                                        param.sz=CGSize(width:param.sz?.width ?? 0,height:CGFloat(h))
                                    }
                                }
                                else*/ if param.index2 != -2 && param.index2 != -4 //header only, footer only
                                {
                                    let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: sender.frame.width, height: param.sz!.height))
                                    footerView.autoresizingMask = [/*.flexibleWidth,*/ .flexibleHeight]
                                    footerView.backgroundColor=sender.footercolor
                                    param.footer=footerView
                                    //print("footer build with candidate ",s.footer!.renderedView)
                                    s.footer!.build(in:footerView,parent:nil,candidate:s.footer!.renderedView,
                                                    constrainedTo:footerView.frame.size,with:[],forceLayout:true)
                                    //print("footer view now:",s.footer!.renderedView)
                            
                                    footerView.frame=CGRect.init(x: 0, y: 0, width: sender.frame.width, height: s.footer!.renderedView!.frame.size.height)
                            
                                    //s.header!.renderedView?.frame=CGRect(x:0,y:0,width:sz.width,height:sz.height)
                                    s.footer!.reconcile(in:footerView,constrainedTo:footerView.frame.size,with:[])
                            
                                    param.sz=CGSize(width:param.sz?.width ?? 0,height:s.footer!.renderedView!.frame.size.height/*footerView.frame.size.height*/)
                                }
                            }
                        }
                        else if _sections.count>0 { //_0section
                            param.sz=CGSize(width:sender.headerheight,height:0)
                            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: sender.frame.width, height: param.sz!.width))
                            headerView.autoresizingMask = [/*.flexibleWidth,*/ .flexibleHeight]
                            headerView.backgroundColor=sender.headercolor
                            param.header=headerView
                        }
                    
                        //print("header/footer size:",param.sz)
                    }
                    else {
                        //get row info
                        let row=param.index2
                        if let indexPath=param.indexPath {
                            if param.result != nil {
                                //display cell
                                
                                //print("display offset:",_initialContentOffset)
                                
                                if let cell=param.result as? SCLTableViewCell {
                                    let container:UIView=cell.contentView
                                    //print("display cell ",cell," for indexPath ",indexPath," with content size \(cell.contentView.frame)")
                                
                                    //populateCell(cell.contentView,cell:cell,sender:sender,section:section,row:row,reconcileOnly:true)
                                
                                    if let selection=list._getSelection?() {
                                        var shouldSelectThisRow=false
                                        //print("display cell selection=",selection)
                                        if let hashable=cellHashableFromCell(cell) {
                                            //print("display cell hashable=",hashable)
                                            for s in selection {
                                                //print("display cell compare ",s.hashValue,"(aka ",s,") to ",hashable.hashValue," (aka ",hashable,")")
                                                if s.hashValue==hashable.hashValue {
                                                    //print("display selected cell ",cell)
                                                    shouldSelectThisRow=true
                                                    break;
                                                }
                                            }
                                        }
                                    
                                        if shouldSelectThisRow {
                                            sender.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                                        } else {
                                            sender.deselectRow(at: indexPath, animated: false)
                                        }
                                    }
                                }
                                
                                if _initialContentOffset != nil {
                                    //print("setting content offset:",_initialContentOffset!)
                                    sender.contentOffset.y=_initialContentOffset!
                                    _initialContentOffset=nil
                                }
                                return
                            }
                        
                            //return cell
                            var cell:UITableViewCell?=sender.dequeueReusableCell(withIdentifier:"listdefault", for:indexPath)
                            //var cell:UITableViewCell?=SCLTableViewCell(style:.default)
                            //print("reused cell ",cell)
                    
                            if (cell==nil) {
                                cell=SCLTableViewCell(style:.default,reuseIdentifier:"listdefault")
                                //cell!.frame=CGRect(x:0,y:0,width:100,height:20)
                                cell!.accessoryType = .none
                                //print("created cell ",cell)
                            }
                        
                            //cell!.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        
                            //cell!.contentView.subviews.forEach { $0.removeFromSuperview() }
                            let container:UIView=cell!.contentView
                
                            cell!.backgroundColor = .clear
                        
                            //cell!.textLabel?.isHidden=true
                            //cell!.detailTextLabel?.isHidden=true
                            
                            if container.subviews.count==0 || container.subviews.count>1 || !(container.subviews.first is SCLCellContentView) {
                                container.subviews.forEach { $0.removeFromSuperview() }
                                let celldummy = SCLCellContentView.init(frame: CGRect.init(x: 0, y: 0, width: sender.frame.width, height: sender.rowHeight))
                                container.addSubview(celldummy)
                            }
                            
                            param.sz=populateCell(container.subviews.first!,cell:cell,sender:sender,section:section,row:row)
                            cell!.tag=container.subviews.first!.tag
                            container.subviews.first!.tag=0
                        
                            //print("cell ",cell!," subviews:",cell!.subviews.count)
                            //dump(cell)
                            //print("cell dimensions ",cell!.frame)
                
                            param.result=cell
                        }
                        else {
                            //return row height
                            param.sz=nil
                            
                            var n:ConcreteNode?=nil
                            if section<_sections.count {
                                let s=_sections[section]
                                if row<s.children.count {n=s.children[row]}
                            }
                            else {
                                if row<_0sections.count {n=_0sections[row]}
                            }
                            
                            if n != nil {
                                var w=sender.frame.width
                                //if w<=0 {w=100}
                                let celldummy = n!.rawView()//UIView.init(frame: CGRect.init(x: 0, y: 0, width: w, height: sender.rowHeight))
                                celldummy.frame=CGRect.init(x: 0, y: 0, width: w, height: sender.rowHeight)
                                let spec=TestLayoutSpec(node:n!,view:celldummy,constrainedTo:celldummy.bounds.size,testList:["yoga.height"])
                                //print("getting height for view ",spec.view," layoutspec=",n!.layoutSpec," frame=",celldummy.frame)
                                spec.set("yoga.height",value:sender.rowHeight,animator:nil)
                    
                                //print("got height ",celldummy.yoga.height)
                                spec.test()
                                //print("node with \(n!.children.count) children height=",celldummy.yoga.height)
                                
                                if let h=spec.floatValue("yoga.height") {
                                    param.sz=CGSize(width:sender.frame.width, height:CGFloat(h))
                                }
                                
                                //print("node dimensions ",param.sz)
                            }
                        }
                    }
                }
            }
        }
        
        public func onValueChanging(sender:SCLTableView,param:SCLOnValueParam,_ view:UIView) {
            /*if let cellData=cellHashValueFromIndexPath(tableView:sender,indexPath:param.indexPath) {
                let action = param.ok ? "select" : "deselect"
                print("onValueChanging \(action) data=",cellData)
            }*/
        }
    
        public func onValueChanged(sender:SCLTableView,param:SCLOnValueParam,_ view:UIView) {
            if let cellData=cellHashableFromIndexPath(tableView:sender,indexPath:param.indexPath) {
                //let action = param.ok ? "select" : "deselect"
                //print("onValueChanged \(action) hash=",cellData.hashValue," base:",cellData.base," of \(type(of:cellData.base))")
            
                if param.ok {
                    list._addSelection?(cellData)
                }
                else {list._removeSelection?(cellData)}
            }
        }
    
        public func onClick(sender:SCLTableView,param:SCLOnValueParam,_ view:UIView) {
            if let cellData=cellHashableFromIndexPath(tableView:sender,indexPath:param.indexPath) {
                print("onClick data=",cellData)
            }
        }
    } //Coordinator
}















