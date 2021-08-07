import Foundation
import CoreRender


public typealias SCLCoordinator=Coordinator 

public class SCLContext:CRContext {
    public var environment:SCLEnvironment
    public var viewController:UIViewController?
    public var parent:UIView?
    
    public init(environment:SCLEnvironment) {
        self.environment=environment
        super.init()
    }
}

public protocol UIViewBuildable {
    
    func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode?
}

public class UIViewRepresentableContext<Representable>:SCLContext where Representable:UIViewRepresentable {
    public let coordinator:Representable.Coordinator
    public var nextCoordinator:Representable.Coordinator?=nil
    public var previousCoordinator:Representable.Coordinator?=nil
    
    public init(environment:SCLEnvironment,coordinator:Representable.Coordinator) {
        self.coordinator=coordinator
        super.init(environment:environment)
    }
}

public protocol UIViewRepresentable: View, UIViewBuildable {
    associatedtype UIViewType: UIView
    associatedtype Coordinator
    typealias Context=UIViewRepresentableContext<Self>
    
    func makeUIView(context:Context) -> UIViewType
    
    func updateUIView(_ view:UIViewType,context:Context) -> Void
    
    //func reuseUIView(_ view:UIViewType,context:Context) -> Void
    
    static func dismantleUIView(_ uiView: UIViewType, coordinator: Self.Coordinator,context:Context)
    
    func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<Self.UIViewType>) -> Void) -> Self
    
    func makeCoordinator() -> Self.Coordinator
}

public extension UIViewRepresentable {
    //default implementation
    static func dismantleUIView(_ uiView: UIViewType, coordinator: Self.Coordinator,context:Context) {}
    
    //func reuseUIView(_ view:UIViewType,context:Context) -> Void {}
}

public extension UIViewRepresentable where Coordinator == CoreRender.Coordinator { //default coordinator implementation
    //public typealias Coordinator=CoreRender.Coordinator
    
    func makeCoordinator() -> CoreRender.Coordinator {
        return CoreRender.Coordinator()
    }
}

public protocol UIViewControllerRepresentable: UIViewRepresentable {
    associatedtype UIViewControllerType: UIViewController
    typealias UIViewType=UIView
    typealias Context=UIViewRepresentableContext<Self>
    associatedtype UIContainerType: UIView
    
    func makeUIViewController(context:Context) -> UIViewControllerType
    
    func updateUIViewController(_ view:UIViewControllerType,context:Context) -> Void
    
    //func reuseUIViewController(_ view:UIViewControllerType,context:Context)
    
    static func dismantleUIViewController(_ view: UIViewControllerType, coordinator: Coordinator,context:Context)
    
    //update all controller children
    func reconcileUIView(_ view:UIViewType,context:Context, constrainedTo size:CGSize, with parentView:UIView?,previousViews:[UIView]) -> [ViewNode]
    
    //check if structure of element matches with existing node
    func structureMatches(to:ViewNode) -> Bool
}

public extension UIViewControllerRepresentable {
    func makeUIView(context:Context) -> UIViewType {
        //print("make controller view for \(context._viewController)")
        return context.viewController?.view ?? UIViewType()
    }
    
    func updateUIView(_ view:UIViewType,context:Context) -> Void {}
    
    //update all controller children
    func reconcileUIView(_ view:UIViewType,context:Context, constrainedTo size:CGSize, with parentView:UIView?,previousViews:[UIView]) -> [ViewNode] {
        return []
    }
    
    func structureMatches(to:ViewNode) -> Bool {
        return false
    }
    
    static func dismantleUIViewController(_ view: UIViewControllerType, coordinator: Coordinator,context:Context) {}
    
    //func reuseUIViewController(_ view:UIViewControllerType,context:Context) {}
}

 
public class ViewTagMapping {
    var tagMapping:[Int:AnyHashable]=[:]
    
    public init() {}
}

public protocol UIViewBuildableList {
    var tags:ViewTagMapping {get}
    
    func buildTree(parent: ViewNode, in env:SCLEnvironment) -> [ViewNode]?
}
    
public final class DummyController:UIViewControllerRepresentable {
    public typealias UIViewControllerType=UIViewController
    public typealias Body = Never
    public typealias UIContainerType = UIView
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {return nil}
    
    public func makeUIViewController(context:Context) -> UIViewControllerType {return UIViewController()}
    
    public func updateUIViewController(_ view:UIViewControllerType,context:Context) -> Void {}
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> DummyController {return self}
    
    public var body: Never {
        fatalError()
    }
}

func log(_ msg:String, _ spacing:Int=0) {
    var s=""
    for i in 0..<spacing {s=s+"   "}
    print(s+msg)
}

//var reconcileCount = -1

public func dumpView(view:UIView,tabs:String="") {
    print(tabs+"\(type(of:view)) with ",view.subviews.count," children (",view.frame,")")
    
    for v in view.subviews {
        dumpView(view:v,tabs:tabs+"    ")
    }
}

public func dumpView(controller:UIViewController,tabs:String="") {
    print(tabs+"\(type(of:controller)) with ",controller.children.count," children")
    
    for v in controller.children {
        dumpView(controller:v,tabs:tabs+"    ")
    }
}

public var defaultController=DummyController()

public class SCLNode<Representable,Controller>:NSObject,NodeDelegate where Representable:UIViewRepresentable, Controller:UIViewControllerRepresentable {
    var node:ConcreteNode<Representable.UIViewType>?=nil
    var canReuseNodes:Bool {get {node?.canReuseNodes ?? false} set(newvalue) {node?.canReuseNodes=newvalue}}
    public let context:UIViewRepresentableContext<Representable>
    let host:Representable
    let controller:Controller
    //let dismantleNode:((_ view:Representable.UIViewType,_ context:UIViewRepresentableContext<Representable>)->Void)?
    
