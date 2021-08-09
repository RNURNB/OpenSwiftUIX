#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(AnyNode)
@interface CRAnyNode : NSObject
@end

NS_SWIFT_NAME(NodeLayoutOptions)
typedef NS_OPTIONS(NSUInteger, CRNodeLayoutOptions) {
  CRNodeLayoutOptionsNone = 1 << 0,
  CRNodeLayoutOptionsSizeContainerViewToFit = 1 << 1,
  CRNodeLayoutOptionsUseSafeAreaInsets = 1 << 2
};

@class CRNode;
@class CRNodeHierarchy;
@class CRContext;
@class CRCoordinator;
@class CRCoordinatorDescriptor;
@class CRNodeLayoutSpec<__covariant V : UIView *>;

NS_SWIFT_NAME(NodeDelegate)
@protocol CRNodeDelegate <NSObject>
@optional
/// The root node for this hierarchy is being configured and layed out.
/// Additional custom manual layout can be defined here.
/// @note: Use @viewWithKey or @viewsWithReuseIdentifier to query the desired views in the
/// installed view hierarchy.
- (void)rootNodeDidLayout:(CRNode *)node;
/// The node @renderedView just got inserted in the view hierarchy.
- (void)rootNodeDidMount:(CRNode *)node;

- (UIView*) constructView:(nullable UIView *)reusableView with:(nullable UIView *)parentView candidate:(nullable UIView *)candidate;

-(void) reconcileView:(CRNode *)node in:(nullable UIView *)candidateView constrainedTo:(CGSize)size 
                    with:(nullable UIView *)parentView forceLayout:(BOOL)forceLayout;

- (void) dismantleView:(UIView *)view;

//- (void) reuseView:(UIView *)view;

@end

NS_SWIFT_NAME(ConcreteNode)
@interface CRNode<__covariant V : UIView *> : CRAnyNode
/// The context associated with this node hierarchy.
@property(nonatomic, readonly, nullable, weak) CRContext *context;
/// The node hierarchy this node belongs to (if applicable).
@property(nonatomic, nullable, weak) CRNodeHierarchy *nodeHierarchy;
/// The reuse identifier for this node is its hierarchy.
/// Identifiers help Render understand which items have changed.
/// A custom *reuseIdentifier* is mandatory if the node has a custom creation closure.
@property(nonatomic, readonly) NSString *reuseIdentifier;
/// A unique key for the component/node (necessary if the associated coordinator is stateful).
@property(nonatomic, readonly, nullable) NSString *coordinatorKey;
/// This component is the n-th children.
@property(nonatomic, readonly) NSUInteger index;
/// The subnodes of this node.
@property(nonatomic, readonly) NSArray<CRNode *> *children;
/// The parent node (if this is not the root node in the hierarchy).
@property(nonatomic, readonly, nullable, weak) CRNode *parent;
/// Returns the root node for this node hierarchy.
@property(nonatomic, readonly) CRNode *root;
/// The type of the associated backing view.
@property(nonatomic, readonly) Class viewType;
/// Backing view for this node.
@property(nonatomic, readonly, nullable) V renderedView;
/// The layout delegate for this node.
@property(nonatomic, nullable, weak) id<CRNodeDelegate> delegate;
/// Whether this node is a @c CRNullNode or not.
@property(nonatomic, readonly) BOOL isNullNode;
/// Returns the associated coordinator.
/// @note: @c nil if this node hierarchy is not registered to any @c CRContext, or if
/// @c coordinatorType is @c nil.
@property(nonatomic, nullable, readonly) __kindof CRCoordinator *coordinator;
/// The type of the associated coordinator.
@property(nonatomic, nullable, readonly) CRCoordinatorDescriptor *coordinatorDescriptor;
/// View configuration block.
@property(nonatomic, copy, nonnull) void (^layoutSpec)(CRNodeLayoutSpec *,CRContext *);
@property(nonatomic) BOOL canReuseNodes;
@property(nonatomic, nullable) CRNode *header;
@property(nonatomic, nullable) CRNode *footer;
@property(nonatomic) int64_t tag;
@property(nonatomic) BOOL isControllerNode;
@property(nonatomic, nullable) UIViewController *viewController;
@property(nonatomic, nullable) V origCandidate;

#pragma mark Constructors

