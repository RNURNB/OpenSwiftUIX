import Foundation
import Combine
import UIKit
import CoreRender

//  Copyright © 2020 Yasin TURKOGLU.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

/// Options that define how the detail controller is displayed on screen.
///
public enum USCDetailAppearance {
    /// - Detail controller always be visible in portrait orientation for all devices
    /// except phones and user can toggle it to hide/show.
    /// - Detail controller always be visible in landscape orientation for all devices
    /// and user can toggle it to hide/show.
    ///
    case auto

    /// - Detail controller always be visible in all orientations for all devices
    /// and user can toggle it to hide/show.
    /// - Orientation changes make it visible if previously hidden.
    ///
    case visibleInit

    /// - Detail controller always be invisible in all orientations for all devices
    /// and user can toggle it to show/hide.
    /// - Orientation changes make it invisible if previously shown.
    ///
    case invisibleInit

    /// - Detail controller always be visible in all orientations for all devices
    /// and user can toggle it to hide/show.
    /// - Visibility won't affected by orientation changes.
    ///
    case visibleInitAndPreserveTheStatus

    /// - Detail controller always be invisible in all orientations for all devices
    /// and user can toggle it to show/hide.
    /// - Visibility won't affected by orientation changes.
    ///
    case invisibleInitAndPreserveTheStatus
}

/// Options that define the displaying direction of the detail controller on screen.
///
public enum USCDetailDirection {
    /// Detail controller appears from the left side of screen.
    ///
    case leading
    /// Detail controller appears from the right side of screen.
    ///
    case trailing
}

/// Options that define the visibility of the detail controller on screen.
///
public enum USCDetailVisibility {
    /// Detail controller visible on screen.
    ///
    case visible

    /// Detail controller invisible on screen.
    ///
    case invisible
}

public enum USCAnimationPreference {
    case auto
    case none
    case noneWithoutCompletion
}

public enum USCHorizontalSwipeState {
    case began(point: CGFloat)
    case moved(direction: CGFloat, maximumChanges: CGFloat, distance: CGFloat)
    case ended
}

public enum USCSwipeOccurrence {
    case locked
    case trailingOpeningSequence
    case trailingClosingSequence
    case leadingOpeningSequence
    case leadingClosingSequence
}

protocol USCDataSourceProtocol {
    func getCurrentVisibility() -> USCDetailVisibility
    func detailToggle(animated: Bool)
    func disposeTheController()
    var forceToHide: Bool { get set }
}

public class USCDataSource {
    typealias AnimationProperties = (duration: TimeInterval,
        options: UIView.AnimationOptions,
        forwardDampingRatio: CGFloat,
        rewindDampingRatio: CGFloat,
        velocity: CGFloat)
    internal lazy var universalSplitController = SCLUniversalSplitController()
    private(set) var parentController: UIViewController?
    private(set) var masterController: UIViewController?
    private(set) var masterWillEmbedInNavController: Bool = false
    private(set) var detailController: UIViewController?
    private(set) var detailWillEmbedInNavController: Bool = false
    private(set) var appearance: USCDetailAppearance = .auto
    private(set) var direction: USCDetailDirection = .trailing
    private(set) var contentBlockerColor: UIColor?
    private(set) var contentBlockerBlur: UIBlurEffect.Style?
    private(set) var contentBlockerInteractions: Bool?
    private(set) var customWidthForPortrait: CGFloat?
    private(set) var widthInPercentageForPortrait: Bool = false
    private(set) var customWidthForLandscape: CGFloat?
    private(set) var widthInPercentageForLandscape: Bool = false
    private(set) var overlapWhileInPortrait: Bool = false
    private(set) var overlapWhileInLandscape: Bool = false
    private(set) var visibilityWillStartBlock: ((USCDetailVisibility) -> Void)?
    private(set) var visibilityAnimationBlock: ((USCDetailVisibility) -> Void)?
    private(set) var visibilityDidEndBlock: ((USCDetailVisibility) -> Void)?
    private(set) var swipeable: Bool = false
    private(set) var detailBackgroundColor: UIColor?
    private(set) var detailBackgroundBlur: UIBlurEffect.Style?
    private(set) var couldBeBlockedByOtherEventsIfAny: Bool = false
    private(set) var invokeAppearanceMethods: Bool = false
    private(set) var animationPropsForPortrait = AnimationProperties(duration: 0.35,
                                                                          options: .curveEaseInOut,
                                                                          forwardDampingRatio: 1.0,
                                                                          rewindDampingRatio: 1.0,
                                                                          velocity: 1.0)
    private(set) var animationPropsForLandscape = AnimationProperties(duration: 0.35,
                                                                           options: .curveEaseInOut,
                                                                           forwardDampingRatio: 1.0,
                                                                           rewindDampingRatio: 1.0,
                                                                           velocity: 1.0)
    /// Builder object should be initiated with `parentController` parameter
    /// to specify where the USController will append as child controller.
    ///
    public class Builder {