    public init(environment:SCLEnvironment,host:Representable,reuseIdentifier:String?,key:String?,
                layoutSpec:@escaping (_ spec:LayoutSpec<Representable.UIViewType>,_ context:SCLContext)->Void, controller:Controller
                //,dismantleNode:((_ view:Representable.UIViewType,_ context:UIViewRepresentableContext<Representable>)->Void)?=nil
               ) 
    {
        self.host=host
        self.controller=controller
        //self.dismantleNode=dismantleNode
        
        //print(Representable.UIViewType.self," environment is:",environment?.values)
        
        self.context=UIViewRepresentableContext<Representable>(environment:environment,
                                                               coordinator:host.makeCoordinator())
        super.init()
        self.node=ConcreteNode<Representable.UIViewType>.init(type:Representable.UIViewType.self,reuseIdentifier:reuseIdentifier,key:key,
        viewInit: { reused in
            //viewInit
            if let reused = reused as? Representable.UIViewType {
                host.updateUIView(reused,context:self.context)
                return reused
            }
            return host.makeUIView(context:self.context)
        },
        viewUpdate: { view in 
            if let view = view as? Representable.UIViewType {host.updateUIView(view,context:self.context)}
        },
        layoutSpec:{spec, context in
            layoutSpec(spec,context as! SCLContext)
        }
        /*,dismantleNode:nil { view in
            if let v=view as? Representable.UIViewType {
                self.dismantleNode?(v,self.context)
            }
        }*/
        );
        
        node?.isControllerNode = !(controller is DummyController)
        node?.delegate=self
        node?.setContext(context)
        node?.canReuseNodes=true
    }
    
    @objc public func constructView(_ reusableView:UIView?,with:UIView?,candidate:UIView?) -> UIView {
        /*if node?.isControllerNode == true  {
            print("constructing controller view:",reusableView," of ",Representable.self)
        }*/
        
        self.context.parent=with
        
        /*if node?.renderedView != nil {
            Representable.dismantleUIView(node!.renderedView!,coordinator:self.context.coordinator,context:self.context)
        }*/
        
        if node?.renderedView != nil {return node!.renderedView!}
        
        var canReuse=false
        
        var view:UIView?=nil
        
        if node?.isControllerNode == true {
            if reusableView==node!.viewController?.view {
                view=reusableView as? Controller.UIContainerType
                canReuse=view != nil
                //if Application?.canReuseNodes == false {canReuse=false}
            }
            else {
                let cview=reusableView as? Controller.UIContainerType
                if cview != nil {
                    canReuse=true //Application?.canReuseNodes ?? true
                
                    if canReuse {
                        //check structure matches
                        if node!.viewController==nil {
                            node!.viewController=cview!.findViewController() as? Controller.UIViewControllerType //reuse controller from view
                            //canReuse=false
                        }
                        else {
                            if let reusedVC=cview!.findViewController() as? Controller.UIViewControllerType, let reusedNode=reusedVC.node {
                                if node != reusedNode.value {
                                    //print("node ",node!," vc:",node!.viewController," view vc:",reusedVC," with node ",reusedNode)
                                    canReuse=controller.structureMatches(to:reusedNode)
                                    //canReuse=false
                                    //print("canreuse:",canReuse)
                                }
                            }
                            else {canReuse=false}
                        }
                    }
                }
                else {
                    //log("controller view \(reusableView) does not match \(Controller.UIContainerType.self))",reconcileCount)
                }
                
                view=cview
            }
        }
        else {
            view=reusableView as? Representable.UIViewType
            canReuse = view != nil
        }
        
        if canReuse==true {
             if node?.isControllerNode == true {
                 /*print("")
                 print("reused controller view \(type(of:Representable.self)) for env=",(view?.cr_nodeBridge.node?.context as? SCLContext)?.environment.values)
                 print("node env=",(node!.context as? SCLContext)?.environment.values)*/
                 
                 if node!.viewController==nil {
                     fatalError()
                     node!.viewController=view!.findViewController() as? Controller.UIViewControllerType //reuse controller from view
                     if node!.viewController==nil {
                        fatalError()
                        let context=Controller.Context(environment:self.context.environment,coordinator:self.context.coordinator as! Controller.Coordinator)
                        node!.viewController=controller.makeUIViewController(context:context)
                     }
                 }
                       
                 self.context.viewController=node!.viewController
                 
                 /*if let vc=node!.viewController {
                    //print("drop:",type(of:vc))
                    for c in vc.children {
                        //print("drop:",c)
                        c.willMove(toParent:nil)
                        c.removeFromParent()
                        c.didMove(toParent:nil)
                    }
                }*/
                 
                 //log("reused controller \(type(of:Controller.UIViewControllerType.self))",reconcileCount)
             }
             else {
                 //reuse this uiview
                 /*print("")
                 print("reuse view \(type(of:Representable.self)) env=",(view?.cr_nodeBridge.node?.context as? SCLContext)?.environment.values)
                 print("node env=",(node!.context as? SCLContext)?.environment.values)
                 print("self env=",self.context.environment.values)*/
                 
                 view!.removeFromSuperview()
             }
            
             node?.setRenderedView(view!)
         
             view!.cr_nodeBridge.node = node as? ConcreteNode<UIView>
             view!.yoga.isEnabled = true 
             view!.tag = node?.reuseIdentifier.hash ?? 0
             
             //reuse this uiview
             host.updateUIView(view as! Representable.UIViewType,context:self.context)
             
             return view!
        } 
        else {
             //print("recreate view \(type(of:Representable.UIViewType.self)):",candidate?.cr_nodeBridge.node," self=",node," view=",candidate)
             if (candidate != nil) {
                 //print("dismantleView ",candidate!,"from constructView node=",node)
                 if let vc=candidate!.next as? UIViewController {
                    vc.willMove(toParent:nil)
                    candidate!.removeFromSuperview()
                    vc.removeFromParent()
                    vc.didMove(toParent:nil)
                }
                else {
                    candidate!.removeFromSuperview()
                }
                
                node?._dismantleView(candidate!)
                 candidate!.node=nil
             }
            
             reusableView?.node=nil
            
             //create newUIView
             if node?.isControllerNode == true /*&& node!.viewController==nil*/ { //always reuse view controller?
                //log("create new controller \(type(of:Controller.UIViewControllerType.self))",reconcileCount)
                
                //if this view controller is still part of a tree. remove it
                if node!.viewController?.parent != nil {
                    //print("finally removing view controller ",node!.viewController)
                    node!.viewController!.willMove(toParent: nil)
                    node!.viewController!.view.removeFromSuperview()
                    node!.viewController!.removeFromParent()
                }
                
                var context=Controller.Context(environment:self.context.environment,coordinator:self.context.coordinator as! Controller.Coordinator)
                context.parent=with
                node!.viewController=controller.makeUIViewController(context:context)
                self.context.viewController=node!.viewController
                //print("got view controller ",node?.viewController," for parent controller ",node?.parent?.viewController)
                
                if with==nil {
                    //if parent is nil, only construct uiviewcontroller
                    let v=node!.viewController!.view!
                    v.yoga.isEnabled = true;
                    v.tag = node?.reuseIdentifier.hash ?? 0;
                    v.cr_nodeBridge.node = node as? ConcreteNode<UIView>
                    return v
                }
             }
             else {
                 //log("create new view \(type(of:Representable.UIViewType.self))",reconcileCount)
             }
             
             let view=host.makeUIView(context:self.context)
             //print("created view ",view)
             node?.setRenderedView(view)
             view.yoga.isEnabled = true;
             view.tag = node?.reuseIdentifier.hash ?? 0;
             view.cr_nodeBridge.node = node as? ConcreteNode<UIView>
             node?.shouldInvokeDidMount()
             return view
        }
    }
    
