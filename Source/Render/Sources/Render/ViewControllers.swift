import UIKit
import Foundation
import CoreRender

@nonobjc extension UIViewController {
    public func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)

        if (frame != nil) {
            child.view.frame = frame!
        }

        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    public func remove(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    public func displayContentController(content: UIViewController)
    {
        add(content,frame:self.view.frame)
    }
    
    public func hideContentController(content: UIViewController)
    {
        remove(content)
    }
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}

/*
infix operator <=>

extension UIViewController {
    
    static let methodSwizzling: Void = {
        #selector(viewDidLoad) <=> #selector(navigation_viewDidLoad)
        #selector(viewWillAppear(_:)) <=> #selector(navigation_viewWillAppear(_:))
        #selector(setNeedsStatusBarAppearanceUpdate) <=> #selector(navigation_setNeedsStatusBarAppearanceUpdate)
        #selector(viewDidLayoutSubviews) <=> #selector(navigation_viewDidLayoutSubviews)
    }()
    
    private var isNavigationBarEnabled: Bool {
        guard let navigationController = navigationController,
              navigationController.navigation.configuration.isEnabled,
              navigationController.viewControllers.contains(self) else {
            return false
        }
        
        return true
    }
    
    @objc private func navigation_viewDidLoad() {
        navigation_viewDidLoad()
        
        guard isNavigationBarEnabled else { return }
        
        setupNavigationBarWhenViewDidLoad()
        
        if let tableViewController = self as? UITableViewController {
            tableViewController.observeContentOffset()
        }
    }
    
    @objc private func navigation_viewWillAppear(_ animated: Bool) {
        navigation_viewWillAppear(animated)
        
        guard isNavigationBarEnabled else { return }
        
        updateNavigationBarWhenViewWillAppear()
    }
    
    @objc private func navigation_setNeedsStatusBarAppearanceUpdate() {
        navigation_setNeedsStatusBarAppearanceUpdate()
        
        adjustsNavigationBarLayout()
    }
    
    @objc private func navigation_viewDidLayoutSubviews() {
        navigation_viewDidLayoutSubviews()
        
        view.bringSubviewToFront(_navigationBar)
    }
}

private extension Selector {
    
    static func <=> (left: Selector, right: Selector) {
        if let originalMethod = class_getInstanceMethod(UIViewController.self, left),
            let swizzledMethod = class_getInstanceMethod(UIViewController.self, right) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}
*/

open class SCLRootViewController: UIViewController
{
    //var vcdata:Dictionary<UIViewController,SCLViewControllerData> = [:]
    //var vdata:Dictionary<UIView,SCLViewData> = [:]
    
    public init()
    {
        super.init(nibName:nil,bundle:nil)
        //self.delegate = self
    }
    
    public required init?(coder: NSCoder) 
    {
        super.init(coder:coder)
        //self.delegate = self
    }
    
    deinit
    {
       _viewDidUnload(self) 
       //vcdata=[:]
       //vdata=[:]
    }
    
    open func destroy()
    {
        self.controllerDestroyed(self)
        //vcdata=[:]
        //vdata=[:]
    }
    
    open func getControls(_ control:UIView?) -> [UIView] {return []}
    //open func encode(_ control:UIView?,archiver:SCLArchiverProtocol)  {}
    //open func decode(_ control:UIView?,unarchiver:SCLUnarchiverProtocol) {}     
    
    open func getDesignerSelection() -> UIView? {
        return nil
    }
    
    open func orientationChanged() {
        var f=self.view.frame //Application.window!.bounds
        f.size.width=CGFloat(SCLDeviceInfo.size.width)
        f.size.height=CGFloat(SCLDeviceInfo.size.height)
        //print("root vc \(self) orientationChanged f=\(f)")
        self.view.frame=f
        
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        //self.view.layoutIfNeeded()
    }
    
    open func controllerDestroyed(_ vc:UIViewController)
    {
        //self.vcdata.removeValue(forKey:vc)
        self._viewDidUnload(vc) 
    }
    