        private let dataSource = USCDataSource()
        /// Builder object should be initiated with `parentController` parameter
        /// to specify where the USController will append as child controller.
        ///
        /// - Parameters:
        ///     - parentController: The controller where the USController will append as child controller.
        ///
        public init(parentController: UIViewController?) {
            dataSource.parentController = parentController
        }
        /// It specifies the controller which will be placed in master controller division of the screen.
        ///
        /// - Parameters:
        ///     - controller: The controller which will be placed in.
        ///     - embedInNavController: If parameter takes true,
        ///     the controller embed in to the navigation controller before place in. Default value is false.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func setMasterController(_ controller: UIViewController, embedInNavController: Bool = false) -> Builder {
            dataSource.masterController = controller
            dataSource.masterWillEmbedInNavController = embedInNavController
            return self
        }
        /// It specifies the controller which will be placed in master controller division of the screen.
        ///
        /// - Parameters:
        ///     - storyboardName: The name of the storyboard resource file without the filename extension.
        ///     - bundle: The bundle containing the storyboard file and its related resources.
        ///     If you specify nil, this method looks in the main bundle of the current application.
        ///     - identifier: An identifier string that uniquely identifies the view controller in the storyboard file.
        ///     At design time, put this same string in the Storyboard ID attribute of your view controller
        ///     in Interface Builder. This identifier is not a property of the view controller object itself.
        ///     The storyboard uses it to locate the appropriate data for your view controller.
        ///     If the specified identifier does not exist in the storyboard file, this method raises an exception.
        ///     If you specify nil, this method looks in the initial controller of the storyboard.
        ///     - embedInNavController: If parameter takes true,
        ///     the controller embed in to the navigation controller before place in. Default value is false.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func setMasterControllerFrom(storyboardName: String,
                                            bundle: Bundle? = nil,
                                            identifier: String? = nil,
                                            embedInNavController: Bool = false) -> Builder {
            let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
            if let identifier = identifier {
                dataSource.masterController = storyboard.instantiateViewController(withIdentifier: identifier)
            } else {
                dataSource.masterController = storyboard.instantiateInitialViewController()!
            }
            dataSource.masterWillEmbedInNavController = embedInNavController
            return self
        }
        /// It specifies the controller which will be placed in detail controller division of the screen.
        ///
        /// - Parameters:
        ///     - controller: The controller which will be placed in.
        ///     - embedInNavController: If parameter takes true,
        ///     the controller embed in to the navigation controller before place in. Default value is false.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func setDetailController(_ controller: UIViewController, embedInNavController: Bool = false) -> Builder {
            dataSource.detailController = controller
            dataSource.detailWillEmbedInNavController = embedInNavController
            return self
        }
        /// It specifies the controller which will be placed in detail controller division of the screen.
        ///
        /// - Parameters:
        ///     - storyboardName: The name of the storyboard resource file without the filename extension.
        ///     - bundle: The bundle containing the storyboard file and its related resources.
        ///     If you specify nil, this method looks in the main bundle of the current application.
        ///     - identifier: An identifier string that uniquely identifies the view controller in the storyboard file.
        ///     At design time, put this same string in the Storyboard ID attribute of your view controller
        ///     in Interface Builder. This identifier is not a property of the view controller object itself.
        ///     The storyboard uses it to locate the appropriate data for your view controller.
        ///     If the specified identifier does not exist in the storyboard file, this method raises an exception.
        ///     If you specify nil, this method looks in the initial controller of the storyboard.
        ///     - embedInNavController: If parameter takes true,
        ///     the controller embed in to the navigation controller before place in. Default value is false.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func setDetailControllerFrom(storyboardName: String,
                                            bundle: Bundle? = nil,
                                            identifier: String? = nil,
                                            embedInNavController: Bool = false) -> Builder {
            let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
            if let identifier = identifier {
                dataSource.detailController = storyboard.instantiateViewController(withIdentifier: identifier)
            } else {
                dataSource.detailController = storyboard.instantiateInitialViewController()!
            }
            dataSource.detailWillEmbedInNavController = embedInNavController
            return self
        }
        /// It specifies the option that define how the detail controller is displayed on the screen.
        ///
        /// - Parameters:
        ///     - appearance: The option that specify how detail controller will display.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        /// - If  this method won't be included in builder chain, default value will be `auto` for detail controller.
        ///
        public func setAppearance(_ appearance: USCDetailAppearance) -> Builder {
            dataSource.appearance = appearance
            return self
        }
        /// It specifies the option that define the displaying direction of the detail controller on screen.
        ///
        /// - Parameters:
        ///     - direction: The option that specify the displaying direction of the detail controller.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        /// - If  this method won't be included in builder chain,
        /// default value will be `trailing` for detail controller.
        ///
        public func setDirection(_ direction: USCDetailDirection) -> Builder {
            dataSource.direction = direction
            return self
        }
        /// It blocks user interactions of the master controller with a view to be placed on
        /// top of the master controller while both in detail and master controller appears on the screen.
        ///
        /// - Parameters:
        ///     - color: Custom color of content blocker.
        ///     - opacity: Custom opacity of content blocker. The opacity value specified as a value f
        ///     rom 0.0 to 1.0. Alpha values below 0.0 are interpreted as 0.0,
        ///     and values above 1.0 are interpreted as 1.0
        ///     - blur: The intensity of the blur effect. See UIBlurEffect.Style for valid options.
        ///     - allowInteractions: If parameter takes true, it allows the user interactions while blocker displayed.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func showBlockerOnMaster(color: UIColor,
                                        opacity: CGFloat = 1.0,
                                        blur: UIBlurEffect.Style? = nil,
                                        allowInteractions: Bool = false) -> Builder {
            dataSource.contentBlockerColor = color.withAlphaComponent(opacity)
            dataSource.contentBlockerBlur = blur
            dataSource.contentBlockerInteractions = allowInteractions
            return self
        }
        /// It sets a background color and optionally apply a blur effect to the background of detail controller.
        ///
        /// - Parameters:
        ///     - color: Custom color for detail controller background.
        ///     - opacity: Custom opacity of detail controller background. The opacity value specified as a value f
        ///     rom 0.0 to 1.0. Alpha values below 0.0 are interpreted as 0.0,
        ///     and values above 1.0 are interpreted as 1.0
        ///     - blur: The intensity of the blur effect. See UIBlurEffect.Style for valid options.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func setDetailBackground(color: UIColor,
                                        opacity: CGFloat = 1.0,
                                        blur: UIBlurEffect.Style? = nil) -> Builder {
            dataSource.detailBackgroundColor = color.withAlphaComponent(opacity)
            dataSource.detailBackgroundBlur = blur
            return self
        }
        /// It makes the detail controller swipeable with UI Gestures to hide or show it.
        ///
        /// - Parameters:
        ///     - couldBeBlockedByOtherEventsIfAny: If parameter takes true, it allows to suppress
        ///     recognizer responsible for the detail controller toggling while other gesture recognizers,
        ///     touch or press events are in use on placed controllers. Default value is false
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func swipeable(couldBeBlockedByOtherEventsIfAny: Bool = false) -> Builder {
            dataSource.swipeable = true
            dataSource.couldBeBlockedByOtherEventsIfAny = couldBeBlockedByOtherEventsIfAny
            return self
        }
        /// It allows calling the appearance methods (viewWillAppear, viewDidAppear,
        /// viewWillDisappear, viewDidDisappear) of master and detail controllers
        /// which invokes by their visibility changes.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func invokeAppearanceMethods() -> Builder {
            dataSource.invokeAppearanceMethods = true
            return self
        }
        /// It overlap detail controller over master controller rather than splitting them while in portrait.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func overlapWhileInPortrait() -> Builder {
            dataSource.overlapWhileInPortrait = true
            return self
        }
        /// It overlap detail controller over master controller rather than splitting them while in landscape.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func overlapWhileInLandscape() -> Builder {
            dataSource.overlapWhileInLandscape = true
            return self
        }
        /// It allows you to define custom width for detail controller while in portrait.
        ///
        /// - Parameters:
        ///     - customWidth: Width or percent value to define custom width for detail while in portrait.
        ///     - inPercentage: If parameter takes true, "customWidth" parameter will takes value
        ///     between 0 .0 - 100.0 for defining detail width as percentage of screen width while in portrait.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        /// - Custom width can not be greater than half of the screen width
        /// while in portrait and smaller than 100px.
        /// - If this method won't be included in builder chain, default width value for the detail controller
        /// while in portrait will vary according to current device type and all cases were explained below:
        ///
        /// **Phones =>** Screen width
        ///
        /// **Pads =>** If half of the screen width is smaller than 414px,
        /// it will be equal to the half of the screen width. Otherwise it will be 414px.
        ///
        public func portraitCustomWidth(_ customWidth: CGFloat, inPercentage: Bool = false) -> Builder {
            dataSource.customWidthForPortrait = CGFloat(fabsf(Float(customWidth)))
            dataSource.widthInPercentageForPortrait = inPercentage
            return self
        }
        /// It allows you to define custom width for detail controller while in landscape.
        ///
        /// - Parameters:
        ///     - customWidth: Width or percent value to define custom width for detail while in landscape.
        ///     - inPercentage: If parameter takes true, "customWidth" parameter will takes value
        ///     between 0 .0 - 100.0 for defining detail width as percentage of screen width while in landscape.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        /// - If this method won't be included in builder chain, default width value for the detail controller
        /// while in landscape will vary device type independent and all cases were explained below:
        ///
        /// ** If screen width while in portrait greater than half of the screen width while in landscape:**
        ///
        /// **case 1 =>** If half of the screen width greater than 414px while in landscape,
        /// so detail controller width will be equal to 414px.
        ///
        /// **case 2 =>** If half of the screen width smaller than 414px while in landscape,
        /// than detail controller width will be equal to half of the screen width while in landscape.
        ///
        /// ** If screen width while in portrait smaller than half of the screen width while in landscape:**
        ///
        /// **case 1 =>** If screen width greater than 414px while in portrait,
        /// so detail controller width will be equal to 414px.
        ///
        /// **case 2 =>**If screen width smaller than 414px while in portrait,
        /// than detail controller width will be equal to screen width while in portrait.
        ///
        public func landscapeCustomWidth(_ customWidth: CGFloat, inPercentage: Bool = false) -> Builder {
            dataSource.customWidthForLandscape = CGFloat(fabsf(Float(customWidth)))
            dataSource.widthInPercentageForLandscape = inPercentage
            return self
        }
        /// Detail controller visibility changes can be observable by this method's closure arguments.
        ///
        /// - Parameters:
        ///     - willStartBlock: A block object to be executed before the visibility animation starts.
        ///     This block has no return value and takes a single enum argument that indicates
        ///     target visibility of detail controller when animation actually finished. This parameter may be NULL.
        ///     
        ///     - animationBlock: A block object to be executed when the detail controller
        ///     visibility change animation ongoing. This block has no return value and takes a
        ///     single enum argument that indicates target visibility of detail controller
        ///     when animation actually finished. This parameter may be NULL.
        ///     
        ///     - didEndBlock: A block object to be executed when the visibility animation ends.
        ///     This block has no return value and takes a single enum argument that indicates
        ///     final visibility of detail controller when animation actually finished. This parameter may be NULL.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func visibilityChangesListener(
            willStartBlock: ((USCDetailVisibility) -> Void)? = nil,
            animationBlock: ((USCDetailVisibility) -> Void)? = nil,
            didEndBlock: ((USCDetailVisibility) -> Void)? = nil
        ) -> Builder {
            dataSource.visibilityWillStartBlock = willStartBlock
            dataSource.visibilityAnimationBlock = animationBlock
            dataSource.visibilityDidEndBlock = didEndBlock
            return self
        }
        /// Its set detail controller's toggling animation while in portrait
        /// using a timing curve corresponding to the motion of a physical spring.
        ///
        /// - Parameters:
        ///     - duration: The total duration of the animations, measured in seconds.
        ///     If you specify a negative value or 0, the changes are made without animating them.
        ///
        ///     - options: A mask of options indicating how you want to perform the animations.
        ///     For a list of valid constants, see UIView.AnimationOptions.
        ///
        ///     - forwardDampingRatio: The damping ratio for the spring animation while detail controller opening.
        ///     To smoothly decelerate the animation without oscillation, use a value of 1.
        ///     Employ a damping ratio closer to zero to increase oscillation.
        ///     
        ///     - rewindDampingRatio:The damping ratio for the spring animation while detail controller closing.
        ///     To smoothly decelerate the animation without oscillation, use a value of 1.
        ///     Employ a damping ratio closer to zero to increase oscillation.
        ///
        ///     - velocity: The initial spring velocity. For smooth start to the animation,
        ///     match this value to the view’s velocity as it was prior to attachment.
        ///     A value of 1 corresponds to the total animation distance traversed in one second.
        ///     For example, if the total animation distance is 200 points and you want the start of the animation
        ///     to match a view velocity of 100 pt/s, use a value of 0.5.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func portraitAnimationProperties(duration: TimeInterval,
                                                options: UIView.AnimationOptions = .curveEaseInOut,
                                                forwardDampingRatio: CGFloat = 1.0,
                                                rewindDampingRatio: CGFloat = 1.0,
                                                velocity: CGFloat = 1.0) -> Builder {
            dataSource.animationPropsForPortrait = AnimationProperties(duration: duration,
                                                                            options: options,
                                                                            forwardDampingRatio: forwardDampingRatio,
                                                                            rewindDampingRatio: rewindDampingRatio,
                                                                            velocity: velocity)
            return self
        }
        /// Its set detail controller's toggling animation while in landscape
        /// using a timing curve corresponding to the motion of a physical spring.
        ///
        /// - Parameters:
        ///     - duration: The total duration of the animations, measured in seconds.
        ///     If you specify a negative value or 0, the changes are made without animating them.
        ///
        ///     - options: A mask of options indicating how you want to perform the animations.
        ///     For a list of valid constants, see UIView.AnimationOptions.
        ///
        ///     - forwardDampingRatio: The damping ratio for the spring animation while detail controller opening.
        ///     To smoothly decelerate the animation without oscillation, use a value of 1.
        ///     Employ a damping ratio closer to zero to increase oscillation.
        ///
        ///     - rewindDampingRatio:The damping ratio for the spring animation while detail controller closing.
        ///     To smoothly decelerate the animation without oscillation, use a value of 1.
        ///     Employ a damping ratio closer to zero to increase oscillation.
        ///
        ///     - velocity: The initial spring velocity. For smooth start to the animation,
        ///     match this value to the view’s velocity as it was prior to attachment.
        ///     A value of 1 corresponds to the total animation distance traversed in one second.
        ///     For example, if the total animation distance is 200 points and you want the start of the animation
        ///     to match a view velocity of 100 pt/s, use a value of 0.5.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func landscapeAnimationProperties(duration: TimeInterval,
                                                 options: UIView.AnimationOptions = .curveEaseInOut,
                                                 forwardDampingRatio: CGFloat = 1.0,
                                                 rewindDampingRatio: CGFloat = 1.0,
                                                 velocity: CGFloat = 1.0) -> Builder {
            dataSource.animationPropsForLandscape = AnimationProperties(duration: duration,
                                                                        options: options,
                                                                        forwardDampingRatio: forwardDampingRatio,
                                                                        rewindDampingRatio: rewindDampingRatio,
                                                                        velocity: velocity)
            return self
        }
        /// Once the USController is completely configured, this method must be called to construct the builder object.
        ///
        /// - Returns: Datasource object returns for be able to access runtime properties and methods.
        ///
        @discardableResult
        public func build() -> USCDataSource {
            dataSource.universalSplitController.setupTheController(with: dataSource)
            return dataSource
        }

    }

    public init() { }
    /// It returns current visibility state of detail controller.
    /// 
    /// - Returns: USCDetailVisibility
    ///
    public func getCurrentVisibility() -> USCDetailVisibility {
        return universalSplitController.getCurrentVisibility()
    }
    /// It changes current visibility state of detail controller between "visible" and "invisible"
    ///
    public func detailToggle() {
        universalSplitController.detailToggle()
    }
    /// It removes the USController and views permanently from its parent controller and view.
    ///
    public func disposeTheController() {
        universalSplitController.disposeTheController()
    }
    /// Default value of this parameter is "false". When it will set as "true",
    /// detail controller will be immediately dissmissed from screen
    /// and visibility state will turning to "invisible". Detail controller won't be visible again
    /// by visibility or orientation changes until setting this parameter to "false".
    ///
    /// - Setting this parameter to its default value back, won’t make the detail controller
    /// visible automatically and action may be required to displaying it again.
    /// (calling detailToggle, swipe action or orientation change if configured.)
    ///
    public var forceToHide: Bool = false {
        didSet {
            universalSplitController.forceToHide = forceToHide
        }
    }
}

