#import "CRNode.h"
#import "CRContext.h"
#import "CRCoordinator+Private.h"
#import "CRMacros.h"
#import "CRNodeBridge.h"
#import "CRNodeHierarchy.h"
#import "CRNodeLayoutSpec.h"
#import "UIView+CRNode.h"
#import "YGLayout.h"

@implementation CRAnyNode
@end
 
@interface CRNode ()
@property(nonatomic, readwrite) __kindof CRCoordinator *coordinator;
//@property(nonatomic, readwrite) NSUInteger index;
@property(nonatomic, readwrite, nullable, weak) CRNode *parent;
@property(nonatomic, readwrite, nullable) __kindof UIView *renderedView;
/// The view initialization block.
@property(nonatomic, copy) UIView * (^viewInit)(UIView*);
@property(nonatomic, copy) void (^viewUpdate)(UIView*);

//@property(nonatomic, copy) void (^dodismantleNode)(UIView*);

@end

void CRIllegalCoordinatorTypeException(NSString *reason) {
  @throw [NSException exceptionWithName:@"IllegalCoordinatorTypeException"
                                 reason:reason
                               userInfo:nil];
}

@implementation CRNode {
  NSMutableArray<CRNode *> *_mutableChildren;
  __weak CRNodeHierarchy *_nodeHierarchy;
  __weak CRContext *_context;
  CGSize _size;
  struct {
    unsigned int shouldInvokeDidMount : 1;
  } __attribute__((packed, aligned(1))) _flags;
}

#pragma mark - Initializer

- (instancetype)initWithType:(Class)type
             reuseIdentifier:(NSString *)reuseIdentifier
                         key:(NSString *)key
                    viewInit:(UIView * (^_Nullable)(UIView* _Nullable))viewInit
                        viewUpdate:(void (^_Nullable)(UIView* _Nullable))viewUpdate
                  layoutSpec:(void (^)(CRNodeLayoutSpec<UIView *> *,CRContext*))layoutSpec 
                  /*dismantleNode:(void (^)(UIView*)) dismantleNode*/ {
  if (self = [super init]) {
    _reuseIdentifier = CR_NIL_COALESCING(reuseIdentifier, NSStringFromClass(type));
    _coordinatorKey = key;
    _viewType = type;
    _mutableChildren = [[NSMutableArray alloc] init];
    self.viewInit = viewInit;
    self.viewUpdate = viewUpdate;
    self.layoutSpec = layoutSpec;
    //self.dodismantleNode = dismantleNode;
    self.canReuseNodes=false;
    self.isControllerNode=false;
    self.viewController=nil;
  }
  return self;
}

- (void) addLayoutSpec:(void (^)(CRNodeLayoutSpec *)) spec {
  CR_ASSERT_ON_MAIN_THREAD();
  void (^oldBlock)(CRNodeLayoutSpec *,CRContext *) = [self.layoutSpec copy];
  void (^newBlock)(CRNodeLayoutSpec *,CRContext *) = [spec copy];
  self.layoutSpec = [^(CRNodeLayoutSpec *spec,CRContext *) {
    if (oldBlock != nil) oldBlock(spec,_context);
    if (newBlock != nil) newBlock(spec,_context);
  } copy];
}

#pragma mark - Convenience Initializer

+ (instancetype)nodeWithType:(Class)type
             reuseIdentifier:(NSString *)reuseIdentifier
                         key:(nullable NSString *)key
                    viewInit:(UIView * (^_Nullable)(UIView* _Nullable))viewInit
                        viewUpdate:(void (^_Nullable)(UIView* _Nullable))viewUpdate
                  layoutSpec:(void (^)(CRNodeLayoutSpec<UIView *> *, CRContext *))layoutSpec
                  /*dismantleNode:(void (^)(UIView*)) dismantleNode*/ {
  return [[CRNode alloc] initWithType:type
                      reuseIdentifier:reuseIdentifier
                                  key:key
                             viewInit:viewInit
                            viewUpdate:viewUpdate
                           layoutSpec:layoutSpec
                           /*dismantleNode:dismantleNode*/];
}