    @objc public func reconcileView(_ node:ConcreteNode<UIView>, in candidateView:UIView?, constrainedTo size:CGSize, 
                             with parentView:UIView?, forceLayout:Bool) -> Void {
        //print("")
        //reconcileCount=reconcileCount+1
        //if node.isControllerNode {
           //print("")
           //print("***reconcile view \(Representable.self) candidate=",candidateView," orig ",node.origCandidate)
        //}
        if node != self.node {
            fatalError()
        }
        
        if candidateView != nil && candidateView!.superview is SCLHostingView {
            //this is the root of a view hierarchy, preserve original children
            //print("******reconcile ",node.children.count," of ",Representable.self," with ",candidateView!.subviews.count," views for parent ",type(of:candidateView!.superview!))
            node.origCandidate=candidateView
        }
        
        var origsubviews: [UIView] = []
        if node.origCandidate != nil {
            origsubviews.reserveCapacity(node.origCandidate!.subviews.count)
            for subview in node.origCandidate!.subviews {
                if !subview.cr_hasNode {
                    //this is a system node
                    if node.isControllerNode && node.origCandidate is Controller.UIContainerType {
                        //print("got controller container ",subview," with ",subview.subviews.count," children from ",node.origCandidate)
                        //dumpView(view:subview)
                    }
                    else {
                        continue
                    }
                } 
                else {
                    if node.isControllerNode {
                        //print("got orig controller view ",subview," with ",subview.subviews.count," children from ",node.origCandidate)
                        //dumpView(view:subview)
                    }
                }
                origsubviews.append(subview)
            }
        }
        //print("orig subviews:",origsubviews.count)
        
        // The candidate view is a good match for reuse.
        var canReuse=false
        if candidateView != nil && candidateView!.isKind(of:node.viewType) && candidateView!.cr_hasNode && candidateView!.tag == node.reuseIdentifier.hash {
            //print("check candidateview for ",type(of:Representable.UIViewType.self))
            
            if node.canReuse(candidateView!)==true {
                  //print("candidateview reused for ",node.viewType," controller ",node.viewController)  
                  /*print("")
                  print("reused view \(type(of:Representable.UIViewType.self)):",candidateView!.cr_nodeBridge.node," self=",node," view=",candidateView)
                  node._reuse(candidateView!)*/
                  
                  if node.renderedView != nil {
                        if node.isControllerNode == true && node.viewController != nil {
                            //remove old viewControlle
                            //print("remove controller node",node.viewController ?? node.renderedView!.findViewController()," from ",node.parent?.viewController)
                            node.viewController!.willMove(toParent: nil)
                            node.renderedView!.removeFromSuperview()
                            node.viewController!.removeFromParent()
                        }
                        else {node.renderedView!.removeFromSuperview()}
                        node.setRenderedView(nil)
                  }
          
                  //print("constructView reuse")
                  node._constructView(withReusableView:candidateView!,with:parentView,candidate:node.origCandidate)
                  candidateView!.cr_nodeBridge.isNewlyCreated = false
                  canReuse=true
            }
            else {
                //print("************candidateview denied reusing for ",Representable.self)  
                
                if node.isControllerNode == true && node.viewController != nil {
                    //remove old viewController
                    //print("remove controller node",node.viewController ?? candidateView!.findViewController()," from ",node.parent?.viewController)
                    node.viewController!.willMove(toParent: nil)
                    candidateView!.removeFromSuperview()
                    node.viewController!.removeFromParent()
                }
                else {candidateView!.removeFromSuperview()}
                
                //just in case this nide still contains a view, check if we can use
                var v:UIView?=nil //node.renderedView
                node.renderedView?.removeFromSuperview()
                /*node.setRenderedView(nil)
                //if node has no children, we may reuse?
                //if v?.subviews.count != 0 {
                    v=nil
                //}*/
                
                //print("constructView reuse fail")
                node._constructView(withReusableView:v,with:parentView,candidate:node.origCandidate)
                node.renderedView!.cr_nodeBridge.isNewlyCreated = true;
            }
        } 
        else {
            //if candidateView != nil {print("************candidateview ", type(of:candidateView!), " did not match ",Representable.self)}
            //else {print("************candidateview nil did not match ",Representable.self," rendered=",node.renderedView)  }
              
            // The view for this node needs to be created.
            if candidateView != nil {
                 if node.isControllerNode == true && node.viewController != nil {
                    //remove old viewController
                    //print("remove controller node",node.viewController ?? candidateView!.findViewController()," from ",node.parent?.viewController)
                    node.viewController!.willMove(toParent: nil)
                    candidateView!.removeFromSuperview()
                    node.viewController!.removeFromParent()
                 }
                 else {candidateView!.removeFromSuperview()}
            }
            
            //print("constructView no previous ",candidateView," node=",node)
            node._constructView(withReusableView:nil,with:parentView,candidate:node.origCandidate)
            if node.isControllerNode != true {
                node.renderedView?.cr_nodeBridge.isNewlyCreated = true
            }
        }
          
        //NSLog("embedding view")
        
        if !canReuse {
            //drop all controller connections
            if node.origCandidate != nil {
                if let vc=node.origCandidate!.next as? UIViewController {
                    //print("drop:",type(of:vc))
                    for c in vc.children {
                        //print("drop:",c)
                        c.willMove(toParent:nil)
                        c.removeFromParent()
                        c.didMove(toParent:nil)
                    }
                }
            }
        }
  
        if node.isControllerNode == true {
            //if parent is nil, only construct uiviewcontroller
            if parentView==nil {
                node.setRenderedView(nil)
                //log("reconcile break \(Representable.self)",reconcileCount)
                //reconcileCount=reconcileCount-1
                node.origCandidate=nil
                return
            }
              
            if node.renderedView != node.viewController!.view {
                //print("renderedNode changed")
                let vc=node.renderedView?.next as? UIViewController
                if vc?.parent != nil {vc!.willMove(toParent:nil)}
                node.renderedView?.removeFromSuperview()
                if vc?.parent != nil {vc!.removeFromParent();vc!.didMove(toParent:nil)}
                
                node.setRenderedView(node.viewController!.view)
            }
            //print("adding controller node renderedView=",node.renderedView)
            //print("adding controller node ",node.viewController," with view ",node.viewController!.view," to ",node.parent?.viewController," with parent",parentView)
            if parentView != nil {
                var parentVC:UIViewController?=node.parent?.viewController
                if node.origCandidate != node.renderedView {
                    //print("orig vc ",node.origCandidate?.next)
                    //print("current vc ",node.renderedView!.next)
                    
                    let vc=node.origCandidate?.next as? UIViewController
                    if vc?.parent != nil {vc!.willMove(toParent:nil)}
                    node.origCandidate?.removeFromSuperview()
                    if vc?.parent != nil {vc!.removeFromParent();vc!.didMove(toParent:nil)}
                    //parentVC=nil
                } 
                //if parentVC==nil {parentVC=parentView?.superview?.findViewController()}
                //print("")
                //print("parentVC:",parentVC," for ",Representable.self," (",node.viewController,")")
                /*if parentVC != nil {
                    print("add ",type(of:node.viewController!)," to ",type(of:parentVC!))
                    print("origCandidate:",node.origCandidate)
                    print("renderedView:",node.renderedView)
                    dumpView(controller:Application!.rootViewController!)
                }*/
                
                parentVC?.addChild(node.viewController!)
                
                //print("for ",node.renderedView!," old controller view parent:",node.renderedView!.superview)
                if parentView != nil && parentView != node.renderedView {
                    node.renderedView!.removeFromSuperview()
                    parentView?.addSubview(node.renderedView!)
                }
                
                if parentVC != nil {node.viewController!.didMove(toParent: parentVC!)}
            }
            //print("added controller node")
        }
        else {
            //print("view ",node.renderedView!," new view parent:",parentView)
            if parentView != nil {
                node.renderedView!.removeFromSuperview()
                //if node.renderedView!.superview != nil {print("*******old view parent:",node.renderedView!.superview," new view parent:",parentView)}
                parentView?.addSubview(node.renderedView!)
            }
        }
          
        //NSLog("embedded view")
          
        let view = node.renderedView!

        // Get all of the subviews.
        var subviews : [UIView] = []
        subviews.reserveCapacity(view.subviews.count)
        for subview in view.subviews {
            if !subview.cr_hasNode {continue} //this is a system node
            subviews.append(subview)
        }
          
        //remove all subviews from tree, if reused they will be added again
        for subview in subviews { 
            //if this subview has a view controller, remove it from parent
            if let vc=subview.next as? UIViewController {
                if vc.parent != nil {
                    //print("build remove view controller ",vc," from ",vc.parent)
                    vc.willMove(toParent: nil)
                    subview.removeFromSuperview()
                    vc.removeFromParent()
                }
                else {subview.removeFromSuperview()}
            }
            else {subview.removeFromSuperview()}
        }

        //print("initial frame of ",type(of:node.renderedView!)," is ",node.renderedView!.frame,"children=",node.children.count," isctrl:",node.isControllerNode) 
  
        // Iterate children.
        //print("iterating ",node.children.count," children of ",node.viewType," canReuse=",canReuse) 
          
        //log("interating children of \(Representable.self)",reconcileCount)
        //print("process ",node.children.count," of ",Representable.self," with ",subviews.count," views")
          
        var childIndex=0
        for child in node.children {
                var candidateView:UIView? = nil;

                if (canReuse) {
                    var index = 0;
                    for subview in subviews {
                      if subview.isKind(of:child.viewType) && subview.tag == child.reuseIdentifier.hash {
                        candidateView = subview;
                        break
                      }
                      break //only reuse first child
                      index=index+1
                    }
                    // Pops the candidate view from the collection.
                    if candidateView != nil {subviews.remove(at:index)}
                    else {
                        //print("************child ",child," did not match ",child.viewType)
                        canReuse=false //stop reusing views
                    } 
                }
                
                child.origCandidate=nil
                
                if canReuse==false {
                    //print("\r\ncan reuse ",child.viewType," false for ",childIndex+1," of ",node.children.count," of ",Representable.self," with ",origsubviews.count," views")
                    if node.children.count == origsubviews.count {
                        if origsubviews[childIndex].isKind(of:child.viewType) {
                        //if let v=origsubviews[childIndex] as? child.viewType {
                            let v=origsubviews[childIndex]
                            //print("dismantle ",type(of:v)," for ",Representable.self," with type ",child.viewType," and ",v.subviews.count," children")
                            
                            //child._dismantleView(v)
                            
                            //print("dismantled ",type(of:v)," for ",Representable.self," with type ",child.viewType," and ",v.subviews.count," children")
                            
                            child.origCandidate=v
                            v.node=nil
                        }
                        //else {print(type(of:origsubviews[childIndex])," does not match ",child.viewType)}
                    }
                    /*else {
                        print("child nodes (",node.children.count,") for ",Representable.self," do not match origsubviews ",origsubviews.count)
                    }*/
                }
                else {
                    /*print("\r\ncan reuse ",child.viewType," TRUE for ",type(of:child.renderedView),":",childIndex+1," of ",node.children.count," of ",Representable.self," with ",origsubviews.count," views")*/
                    if node.children.count == origsubviews.count {
                        if origsubviews[childIndex].isKind(of:child.viewType) {
                        //if let v=origsubviews[childIndex] as? child.viewType {
                            let v=origsubviews[childIndex]
                            child.origCandidate=v
                        }
                    }
                    
                    //deactivated, does not work inside view controllers
                    //child._reuse(candidateView!) 
                }
    
                // Recursively reconcile the subnode.
                child._reconcileNode(child,in:candidateView,constrainedTo:size,withParentView:node.renderedView!,forceLayout:false)
                
                child.origCandidate=nil
                
                childIndex=childIndex+1
        }
          
        //log("interated children of \(Representable.self). reconciling controllers",reconcileCount)
          
        if node.isControllerNode==true {
              var context=Controller.Context(environment:self.context.environment,coordinator:self.context.coordinator as! Controller.Coordinator)
              context.parent=parentView
              context.viewController=self.context.viewController
              //print("reconciling view controller ",Controller.self," children ",node.children," origsubviews",origsubviews.count," candidate ",candidateView)
              //log("recon \(type(of:view))",reconcileCount)
              
              let children=self.controller.reconcileUIView(view,context:context, constrainedTo:size, with:parentView, previousViews:origsubviews)
              //log("recon end \(type(of:view))",reconcileCount)
              
              //print("update:",children)
              for child in children {
                  updateChildren(child)
                  //log("Updated \(type(of:view))",reconcileCount)
              }
              
              /*print("after building controllernode for \(Representable.self)")
              print("renderedView:",node.renderedView)
              print("controllerView:",context.viewController!.view)
              dumpView(view:context.viewController!.view)*/
              
              //node.setRenderedView(context.viewController!.view)
              if node.renderedView != context.viewController!.view {
                  print("*******+*+")
                  print("*******+* ViewController view mismatch for \(Representable.self)")
                  print("*******+* old:",node.renderedView)
                  dumpView(view:node.renderedView!)
                  print("*******+* new:",context.viewController!.view)
                  dumpView(view:context.viewController!.view)
                  print("*******+*+")
                  fatalError()
                  node.setRenderedView(context.viewController!.view)
                  parentView?.addSubview(node.renderedView!)
              }
        }
          
        //print("***reconcileView ",node.viewType," end")
        //print("final frame of ",type(of:node.renderedView!)," is ",node.renderedView!.frame) 
          
        node.origCandidate=nil
        // Remove all of the obsolete old views that couldn't be recycled.
        //for subview in subviews { subview.removeFromSuperview() }
          
        //log("reconcile done \(Representable.self)",reconcileCount)
        //reconcileCount=reconcileCount-1
        
        if forceLayout && self.node?.renderedView != nil {
            //print("Force layout for ",Representable.self," node=",self.node?.renderedView?.node)
            updateChildren(self.node!.renderedView!/*.node!*/)
        }
        
        //print("after building \(Representable.self)")
        //dumpView(view:node.renderedView!)
    }
    
