import UIKit
import Foundation
import CoreRender

public var Application:SCLApplication?;

open class SCLApplication: NSObject, SUICLCRTRedirectDelegate {
    private var _dynamicProperties:[ObjectIdentifier:DynamicProperty]=[:]
    public var flags:UInt8?
    public let window: UIWindow?
    public var root:SCLRootViewController? {
        get {return self.rootViewController}
        set(v) {/*self.rootViewController=v*/}
    }
    public var content:UIViewController?
    public var rootViewController: SCLRootViewController?
    public var ignoreFaceOrientations:Bool=true
    public let appdelegate: SCLAppDelegate?
    public var name:String?
    public var lasttouch:UIView? //used internally for designer
    public var onDebug:((String) -> Void)?=nil
    public var orientation:UIDeviceOrientation?=nil
    public var canReuseNodes:Bool=true
    public var hostingViews:[HostingView]=[]
    public var buildCount=0
    private var stateBuildCount=0
    public var debugMsgs:String=""
    public var debugHost:UITextView?=nil
    public var environment=EnvironmentValues()
    public var buildEnvironment:EnvironmentValues?=nil
    
    //fileprivate var onShow: TargetAction?
    //fileprivate var onHide: TargetAction?
    //fileprivate var onValueChanged: TargetAction?

    public required init(window: UIWindow?, appdelegate: SCLAppDelegate?,rootvc:SCLRootViewController?=nil) {
        //self.application = application;
        self.window = window
        self.appdelegate = appdelegate
        if (rootvc != nil) {self.rootViewController=rootvc!}
        else {self.rootViewController=SCLRootViewController()}
        super.init()
        Application=self
        NotificationCenter.default.addObserver(self,selector:#selector(self.didOrientationChange(_:)),name:UIDevice.orientationDidChangeNotification,object:nil)
    }
    
    @objc func didOrientationChange(_ notification:Notification){
        if self.orientation != nil && self.orientation!==UIDevice.current.orientation {return} //no change
        let old=self.orientation
        self.orientation=UIDevice.current.orientation
        
        //ignore faceup and facedown orientations?
        if ignoreFaceOrientations {
            if old == .faceUp && self.orientation == .faceDown {return}
            if old == .faceDown && self.orientation == .faceUp {return}
            
            if old == .landscapeLeft && self.orientation == .faceDown {return}
            if old == .landscapeLeft && self.orientation == .faceUp {return}
            if old == .landscapeRight && self.orientation == .faceDown {return}
            if old == .landscapeRight && self.orientation == .faceUp {return}
            
            if old == .faceUp && self.orientation == .landscapeLeft {return}
            if old == .faceUp && self.orientation == .landscapeRight {return}
            if old == .faceDown && self.orientation == .landscapeLeft {return}
            if old == .faceDown && self.orientation == .landscapeRight {return}
        }
        
        //if old != nil {print("Orientation changed from \(old!.rawValue) to \(self.orientation!.rawValue)")}
        
        for v in hostingViews {
            //print("rebuilding hosting view:\(v)")
            v.setNeedsBuild()
        }
        
        rootViewController?.orientationChanged()
        
        //return;
        //alert("did","orientationchanged")
        
        /*if let tb=self.content as? SCLTabBarController {
            tb.orientationChanged()
        }
        else if let pv=self.content as? SCLPageViewController {
            pv.orientationChanged()
        }
        else */
        //alert("vc \(type(of:self)) orientationChanged","content=\(self.content)")
        if let vc=self.content as? SCLRootViewController {
            if vc != rootViewController {
                //print("content root orienrationChange")
                vc.orientationChanged()
            }
        }
        else if let vc=self.content as? SCLViewController {
            //print("content orienrationChange")
            vc.orientationChanged()
        }
        
        //self.onValueChanged?.performAction(self)
        
    }
    
    public func setNeedsBuild() {
        stateBuildCount=stateBuildCount+1
        let buildCount=stateBuildCount
        DispatchQueue.main.async {
            if self.stateBuildCount>buildCount {return} //reconcile multiple changes
            for v in self.hostingViews {
                //alert("stateobject value change","willchange");
                v.setNeedsBuild()
            }
        }
    }
    
    public func loadedFromFile(_ designerInfo:Any)
    {
    }
    
    public func getName() -> String? {return name;}
    public func setName(_ value:String?) {name=value;}      
    
    open func getControls() -> [UIView] 
    {
       if (rootViewController != nil) {return rootViewController!.getControls(nil)}
       
       return []
    }
    //open func encode(archiver:SCLArchiverProtocol)  {rootViewController?.encode(nil,archiver:archiver)}
    //open func decode(unarchiver:SCLUnarchiverProtocol) {rootViewController?.decode(nil,unarchiver:unarchiver)}         
    
    /*public func setTarget<T: AnyObject>(_ target: T, 
                                        action: @escaping (T) -> (_ sender: AnyObject, _ param: AnyObject?) ->             
                                        (), event: SCLEvent) 
    {
        let ta:TargetAction=TargetActionWrapper(target: target, action: action)
        
        switch(event)
        {
            case .onShow:
                self.onShow = ta
            case .onHide:
                self.onHide = ta
            case .onValueChanged:
                self.onValueChanged = ta
            default:dbg("Unknown target for SCLApplication.setTarget:\(event)")
        } //switch
    }*/

    open func create() -> UIViewController? {
        return nil; //use default rootViewController 
    }
    
    public func dbg(_ txt: String)
    {
        appdelegate?.dbg(txt+"\n")
        onDebug?(txt)
    }
    
    public func print(_ s:String) {dbg(s)}
    
    open func getDocDir() -> String {
        let paths=FileManager.default.urls(for:.documentDirectory,in:.userDomainMask)
        return paths[0].path
    }
    
    open func getBundleDir() -> String {
        return Bundle.main.bundlePath
    }
    
    public func registerDynamicProperty(_ p:Any) {
        if let dp = p as? DynamicProperty {
            //print("register dynamic property \(type(of:p))")
            _dynamicProperties[ObjectIdentifier(type(of:p))]=dp
        }
    }
    
    public func updateDynamicProperties() {
        //print("dynamic properties:\(_dynamicProperties)")
        for (k,v) in _dynamicProperties {v.update()}
    }
    
    func switchRootViewController(rootViewController: SCLRootViewController, animated: Bool=false, completion: (() -> Void)?=nil) {
        if animated {
            UIView.transition(with:window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                self.window!.rootViewController = rootViewController
                self.rootViewController=rootViewController
                UIView.setAnimationsEnabled(oldState)
            }, completion: { (finished: Bool) -> () in
                if completion != nil {
                    completion!()
                }
            })
        } else {
            window!.rootViewController = rootViewController
            self.rootViewController=rootViewController
        }
    }
}