+ (instancetype)nodeWithType:(Class)type
                  layoutSpec:(void (^)(CRNodeLayoutSpec<UIView *> *,CRContext*))layoutSpec {
  return [[CRNode alloc] initWithType:type
                      reuseIdentifier:nil
                                  key:nil
                             viewInit:nil
                             viewUpdate:nil
                           layoutSpec:layoutSpec
                           /*dismantleNode:nil*/];
}

#pragma mark - Context

- (void)registerNodeHierarchyInContext:(CRContext *)context {
  CR_ASSERT_ON_MAIN_THREAD();
  if (!_parent) {
    _context = context;
    [self _recursivelyConfigureCoordinatorsInNodeHierarchy];
  } else
    [_parent registerNodeHierarchyInContext:context];
}

- (void)_recursivelyConfigureCoordinatorsInNodeHierarchy {
  self.coordinator.node = self;
  CR_FOREACH(child, _mutableChildren) { [child _recursivelyConfigureCoordinatorsInNodeHierarchy]; }
}

- (CRContext *)context {
  if (_context) return _context;
  return _parent.context;
}

-(void)setContext:(CRContext *)context {
  _context=context;
}

-(void)setRenderedView:(nullable UIView*)view {
  _renderedView=view;
}

- (CRNode *)root {
  if (!_parent) return self;
  return _parent.root;
}

- (__kindof CRCoordinator *)coordinator {
  const auto context = self.context;
  if (!context) return nil;
  if (!_coordinatorDescriptor) return _parent.coordinator;
  return [context coordinator:_coordinatorDescriptor];
}

- (CRNodeHierarchy *)nodeHierarchy {
  if (!_parent) return _nodeHierarchy;
  return _parent.nodeHierarchy;
}

- (void)setNodeHierarchy:(CRNodeHierarchy *)nodeHierarchy {
  if (!_parent) {
    _nodeHierarchy = nodeHierarchy;
    return;
  }
  [_parent setNodeHierarchy:nodeHierarchy];
}

- (void)setRootHierarchy:(CRNodeHierarchy *)nodeHierarchy {
  if (!_parent) {
    _nodeHierarchy = nodeHierarchy;
    return;
  }
  [_parent setNodeHierarchy:nodeHierarchy];
}

#pragma mark - Children

- (BOOL)isNullNode {
  return false;
}

- (NSArray<CRNode *> *)children {
  return _mutableChildren;
}

- (instancetype)appendChildren:(NSArray<CRNode *> *)children {
  CR_ASSERT_ON_MAIN_THREAD();
  //auto lastIndex = _mutableChildren.lastObject.index;
  CR_FOREACH(child, children) {
    if (child.isNullNode) continue;
    //child.index = lastIndex++;
    child.parent = self;
    [_mutableChildren addObject:child];
  }
  return self;
}

- (instancetype)addChild:(CRNode *)child {
 CR_ASSERT_ON_MAIN_THREAD();
  //auto lastIndex = _mutableChildren.lastObject.index;
  
    if (child.isNullNode) return self;
    //child.index = lastIndex++;
    child.parent = self;
    [_mutableChildren addObject:child];
  
  return self;
}

- (void) reverse {
  _mutableChildren = [[_mutableChildren reverseObjectEnumerator] allObjects];
}

- (instancetype)bindCoordinator:(CRCoordinatorDescriptor *)descriptor {
  CR_ASSERT_ON_MAIN_THREAD();
  _coordinatorDescriptor = descriptor;
  return self;
}

#pragma mark - Querying

- (UIView *)viewWithKey:(NSString *)key {
  if ([_coordinatorKey isEqualToString:key]) return _renderedView;
  CR_FOREACH(child, _mutableChildren) {
    const auto view = [child viewWithKey:key];
    if (view) return view;
  }
  return nil;
}