    func updateChildren(_ child:ViewNode) {
        for sub in child.children {updateChildren(sub)}
        
        if let view:UIView=child.value?.renderedView {
            //print("Update (ViewNode) \(type(of:view)) env=",context.environment)
            child.value?.update(view,doLayout:true)
        }
    }
    
    func updateChildren(_ child:UIView) {
        for sub in child.subviews {updateChildren(sub)}
        
        //print("Update (UIView) \(type(of:child)) node=",child.cr_nodeBridge.node," env=",context.environment)
        child.cr_nodeBridge.node?.update(child,doLayout:true)
    }
    
    @objc public func dismantleView(_ view:UIView) {
        //print("dismantle:",Representable.self)
        if let v=view as? Representable.UIViewType {
            if var oldContext=view.cr_nodeBridge.node?.context as? UIViewRepresentableContext<Representable> {
                if oldContext != self.context {
                    //print("dismantle old context:",oldContext)
                    oldContext.nextCoordinator=self.context.coordinator
                    //print("dismantle:",Representable.self)
                    Representable.dismantleUIView(v,coordinator:oldContext.coordinator,context:oldContext)
                }
                //else {print("old context same as new context:",self.context)}
            }
            //else {print("old context does not match:",view.cr_nodeBridge.node?.context)}
        }
        //else {print("dismantle view:",view," does not match ",Representable.UIViewType.self)}
    }
    