public class SCLUniversalSplitControllerMasterHolder:UIView {
}

public class SCLUniversalSplitControllerDetailHolder:UIView {
}

public class SCLUniversalSplitControllerDetailInnerHolder:UIView {
}

public class SCLUniversalSplitControllerBlocker:UIView {
}

public class SCLUniversalSplitController: UIViewController, USCDataSourceProtocol {

    var dataSource: USCDataSource?
    var previousVisibility: USCDetailVisibility = .invisible
    var visibility: USCDetailVisibility = .invisible
    var portraitScreenWidth: CGFloat = 0.0
    var landscapeScreenWidth: CGFloat = 0.0
    private let defaultMaxWidth: CGFloat = 414.0
    let defaultMinWidth: CGFloat = 100.0
    private (set) var calculatedLandscapeWidth: CGFloat {
        get {
            return landscapeScreenWidth + safeAreaAdditionForLandsacpe()
        }
        set { _ = newValue }
    }
    var isCustomWidthSetForLandscape: CGFloat?
    var ignoreDetailAppearanceForOnce: Bool = true
    var ignoreMasterAppearanceForOnce: Bool = true
    var isMasterControllerVisible: Bool = false
    var isAnimationInProgress: Bool = false
    var horizontalSwipeHandler: ((USCHorizontalSwipeState) -> Void)?
    var startingPointOfSwipe: CGFloat?
    var maximumChanges: CGFloat = 0.0
    var previousPosition: CGPoint = .zero
    var isHorizontalSwipeOccurred: USCSwipeOccurrence = .locked