- (NSArray<UIView *> *)viewsWithReuseIdentifier:(NSString *)reuseIdentifier {
  auto result = [[NSMutableArray alloc] init];
  [self _viewsWithReuseIdentifier:reuseIdentifier withArray:result];
  return result;
}

- (void)_viewsWithReuseIdentifier:(NSString *)reuseIdentifier
                        withArray:(NSMutableArray<UIView *> *)array {
  if ([_coordinatorKey isEqualToString:reuseIdentifier] && _renderedView) {
    [array addObject:_renderedView];
  }
  CR_FOREACH(child, _mutableChildren) {
    [child _viewsWithReuseIdentifier:reuseIdentifier withArray:array];
  }
}

#pragma mark - Layout

- (void)_constructViewWithReusableView:(nullable UIView *)reusableView with:(nullable UIView *)parentView candidate:(nullable UIView *)candidate {
  CR_ASSERT_ON_MAIN_THREAD();

  if ([self.delegate respondsToSelector:@selector(constructView:with:candidate:)]) {
     [self.delegate constructView:reusableView with:parentView candidate:candidate];
     return;
  }

  if (_renderedView != nil) return;

  if ([reusableView isKindOfClass:self.viewType]) {
     if (_viewInit) {
      _renderedView = _viewInit(reusableView);
    } else {
      _renderedView = reusableView;
    }
    _renderedView.cr_nodeBridge.node = self;
    _renderedView.yoga.isEnabled = true;
    _renderedView.tag = _reuseIdentifier.hash;
  } else {
    if (_viewInit) {
      _renderedView = _viewInit(nil);
    } else {
      _renderedView = [[self.viewType alloc] initWithFrame:CGRectZero];
    }
    _renderedView.yoga.isEnabled = true;
    _renderedView.tag = _reuseIdentifier.hash;
    _renderedView.cr_nodeBridge.node = self;
    _flags.shouldInvokeDidMount = true;
  }
}

-(UIView*) rawView {
    return [[self.viewType alloc] initWithFrame:CGRectZero];
}

-(void) shouldInvokeDidMount {
    _flags.shouldInvokeDidMount = true;
}

- (void)_configureConstrainedToSize:(CGSize)size withOptions:(CRNodeLayoutOptions)options {
  [self _constructViewWithReusableView:nil with:nil candidate:nil];
  [_renderedView.cr_nodeBridge storeViewSubTreeOldGeometry];
  const auto spec = [[CRNodeLayoutSpec alloc] initWithNode:self constrainedToSize:size];
  if (_layoutSpec) _layoutSpec(spec,_context);

  CR_FOREACH(child, _mutableChildren) {
    [child _configureConstrainedToSize:size withOptions:options];
  }

  if (_renderedView.yoga.isEnabled && _renderedView.yoga.isLeaf &&
      _renderedView.yoga.isIncludedInLayout) {
    //_renderedView.frame.size = CGSizeZero;
    auto rect = _renderedView.frame;
    rect.size = _renderedView.yoga.intrinsicSize;
    _renderedView.frame = rect;
    [_renderedView.yoga markDirty];
  }

  if (spec.onLayoutSubviews) {
    spec.onLayoutSubviews(self, _renderedView, size);
  }
}

- (void)_computeFlexboxLayoutConstrainedToSize:(CGSize)size {
  auto rect = CGRectZero;
  rect.size = size;
  _renderedView.frame = rect;
  [_renderedView.yoga applyLayoutPreservingOrigin:NO];
  rect = _renderedView.frame;
  rect.size = _renderedView.yoga.intrinsicSize;
  _renderedView.frame = rect;
  [_renderedView.yoga applyLayoutPreservingOrigin:NO];
  rect = _renderedView.frame;
  [_renderedView cr_normalizeFrame];
}