    /*@objc public func reuse(_ view:UIView) {
        
        func iteratechildren(_ v:UIView) {
            for subview in v.subviews {
                if subview.cr_hasNode {
                    subview.cr_nodeBridge.node!._reuse(subview)
                }
                else {if subview.subviews.count>0 {iteratechildren(subview)}}
            }
        }
        
        if let v=view as? Representable.UIViewType {
            //print("reuseuiview:",Representable.self)
            //if v.subviews.count>0 {iteratechildren(v)}
        
            if var oldContext=view.cr_nodeBridge.node?.context as? UIViewRepresentableContext<Representable> {
                if oldContext != self.context {
                    //print(Representable.self," reuse. old coordinator=",oldContext.coordinator)
                    self.context.previousCoordinator=oldContext.coordinator
                    host.reuseUIView(v,context:self.context)
                }
            }
        }
    }*/
}

/*
if node!.viewController==nil {
                     if let host=self.controllerHost {
                         var context=UIViewRepresentableContext<UIViewControllerRepresentable>()
                         context.environment=self.context.environment
                         context._viewController=self.context._viewController
                         
                         node!.viewController=hist.makeUIViewController(context:context)
                         
                         self.context.environment=context.environment
                         self.context._viewController=node!.viewController
                     }
                 }
*/