    func _viewDidLoad(_ vc:UIViewController)
    {
        //includeControllerStateValue(.csLoaded,vc)
        //self.vcdata[vc]?.performActionForControlEvent(event:.onLoaded, sender:vc, param:nil)
    }
    
    func _viewDidUnload(_ vc:UIViewController)
    {
        //self.vcdata[vc]?.performActionForControlEvent(event:.onUnloaded, sender:vc, param:nil)
        //excludeControllerStateValue(.csLoaded,vc)
        //self.vcdata.removeValue(forKey:vc)
    }
    
    func _viewDidAppear(_ vc:UIViewController, _ animated: Bool)
    {
        _controlDidAppear(vc.view,animated)
        
        //dbg("controller did show \(vc)")

        //includeControllerStateValue(.csShown,vc)
        //self.vcdata[vc]?.performActionForControlEvent(event:.onShow, sender:vc, param:nil)
    }
    
    func _viewDidDisappear(_ vc:UIViewController, _ animated: Bool)
    {
        _controlDidDisappear(vc.view,animated)
        
        //excludeControllerStateValue(.csShown,vc)
        //self.vcdata[vc]?.performActionForControlEvent(event:.onHide, sender:vc, param:nil)
        
        //dbg("controller did hide \(vc)")
    }
    
    func _shouldPerformSegue(_ vc:UIViewController, _ identifier: String, _ sender: Any?,_ def: Bool) -> Bool
    {
        return def; //TODO
    }
    
    func _controlDidLoad(_ v:UIView)
    {
        /*if (self.vdata[v]==nil)
        {
            return
        }
        
        //dbg("control did load \(v)") 
        includeViewStateValue(.csLoaded,v)
        self.vdata[v]?.performActionForControlEvent(event:.onLoaded, sender:v, param:nil)*/
    }
    
    func _controlDidUnload(_ v:UIView)
    {
        /*if (self.vdata[v]==nil)
        {
            return
        }
        
        //dbg("control did unload \(v)")
    
        self.vdata[v]?.performActionForControlEvent(event:.onUnloaded, sender:v, param:nil)
        excludeViewStateValue(.csLoaded,v)*/
        controlDestroyed(v)
    }
    
    func _controlDidAppear(_ v:UIView, _ animated: Bool)
    {
        /*if (self.vdata[v]==nil)
        {
            return
        }
        
        //dbg("control did show \(v)")
    
        includeViewStateValue(.csShown,v)
        self.vdata[v]?.performActionForControlEvent(event:.onShow, sender:v, param:nil)*/
    }
    
    func _controlDidDisappear(_ v:UIView, _ animated: Bool)
    {
        /*if (self.vdata[v]==nil)
        {
            return
        }
        
        //dbg("control did hide \(v)")
    
        excludeViewStateValue(.csShown,v)
        self.vdata[v]?.performActionForControlEvent(event:.onHide, sender:v, param:nil)*/
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    
    func addContentController(_ vc:UIViewController)
    {
        displayContentController(content:vc)
    }
    
    func removeContentController(_ vc:UIViewController)
    {
        hideContentController(content:vc)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        _viewDidLoad(self)
    }
    
    open func controlCreated(_ control:UIView)
    {
        /*if (self.vdata[control] == nil) {
            self.vdata[control] = SCLViewData()
        }*/
    }
    
    open func controlDestroyed(_ control:UIView)
    {
        control.removeFromSuperview()
        //self.vdata.removeValue(forKey:control)
        self.controlDidUnload(control) 
    }
    
    open func controlDidLoad(_ control:UIView)
    {
        _controlDidLoad(control)
    }
    
    open func controlDidUnload(_ control:UIView)
    {
        _controlDidUnload(control)
    }
    
    open func controlAdded(parent:UIView,control:UIView)
    {}
    
    open func controlRemoved(parent:UIView,control:UIView)
    {}

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _viewDidAppear(self,animated)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _viewDidDisappear(self,animated)
    }

