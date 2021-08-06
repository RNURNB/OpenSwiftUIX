#import "CRNodeLayoutSpec.h"
#import "CRContext.h"
#import "CRCoordinator.h"
#import "CRMacros.h"
#import "CRNode.h"
#import "CRNodeBridge.h"
#import "UIView+CRNode.h"

@implementation CRNodeLayoutSpec {
  //NSMutableDictionary<NSString *, CRNodeLayoutSpecProperty *> *_properties;
  //NSString *_properties2;
}

- (void)set:(NSString *)keyPath value:(id)value {
  [self set:keyPath value:value animator:nil];
}

- (void)set:(NSString *)keyPath value:(id)value animator:(UIViewPropertyAnimator *)animator {
  CR_ASSERT_ON_MAIN_THREAD();
  static Class swiftValueClass;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^() {
    swiftValueClass = NSClassFromString(@"__SwiftValue");
  });
  if ([value isKindOfClass:swiftValueClass]) {
    CR_LOG(@"__SwiftValue passed for key %@. Make sure your enum conforms to "
           @"WritableKeyPathBoxableEnum. ",
           keyPath);
    return;
  }
  /*const auto property = [[CRNodeLayoutSpecProperty alloc] initWithKeyPath:keyPath
                                                                    value:value
                                                                 animator:animator];*/
  //_properties[keyPath] = property;
  /*NSRange rng1 = [_properties2 rangeOfString:[keyPath stringByAppendingString:@";"] options:NSLiteralSearch];
  if (rng1.location == NSNotFound)
      _properties2=[_properties2 stringByAppendingString:[keyPath stringByAppendingString:@";"]];*/
  [_view.cr_nodeBridge setPropertyWithKeyPath:keyPath value:value animator:animator];
}

-(BOOL) containsProperty:(NSString*)keyPath {
  //NSRange rng = [_properties2 rangeOfString:[keyPath stringByAppendingString:@";"] options:NSLiteralSearch];
  //return rng.location != NSNotFound;
  return false;
}

- (instancetype)initWithNode:(CRNode *)node constrainedToSize:(CGSize)size {
  if (self = [super init]) {
    _node = node;
    _view = node.renderedView;
    _context = node.context;
    _size = size;
  }
  return self;
}

- (__kindof CRCoordinator *)coordinatorOfType:(Class)coordinatorType {
  if (![coordinatorType isSubclassOfClass:CRCoordinator.class]) return nil;

  auto coordinator = (CRCoordinator *)nil;
  auto node = self.node;
  auto context = self.context;
  NSAssert(node, @"Called when *node* is nil.");
  NSAssert(context, @"Called when *context* is nil.");
  while (node) {
    if (node.coordinatorDescriptor.type == coordinatorType) {
      coordinator = node.coordinator;
      break;
    }
    node = node.parent;
  }
  return coordinator;
}

- (void)restore {
    //NSLog(@"NodeLayoutSpec restore");
  [_view.cr_nodeBridge restore];
}

- (void)resetAllTargets {
  [_view cr_resetAllTargets];
}

@end

@implementation CRNodeLayoutSpecProperty

- (instancetype)initWithKeyPath:(NSString *)keyPath
                          value:(id)value
                       animator:(UIViewPropertyAnimator *)animator {
  if (self = [super init]) {
    _keyPath = keyPath;
    _value = value;
    _animator = animator;
  }
  return self;
}

@end


@implementation LayoutSpecWrapper 

- (instancetype)init {
  if (self = [super init]) {
     _layoutSpec=NULL;
  }
  return self;
}

- (void) add:(void (^)(CRNodeLayoutSpec *)) spec {
  CR_ASSERT_ON_MAIN_THREAD();
  void (^oldBlock)(CRNodeLayoutSpec *) = [_layoutSpec copy];
  void (^newBlock)(CRNodeLayoutSpec *) = [spec copy];
  _layoutSpec = [^(CRNodeLayoutSpec *spec) {
    if (oldBlock != nil) oldBlock(spec);
    if (newBlock != nil) newBlock(spec);
  } copy];
}

@end