public class ViewNode {
    public typealias V = UIView
    //public weak var parent: ViewNode?
    //public var children: [ViewNode]
    public var uuid = UUID()
    //public var processor: String
    public var value:ConcreteNode<V>?
    public var tags:ViewTagMapping?=nil
    public var children:[ViewNode]=[]
    public var runtimeenvironment:SCLEnvironment {
        get{(value?.context as? SCLContext)?.environment ?? SCLEnvironment(values:EnvironmentValues())}
        set(newvalue) {if let c=(value?.context as? SCLContext) {
                           //if newvalue != nil {c.environment=newvalue!}
                           //else {c.environment=SCLEnvironment(values:EnvironmentValues())}
                           c.environment=newvalue
                       }
        }
    }
    internal var buildenvironment:SCLEnvironment?
    
    public init() {self.value=nil}
    
    public init(value: ConcreteNode<V>) {
        self.value = value
    }
    
    public init<Representable,Controller>(value:SCLNode<Representable,Controller>) 
            where Representable:UIViewRepresentable, Controller:UIViewControllerRepresentable {
        self.value=value.node?.viewnode()
    }
    
    public func addChild(node c:ViewNode) {
        children.append(c)
        if c.value != nil {
            //copy parent view controller if node itself is not a view controller
            if c.value!.viewController==nil && c.value!.isControllerNode != true {c.value!.viewController=value?.viewController}
            value?.addChild(c.value!)
        }
    }
    
    open func addLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<V>) -> Void) {
        value?.addLayoutSpec(spec)
    }
    
    open func structureMatches(to:ViewNode?,deep:Bool=true) -> Bool {
        if to==nil {return false}
        if self==to! {return true}
        
        if self.children.count != to!.children.count {return false}
        
        var i=0
        for child in self.children {
            var child1=to!.children[i]
            
            if !child.structureMatches(to:child1,deep:deep) {return false}
            if child1.value != nil {
                if deep && !(child.value?._structureMatches(to:child1.value!) ?? false) {return false}
            }
            else if child.value != nil {return false}
            
            i=i+1
        }
        
        return true
    }
    
    /*open func dismantleNode() {
        for child in self.children {
            child.dismantleNode()
        }
    }*/
}

public class ViewNodeList:ViewNode {
    public init(_ children:[ViewNode]) {super.init();self.children=children;}
    
    public override func addLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIView>)  -> Void) {
        for c in children {c.addLayoutSpec(spec)}
    }
}

extension ViewNode: Equatable {
    public static func == (lhs: ViewNode, rhs: ViewNode) -> Bool {
        return lhs.uuid == rhs.uuid && lhs.value?.parent == rhs.value?.parent
    }
}

extension ViewNode: CustomStringConvertible {
    public var description: String {
        return "\(value)"
    }
}

public protocol OptionalProtocol {}
extension Optional : OptionalProtocol {}

func unwrap<T>(_ x: Any) -> T {
      return x as! T
}

func checkNil(_ v:Any) -> AnyObject? {
        let t=type(of:v)
        if (t is OptionalProtocol.Type)
        {
            //print("Has optional protocol")
            
            if (v is AnyObject)
            {
                let z: AnyObject? = unwrap(v)
                //if (z==nil) {return true}
                return z
            }
            return nil
        }

        return nil;
}


extension TupleView {
    
    /*public func makeUIView(context:SCLContext,reusedView:UIView?) -> UIView {
        return reusedView ?? UIView(frame:CGRect(x:0,y:0,width:0,height:0))
    }
    
    public func updateUIView(context:SCLContext,view:UIView?) -> Void {
    }*/
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        
        var childlist:[ViewNode]=[]
        //self.context=context
        
        for child in Mirror(reflecting: value).children {
            
            //print("TupleView: ViewBuildable: \(type(of:child.value)))")
            
            if child.value==nil {continue}
            if let viewBuildable = child.value as? UIViewBuildable {
                //print("build normal \(viewBuildable)")
                if let viewBuildable1 = child.value as? UIViewBuildableList {
                    //print("build normal \(viewBuildable)")
                    if let l=viewBuildable1.buildTree(parent: parent, in:env) {
                        for n in l {childlist.append(n)}
                    }
                }
                else if let n=viewBuildable.buildTree(parent: parent, in:env) {childlist.append(n)}
            }
            else if let viewBuildable = child.value as? OptionalProtocol {
                if let value=checkNil(child.value) {
                    if let viewBuildable = value as? UIViewBuildable {
                        //print("build optional \(viewBuildable)")
                        if let viewBuildable1 = value as? UIViewBuildableList {
                        //print("build optional \(viewBuildable)")
                            if let l=viewBuildable1.buildTree(parent: parent, in:env) {
                                for n in l {childlist.append(n)}
                            }
                        }
                        else if let n=viewBuildable.buildTree(parent: parent, in:env) {childlist.append(n)}
                    } 
                    else if let viewBuildable = value as? EmptyView {
                        //just skip
                    }
                    else {
                        print("TupleView: ViewBuildable: Can't render optional custom views \(value) (\(type(of:value))), yet.")
                    }
                }
                else {
                    //print("TupleView: ViewBuildable: skip empty optional")
                }
            }
            else if let viewBuildable = child.value as? EmptyView {
                //just skip
            }
            else if let _view = child.value as? _View {
                if let viewBuildable1 = _view.viewBuildableList {
                    //print("build optional \(viewBuildable)")
                    if let l=viewBuildable1.buildTree(parent: parent, in:env) {
                        for n in l {childlist.append(n)}
                    }
                }
                else if let viewBuildable=_view.viewBuildable {
                    //print("build body ",viewBuildable)
                    if let n=viewBuildable.buildTree(parent: parent, in:env) {childlist.append(n)}
                }
            }
            else {
                // child as View
                print("TupleView: ViewBuildable: Can't render custom views \(child.value) (\(type(of:child.value))), yet.")
            }
        } //for
        
        return ViewNodeList(childlist)
    }
}


extension _ConditionalContent {
    
