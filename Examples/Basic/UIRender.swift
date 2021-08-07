import UIKit
import SwiftUIX

class TMyApplication: SCLApplication {
    var vc: UIViewController?
    //var forms:[SCLStoredForm]=[]
    //var mainform:SCLStoredForm?
    
    override public func getDocDir() -> String {
        return "/var/mobile/Documents"
    }

    override func create() -> UIViewController? {
        //if SCLControlsRegistration==false {return nil}
        //if SCLExtControlsRegistration==false {return nil}
        
        _=SUICLCRTRedirect(delegate:self)
        
        _=super.create();
        /*RegisterClass(TMyApplication.self, designerinfo:nil)
        let r=iMath2createForms()
        self.mainform=r.1
        self.forms=r.0
        if mainform?.isdesignTabbed == true {
            let tbc=SCLTabBarController()
            vc=tbc
            tbc.setTarget(self, action: TMyApplication.onGetTabPage, event: .onGetValue)
        }
        else {vc=mainform}*/
        vc=TMainForm()
        return vc
    }
}



@UIApplicationMain
class TMyAppDelegate: SCLAppDelegate {
 
    override func setup() {
        let App:TMyApplication = TMyApplication(window:self.window, appdelegate:self)
        self.app = App;
    }
}

