    lazy var masterHolder: SCLUniversalSplitControllerMasterHolder = {
        let view = SCLUniversalSplitControllerMasterHolder()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var detailHolder: SCLUniversalSplitControllerDetailHolder = {
        let view = SCLUniversalSplitControllerDetailHolder()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var detailInnerHolder: SCLUniversalSplitControllerDetailInnerHolder = {
        let view = SCLUniversalSplitControllerDetailInnerHolder()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var masterHolderLeading: NSLayoutConstraint!
    var masterHolderTrailing: NSLayoutConstraint!
    var detailInnerHolderWidth: NSLayoutConstraint!
    var detailHolderLeading: NSLayoutConstraint!
    var detailHolderTrailing: NSLayoutConstraint!

    lazy var blocker: SCLUniversalSplitControllerBlocker = {
        let view = SCLUniversalSplitControllerBlocker()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var detailControllerReference: UIViewController!
    var masterControllerReference: UIViewController!
    //var parentControllerReference: UIViewController!

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /*public override func didMove(toParent:UIViewController?) {
        print("splitview move to ",toParent?.view)
        
        super.didMove(toParent:toParent)
    }*/

    func setupTheController(with dataSource: USCDataSource) {
        self.dataSource = dataSource
        setupInitialData()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        
        /*guard let parentController = dataSource.parentController else {return}
        
        print("self=",self," parent=",parentController)
        
        parentController.addChild(self)
        didMove(toParent: parentController)*/
        
        
        guard let parentController = dataSource.parentController,
            let parrentControllerView = parentController.view else { return }
            
        //print("self=",self," parent=",parentController)
        
        parentController.addChild(self)
        didMove(toParent: parentController)
        parrentControllerView.addSubview(view)
        didMove(toParent: parentController)
        
        view.topAnchor.constraint(equalTo: parrentControllerView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: parrentControllerView.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: parrentControllerView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: parrentControllerView.trailingAnchor).isActive = true
        parentController.view.layoutIfNeeded()
        parentController.view.clipsToBounds = true
        view.clipsToBounds = true
        //parentControllerReference=parentController
    }
    
    func detachParentController() {
        /*guard let parentController = parentControllerReference,
            let parrentControllerView = parentController.view else { return }
            
        parentController.willMove(toParent: nil)
        parrentControllerView.removeFromSuperview()
        parentController.removeFromParent()
        parentController.didMove(toParent: nil)
        
        parentControllerReference=nil
        */
        
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
        self.didMove(toParent: nil)
    }

    private func setupInitialData() {
        setPortraitScreenWidth()
        setLandscapeScreenWidth()
    }

    private func setPortraitScreenWidth() {
        let halfWidthOfPortrait: CGFloat = getPortraitWidthOfScreen() / 2.0
        let portraitWidthExceptPhones = halfWidthOfPortrait < defaultMaxWidth ? halfWidthOfPortrait : defaultMaxWidth
        portraitScreenWidth = isPhone() ? getPortraitWidthOfScreen() : portraitWidthExceptPhones
        if let currentDataSource = dataSource,
            var customWidth = currentDataSource.customWidthForPortrait {
            if currentDataSource.widthInPercentageForPortrait {
                if customWidth > 100.0 {
                    customWidth = 100.0
                }
                customWidth = getPortraitWidthOfScreen() * (customWidth / 100.0)
            }
            if currentDataSource.overlapWhileInPortrait {
                if customWidth > getPortraitWidthOfScreen() {
                    portraitScreenWidth = getPortraitWidthOfScreen()
                } else if customWidth < defaultMinWidth {
                    portraitScreenWidth = defaultMinWidth
                } else {
                    portraitScreenWidth = customWidth
                }
            } else {
                if customWidth > halfWidthOfPortrait {
                    portraitScreenWidth = halfWidthOfPortrait
                } else if customWidth < defaultMinWidth {
                    portraitScreenWidth = defaultMinWidth
                } else {
                    portraitScreenWidth = customWidth
                }
            }
        }
    }

    private func setLandscapeScreenWidth() {
        let halfWidthOfLandscape: CGFloat = getLandscapeWidthOfScreen() / 2.0
        var landscapeWidthForAll: CGFloat = 0.0
        if getPortraitWidthOfScreen() > halfWidthOfLandscape {
            if halfWidthOfLandscape > defaultMaxWidth {
                landscapeWidthForAll = defaultMaxWidth
            } else {
                landscapeWidthForAll = halfWidthOfLandscape
            }
        } else {
            if getPortraitWidthOfScreen() > defaultMaxWidth {
                landscapeWidthForAll = defaultMaxWidth
            } else {
                landscapeWidthForAll = getPortraitWidthOfScreen()
            }
        }
        landscapeScreenWidth = landscapeWidthForAll
        if let currentDataSource = dataSource,
            var customWidth = currentDataSource.customWidthForLandscape {
            if currentDataSource.widthInPercentageForLandscape {
                customWidth = customWidth > 100.0 ? 100.0 : customWidth
                customWidth = getLandscapeWidthOfScreen() * (customWidth / 100.0)
            }
            if currentDataSource.overlapWhileInLandscape {
                if customWidth > getLandscapeWidthOfScreen() {
                    customWidth = getLandscapeWidthOfScreen()
                    landscapeScreenWidth = customWidth
                } else if customWidth < defaultMinWidth {
                    customWidth = defaultMinWidth
                    landscapeScreenWidth = customWidth
                } else {
                    landscapeScreenWidth = customWidth
                }
            } else {
                if customWidth > halfWidthOfLandscape {
                    customWidth = halfWidthOfLandscape
                    landscapeScreenWidth = customWidth
                } else if customWidth < defaultMinWidth {
                    customWidth = defaultMinWidth
                    landscapeScreenWidth = customWidth
                } else {
                    landscapeScreenWidth = customWidth

                }
            }
            isCustomWidthSetForLandscape = customWidth
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        var isTargetLandscape: Bool = false
        if size.width > size.height {
            isTargetLandscape = true
        }
        visibilityConfigurator(isLandscape: isTargetLandscape)
        triggerMasterWillVisibility(isAppearing: masterControllerVisibilityCheckher(isLandscape: isTargetLandscape),
                                    animated: true)
        if previousVisibility != visibility {
            triggerDetailWillVisibility(isAppearing: visibility == .visible, animated: true)
        }
        visibility = previousVisibility
        coordinator.animate(alongsideTransition: { [weak self] (_) in
            guard let self = self else { return }
            self.visibilityConfigurator(isLandscape: self.isLandscape())
            self.animateUI(.noneWithoutCompletion)
            self.view.layoutSubviews()
            }, completion: { [weak self] (_) in
                guard let self = self else { return }
                self.isAnimationInProgress = false
                if self.forceToHide && self.visibility == .visible {
                    self.detailToggle(animated: false)
                }
                self.triggerMasterDidVisibility(
                    isAppearing: self.masterControllerVisibilityCheckher(isLandscape: self.isLandscape()),
                    animated: true)
                guard self.previousVisibility != self.visibility else { return }
                self.triggerDetailDidVisibility(isAppearing: self.visibility == .visible, animated: true)
        })
    }

    // MARK: UniversalSplitControllerDataSourceProtocol stubs
    func getCurrentVisibility() -> USCDetailVisibility {
        return visibility
    }

    func detailToggle(animated: Bool = true) {
        guard !isAnimationInProgress else { return }
        previousVisibility = visibility
        if forceToHide {
            visibility = .invisible
        } else {
            visibility = visibility == .visible ? .invisible : .visible
        }
        animateUI(animated ? .auto : .none)
    }

    func disposeTheController() {
        if view.superview != nil {
            view.removeFromSuperview()
        }
        if parent != nil {
            willMove(toParent: nil)
            removeFromParent()
        }
    }

    var forceToHide: Bool = false {
        didSet {
            if forceToHide {
                detailToggle(animated: false)
            }
        }
    }

}

extension UIView {

    func applyBlur(blur style: UIBlurEffect.Style = .light, mixColor: UIColor? = nil) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        if let receivedMixColor = mixColor {
            blurEffectView.backgroundColor = receivedMixColor
        }
        addSubview(blurEffectView)
        sendSubviewToBack(blurEffectView)
        blurEffectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        layoutIfNeeded()
    }

}

extension SCLUniversalSplitController {

    func setupUI() {
        visibilityConfigurator(isLandscape: isLandscape(), isInitialConfiguration: true)
        setupmMasterHolder()
        setupDetailHolder()
        alignHolders()
        configureSwipe()
        animateUI(.none)
    }

    func visibilityConfigurator(isLandscape: Bool, isInitialConfiguration: Bool = false) {
        guard let currentDataSource = dataSource, !forceToHide else { return }
        if !isInitialConfiguration {
            previousVisibility = visibility
        }
        if currentDataSource.appearance == .invisibleInit {
            visibility = .invisible
        } else if currentDataSource.appearance == .invisibleInitAndPreserveTheStatus &&
            isInitialConfiguration {
            visibility = .invisible
        } else if currentDataSource.appearance == .visibleInit {
            visibility = .visible
        } else if currentDataSource.appearance == .visibleInitAndPreserveTheStatus &&
            isInitialConfiguration {
            visibility = .visible
        } else if currentDataSource.appearance == .auto &&
            isPhone() &&
            !isLandscape {
            visibility = .invisible
        } else if currentDataSource.appearance == .auto &&
            isPhone() &&
            isLandscape {
            visibility = .visible
        } else if currentDataSource.appearance == .auto &&
            !isPhone() {
            visibility = .visible
        }
        if isInitialConfiguration {
            previousVisibility = visibility == .visible ? .invisible : .visible
        }
    }

    func setupmMasterHolder() {
        guard let currentDataSource = dataSource else { return }
        view.addSubview(masterHolder)
        if let backgroundColor = currentDataSource.contentBlockerColor {
            if let blur = currentDataSource.contentBlockerBlur {
                blocker.applyBlur(blur: blur, mixColor: backgroundColor)
            } else {
                blocker.backgroundColor = backgroundColor
            }
            masterHolder.addSubview(blocker)
            blocker.topAnchor.constraint(equalTo: masterHolder.topAnchor).isActive = true
            blocker.bottomAnchor.constraint(equalTo: masterHolder.bottomAnchor).isActive = true
            blocker.leadingAnchor.constraint(equalTo: masterHolder.leadingAnchor).isActive = true
            blocker.trailingAnchor.constraint(equalTo: masterHolder.trailingAnchor).isActive = true
        }
        guard var masterController = currentDataSource.masterController else { return }
        if currentDataSource.masterWillEmbedInNavController,
            let wrappedController = navigationControllerWrapper(masterController) {
            masterController = wrappedController
        }
        masterControllerReference = masterController
    }
    
    func detachMasterController() {
        guard let masterController = masterControllerReference,
            let masterControllerView = masterController.view  else { return }
        masterController.willMove(toParent: nil)
        masterControllerView.removeFromSuperview()
        masterController.removeFromParent()
        masterController.didMove(toParent: nil)
        masterControllerReference=nil
    }

    func attachMasterController() {
        guard let masterController = masterControllerReference,
            let masterControllerView = masterController.view  else { return }
        addChild(masterController)
        masterController.didMove(toParent: self)
        masterControllerView.translatesAutoresizingMaskIntoConstraints = false
        masterHolder.addSubview(masterControllerView)
        masterHolder.sendSubviewToBack(masterControllerView)
        masterControllerView.topAnchor.constraint(equalTo: masterHolder.topAnchor).isActive = true
        masterControllerView.bottomAnchor.constraint(equalTo: masterHolder.bottomAnchor).isActive = true
        masterControllerView.leadingAnchor.constraint(equalTo: masterHolder.leadingAnchor).isActive = true
        masterControllerView.trailingAnchor.constraint(equalTo: masterHolder.trailingAnchor).isActive = true
        masterHolder.layoutIfNeeded()
    }

    func isMasterControllerAttached() -> Bool {
        guard let masterController = masterControllerReference else { return false }
        return masterController.parent != nil
    }

    func setupDetailHolder() {
        guard let currentDataSource = dataSource else { return }
        view.addSubview(detailHolder)
        detailHolder.addSubview(detailInnerHolder)
        if let backgroundColor = currentDataSource.detailBackgroundColor {
            if let blur = currentDataSource.detailBackgroundBlur {
                detailHolder.applyBlur(blur: blur, mixColor: backgroundColor)
            } else {
                detailHolder.backgroundColor = backgroundColor
            }
        }
        guard var detailController = currentDataSource.detailController else { return }
        if currentDataSource.detailWillEmbedInNavController,
            let wrappedController = navigationControllerWrapper(detailController) {
            detailController = wrappedController
        }
        detailControllerReference = detailController
    }
    
    func detachDetailController() {
        guard let detailController = detailControllerReference,
            let detailControllerView = detailController.view  else { return }
        detailController.willMove(toParent: nil)
        detailControllerView.removeFromSuperview()
        detailController.removeFromParent()
        detailController.didMove(toParent: nil)
        detailControllerReference=nil
    }

    func attachDetailController() {
        guard let detailController = detailControllerReference,
            let detailControllerView = detailController.view  else { return }
        addChild(detailController)
        detailController.didMove(toParent: self)
        detailControllerView.translatesAutoresizingMaskIntoConstraints = false
        detailInnerHolder.addSubview(detailControllerView)
        detailControllerView.topAnchor.constraint(equalTo: detailInnerHolder.topAnchor).isActive = true
        detailControllerView.bottomAnchor.constraint(equalTo: detailInnerHolder.bottomAnchor).isActive = true
        detailControllerView.leadingAnchor.constraint(equalTo: detailInnerHolder.leadingAnchor).isActive = true
        detailControllerView.trailingAnchor.constraint(equalTo: detailInnerHolder.trailingAnchor).isActive = true
        detailInnerHolder.layoutIfNeeded()
    }

    func isDetailControllerAttached() -> Bool {
        guard let detailController = detailControllerReference else { return false }
        return detailController.parent != nil
    }

    func alignHolders() {
        guard let currentDataSource = dataSource else { return }
        let startWidth = getLandscapeWidthOfScreen() * 2.0
        let innerHolderWidth = isLandscape() ? calculatedLandscapeWidth : portraitScreenWidth
        if currentDataSource.direction == .trailing {
            masterHolder.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            masterHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            masterHolderLeading = masterHolder.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            masterHolderLeading.isActive = true
            masterHolderTrailing = masterHolder.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            masterHolderTrailing.isActive = true
            detailHolder.widthAnchor.constraint(equalToConstant: startWidth).isActive = true
            detailHolder.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            detailHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            detailHolderLeading = detailHolder.leadingAnchor.constraint(equalTo: masterHolder.trailingAnchor)
            detailHolderLeading.isActive = true
            detailInnerHolderWidth = detailInnerHolder.widthAnchor.constraint(equalToConstant: innerHolderWidth)
            detailInnerHolderWidth.isActive = true
            detailInnerHolder.topAnchor.constraint(equalTo: detailHolder.topAnchor).isActive = true
            detailInnerHolder.bottomAnchor.constraint(equalTo: detailHolder.bottomAnchor).isActive = true
            detailInnerHolder.leadingAnchor.constraint(equalTo: detailHolder.leadingAnchor).isActive = true
        } else if currentDataSource.direction == .leading {
            masterHolder.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            masterHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            masterHolderLeading = masterHolder.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            masterHolderLeading.isActive = true
            masterHolderTrailing = masterHolder.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            masterHolderTrailing.isActive = true
            detailHolder.widthAnchor.constraint(equalToConstant: startWidth).isActive = true
            detailHolder.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            detailHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            detailHolderTrailing = detailHolder.trailingAnchor.constraint(equalTo: masterHolder.leadingAnchor)
            detailHolderTrailing.isActive = true
            detailInnerHolderWidth = detailInnerHolder.widthAnchor.constraint(equalToConstant: innerHolderWidth)
            detailInnerHolderWidth.isActive = true
            detailInnerHolder.topAnchor.constraint(equalTo: detailHolder.topAnchor).isActive = true
            detailInnerHolder.bottomAnchor.constraint(equalTo: detailHolder.bottomAnchor).isActive = true
            detailInnerHolder.trailingAnchor.constraint(equalTo: detailHolder.trailingAnchor).isActive = true
        }
        view.layoutIfNeeded()
    }

}

extension SCLUniversalSplitController {

    func getPortraitWidthOfScreen() -> CGFloat {
        var absoulteSize = UIScreen.main.bounds.size
        if absoulteSize.width > absoulteSize.height {
            absoulteSize = CGSize(width: absoulteSize.height, height: absoulteSize.width)
        }
        return absoulteSize.width
    }

    func getLandscapeWidthOfScreen() -> CGFloat {
        var absoulteSize = UIScreen.main.bounds.size
        if absoulteSize.width > absoulteSize.height {
            absoulteSize = CGSize(width: absoulteSize.height, height: absoulteSize.width)
        }
        return absoulteSize.height
    }

    func isLandscape() -> Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isLandscape ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }

    func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    func getSafeAreaInsets() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.windows
            .first?
            .safeAreaInsets ?? .zero
        } else {
            return .zero
        }
    }

    func navigationControllerWrapper(_ controller: UIViewController) -> UINavigationController? {
        if !controller.isKind(of: UINavigationController.self) {
            let navigationController = UINavigationController(rootViewController: controller)
            return navigationController
        }
        return nil
    }

    func safeAreaAdditionForLandsacpe() -> CGFloat {
        guard #available(iOS 11.0, *),
            let currentDataSource = dataSource,
            let window = UIApplication.shared.windows.first,
            isLandscape(),
            let customWidth = isCustomWidthSetForLandscape else { return 0.0 }
        var returunValue: CGFloat = 0.0
        if currentDataSource.direction == .trailing {
            if customWidth < defaultMinWidth + window.safeAreaInsets.right {
                returunValue = window.safeAreaInsets.right
            }
        } else if currentDataSource.direction == .leading {
            if customWidth < defaultMinWidth + window.safeAreaInsets.left {
                returunValue = window.safeAreaInsets.left
            }
        }
        return returunValue
    }

    func masterControllerVisibilityCheckher(isLandscape: Bool) -> Bool {
        if !isPhone() || isLandscape {
            return true
        } else {
            if isPhone() && portraitScreenWidth == getPortraitWidthOfScreen() {
                if let currentDataSource = dataSource, currentDataSource.overlapWhileInPortrait {
                    return true
                }
                return visibility == .invisible
            } else {
                return true
            }
        }
    }

    func triggerDetailWillVisibility(isAppearing: Bool, animated: Bool) {
        if isDetailControllerAttached() {
            triggerDetailAppearance(isBegin: true, isAppearing: isAppearing, animated: animated)
        } else {
            if isAppearing {
                attachDetailController()
            }
        }
        guard let currentDataSource = dataSource,
            let visibilityWillStartBlock = currentDataSource.visibilityWillStartBlock else { return }
        visibilityWillStartBlock(visibility)
    }

    func triggerDetailDidVisibility(isAppearing: Bool, animated: Bool) {
        if isDetailControllerAttached() {
            if ignoreDetailAppearanceForOnce {
                ignoreDetailAppearanceForOnce = false
            } else {
                triggerDetailAppearance(isBegin: false, isAppearing: isAppearing, animated: animated)
            }
        }
        guard let currentDataSource = dataSource,
            let visibilityDidEndBlock = currentDataSource.visibilityDidEndBlock else { return }
        visibilityDidEndBlock(visibility)
    }

    func triggerDetailAppearance(isBegin: Bool, isAppearing: Bool, animated: Bool) {
        guard let detailController = detailControllerReference,
            let currentDataSource = dataSource,
            currentDataSource.invokeAppearanceMethods else { return }
        if isBegin {
            detailController.beginAppearanceTransition(isAppearing, animated: animated)
        } else {
            detailController.endAppearanceTransition()
        }
        detailController.view.setNeedsLayout()
        detailHolder.setNeedsLayout()
        detailHolder.layoutIfNeeded()
    }

    func triggerMasterWillVisibility(isAppearing: Bool, animated: Bool) {
        if isMasterControllerAttached() {
            triggerMasterAppearance(isBegin: true,
                                    isAppearing: isAppearing,
                                    animated: animated)
        } else {
            if isAppearing {
                attachMasterController()
                isMasterControllerVisible = true
            }
        }
    }

    func triggerMasterDidVisibility(isAppearing: Bool, animated: Bool) {
        if isMasterControllerAttached() {
            if ignoreMasterAppearanceForOnce {
                ignoreMasterAppearanceForOnce = false
            } else {
                triggerMasterAppearance(isBegin: false,
                                        isAppearing: isAppearing,
                                        animated: animated)
            }
        }
    }

    func triggerMasterAppearance(isBegin: Bool, isAppearing: Bool, animated: Bool) {
        guard let masterController = masterControllerReference,
            let currentDataSource = dataSource,
            currentDataSource.invokeAppearanceMethods else { return }
        if isMasterControllerVisible != isAppearing {
            if isBegin {
                masterController.beginAppearanceTransition(isAppearing, animated: animated)
            } else {
                masterController.endAppearanceTransition()
                isMasterControllerVisible = isAppearing
            }
            masterController.view.setNeedsLayout()
            masterController.view.layoutIfNeeded()
            masterHolder.setNeedsLayout()
            masterHolder.layoutIfNeeded()
        }
    }

}

extension SCLUniversalSplitController: UIGestureRecognizerDelegate {