- (void)_animateLayoutChangesIfNecessary {
  const auto animator = self.context.layoutAnimator;
  const auto view = _renderedView;
  if (!animator) return;
  [view.cr_nodeBridge storeViewSubTreeNewGeometry];
  [view.cr_nodeBridge applyViewSubTreeOldGeometry];
  [animator stopAnimation:YES];
  [animator addAnimations:^{
    [view.cr_nodeBridge applyViewSubTreeNewGeometry];
  }];
  [view.cr_nodeBridge fadeInNewlyCreatedViewsInViewSubTreeWithDelay:animator.duration];
  [animator startAnimation];
}

- (void)layoutConstrainedToSize:(CGSize)size withOptions:(CRNodeLayoutOptions)options {
  CR_ASSERT_ON_MAIN_THREAD();
  if (_parent != nil) return [_parent layoutConstrainedToSize:size withOptions:options];

  _size = size;
  auto safeAreaOffset = CGPointZero;
  if (@available(iOS 11, *)) {
    if (options & CRNodeLayoutOptionsUseSafeAreaInsets) {
      UIEdgeInsets safeArea = _renderedView.superview.safeAreaInsets;
      CGFloat heightInsets = safeArea.top + safeArea.bottom;
      CGFloat widthInsets = safeArea.left + safeArea.right;
      size.height -= heightInsets;
      size.width -= widthInsets;
      safeAreaOffset.x = safeArea.left;
      safeAreaOffset.y = safeArea.top;
    }
  }
  NSUInteger numberOfLayoutPasses = 1;
  for (NSUInteger pass = 0; pass < numberOfLayoutPasses; pass++) {
    [self _configureConstrainedToSize:size withOptions:options];
    [self _computeFlexboxLayoutConstrainedToSize:size];
  }
  
  auto frame = _renderedView.frame;
  frame.origin.x += safeAreaOffset.x;
  frame.origin.y += safeAreaOffset.y;
  _renderedView.frame = frame;

  if ((options & CRNodeLayoutOptionsSizeContainerViewToFit) && _renderedView.superview != nil){
    auto superview = _renderedView.superview;
    UIEdgeInsets insets;
    insets.left = CR_NORMALIZE(_renderedView.yoga.marginLeft);
    insets.right = CR_NORMALIZE(_renderedView.yoga.marginRight);
    insets.top = CR_NORMALIZE(_renderedView.yoga.marginTop);
    insets.bottom = CR_NORMALIZE(_renderedView.yoga.marginBottom);
    auto rect = CGRectInset(_renderedView.bounds, -(insets.left + insets.right),
                            -(insets.top + insets.bottom));
    rect.origin = superview.frame.origin;
    superview.frame = rect;
  }
  [_renderedView cr_adjustContentSizePostLayoutRecursivelyIfNeeded];

  [self.coordinator onLayout];
  [self _animateLayoutChangesIfNecessary];
}

-(BOOL)canReuseNode:(UIView*) view {
  return self.canReuseNodes;
}

-(void)updateReusedNode:(UIView*) view {
  if (_viewUpdate) {
      _viewUpdate(view);
  }
}

//update node and all subnodes
-(void) updateUIView:(UIView *)view doLayout:(BOOL) doLayout {
    if (doLayout) {
        const auto spec = [[CRNodeLayoutSpec alloc] initWithNode:self constrainedToSize:view.frame.size];
        if (_layoutSpec) _layoutSpec(spec,_context);
    }
    
    if (_viewUpdate) {
      _viewUpdate(view);
    }
    
    // update all of the subviews.
    const auto subviews = [[NSMutableArray<UIView *> alloc] initWithCapacity:view.subviews.count];
    CR_FOREACH(subview, view.subviews) {
        if (!subview.cr_hasNode) continue;
        [subviews addObject:subview];
    }
    
    CR_FOREACH(subview, subviews) {
        [subview.cr_nodeBridge.node updateUIView:subview.cr_nodeBridge.node.renderedView doLayout:false];
    }
}