open class SCLAppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?
    public var app: SCLApplication?
    
    open func dbg(_ txt: String) {
        if let app=self.app {
            app.debugMsgs=app.debugMsgs+txt
            //alert("appdelegate dbg",app.debugMsgs)
            DispatchQueue.main.async {
                app.debugHost?.text=app.debugMsgs
            }
        }
    }

    open func setup() 
    {
        self.app = SCLApplication(window:self.window, appdelegate:self);
    }
    
    open func application(_ app: UIApplication, open url: URL, 
                          options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool 
    {
        var host:String = url.host!;
        host=host.removingPercentEncoding!
    
        return true;
    }
    
    open func application(_ application: UIApplication, 
                          didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) 
                          -> Bool 
    {          
        // Override point for customization after application launch.
        self.window = self.window ?? UIWindow()
        self.window!.backgroundColor = .black
        
        setup()
        
        /*if let exception = UserDefaults.standard.object(forKey: "ExceptionHandler") as? [String] 
        {
            var exceptions = ""
            for e in exception {
                exceptions = exceptions + e + "\n"
            }
            dbg("Error was occured on previous session! \n")
            dbg(exceptions)
            dbg("\n\n-------------------------")
            //alert("Error was occured on previous session!", exceptions)
            UserDefaults.standard.removeObject(forKey: "ExceptionHandler")
            UserDefaults.standard.synchronize()
        }*/
        
        
        NSSetUncaughtExceptionHandler { exception in
            Application?.dbg("Uncaught exception")
            Application?.dbg("Error Handling:\(exception)")
            var exceptions = ""
            for e in exception.callStackSymbols {
                exceptions = exceptions + e + "\n"
            }
            
            Application?.dbg("Error Handling callStackSymbols:\n\(exceptions)")

            //UserDefaults.standard.set(exception.callStackSymbols, forKey: "ExceptionHandler")
            //UserDefaults.standard.synchronize()
        }
        
        //dbg(txt:"test")
        
        let vc:UIViewController?=self.app!.create() //this should setup the root view controller
        self.app!.content=vc
        
        if vc is SCLRootViewController {
            //print("main vc is rootview")
            self.app!.rootViewController=vc as! SCLRootViewController
        }
        else {self.app!.rootViewController!.displayContentController(content:vc!)}
        
        self.window!.rootViewController = self.app!.rootViewController
        
        self.window!.makeKeyAndVisible()
        
        //dbg("application launch ok")

        return true
    }

    open func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    open func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }

    open func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. 
        //This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS 
        //message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. 
        //Games should use this method to pause the game.
        //Application?.onHide?.performAction(self)
        Application?.environment.scenePhase = .inactive
    }

    open func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough 
        //application state information to restore your application to its current state in case it is 
        //terminated later.
        // If your application supports background execution, this method is called instead of 
        //applicationWillTerminate: when the user quits.
        //Application?.onHide?.performAction(self)
        Application?.environment.scenePhase = .background
    }

    open func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo 
        //many of the changes made on entering the background.
    }

    open func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. 
        //If the application was previously in the background, optionally refresh the user interface.
        //Application?.onShow?.performAction(self)
        Application?.environment.scenePhase = .active
    }

    open func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. 
        //See also applicationDidEnterBackground:.
        //Application?.onHide?.performAction(self)
    }

    open func application(_ application: UIApplication,handleOpen url: URL) -> Bool {
        return true
    }
}