    func configureSwipe() {
        guard let currentDataSource = dataSource, currentDataSource.swipeable else { return }

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(recognizer:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)

        horizontalSwipeHandler = { [weak self ]state in
            guard let self = self else { return }
            switch state {
            case .began(let point):
                self.swipeBeganLogic(point: point)
            case .moved(let direction, let maximumChanges, let distance):
                self.swipeMovedLogic(direction: direction, maximumChanges: maximumChanges, distance: distance)
            case .ended:
                self.isHorizontalSwipeOccurred = .locked
            }
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let currentDataSource = dataSource else { return false }
        return currentDataSource.couldBeBlockedByOtherEventsIfAny
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        guard let currentDataSource = dataSource else { return true }
        return !currentDataSource.couldBeBlockedByOtherEventsIfAny
    }

    @objc func panGesture(recognizer: UIPanGestureRecognizer) {
        //print("check swipe with handler ",horizontalSwipeHandler)
        guard let swipeHandler = horizontalSwipeHandler else { return }
        let position = recognizer.location(in: view)
        switch recognizer.state {
        case .began:
            startingPointOfSwipe = position.x
            maximumChanges = 0.0
            previousPosition = position
            swipeHandler(.began(point: position.x))
        case .changed:
            let diff = previousPosition.x - position.x
            var distance: CGFloat = 0.0
            if let currentStartingPointOfSwipe = startingPointOfSwipe {
                distance = CGFloat(fabsf(Float(currentStartingPointOfSwipe - position.x)))
            }
            let absoluteDifference = CGFloat(fabsf(Float(diff)))
            if absoluteDifference > maximumChanges {
                maximumChanges = absoluteDifference
            }
            if fabsf(Float(diff)) > 0 {
                swipeHandler(.moved(direction: diff, maximumChanges: maximumChanges, distance: distance))
            }
            previousPosition = position
        case .ended, .cancelled, .failed:
            startingPointOfSwipe = nil
            maximumChanges = 0.0
            previousPosition = .zero
            swipeHandler(.ended)
        default:
            break
        }
    }

    func swipeBeganLogic(point: CGFloat) {
        guard let currentDataSource = dataSource else { return }
        let viewWidth = view.bounds.size.width
        let swipeWidth = isLandscape() ? calculatedLandscapeWidth : portraitScreenWidth
        var limit: CGFloat = visibility == .visible ? swipeWidth < viewWidth ? 50.0 : 60.0 : 60.0
        isHorizontalSwipeOccurred = .locked
        let diff: CGFloat = (viewWidth - swipeWidth) < 0.0 ? 0.0 : (viewWidth - swipeWidth)
        let screenWidth = isLandscape() ? getLandscapeWidthOfScreen() : getPortraitWidthOfScreen()
        //print("swipeBeganLogic occured direction=",currentDataSource.direction," width=",swipeWidth)
        if currentDataSource.direction == .trailing {
            limit += getSafeAreaInsets().right
            if point >= viewWidth - limit && point <= viewWidth {
                isHorizontalSwipeOccurred = .trailingOpeningSequence
            } else if (swipeWidth == screenWidth && point >= diff && point <= limit) ||
                (swipeWidth != screenWidth && diff - limit >= 0.0 && point >= diff - (limit * 2.0) && point <= diff) ||
                (swipeWidth != screenWidth && diff - limit < 0.0 && point >= 0.0 && point <= limit) {
                isHorizontalSwipeOccurred = .trailingClosingSequence
            }
        } else if currentDataSource.direction == .leading {
            limit += getSafeAreaInsets().left
            if point >= 0.0 && point <= limit {
                isHorizontalSwipeOccurred = .leadingOpeningSequence
            } else if (swipeWidth == screenWidth && point >= viewWidth - limit && point <= viewWidth) ||
                (swipeWidth != screenWidth && diff - limit >= 0.0 && point >= swipeWidth &&
                    point <= swipeWidth + (limit * 2.0)) ||
                (swipeWidth != screenWidth && diff - limit < 0.0 && point >= viewWidth - limit && point <= viewWidth) {
                isHorizontalSwipeOccurred = .leadingClosingSequence
            }
        }
    }

    func swipeMovedLogic(direction: CGFloat, maximumChanges: CGFloat, distance: CGFloat) {
        let minimumChangingToTrigger: CGFloat = 10.0
        //print("swipeMovedLogic occured=",isHorizontalSwipeOccurred," max=",maximumChanges," min=",minimumChangingToTrigger," dist=",distance)
        if isHorizontalSwipeOccurred != .locked && maximumChanges > minimumChangingToTrigger && distance >= 80.0 {
            if direction < 0.0 {
                if isHorizontalSwipeOccurred == .trailingClosingSequence && visibility == .visible {
                    detailToggle()
                } else if isHorizontalSwipeOccurred == .leadingOpeningSequence && visibility == .invisible {
                    detailToggle()
                }
            } else if direction > 0.0 {
                if isHorizontalSwipeOccurred == .trailingOpeningSequence && visibility == .invisible {
                    detailToggle()
                } else if isHorizontalSwipeOccurred == .leadingClosingSequence && visibility == .visible {
                    detailToggle()
                }
            }
            isHorizontalSwipeOccurred = .locked
        }
    }

}

extension SCLUniversalSplitController {