-(BOOL) _structureMatchesTo:(CRNode*) to {
  if (_viewType != to.viewType) return false;

  //if (canReuseNode == false) return false;

  if ([self.children count] != [to.children count]) return false;

  int i=0;
  CR_FOREACH(child, self.children) {
     CRNode* n=[to.children objectAtIndex:i];
     if (![child _structureMatchesTo:n]) return false;
     i=i+1;
  }
  
  return true;
}

- (void)_reconcileNode:(CRNode *)node
             inView:(nullable UIView *)candidateView
             constrainedToSize:(CGSize)size
             withParentView:(nullable UIView *)parentView
             forceLayout:(BOOL)forceLayout {
            
  if ([self.delegate respondsToSelector:@selector(reconcileView:in:constrainedTo:with:forceLayout:)]) {
     [self.delegate reconcileView:node in:candidateView constrainedTo:size with:parentView forceLayout:forceLayout];
     return;
  }         
  
  //NSLog(@"reconcileNode objc");
            
  // The candidate view is a good match for reuse.
  BOOL canReuse=false;
  if (candidateView != NULL && [candidateView isKindOfClass:node.viewType] && 
       candidateView.cr_hasNode && candidateView.tag == node.reuseIdentifier.hash) {
    if ([node canReuseNode:candidateView]==true) {
          if (node.renderedView != nil) {
                [node.renderedView removeFromSuperview];
                /*if (node.renderedView == candidateView) {
                    NSLog(@"reuse node true reuse with candidate");
                }
                else {
                    NSLog(@"*****reuse node true reuse with existing view");
                }*/
                node.renderedView=nil;
          }
          //else NSLog(@"reuse node true reuse with empty view");
        [node _constructViewWithReusableView:candidateView with:parentView candidate:candidateView];
        candidateView.cr_nodeBridge.isNewlyCreated = false;
        //[candidateView.cr_nodeBridge.initialPropertyValues removeAllObjects]
        canReuse=true;
        //[node.renderedView removeFromSuperview];
        //[self updateReusedNode:self.renderedView];
    }
    else {
      //NSLog(@"reuse node skipped reuse");
      [candidateView removeFromSuperview];
      [node _constructViewWithReusableView:nil with:parentView candidate:nil];
      node.renderedView.cr_nodeBridge.isNewlyCreated = true;
      //[parentView insertSubview:node.renderedView atIndex:node.index];
    }
    // The view for this node needs to be created.
  } else {
    if (candidateView != NULL) {
         [candidateView removeFromSuperview];
         //NSLog(@"new node for existing candidate");
     }
     //else NSLog(@"new node");
    [node _constructViewWithReusableView:nil with:parentView candidate:nil];
    node.renderedView.cr_nodeBridge.isNewlyCreated = true;
    //[parentView insertSubview:node.renderedView atIndex:node.index];
  }
  if (parentView != nil) {[parentView addSubview:node.renderedView];}
  const auto view = node.renderedView;

  // Get all of the subviews.
  const auto subviews = [[NSMutableArray<UIView *> alloc] initWithCapacity:view.subviews.count];
  CR_FOREACH(subview, view.subviews) {
    if (!subview.cr_hasNode) continue;
    [subviews addObject:subview];
  }
  
  /*for (UIView *subUIView in view.subviews) {
        [subUIView removeFromSuperview];
  }*/
  
  // Iterate children.
  CR_FOREACH(child, node.children) {
    UIView *candidateView = nil;

    if (canReuse) {
        auto index = 0;
        CR_FOREACH(subview, subviews) {
          if ([subview isKindOfClass:child.viewType] && subview.tag == child.reuseIdentifier.hash) {
                candidateView = subview;
                break;
          }
          break; //only reuse first child
          index++;
        }
        // Pops the candidate view from the collection.
        if (candidateView != nil) [subviews removeObjectAtIndex:index];
        else canReuse=false; //stop reusing views
    }
    
    // Recursively reconcile the subnode.
    [node _reconcileNode:child
                   inView:candidateView
        constrainedToSize:size
           withParentView:node.renderedView forceLayout:false];
  }
  // Remove all of the obsolete old views that couldn't be recycled.
  CR_FOREACH(subview, subviews) { [subview removeFromSuperview]; }
}