public protocol SUICLCRTRedirectDelegate {
    func print(_ s:String)
}

@objc public class SUICLCRTRedirect:NSObject
{
    static var inputPipe:Pipe?=nil
    static var outputPipe:Pipe?=nil
    //var pipe = Pipe()
    //var pipe2 = Pipe()
    public static var delegate:SUICLCRTRedirectDelegate?=nil

    public init(delegate:SUICLCRTRedirectDelegate?=nil) {
        SUICLCRTRedirect.delegate=delegate
        if delegate != nil {SUICLCRTRedirect.openConsolePipe()}
    }

    public static func openConsolePipe () {
       setvbuf(stdout, nil, _IONBF, 0)
       setvbuf(stderr, nil, _IONBF, 0)
       // open a pipe to consume data sent into STDOUT and STDERR
       inputPipe = Pipe()
       // open a pipe to output data back to STDOUT
       outputPipe = Pipe()
       guard let inputPipe = inputPipe, let outputPipe = outputPipe else {
            return
       }

       let inputPipeReadHandle = inputPipe.fileHandleForReading

       // Redirect data sent into the output pipe into STDOUT, too.
       dup2(STDOUT_FILENO, outputPipe.fileHandleForWriting.fileDescriptor)

       // Redirect data sent into STDOUT and STDERR into the input pipe, too.
       dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
       dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)