    /*public func makeUIView(context:SCLContext,reusedView:UIView?) -> UIView {
        return reusedView ?? UIView(frame:CGRect(x:0,y:0,width:0,height:0))
    }
    
    public func updateUIView(context:SCLContext,view:UIView?) -> Void {
    }*/
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        switch _storage {
        case .trueContent(let content):
            if let element = content as? UIViewBuildable {
                return element.buildTree(parent: parent, in:env)
            } else {
                print("Non-ViewBuildable detected. \(content)", #function)
                return nil
            }
        case .falseContent(let content):
            if let element = content as? UIViewBuildable {
                return element.buildTree(parent: parent, in:env)
            } else {
                print("Non-ViewBuildable detected. \(content)", #function)
                return nil
            }
        }
    }
}

extension Optional {
    /// Evaluates the given closure when this `Optional` instance is not `nil`,
    /// passing the unwrapped value as a parameter.
    ///
    /// Use the `map` method with a closure that returns a non-optional view.
    @inlinable
    public func map<V: View>(@ViewBuilder _ transform: (Wrapped) throws -> V) rethrows -> V? {
        if let wrapped = self {
            return try transform(wrapped)
        } else {
            return nil
        }
    }
    
    /// Evaluates the given closure when this `Optional` instance is not `nil`,
    /// passing the unwrapped value as a parameter.
    ///
    /// Use the `flatMap` method with a closure that returns an optional view.
    @inlinable
    public func flatMap<V: View>(@ViewBuilder _ transform: (Wrapped) throws -> V?) rethrows -> V? {
        if let wrapped = self {
            return try transform(wrapped)
        } else {
            return nil
        }
    }
}

extension Optional where Wrapped: View {
    @inlinable
    public static func ?? <V: View>(lhs: Self, rhs: @autoclosure () -> V) -> _ConditionalContent<Self, V> {
        if let wrapped = lhs {
            return ViewBuilder.buildEither(first: wrapped)
        } else {
            return ViewBuilder.buildEither(second: rhs())
        }
    }
}

extension AnyView {
    
    /*public func makeUIView(context:SCLContext,reusedView:UIView?) -> UIView {
        return reusedView ?? UIBody(frame:CGRect(x:0,y:0,width:0,height:0))
    }
    
    public func updateUIView(context:SCLContext,view:UIView?) -> Void {
    }*/
    
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        if let view = Mirror(reflecting: _storage).children.first?.value as? UIViewBuildable {
            return view.buildTree(parent: parent, in:env)
        }
        return nil
    }
}



public struct ViewExtractor<Content>: View where Content: View {
    public static func extractViews(contents: Content) -> [UIViewBuildable] {
        //print("extractViews for ",contents)
        //print("extractViews")
        
        var buildables = [UIViewBuildable]()
        
        if let element = contents as? UIViewBuildable {
            //print("add buildable:",type(of:element))
            buildables.append(element)
        }
        else if let element = contents as? EmptyView {
            //just skip
        }
        else if let element = contents.body as? UIViewBuildable {
            // Custom View
            buildables.append(element)
        } else {
            print("ViewExtractor: No Idea what's inside.")
            print(contents)
        }
        
        //print("extracted Views")
        
        return buildables
    }
    
    public var context:SCLContext? = nil
    
    public func withLayoutSpec(_ spec:(_ spec:LayoutSpec<UIView/*Self.UIBody*/>) -> Void) -> ViewExtractor<Content> {return self}
}

public extension ViewExtractor {
    public var body: Never {
        fatalError()
    }
}

/*public func makeViewNode<C: Coordinator, V:UIView>(type: V.Type,coordinatortype:C.Type,context: Context,
                                                   key: String,props: [AnyProp] = []) -> ViewNode {
    let reuseIdentifier = NSStringFromClass(C.self)
    let coordinator = context.coordinator(CoordinatorDescriptor(type: C.self, key: key)) as! C   
    for setter in props {
         setter.apply(coordinator: coordinator)
    }
    context.pushCoordinatorContext(key);
    let v=ViewNode(value:ConcreteNode(type:type,reuseIdentifier:reuseIdentifier,key:nil,viewInit:nil,layoutSpec:{spec in})) 
    context.popCoordinatorContext()
    return v
}*/

public final class SCLNodeHierarchy<Content>:NodeHierarchy, UIViewRepresentable where Content:View {
  var _content:Content/*()->Content*/
  var _environment:EnvironmentValues?
  var _controller:UIViewController?
  public typealias UIViewType=UIView
  var _orientation:UIDeviceOrientation?=Application?.orientation
  var _rootNode:ViewNode?=nil
  
  public func makeUIView(context:UIViewRepresentableContext<SCLNodeHierarchy>) -> UIViewType {
        UIViewType(frame:CGRect(x:0,y:0,width:0,height:0))
  }
  
  public func updateUIView(_ view:UIViewType,context:UIViewRepresentableContext<SCLNodeHierarchy>) -> Void {
  }
  
  public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> SCLNodeHierarchy<Content> {return self}

  public init(content: Content,environment:EnvironmentValues?=nil,controller:UIViewController?=nil) {
      _content=content
      _environment=environment
      _controller=controller
      //_content.context=context
      //print("hierarchy init")
      super.init(context:nil/*SCLContext()*/)
      //print("hierarchy init context=",self.context)
  } 
  