- (void)_dismantleView:(UIView *)view {
    if ([self.delegate respondsToSelector:@selector(dismantleView:)]) {
     [self.delegate dismantleView:view];
     return;
  } 
}

/*
- (void)_dismantleNode:(UIView *)view {
    if (_dodismantleNode) {
        _dodismantleNode(view);
    }
}
*/

/*
- (void)_reuseNode:(UIView *)view {
    if ([self.delegate respondsToSelector:@selector(reuseView:)]) {
     [self.delegate reuseView:view];
     return;
  } 
}
*/

- (void)reconcileInView:(UIView *)view
      constrainedToSize:(CGSize)size
            withOptions:(CRNodeLayoutOptions)options {
  CR_ASSERT_ON_MAIN_THREAD();
  /*if (_parent != nil)
    return [_parent reconcileInView:view constrainedToSize:size withOptions:options];

  _size = size;
  const auto containerView = CR_NIL_COALESCING(view, _renderedView.superview);
  const auto bounds = CGSizeEqualToSize(size, CGSizeZero) ? containerView.bounds.size : size;
  //[containerView.subviews.firstObject removeFromSuperview];
  [self _reconcileNode:self
         inView:containerView.subviews.firstObject
              constrainedToSize:bounds
         withParentView:containerView];

  [self layoutConstrainedToSize:size withOptions:options];

  if (_flags.shouldInvokeDidMount &&
      [self.delegate respondsToSelector:@selector(rootNodeDidMount:)]) {
    _flags.shouldInvokeDidMount = false;
    [self.delegate rootNodeDidMount:self];
  }
  */
  const auto cview = CR_NIL_COALESCING(view, _renderedView.superview);
  [self buildInView:cview parent:_parent candidate:cview.subviews.firstObject constrainedToSize:size withOptions:options forceLayout:false];
}

- (void)buildInView:(nullable UIView *)view
          parent:(nullable CRNode*) parent
          candidate:(nullable UIView*)candidate
          constrainedToSize:(CGSize)size
          withOptions:(CRNodeLayoutOptions)options 
          forceLayout:(BOOL)forceLayout {
  CR_ASSERT_ON_MAIN_THREAD();
  _parent=parent;
  if (_parent != nil)
    return [_parent reconcileInView:view constrainedToSize:size withOptions:options];

  _size = size;
  const auto containerView=view;
  const auto bounds = CGSizeEqualToSize(size, CGSizeZero) ? containerView.bounds.size : size;
  //[containerView.subviews.firstObject removeFromSuperview];
  [self _reconcileNode:self
                 inView:candidate
                 constrainedToSize:bounds
                 withParentView:containerView
                 forceLayout:forceLayout];
                  
   //NSLog(@"dolayout crnode");

  [self layoutConstrainedToSize:size withOptions:options];
  
   //NSLog(@"didlayout crnode");

  if (_flags.shouldInvokeDidMount &&
      [self.delegate respondsToSelector:@selector(rootNodeDidMount:)]) {
    _flags.shouldInvokeDidMount = false;
    [self.delegate rootNodeDidMount:self];
  }
}

- (void)setNeedsConfigure {
  const auto spec = [[CRNodeLayoutSpec alloc] initWithNode:self constrainedToSize:_size];
  if (_layoutSpec) _layoutSpec(spec,_context);
}

-(CRNode *) viewnode {
  return self;
}

@end

#pragma mark - nullNode

@implementation CRNullNode

+ (instancetype)nullNode {
  static CRNullNode *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (BOOL)isNullNode {
  return true;
}

@end