       // listen for the readCompletionNotification.
       NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveReadCompletionNotification),
                                               name: FileHandle.readCompletionNotification,
                                               object: inputPipeReadHandle)

       // We want to be notified of any data coming into our input pipe.
       inputPipeReadHandle.readInBackgroundAndNotify()
       
       print("crt redirected")

       /*
       setvbuf(stdout, nil, _IONBF, 0)
       dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
       // listening on the readabilityHandler
       pipe.fileHandleForReading.readabilityHandler = {
         [weak self] handle in
           let data = handle.availableData
           let str = String(data: data, encoding: .ascii) ?? "<Non-ascii data of size\(data.count)>\n"
           #if NATIVE
           async(dispatch_get_main_queue()) {
               self?.delegate?.print(str)
           }
           #else
           DispatchQueue.main.async {
             self?.delegate?.print(str)
           }
           #endif
       }
       
       setvbuf(stderr, nil, _IONBF, 0)
       dup2(pipe2.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
       // listening on the readabilityHandler
       pipe2.fileHandleForReading.readabilityHandler = {
         [weak self] handle in
           let data = handle.availableData
           let str = String(data: data, encoding: .ascii) ?? "<Non-ascii data of size\(data.count)>\n"
           #if NATIVE
           async(dispatch_get_main_queue()) {
               self?.delegate?.print(str)
           }
           #else
           DispatchQueue.main.async {
             self?.delegate?.print(str)
           }
           #endif
       }
       */
    }
    
    @objc static func didReceiveReadCompletionNotification(notification: Notification) {
        // Need to call this to keep getting notified.
        inputPipe?.fileHandleForReading.readInBackgroundAndNotify()

        if let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data,
           let str = String(data: data, encoding: .utf8) {

            // Write the data back into the output pipe.
            // The output pipe's write file descriptor points to STDOUT,
            // which makes the logs show up in the Xcode console.
            outputPipe?.fileHandleForWriting.write(data)

            //writeToLogfile(str.trimmingCharacters(in: .whitespacesAndNewlines))
            DispatchQueue.main.async {
               self.delegate?.print(str.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }
}


public struct SCLDeviceInfo {
    public struct orientation {
        public static var isLandscape: Bool {
            return UIDevice.current.orientation.isValidInterfaceOrientation ? UIDevice.current.orientation.isLandscape : UIApplication.shared.statusBarOrientation.isLandscape
        }
        
        public static var isPortrait: Bool {
            return UIDevice.current.orientation.isValidInterfaceOrientation ? UIDevice.current.orientation.isPortrait : UIApplication.shared.statusBarOrientation.isPortrait
        }
    }
    
    public struct size {
        public static var width: Double {
            let w=Double(UIScreen.main.nativeBounds.width/UIScreen.main.nativeScale)
            let h=Double(UIScreen.main.nativeBounds.height/UIScreen.main.nativeScale)
            if (w>h) {
                if (SCLDeviceInfo.orientation.isLandscape) {return w}
                else {return h}
            }
            
            if (SCLDeviceInfo.orientation.isLandscape) {return h}
            else {return w}
        }
        
        public static var height: Double {
            let w=Double(UIScreen.main.nativeBounds.width/UIScreen.main.nativeScale)
            let h=Double(UIScreen.main.nativeBounds.height/UIScreen.main.nativeScale)
            if (h>w) {
                if (SCLDeviceInfo.orientation.isLandscape) {return w}
                else {return h}
            }
            
            if (SCLDeviceInfo.orientation.isLandscape) {return h}
            else {return w}
        }
    }
}


public func alert(_ title:String,_ msg:String)
{
    //let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)

//alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
//alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

    //self.present(alert, animated: true)
    
    let alert = UIAlertView()
    alert.title = title
    alert.message = msg
    alert.addButton(withTitle:"Ok")
    alert.show()
    
    //let alertView = UIAlertController(title: "alert", message: msg, preferredStyle: .alert)
    //alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    //presentViewController(alertView, animated: true, completion: nil)
}

public func dbg(_ msg:String) {
    Application?.dbg(msg)
}

public enum ScenePhase {
    case active
    case inactive
    case background
}

extension ScenePhase: CustomStringConvertible {
    public var description : String { 
    switch self {
    // Use Internationalization, as appropriate.
    case .active: return "Active"
    case .inactive: return "Inactive"
    case .background: return "Background"
    }
  }
}

private struct ScenePhaseEnvironmentKey: EnvironmentKey {
    static let defaultValue: ScenePhase = .active
}

extension EnvironmentValues {
    public var scenePhase: ScenePhase {
        get { self[ScenePhaseEnvironmentKey.self] }
        set { self[ScenePhaseEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func scenePhase(_ value: ScenePhase) -> some View {
        environment(\.scenePhase, value)
    }
}