  public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
      fatalError() //not to be called, only here for protocol conformance
  }

  public override func build(in view:UIView,constrainedTo size:CGSize,with options:CRNodeLayoutOptions) {
      //print("hierarchy build context=",self.context)
      
      if (Application != nil) {Application!.buildCount=Application!.buildCount+1}
      
      var env=_environment
      if env==nil {env=Application?.environment}
      if env==nil {env=EnvironmentValues()}
      
      //self._rootNode?.dismantleNode()
      
      //alert("build","build nodehierarchy body options=\(options)")
      var sclnode=SCLNode(environment:SCLEnvironment(values:env!), host:self/*,type:UIView.self*/,reuseIdentifier:"SCLNodeHierarchy",
                          key:nil,layoutSpec:{spec, context in},controller:defaultController)
      sclnode.node?.viewController=_controller
      if sclnode.node?.viewController==nil {sclnode.node?.viewController=Application?.rootViewController}
      let rootNode=ViewNode(value:sclnode)
      let oldnode=self._rootNode
      self._rootNode=rootNode
      self.setup(view,constrainedTo:size,with:options,root:rootNode.value!)
      
      //print("root environment:",rootNode.environment)
    
      //print("content=",_content)
      if let c=_content as? UIViewBuildable {
          c.buildTree(parent: rootNode, in:rootNode.runtimeenvironment)
      }
      else {
          ViewExtractor.extractViews(contents: _content.body/*()*/).forEach {
              $0.buildTree(parent: rootNode, in:rootNode.runtimeenvironment)
          }
      }
      
      //print("root node scenePhase:",sclnode.context.environment.values[keyPath:\.scenePhase])
      //print("Application scenePhase:",Application?.environment[keyPath:\.scenePhase])
      
      //we can onle reuse nodes if the structure is identical
      if self.root != nil {
          //alert("compare","\(oldnode) and \(self.root)")
          //sclnode.canReuseNodes=sclnode.node?.structureMatches(to:oldnode.node) ?? false
          sclnode.canReuseNodes=rootNode.structureMatches(to:oldnode)
          //if sclnode.canReuseNodes {print("SCLNodeHierarchy hierarchy matches")}
          
          if self._orientation != Application?.orientation {
              //print("Invalidate on orientation change")
              sclnode.canReuseNodes=false
          }
      }
      
      self._orientation=Application?.orientation
      
      //print("SCLNodeHierarchy global can reuse:",sclnode.canReuseNodes)
      let canreuse=sclnode.canReuseNodes
      Application?.canReuseNodes=canreuse
      
      if !canreuse {
          //drop all controllers
          if oldnode != nil && oldnode?.value?.viewController != nil {
              //print("old vc:",oldnode?.value?.viewController)
              for c in oldnode!.value!.viewController!.children {
                  c.willMove(toParent:nil)
                  c.removeFromParent()
                  c.didMove(toParent:nil)
              }
          }
      }
      
      //reconcileCount = -1
      
      //self.reverse()
      if self.context != nil {self.root.registerHierarchy(in:self.context!)}
      self.root.setRootHierarchy(self)
      self.root.reconcile(in:view,constrainedTo:size,with:options)
      
      Application?.canReuseNodes=true
      
      //print("SCLNodeHierarchy first build ok. layout phase")
      //dumpView(view:self.root.renderedView!)
      //reconcileCount = -1
      
      if !canreuse { //issue layout
          sclnode.canReuseNodes=true
          self.root.reconcile(in:view,constrainedTo:size,with:options)
      }
      
      /*print("SCLNodeHierarchy layout ok")
      dumpView(view:self.root.renderedView!)
      dumpView(controller:Application!.rootViewController!)*/
  }
  

}

public extension SCLNodeHierarchy {
    public var body: Never {
        fatalError()
    }
}


open class SCLHostingView:HostingView  {
    //var with:CRNodeLayoutOptions
    private var stateBuildCount=0
    
    public init<V:View>(with:CRNodeLayoutOptions,hierarchy:SCLNodeHierarchy<V>) {
        //self.with=with
        super.init(hierarchy:hierarchy,context:CRContext(),with:with)
        //Application?.hostingViews.append(self)
    }
    
    /*public func setNeedsBuild() {
        //alert("need rebuild","with \(with)")
        self.body.build(in:self,constrainedTo:self.bounds.size,with:self.with)
    }*/
    
    public override func didMoveToSuperview() {
        if self.superview==nil {
            if let index = Application?.hostingViews.firstIndex(of: self) {
                Application?.hostingViews.remove(at: index)
            }
        }
        else if !(Application?.hostingViews.contains(self) ?? false) {Application?.hostingViews.append(self)}
    }
    
    public override func setNeedsBuild() {
        stateBuildCount=stateBuildCount+1
        let buildCount=stateBuildCount
        DispatchQueue.main.async {
            if self.stateBuildCount>buildCount {return} //reconcile multiple changes
            var f=self.frame //Application.window!.bounds
            if f.size.width != CGFloat(SCLDeviceInfo.size.width) || f.size.height != CGFloat(SCLDeviceInfo.size.height) {
                //needs resize. this may happen after orientationchange
                f.size.width=CGFloat(SCLDeviceInfo.size.width)
                f.size.height=CGFloat(SCLDeviceInfo.size.height)
                //print("root hostingview \(self) build f=\(f)")
                self.frame=f
            }
            super.setNeedsBuild()
        }
    }
}

//test run with layoutSpec and concrete UIView to capture property setters
internal class TestLayoutSpec:LayoutSpec<UIView> {
    private var _testValues:[String:Any]=[:]
    private var _testList:[String]=[]
    private var _node:ConcreteNode<UIView>
    
    public init(node:ConcreteNode<UIView>,view:UIView,constrainedTo:CGSize,testList:[String]) {
        self._testList=testList
        let save=node.renderedView
        _node=node
        _node.setRenderedView(view)
        super.init(node:_node,constrainedTo:constrainedTo)
        _node.setRenderedView(save)
        view.yoga.isEnabled = true
    }
    
    func test () {
        if _node.layoutSpec != nil {_node.layoutSpec(self,SCLContext(environment:SCLEnvironment(values:EnvironmentValues())))}
    }
    
    public override func set(_ keyPath:String, value:Any) -> Void {
        return set(keyPath,value:value,animator:nil)
    }
    
    public override func set(_ keyPath:String, value:Any,  animator:UIViewPropertyAnimator?) -> Void {
        //print("test set ",keyPath," to ",value)
        if _testList.contains(keyPath) {_testValues[keyPath]=value}
    }
    
    func floatValue(_ key:String) -> Double? {
        if let v=_testValues[key] {
            if let v=v as? CGFloat {return Double(v)}
            if let v=v as? Int {return Double(v)}
            if let v=v as? Float {return Double(v)}
            if let v=v as? Double {return Double(v)}
        }
        return nil
    }
}