    func animateUI(_ animated: USCAnimationPreference = .auto) {
        guard let currentDataSource = dataSource else { return }
        if visibility == .visible {
            if currentDataSource.direction == .trailing && isLandscape() {
                visibleTrailingLandscapeConstraints(showOnTop: currentDataSource.overlapWhileInLandscape)
            } else if currentDataSource.direction == .trailing && !isLandscape() {
                visibleTrailingPortraitConstraints(showOnTop: currentDataSource.overlapWhileInPortrait)
            } else if currentDataSource.direction == .leading && isLandscape() {
                visibleLeadingLandscapeConstraints(showOnTop: currentDataSource.overlapWhileInLandscape)
            } else if currentDataSource.direction == .leading && !isLandscape() {
                visibleLeadingPortraitConstraints(showOnTop: currentDataSource.overlapWhileInPortrait)
            }
        } else if visibility == .invisible {
            invisiblityConstraints()
        }
        commitAnimation(animated)
    }

    func commitAnimation(_ animated: USCAnimationPreference = .auto) {
        guard let currentDataSource = dataSource else { return }
        isAnimationInProgress = true
        if animated == .none {
            withoutAnimation()
        } else if animated == .noneWithoutCompletion {
            if currentDataSource.contentBlockerColor != nil {
                let interactions = currentDataSource.contentBlockerInteractions ?? false
                blocker.isUserInteractionEnabled = interactions ? false : visibility == .visible
                blocker.alpha = visibility == .visible ? 1.0 : 0.0
            }
            if let visibilityAnimationBlock = currentDataSource.visibilityAnimationBlock,
                previousVisibility != visibility {
                visibilityAnimationBlock(visibility)
            }
            view.layoutIfNeeded()
        } else {
            animation()
        }
    }

    func withoutAnimation() {
        guard let currentDataSource = dataSource else { return }
        if currentDataSource.contentBlockerColor != nil {
            let interactions = currentDataSource.contentBlockerInteractions ?? false
            blocker.isUserInteractionEnabled = interactions ? false : visibility == .visible
            blocker.alpha = visibility == .visible ? 1.0 : 0.0
        }

        triggerMasterWillVisibility(isAppearing: masterControllerVisibilityCheckher(isLandscape: isLandscape()),
                                    animated: false)
        if previousVisibility != visibility {
            triggerDetailWillVisibility(isAppearing: visibility == .visible, animated: false)
            if let visibilityAnimationBlock = currentDataSource.visibilityAnimationBlock {
                visibilityAnimationBlock(visibility)
            }
            view.layoutIfNeeded()
        }
        triggerMasterDidVisibility(isAppearing: masterControllerVisibilityCheckher(isLandscape: isLandscape()),
                                   animated: false)
        if previousVisibility != visibility {
            triggerDetailDidVisibility(isAppearing: visibility == .visible, animated: false)
        }
        isAnimationInProgress = false
        if forceToHide && visibility == .visible {
            detailToggle(animated: false)
        }
    }

    func animation() {
        guard let currentDataSource = dataSource else { return }
        triggerMasterWillVisibility(isAppearing: masterControllerVisibilityCheckher(isLandscape: isLandscape()),
                                    animated: true)
        if previousVisibility != visibility {
            triggerDetailWillVisibility(isAppearing: visibility == .visible, animated: true)
        }
        var animationProps = currentDataSource.animationPropsForPortrait
        if isLandscape() {
            animationProps = currentDataSource.animationPropsForLandscape
        }
        let damping = visibility == .visible ? animationProps.forwardDampingRatio : animationProps.rewindDampingRatio
        UIView.animate(withDuration: animationProps.duration,
                       delay: 0.0, usingSpringWithDamping: damping,
                       initialSpringVelocity: animationProps.velocity,
                       options: animationProps.options,
                       animations: { [weak self] in
                        guard let self = self else { return }
                        if currentDataSource.contentBlockerColor != nil {
                            let interactions = currentDataSource.contentBlockerInteractions ?? false
                            self.blocker.isUserInteractionEnabled = interactions ? false : self.visibility == .visible
                            self.blocker.alpha = self.visibility == .visible ? 1.0 : 0.0
                        }
                        if let visibilityAnimationBlock = currentDataSource.visibilityAnimationBlock,
                            self.previousVisibility != self.visibility {
                            visibilityAnimationBlock(self.visibility)
                        }
                        self.view.layoutIfNeeded()
            }, completion: { [weak self] (_) in
                guard let self = self else { return }
                if currentDataSource.contentBlockerColor != nil {
                    let interactions = currentDataSource.contentBlockerInteractions ?? false
                    self.blocker.isUserInteractionEnabled = interactions ? false : self.visibility == .visible
                    self.blocker.alpha = self.visibility == .visible ? 1.0 : 0.0
                }
                self.triggerMasterDidVisibility(
                    isAppearing: self.masterControllerVisibilityCheckher(isLandscape: self.isLandscape()),
                    animated: true)
                if self.previousVisibility != self.visibility {
                    self.triggerDetailDidVisibility(isAppearing: self.visibility == .visible, animated: true)
                }
                self.isAnimationInProgress = false
                if self.forceToHide && self.visibility == .visible {
                    self.detailToggle(animated: false)
                }
        })
    }

    func visibleTrailingLandscapeConstraints(showOnTop: Bool) {
        masterHolderLeading.constant = 0.0
        masterHolderTrailing.constant = showOnTop ? 0.0 : -calculatedLandscapeWidth
        detailInnerHolderWidth.constant = calculatedLandscapeWidth
        detailHolderLeading.constant = showOnTop ? -calculatedLandscapeWidth : 0.0
    }

    func visibleTrailingPortraitConstraints(showOnTop: Bool) {
        if isPhone() && portraitScreenWidth == getPortraitWidthOfScreen() {
            masterHolderLeading.constant = showOnTop ? 0.0 : -portraitScreenWidth
            masterHolderTrailing.constant = showOnTop ? 0.0 : -portraitScreenWidth
            detailInnerHolderWidth.constant = portraitScreenWidth
            detailHolderLeading.constant = showOnTop ? -portraitScreenWidth : 0.0
        } else {
            masterHolderLeading.constant = 0.0
            masterHolderTrailing.constant = showOnTop ? 0.0 : -portraitScreenWidth
            detailInnerHolderWidth.constant = portraitScreenWidth
            detailHolderLeading.constant = showOnTop ? -portraitScreenWidth : 0.0
        }
    }

    func visibleLeadingLandscapeConstraints(showOnTop: Bool) {
        masterHolderLeading.constant = showOnTop ? 0.0 : calculatedLandscapeWidth
        masterHolderTrailing.constant = 0.0
        detailInnerHolderWidth.constant = calculatedLandscapeWidth
        detailHolderTrailing.constant = showOnTop ? calculatedLandscapeWidth : 0.0
    }

    func visibleLeadingPortraitConstraints(showOnTop: Bool) {
        if isPhone() && portraitScreenWidth == getPortraitWidthOfScreen() {
            masterHolderLeading.constant = showOnTop ? 0.0 : portraitScreenWidth
            masterHolderTrailing.constant = showOnTop ? 0.0 : portraitScreenWidth
            detailInnerHolderWidth.constant = portraitScreenWidth
            detailHolderTrailing.constant = showOnTop ? portraitScreenWidth : 0.0
        } else {
            masterHolderLeading.constant = showOnTop ? 0.0 : portraitScreenWidth
            masterHolderTrailing.constant = 0.0
            detailInnerHolderWidth.constant = portraitScreenWidth
            detailHolderTrailing.constant = showOnTop ? portraitScreenWidth : 0.0
        }
    }

    func invisiblityConstraints() {
        masterHolderLeading.constant = 0.0
        masterHolderTrailing.constant = 0.0
        detailInnerHolderWidth.constant = isLandscape() ? calculatedLandscapeWidth : portraitScreenWidth
        guard let currentDataSource = dataSource else { return }
        if currentDataSource.direction == .trailing {
            detailHolderLeading.constant = 0.0
        } else if currentDataSource.direction == .leading {
            detailHolderTrailing.constant = 0.0
        }
    }

}

public struct _SplitViewLayout {
    var splitview:ViewNode?
    
    @inlinable public init() {
    }
    
    public typealias Body = Never
}

extension _SplitViewLayout: _VariadicView_UnaryViewRoot {}
extension _SplitViewLayout: _VariadicView_ViewRoot {}

class DataSourceWrapper {
    var dataSource:USCDataSource?=nil
    var masterController:UIViewController?=nil
    var detailController:UIViewController?=nil
}

public class SCLSplitViewContainer:UIView {
    /*public override func sizeThatFits(_ size: CGSize) -> CGSize {
        print("splitviewcontainer sizethatfits frame ",frame," for ",size," parent=",superview)
        let sz = super.sizeThatFits(size)
        print("sizethatfits return ",sz)
        return sz
    }*/
}

public class SCLSplitContentView:UIView {
}

public class SCLSplitViewController:UIViewController {
}

public struct SplitView<PrimaryContent,SecondaryContent>: UIViewControllerRepresentable where PrimaryContent: View, SecondaryContent: View  {
    //var primaryContent:PrimaryContent
    //var secondaryContent:SecondaryContent
    var primaryWidth:CGFloat
    public typealias Body = Never
    public typealias UIViewType=UIView
    public typealias UIViewControllerType=SCLSplitViewController /*SCLUniversalSplitController*/
    public typealias UIContainerType = SCLSplitViewContainer
    