    override open func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var shouldPerformSegue = super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
        shouldPerformSegue=_shouldPerformSegue(self, identifier, sender, shouldPerformSegue)
        return shouldPerformSegue
    }
    
    /*public func setControllerTarget<T: AnyObject>(target: T, 
                                        action: @escaping (T) -> (_ sender: AnyObject, _ param: AnyObject?) ->             
                                        (), event: SCLEvent, _ vc:UIViewController?=nil) 
    {
        var thevc=vc
        if (thevc == nil) {
            thevc=self
        }
        
        if (self.vcdata[thevc!] == nil) {
            self.vcdata[thevc!] = SCLViewControllerData()
        }
      
        self.vcdata[thevc!]!.setTarget(target,action:action,event:event)
    }
    
    public func hasControllerTargetAction(_ event: SCLEvent,_ vc:UIViewController?=nil) -> Bool
    {
        var thevc=vc
        if (thevc == nil) {
            thevc=self
        }
        
        if (self.vcdata[thevc!] == nil) {
            return false
        }
        
        return self.vcdata[thevc!]!.hasTargetForControlEvent(event:event)
    }
    
    public func performControllerTargetAction(_ event: SCLEvent, sender: AnyObject, param: AnyObject?, _ vc:UIViewController?=nil)
    {
        var thevc=vc
        if (thevc == nil) {
            thevc=self
        }
        
        if (self.vcdata[thevc!] == nil) {
            return
        }
        self.vcdata[thevc!]?.performActionForControlEvent(event:event,sender:sender,param:param) 
    }
    
    public func includeControllerStateValue(_ state: SCLState, _ vc:UIViewController?=nil)
    {
        var thevc=vc
        if (thevc == nil) {
            thevc=self
        }
        
        if (self.vcdata[thevc!] == nil) {
            self.vcdata[thevc!] = SCLViewControllerData()
        }
        self.vcdata[thevc!]?.stateInclude(state) 
    }
    
    public func excludeControllerStateValue(_ state: SCLState, _ vc:UIViewController?=nil)
    {
        var thevc=vc
        if (thevc == nil) {
            thevc=self
        } 
        
        if (self.vcdata[thevc!] == nil) {
            return
        }
        self.vcdata[thevc!]?.stateExclude(state) 
    }
    
    public func hasControllerState(_ state: SCLState, _ vc:UIViewController?=nil) -> Bool
    {
        var thevc=vc
        if (thevc == nil) {
            thevc=self
        } 
        
        if (self.vcdata[thevc!] == nil) {
            return false
        }
        return self.vcdata[thevc!]!.stateCheck(state) 
    }
    
    public func setViewTarget<T: AnyObject>(target: T, 
                                        action: @escaping (T) -> (_ sender: AnyObject, _ param: AnyObject?) ->             
                                        (), event: SCLEvent, _ v:UIView?) 
    {
        if (v == nil) {
            return
        }
        
        if (self.vdata[v!] == nil) {
            //self.vdata[v!] = SCLViewData()
            return //ignore this control, vdata created in controlCreated called from init of SCLView 
        }
      
        self.vdata[v!]!.setTarget(target,action:action,event:event)
    }
    
    public func hasViewTargetAction(_ event: SCLEvent,_ v:UIView?=nil) -> Bool
    {
        if (v == nil) {
            return false;
        }
        
        if (self.vdata[v!] == nil) {
            return false
        }
        
        return self.vdata[v!]!.hasTargetForControlEvent(event:event)
    }
    
    public func performViewTargetAction(_ event: SCLEvent, sender: AnyObject, param: AnyObject?, _ v:UIView?)
    {
        if (v == nil) {
            return;
        }
        
        if (self.vdata[v!] == nil) {
            return
        }
        self.vdata[v!]?.performActionForControlEvent(event:event,sender:sender,param:param) 
    }
    
    public func includeViewStateValue(_ state: SCLState, _ v:UIView?)
    {
        if (v == nil) {
            return
        }
        
        if (self.vdata[v!] == nil) {
            //self.vdata[v!] = SCLViewData()
            return //ignore this control, vdata created in controlCreated called from init of SCLView 
        }
        self.vdata[v!]?.stateInclude(state) 
    }
    
    public func excludeViewStateValue(_ state: SCLState, _ v:UIView?)
    {
        if (v == nil) {
            return
        } 
        
        if (self.vdata[v!] == nil) {
            return
        }
        self.vdata[v!]?.stateExclude(state) 
    }
    
    public func hasViewState(_ state: SCLState, _ v:UIView?) -> Bool
    {
        if (v == nil) {
            return false
        } 
        
        if (self.vdata[v!] == nil) {
            return false
        }
        return self.vdata[v!]!.stateCheck(state) 
    }*/
}