- (instancetype)initWithType:(Class)type
             reuseIdentifier:(nullable NSString *)reuseIdentifier
                         key:(nullable NSString *)key
                    viewInit:(UIView * (^_Nullable)(UIView* _Nullable))viewInit
                        viewUpdate:(void (^_Nullable)(UIView* _Nullable))viewUpdate
                  layoutSpec:(void (^)(CRNodeLayoutSpec<V> *,CRContext*))layoutSpec
                  /*dismantleNode:(void (^)(UIView*)) dismantleNode*/;

+ (instancetype)nodeWithType:(Class)type
             reuseIdentifier:(nullable NSString *)reuseIdentifier
                         key:(nullable NSString *)key
                    viewInit:(UIView * (^_Nullable)(UIView* _Nullable))viewInit
                         viewUpdate:(void (^_Nullable)(UIView* _Nullable))viewUpdate
                  layoutSpec:(void (^)(CRNodeLayoutSpec<V> *,CRContext*))layoutSpec
                  /*dismantleNode:(void (^)(UIView*)) dismantleNode*/;

+ (instancetype)nodeWithType:(Class)type layoutSpec:(void (^)(CRNodeLayoutSpec<V> *,CRContext*))layoutSpec;

#pragma mark Setup

/// Adds the nodes as children of this node.
- (instancetype)appendChildren:(NSArray<CRNode *> *)children;

/// Adds the node as children of this node.
- (instancetype)addChild:(CRNode *)child;

/// Bind this node to the @c CRCoordinator class passed as argument.
- (instancetype)bindCoordinator:(CRCoordinatorDescriptor *)descriptor;

-(void)setContext:(CRContext *)context;

-(void)setRenderedView:(nullable UIView*)view;

/// Register the context for the root node of this node hierarchy.
- (void)registerNodeHierarchyInContext:(CRContext *)context;

- (void)setNodeHierarchy:(CRNodeHierarchy *)nodeHierarchy;

- (void)setRootHierarchy:(CRNodeHierarchy *)nodeHierarchy;

- (void) addLayoutSpec:(void (^)(CRNodeLayoutSpec *)) spec;

-(void) shouldInvokeDidMount;

-(void) updateUIView:(UIView *)view doLayout:(BOOL) doLayout;

-(UIView*) rawView;

#pragma mark Render

- (void) reverse;

/// Reconcile the view hierarchy with the one in the container view passed as argument.
/// @note: This method also performs layout and configuration.
- (void)reconcileInView:(nullable UIView *)view
      constrainedToSize:(CGSize)size
            withOptions:(CRNodeLayoutOptions)options;

/// Layout and configure the views.
- (void)layoutConstrainedToSize:(CGSize)size withOptions:(CRNodeLayoutOptions)options;

/// Re-configure the node's backed view.
/// @note This won't invalidate the layout.
- (void)setNeedsConfigure;

#pragma mark Querying

/// Returns the view in the subtree of this node with the given @c key.
- (nullable UIView *)viewWithKey:(NSString *)key;

/// Returns all the views that have been registered with the given @c reuseIdentifier.
- (NSArray<UIView *> *)viewsWithReuseIdentifier:(NSString *)reuseIdentifier;

-(BOOL)canReuseNode:(UIView*) view;

-(void)updateReusedNode:(UIView*) view;
                    
- (void)buildInView:(nullable UIView *)view
          parent:(nullable CRNode*) parent
          candidate:(nullable UIView*)candidate
          constrainedToSize:(CGSize)size
          withOptions:(CRNodeLayoutOptions)options
          forceLayout:(BOOL)forceLayout;
    
- (void)_constructViewWithReusableView:(nullable UIView *)reusableView with:(nullable UIView *)parentView candidate:(nullable UIView *)candidate;
- (void)_reconcileNode:(CRNode *)node inView:(nullable UIView *)candidateView constrainedToSize:(CGSize)size 
                        withParentView:(nullable UIView *)parentView forceLayout:(BOOL)forceLayout;
- (void)_dismantleView:(UIView *)view;
//- (void)_reuseNode:(UIView *)view;
//- (void)_dismantleNode:(UIView *)view;

-(BOOL) _structureMatchesTo:(CRNode*) to;

-(CRNode *) viewnode;

@end

NS_SWIFT_NAME(NullNode)
@interface CRNullNode : CRNode

/// The default nil node instance.
@property(class, readonly) CRNullNode *nullNode;

@end

NS_ASSUME_NONNULL_END