    private var _layoutSpec=LayoutSpecWrapper<UIViewType>()
    public var _primarytree: _VariadicView.Tree<_SplitViewLayout, PrimaryContent>
    public var _secondarytree: _VariadicView.Tree<_SplitViewLayout, SecondaryContent>
    private var _dataSource=DataSourceWrapper()
    
    public init(primaryWidth:CGFloat=400,@ViewBuilder primary: () -> PrimaryContent, @ViewBuilder secondary: () -> SecondaryContent) {
        //primaryContent = primary()
        //secondaryContent = secondary()
        _primarytree = .init(root: _SplitViewLayout() , content: primary())
        _secondarytree = .init(root: _SplitViewLayout() , content: secondary())
        
        self.primaryWidth=primaryWidth
    }
    
    /*public var body: some View {
          HStack(spacing:0) {
            //primaryContent
            PassthroughView {primaryContent}.backgroundColor(.blue).matchParentHeight(withMargin: 0).width(primaryWidth).maxWidth(primaryWidth)
            
            //secondaryContent
            PassthroughView {secondaryContent}.backgroundColor(.red).matchParentHeight(withMargin: 0).flexGrow(1.0)
          }
          .matchParentWidth(withMargin: 0)
          .matchParentHeight(withMargin: 0)
    }*/
    
    public func makeUIViewController(context:Context) -> UIViewControllerType {
        //print("make splitview viewcontroller parent=",context.parent)
        let vc=UIViewControllerType()
        vc.node=_primarytree.root.splitview!
        let v=UIContainerType()
        v.node=_primarytree.root.splitview!
        vc.view=v
        
        return vc
    }
    
    public func updateUIViewController(_ view:UIViewControllerType,context:Context) -> Void {
        //print("update splitview viewcontroller parent=",context.parent)
    }
    
    public func withLayoutSpec(_ spec:@escaping (_ spec:LayoutSpec<UIViewType>) -> Void) -> SplitView<PrimaryContent,SecondaryContent> {
       _layoutSpec.add(spec)
       return self
    }
}

extension SplitView {
    public var body: Never {
        fatalError()
    }
}

class SplitViewNode:ViewNode {
    public override func structureMatches(to:ViewNode?,deep:Bool=true) -> Bool {
        //print("SplitViewNode structureMatches")
        if let to=to as? SplitViewNode { 
            if self==to {return true}
            var match:Bool=true
            
            //print("SplitViewNode node structurematches for self=",self.children," to=",to.children)
            
            match=super.structureMatches(to:to,deep:deep)
            
            //print("match=",match)
            return match
        }
        else {return false}
    }
}

extension SplitView {
    public func buildTree(parent: ViewNode, in env:SCLEnvironment) -> ViewNode? {
        //self.context=context
        var env=parent.runtimeenvironment
        //print("Spliview build tree env=",env)
            
        //print("create navigation node")
        let node=SCLNode(environment:env, host:self,reuseIdentifier:"SplitView",key:nil,layoutSpec: { spec, context in
                guard let yoga = spec.view?.yoga else { return }
                spec.view!.clipsToBounds=true
                //print("***splitview layoutspec view=",spec.view," parent=",spec.view?.superview)
                
                //init width and height, else crash for empty list
                /*if let parent:UIView=spec.view?.superview {
                    spec.set("yoga.width",value:parent.frame.size.width-spec.view!.frame.origin.x)
                    spec.set("yoga.height",value:parent.frame.size.height-spec.view!.frame.origin.y)
                }
                else {
                    //spec.set("yoga.width",value:spec.size.width)
                    //spec.set("yoga.height",value:spec.size.height)
                }*/
                
                yoga.flex() 

                //print("HStack spec layout=\(self._layoutSpec) align=\(yoga.alignItems.rawValue)")
                self._layoutSpec.layoutSpec?(spec)
                //print("HStack spec end 2 align=\(yoga.alignItems.rawValue)")
                //yoga.alignItems = .center
                //yoga.justifyContent = .center
                
                /*if spec.view!.subviews.count==1 {
                    print("controller child:",spec.view!.subviews[0])
                    if spec.view!.subviews[0].subviews.count>0 {print("1st subchild:",spec.view!.subviews[0].subviews[0])}
                    if spec.view!.subviews[0].subviews.count>1 {print("2nd subchild:",spec.view!.subviews[0].subviews[1])}
                    spec.view!.subviews[0].frame=CGRect(x:0,y:0,width:spec.view!.frame.size.width,height:spec.view!.frame.size.height)
                }
                
                print("splitview layoutspec frame ",spec.view!.frame," parent ",spec.view!.superview?.frame," 1stchild:",spec.view!.subviews.first?.frame)
                */
            },
            controller:self
        )
        
        let vnode = SplitViewNode(value: node)
        _primarytree.root.splitview=vnode
        _secondarytree.root.splitview=vnode
        
        parent.addChild(node: vnode)
        
        //print("splitview context env is:",node.context.environment)
        
        //create a dummy node for primary
        let primary=ViewNode(value: ConcreteNode(type:UIView.self, layoutSpec:{spec, context in 
            //fatalError()
            print("splitview primary layoutspec")
            spec.view?.clipsToBounds=true
            //if minLength>0 {yoga.width=minLength}
        }))
        primary.value?.setContext(_secondarytree.root.splitview!.value!.context!) //this will also specify environment
        vnode.children.append(primary)
        
        //print("primary environment:",primary.environment)

        ViewExtractor.extractViews(contents: _primarytree.content).forEach { 
            //print("build list node ",$0)
            if let n=$0.buildTree(parent: primary, in:primary.runtimeenvironment) 
            {
                //elements.append(n)
                //print("got list view node ",n)
            }
        }
        
        //create a dummy node for secondary
        let secondary=ViewNode(value: ConcreteNode(type:UIView.self, layoutSpec:{spec, context in 
            //fatalError()
            print("splitview secondary layoutspec")
            spec.view?.clipsToBounds=true
            //if minLength>0 {yoga.width=minLength}
        }))
        secondary.value?.setContext(_secondarytree.root.splitview!.value!.context!) //this will also specify environment
        vnode.children.append(secondary)
        
        ViewExtractor.extractViews(contents: _secondarytree.content).forEach { 
            //print("build list node ",$0)
            if let n=$0.buildTree(parent: secondary, in:secondary.runtimeenvironment) 
            {
                //elements.append(n)
                //print("got list view node ",n)
            }
        }
        
        //list.canReuseNodes=oldlist==nil || oldlist!.value==nil || list.node.structureMatches(to:oldlist!.value!)
        
        //  print("got list with tags ",_tree.root.list!.tags?.tagMapping ?? "nil")
        return vnode
    }
    
    public func makeCoordinator() -> Coordinator { 
        return Coordinator(self)
    }
    
    public class Coordinator:NSObject {
        let splitView:SplitView<PrimaryContent,SecondaryContent>
        
        public init(_ splitView:SplitView<PrimaryContent,SecondaryContent>) {
            self.splitView=splitView
        }
    }
}

class SCLSplitMasterController:UIViewController {
}

class SCLSplitDetailController:UIViewController {
}


extension SplitView {
    public func makeUIView(context:Context) -> UIViewType {
        return context.viewController!.view
    }
    
    public func updateUIView(_ view:UIViewType,context:Context) -> Void {
        if let vc=context.viewController as? UIViewControllerType {
            //print("updateuiview splitview ",view," parent=",context.parent)
        }
    }
    