open class SCLViewController: UIViewController/*,SCLBaseProtocol*/ {
    public var flags:UInt8?
    public var root:SCLRootViewController?=Application!.rootViewController!
    public var name:String?
    
    public var tag:Int?
    
    public init()
    {
        super.init(nibName:nil,bundle:nil)
        //self.delegate = self
        self.Create()
    }
    
    public required init?(coder: NSCoder) 
    {
        super.init(coder:coder)
        //self.delegate = self
        self.Create()
    }
    
    public func loadedFromFile(_ designerInfo:Any)
    {
    }
    
    open func orientationChanged() {
        var f=self.view.frame 
        //if we have a parent, take size from parent, else from device
        if parent?.view != nil {
            let f1=parent!.view!.frame 
            f.size.width=f1.size.width
            f.size.height=f1.size.height
        }
        else {
            f.size.width=CGFloat(SCLDeviceInfo.size.width)
            f.size.height=CGFloat(SCLDeviceInfo.size.height)
        }
        self.view.frame=f
        //print("vc \(self) parent=\(parent) root=\(Application!.rootViewController) orientationChanged f=\(f)")
        
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        //self.view.layoutIfNeeded()
    }
    
    public func getName() -> String? {return name;}
    public func setName(_ value:String?) {name=value;}     
    
    open func getControls() -> [UIView] 
    {
       if (root != nil) {return root!.getControls(nil)}
       
       return []
    }
    //open func encode(archiver:SCLArchiverProtocol)  {root?.encode(nil,archiver:archiver)}
    //open func decode(unarchiver:SCLUnarchiverProtocol) {root?.decode(nil,unarchiver:unarchiver)} 
    
    open func Create()
    {
    }
    
    open func Destroy()
    {
    }
    
    deinit
    {
        self.Destroy()
        root?._viewDidUnload(self) 
        root=nil
    }
    
    open func destroy()
    {
        self.Destroy()
        root?.controllerDestroyed(self)
        root=nil
    }
    
    open override var view:UIView! {
        get {
            return super.view
        }

        set(newValue) {
            //var oldValue:UIView?=super.view;
            super.view=newValue;
            if (newValue != nil) {
                root?._controlDidLoad(newValue) 
                /*if (root!.hasControllerState(.csShown,self)) {
                    root?._controlDidAppear(newValue,false)
                }*/
            }
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        root?._viewDidLoad(self)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        root?._viewDidAppear(self,animated)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        root?._viewDidDisappear(self,animated)
    }

    override open func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var shouldPerformSegue = super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
        shouldPerformSegue=root!._shouldPerformSegue(self,identifier, sender,shouldPerformSegue)
        return shouldPerformSegue
    }
    
    /*public func setTarget<T: AnyObject>(_ target: T, 
                                        action: @escaping (T) -> (_ sender: AnyObject, _ param: AnyObject?) ->             
                                        (), event: SCLEvent) 
    {
        root?.setControllerTarget(target:target,action:action,event:event,self)
    }*/
    
    /////////////////////////////////////////////////////////////////////////////////////////////
}

private var ViewControllerAssociatedObjectHandle: UInt8 = 2

extension UIViewController {
    
    /// [MarcoPolo] Navigation item (details)
    public internal(set) var node: ViewNode? {
        get {
            guard let item = objc_getAssociatedObject(self, &ViewControllerAssociatedObjectHandle) as? ViewNode else {
                return nil
            }
            return item
        }
        set {
            if newValue==nil {
                objc_setAssociatedObject(self, &ViewControllerAssociatedObjectHandle, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return
            }
            objc_setAssociatedObject(self, &ViewControllerAssociatedObjectHandle, newValue!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}



