    //update all controller children
    public func reconcileUIView(_ view:UIViewType,context:Context, constrainedTo size:CGSize, with parentView:UIView?,previousViews:[UIView]) -> [ViewNode] {
        
        //print("make spliview controller view frame ",context._viewController?.view?.frame," for parent \(context.parent)"," rendered=",_primarytree.root.splitview?.value?.renderedView)
        
        if let vc=context.viewController as? UIViewControllerType {
            /*if context.parent != nil {
                view.frame=CGRect(x:0,y:0,width:context.parent!.frame.size.width,height:context.parent!.frame.size.height)
            }*/
            for view in vc.view.subviews {
                view.removeFromSuperview()
            }
            for controller in vc.children {
                //print("remove splitview vc:",vc)
                controller.willMove(toParent:nil)
                controller.removeFromParent()
                controller.didMove(toParent:nil)
            }
            
            //print("start of reconcilensplitview has layout:")
            //print("view=",view," vc.view=",vc.view)
            //dumpView(view:vc.view)
            
            //switch primary and secondary here
            let secondary=_primarytree.root.splitview!.children[0]
            let primary=_secondarytree.root.splitview!.children[1]
            
            //print("reconcile splitview previousViews=",previousViews," context=",context.environment)
            //print("secondary env:",(secondary.children[0].value?.context as! SCLContext).environment)
            //print("secondary view:",secondary.children[0].value?.renderedView)
            
            _dataSource.dataSource?.universalSplitController.detachParentController()
            
            //vc.detachMasterController()
            _dataSource.dataSource?.universalSplitController.detachMasterController()
             
            if primary.children.count == 1 && primary.children[0].value?.isControllerNode == true {
                //build view controller
                primary.children[0].value?.build(in:nil,parent:nil,candidate:nil,
                                                 constrainedTo:vc.view.frame.size,with:[],forceLayout:false)
                //print("primary is a controller:",primary.children[0].value?.viewController," childcount:",primary.children[0].value?.children.count)
                                                     
                _dataSource.masterController = primary.children[0].value!.viewController!
                //_dataSource.masterController!.view.backgroundColor = .blue
            }
            else {
                if _dataSource.masterController != nil {
                    //print("reusing view of splitview master:")
                    //dumpView(view:_dataSource.masterController!.view)
                    /*for view in _dataSource.masterController!.view.subviews {
                        view.removeFromSuperview()
                    }*/
                    
                    _dataSource.masterController = SCLSplitMasterController()
                    _dataSource.masterController!.view=SCLSplitContentView()
                    _dataSource.masterController!.view.backgroundColor = .clear
                }
                else {
                    _dataSource.masterController = SCLSplitMasterController()
                    _dataSource.masterController!.view=SCLSplitContentView()
                    _dataSource.masterController!.view.backgroundColor = .clear
                }
                _dataSource.masterController!.view.frame=CGRect(x:0,y:0,width:view.frame.size.width,height:view.frame.size.height)
            }
            _dataSource.masterController!.node=primary
            
            //vc.detachDetailController()
            _dataSource.dataSource?.universalSplitController.detachDetailController()
            
            if secondary.children.count == 1 && secondary.children[0].value?.isControllerNode == true {
                //build view controller
                secondary.children[0].value?.build(in:nil,parent:nil,candidate:nil,
                                                   constrainedTo:vc.view.frame.size,with:[],forceLayout:false)
                //print("secondary is a controller:",secondary.children[0].value?.viewController," childcount:",secondary.children[0].value?.children.count)
                                                     
                _dataSource.detailController = secondary.children[0].value!.viewController!
                //_dataSource.detailController!.view.backgroundColor = .red
            }
            else {
                if _dataSource.detailController != nil {
                    //print("**************************************************reusing view of splitview detail:")
                    //dumpView(view:_dataSource.detailController!.view)
                    
                    /*for view in _dataSource.detailController!.view.subviews {
                        view.removeFromSuperview()
                    }*/
                    
                    _dataSource.detailController = SCLSplitDetailController()
                    _dataSource.detailController!.view=SCLSplitContentView()
                    _dataSource.detailController!.view.backgroundColor = .clear
                }
                else {
                    /*print("")
                    //print("***********create new detail view controller")*/
                    _dataSource.detailController = SCLSplitDetailController()
                    _dataSource.detailController!.view=SCLSplitContentView()
                    _dataSource.detailController!.view.backgroundColor = .clear
                }
                _dataSource.detailController!.view.frame=CGRect(x:0,y:0,width:view.frame.size.width,height:view.frame.size.height)
            }
            _dataSource.detailController!.node=secondary
            
            /*print("before build splitview mastercontainer has ",_dataSource.masterController!.view.subviews.count," children")
            print("before build splitview detailcontainer has ",_dataSource.detailController!.view.subviews.count," children")
            dumpView(controller:vc)
            print("master:")
            dumpView(controller:_dataSource.masterController!)
            print("detail:")
            dumpView(controller:_dataSource.detailController!)
            print("parent vc for ",parentView,":",parentView?.findViewController() ?? Application?.rootViewController)*/
            
            _dataSource.dataSource = USCDataSource.Builder(parentController: vc/*parentView?.findViewController() ?? Application?.rootViewController*/)
                  .setMasterController(_dataSource.masterController!, embedInNavController: false)
                  .setDetailController(_dataSource.detailController!, embedInNavController: false)
                  .setAppearance(.visibleInit)
                  //.setDirection(.trailing) //detail on right
                  .setDirection(.leading) //detail on left
                  //.showBlockerOnMaster(color: .black, opacity: 0.1, allowInteractions: true)
                  .swipeable()
                  .invokeAppearanceMethods()
                  .portraitAnimationProperties(duration: 0.35, forwardDampingRatio: 0.5)
                  .landscapeAnimationProperties(duration: 0.35, forwardDampingRatio: 0.5)
                  //.portraitCustomWidth(100.0)
                  .portraitCustomWidth(30,inPercentage:true) //detail width portrait
                  //.landscapeCustomWidth(100.0)
                  .landscapeCustomWidth(30,inPercentage:true) //detail width landscape
                  .visibilityChangesListener(willStartBlock: { (targetVisibility) in
                        //print("SplitView targetVisibility:\(targetVisibility)")
                  })
                  .build()                  
            
            var toUpdate:[ViewNode]=[]
            
            //print("after build splitview mastercontainer has ",_dataSource.masterController!.view.subviews.count," children")
            //print("after build splitview detailcontainer has ",_dataSource.detailController!.view.subviews.count," children")
            //dumpView(controller:vc)
            
            if primary.children.count == 1 && primary.children[0].value?.isControllerNode == true {
                //print("primary is a controller 2 view=\(primary.children[0].value!.viewController!.view))")
                /*if previousViews.count==2 {
                    let prev=previousViews[0];
                    print("prev primary controller=",type(of:prev))
                }*/
                
                primary.children[0].value?.build(in:_dataSource.masterController!.view,parent:nil,candidate:primary.children[0].value!.viewController!.view,
                                                 constrainedTo:_dataSource.masterController!.view.frame.size,with:[],forceLayout:false)
                
                //print("primary is a controller 2 done")
                
                toUpdate.append(primary.children[0])
            }
            else {
                if primary.children.count==1 {
                    if primary.children[0].value?.renderedView != nil {
                        //reuse
                        //print("reuse primary split view")
                        primary.children[0].value!.renderedView!.removeFromSuperview()
                        _dataSource.masterController!.view.addSubview(primary.children[0].value!.renderedView!)
                    }
                    else {
                        if previousViews.count==1 {
                            var prev=previousViews[0];
                            if prev.subviews.count==2 {
                                prev=prev.subviews[0]
                                if prev is SCLUniversalSplitControllerMasterHolder {
                                    prev=prev.subviews[0]
                                    if prev is SCLSplitContentView {
                                        prev=prev.subviews[0]
                                        primary.children[0].value?.origCandidate=prev
                                    }
                                }
                            }
                        }
                        
                        primary.children[0].value?.build(in:_dataSource.masterController!.view,parent:nil,candidate:primary.children[0].value?.origCandidate,
                                                         constrainedTo:_dataSource.masterController!.view.frame.size,with:[],forceLayout:false)
                    }
                    
                    primary.children[0].value?.renderedView?.frame=CGRect.init(x: 0, y: 0, 
                                width: _dataSource.masterController!.view.frame.width, 
                                height: _dataSource.masterController!.view.frame.size.height)
                    //print("primary frame:",primary.children[0].value?.renderedView?.frame)
                            
                    primary.children[0].value?.reconcile(in:_dataSource.masterController!.view,
                                                         constrainedTo:_dataSource.masterController!.view.frame.size,with:[])
                    
                    toUpdate.append(primary.children[0])
                }
                else {
                    print("Primary node of SplitView has none or multiple children. Cannot build")
                }
            }
            
            if secondary.children.count == 1 && secondary.children[0].value?.isControllerNode == true {
                /*if previousViews.count==2 {
                    var prev=previousViews[1]
                    if prev.subviews.count==1 {
                        prev=prev.subviews[0]
                        print("prev secondary controller=",type(of:prev)," value viewtype:",secondary.children[0].value?.viewType)
                    }
                }*/
                
                secondary.children[0].value?.build(in:_dataSource.detailController!.view,parent:nil,candidate:secondary.children[0].value!.viewController!.view,
                                                 constrainedTo:_dataSource.detailController!.view.frame.size,with:[],forceLayout:false)
                
                //print("primary is a controller 2 done")
                
                toUpdate.append(secondary.children[0])
            }
            else {
                if secondary.children.count==1 {
                    if secondary.children[0].value?.renderedView != nil {
                        //reuse
                        //print("zstackviewcreconcile reuse ",primary.children[0].value!.renderedView!)
                        //print("")
                        //print("reuse secondary split view")
                        secondary.children[0].value!.renderedView!.removeFromSuperview()
                        _dataSource.detailController!.view.addSubview(secondary.children[0].value!.renderedView!)
                    }
                    else {
                        //print("prev views:",previousViews)
                        if previousViews.count==1 {
                            var prev=previousViews[0];
                            if prev.subviews.count==2 {
                                prev=prev.subviews[1]
                                if prev is SCLUniversalSplitControllerDetailHolder {
                                    prev=prev.subviews[0]
                                    if prev is SCLUniversalSplitControllerDetailInnerHolder {
                                        prev=prev.subviews[0]
                                        if prev is SCLSplitContentView {
                                            prev=prev.subviews[0]
                                            secondary.children[0].value?.origCandidate=prev
                                        }
                                    }
                                }
                            }
                        }
                        
                        //print("")
                        //print("build secondary splitview orig candidate:",secondary.children[0].value?.origCandidate)
                        secondary.children[0].value?.build(in:_dataSource.detailController!.view,parent:nil,candidate:secondary.children[0].value?.origCandidate,
                                     constrainedTo:_dataSource.detailController!.view.frame.size,with:[],forceLayout:false)
                    }
                    
                    //print("scondary view do layout")
                    //dumpView(view:_dataSource.detailController!.view)
                    
                    secondary.children[0].value?.renderedView?.frame=CGRect.init(x: 0, y: 0, 
                            width: _dataSource.detailController!.view.frame.width, 
                            height: _dataSource.detailController!.view.frame.size.height)
                    //print("secondary frame:",secondary.children[0].value?.renderedView?.frame)
                            
                    secondary.children[0].value?.reconcile(in:_dataSource.detailController!.view,
                                                           constrainedTo:_dataSource.detailController!.view.frame.size,with:[])
                                                         
                    toUpdate.append(secondary.children[0])
                    
                    //print("scondary view did layout")
                    //dumpView(view:_dataSource.detailController!.view)
                }
                else {
                    print("Secondary node of SplitView has none or multiple children. Cannot build")
                }
            }
            
            //print("after layout splitview mastercontainer has ",_dataSource.masterController!.view.subviews.count," children")
            //print("after layout splitview detailcontainer has ",_dataSource.detailController!.view.subviews.count," children")
            //dumpView(controller:vc)
            
            //print("end of reconcilensplitview has layout:")
            //dumpView(view:vc.view)
            //print("toUpdate is:",toUpdate)
            
            return toUpdate
        }
        else {fatalError()}
    }
    
    public func structureMatches(to:ViewNode) -> Bool {
        if to.value==nil {return false}
        
        //print("splitview structurematches for self=",self," to=",to)
        
        if _primarytree.root.splitview?.value==nil {return false}
        
        if !_primarytree.root.splitview!.structureMatches(to:to) {return false}
        
        //print("structure matches")
        return true
    }
}
























