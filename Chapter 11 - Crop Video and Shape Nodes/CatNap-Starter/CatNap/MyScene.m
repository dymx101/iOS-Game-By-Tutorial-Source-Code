//
//  MyScene.m
//  CatNap
//
//  Created by Main Account on 8/30/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"
#import "SKSpriteNode+DebugDraw.h"
#import "SKTAudio.h"
#import "SKTUtils.h"

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory)
{
  CNPhysicsCategoryCat    = 1 << 0,  // 0001 = 1
  CNPhysicsCategoryBlock  = 1 << 1,  // 0010 = 2
  CNPhysicsCategoryBed    = 1 << 2,  // 0100 = 4
  CNPhysicsCategoryEdge   = 1 << 3,  // 1000 = 8
  CNPhysicsCategoryLabel  = 1 << 4,  // 10000 = 16
  CNPhysicsCategorySpring = 1 << 5,  // 100000 = 32
  CNPhysicsCategoryHook   = 1 << 6,  // 1000000 = 64
};

@interface MyScene()<SKPhysicsContactDelegate>
@end

@implementation MyScene
{
  SKNode *_gameNode;
  SKSpriteNode *_catNode;
  SKSpriteNode *_bedNode;

  int _currentLevel;
  BOOL _isHooked;

  SKSpriteNode *_hookBaseNode;
  SKSpriteNode *_hookNode;
  SKSpriteNode *_ropeNode;
}

- (instancetype)initWithSize:(CGSize)size
{
  if (self = [super initWithSize:size]) {
    [self initializeScene];
  }
  return self;
}

- (void)initializeScene
{
  self.physicsBody = 
    [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
  self.physicsWorld.contactDelegate = self;
  self.physicsBody.categoryBitMask = CNPhysicsCategoryEdge;

  SKSpriteNode* bg = 
    [SKSpriteNode spriteNodeWithImageNamed:@"background"];
  bg.position = 
    CGPointMake(self.size.width/2, self.size.height/2);
  [self addChild: bg];
  
  [self addCatBed];
  
  _gameNode = [SKNode node];
  [self addChild:_gameNode];

  _currentLevel = 4;
  [self setupLevel: _currentLevel];
}

- (void)addCatBed
{
  _bedNode = 
    [SKSpriteNode spriteNodeWithImageNamed:@"cat_bed"];
  _bedNode.position = CGPointMake(270, 15);
  [self addChild:_bedNode];
  
  CGSize contactSize = CGSizeMake(40, 30);
  _bedNode.physicsBody =
    [SKPhysicsBody bodyWithRectangleOfSize:contactSize];
  _bedNode.physicsBody.dynamic = NO;
  
  [_bedNode attachDebugRectWithSize:contactSize];
  _bedNode.physicsBody.categoryBitMask = CNPhysicsCategoryBed;
}

- (void)addCatAtPosition:(CGPoint)pos
{
  //add the cat in the level on its starting position
  _catNode = [
    SKSpriteNode spriteNodeWithImageNamed:@"cat_sleepy"];
  _catNode.position = pos;
  
  [_gameNode addChild:_catNode];
  
  CGSize contactSize = CGSizeMake(_catNode.size.width-40, 
    _catNode.size.height-10);

  _catNode.physicsBody =
    [SKPhysicsBody bodyWithRectangleOfSize: contactSize];
  [_catNode attachDebugRectWithSize: contactSize];
  
  _catNode.physicsBody.categoryBitMask = CNPhysicsCategoryCat;
  _catNode.physicsBody.contactTestBitMask = 
    CNPhysicsCategoryBed | CNPhysicsCategoryEdge;
  _catNode.physicsBody.collisionBitMask = 
    CNPhysicsCategoryBlock | CNPhysicsCategoryEdge |
      CNPhysicsCategorySpring;
}

- (void)setupLevel:(int)levelNum
{
  //load the plist file
  NSString *fileName = 
    [NSString stringWithFormat:@"level%i",levelNum];
  NSString *filePath = 
    [[NSBundle mainBundle] pathForResource:fileName
                                    ofType:@"plist"];
  NSDictionary *level = 
    [NSDictionary dictionaryWithContentsOfFile:filePath];
  
  if (level[@"seesawPosition"]) {
        [self addSeesawAtPosition: CGPointFromString(level[@"seesawPosition"])];
  }
  
  [self addCatAtPosition:
    CGPointFromString(level[@"catPosition"])];
  [self addBlocksFromArray:level[@"blocks"]];
  
  [[SKTAudio sharedInstance] playBackgroundMusic:@"bgMusic.mp3"];
  [self addSpringsFromArray: level[@"springs"]];

  if (level[@"hookPosition"]) {
    [self addHookAtPosition:  
      CGPointFromString(level[@"hookPosition"])];
  }
}

-(void)addBlocksFromArray:(NSArray*)blocks
{
  for (NSDictionary *block in blocks) {
    
    if (block[@"tuple"]) {
      //1
      CGRect rect1 = CGRectFromString([block[@"tuple"] firstObject]);
      SKSpriteNode* block1 = [self addBlockWithRect: rect1];
      block1.physicsBody.friction = 0.8;
      block1.physicsBody.categoryBitMask =
        CNPhysicsCategoryBlock;
      block1.physicsBody.collisionBitMask =
        CNPhysicsCategoryBlock | CNPhysicsCategoryCat |
      CNPhysicsCategoryEdge;
      [_gameNode addChild: block1];
                  
      //2
      CGRect rect2 = CGRectFromString([block[@"tuple"] lastObject]);
      SKSpriteNode* block2 = [self addBlockWithRect: rect2];
      block2.physicsBody.friction = 0.8;
      block2.physicsBody.categoryBitMask =
        CNPhysicsCategoryBlock;
      block2.physicsBody.collisionBitMask =
        CNPhysicsCategoryBlock | CNPhysicsCategoryCat |
      CNPhysicsCategoryEdge;
      [_gameNode addChild: block2];
      
      [self.physicsWorld addJoint: [SKPhysicsJointFixed 
        jointWithBodyA: block1.physicsBody
        bodyB: block2.physicsBody
        anchor:CGPointZero]
      ];
      
    } else {
      SKSpriteNode *blockSprite = [self addBlockWithRect:CGRectFromString(block[@"rect"])];
      blockSprite.physicsBody.categoryBitMask =
        CNPhysicsCategoryBlock;
      blockSprite.physicsBody.collisionBitMask =
        CNPhysicsCategoryBlock | CNPhysicsCategoryCat |
      CNPhysicsCategoryEdge;
      [_gameNode addChild:blockSprite];
    }
  }
}

-(SKSpriteNode*)addBlockWithRect:(CGRect)blockRect
{
  // 3
  NSString *textureName = [NSString stringWithFormat:
    @"%.fx%.f.png",blockRect.size.width, blockRect.size.height];
    
  // 4
  SKSpriteNode *blockSprite =
  [SKSpriteNode spriteNodeWithImageNamed:textureName];
  blockSprite.position = blockRect.origin;
    
  // 5
  CGRect bodyRect = CGRectInset(blockRect, 2, 2);
  blockSprite.physicsBody =
    [SKPhysicsBody bodyWithRectangleOfSize:bodyRect.size];
    
  //6
  [blockSprite attachDebugRectWithSize:blockSprite.size];
    
  return blockSprite;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesBegan:touches withEvent:event];
 
  // 1
  UITouch *touch = [touches anyObject];
  CGPoint location = [touch locationInNode:self];
  
  // 2
  [self.physicsWorld enumerateBodiesAtPoint:location
                                  usingBlock:
    ^(SKPhysicsBody *body, BOOL *stop) {
     // 3
     if (body.categoryBitMask == CNPhysicsCategoryBlock) {

        for (SKPhysicsJoint* joint in body.joints) {
          [self.physicsWorld removeJoint: joint];
          [joint.bodyA.node removeFromParent];
          [joint.bodyB.node removeFromParent];
        }

        [body.node removeFromParent];
        *stop = YES; // 4
       
        // 5
        [self runAction:[SKAction playSoundFileNamed:@"pop.mp3"
                           waitForCompletion:NO]];
      }
      
      if (body.categoryBitMask == CNPhysicsCategorySpring) {
          SKSpriteNode *spring = (SKSpriteNode*)body.node;

          [body applyImpulse:CGVectorMake(0, 12)
                     atPoint:CGPointMake(spring.size.width/2, 
                                         spring.size.height)];
               
          [body.node runAction:
            [SKAction sequence:@[[SKAction waitForDuration:1],
                                 [SKAction removeFromParent]]]];

          *stop = YES;
        }
      
        if (body.categoryBitMask == CNPhysicsCategoryCat && _isHooked) {
          [self releaseHook];
        }

    }];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
  uint32_t collision = (contact.bodyA.categoryBitMask |
                        contact.bodyB.categoryBitMask);
  if (collision == (CNPhysicsCategoryCat|CNPhysicsCategoryBed)) 
  {
    [self win];
  }
  
  if (collision == (CNPhysicsCategoryCat|CNPhysicsCategoryEdge))  
  {
    [self lose];
  }
  
  if (collision == (CNPhysicsCategoryLabel|CNPhysicsCategoryEdge)) {
        SKLabelNode* label = (contact.bodyA.categoryBitMask==CNPhysicsCategoryLabel)?(SKLabelNode*)contact.bodyA.node:(SKLabelNode*)contact.bodyB.node;
        
        if (label.userData==nil) {
            label.userData = [@{@"bounceCount":@0} mutableCopy];
        }
        
        int newBounceCount = [label.userData[@"bounceCount"] intValue]+1;
        NSLog(@"bounce: %i", newBounceCount);
        if (newBounceCount==4) {
            [label removeFromParent];
        } else {
            label.userData = [@{@"bounceCount":@(newBounceCount)} mutableCopy];
        }

    }
  
  if (collision == (CNPhysicsCategoryHook|CNPhysicsCategoryCat)) {
    //1
    _catNode.physicsBody.velocity = CGVectorMake(0, 0);
    _catNode.physicsBody.angularVelocity = 0;
          
    //2
    SKPhysicsJointFixed *hookJoint =
      [SKPhysicsJointFixed
        jointWithBodyA: _hookNode.physicsBody
        bodyB: _catNode.physicsBody
        anchor: CGPointMake(_hookNode.position.x,
                               
        _hookNode.position.y+_hookNode.size.height/2) ];
          
    [self.physicsWorld addJoint:hookJoint];

    //3
    _isHooked = YES;
  }
  
}

- (void)inGameMessage:(NSString*)text
{
  // 1
  SKLabelNode *label = 
    [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Regular"];
  label.text = text;
  label.fontSize = 64.0;
  label.color = [SKColor whiteColor];
  
  // 2
  label.physicsBody =
    [SKPhysicsBody bodyWithCircleOfRadius:10];
  label.physicsBody.collisionBitMask = CNPhysicsCategoryEdge;
  label.physicsBody.categoryBitMask = CNPhysicsCategoryLabel;
  label.physicsBody.contactTestBitMask = CNPhysicsCategoryEdge;
  label.physicsBody.restitution = 0.7;
  label.position = CGPointMake(self.frame.size.width/2,
                                self.frame.size.height);
    
  // 3
  [_gameNode addChild:label];
    
//  // 4
//  [label runAction:
//    [SKAction sequence:@[
//      [SKAction waitForDuration:3.0],
//      [SKAction removeFromParent]]]];
}

- (void)newGame
{
  [_gameNode removeAllChildren];
  [self setupLevel: _currentLevel];
  [self inGameMessage:[NSString stringWithFormat:
    @"Level %i", _currentLevel]];
}

- (void)lose
{
  if (_currentLevel>1) {
    _currentLevel--;
  }

  // 1
  _catNode.physicsBody.contactTestBitMask = 0;
  [_catNode setTexture:
   [SKTexture textureWithImageNamed:@"cat_awake"]];
  
  // 2
  [[SKTAudio sharedInstance] pauseBackgroundMusic];
  [self runAction:[SKAction playSoundFileNamed:@"lose.mp3"
                             waitForCompletion:NO]];
  
  [self inGameMessage:@"Try again ..."];
    
  // 3
  [self runAction:
    [SKAction sequence:
     @[[SKAction waitForDuration:5.0],
       [SKAction performSelector:@selector(newGame) 
                        onTarget:self]]]];
}

- (void)win
{
  if (_currentLevel<4) {
    _currentLevel++;
  }

  // 1
  _catNode.physicsBody=nil;

  // 2
  CGFloat curlY = _bedNode.position.y+_catNode.size.height/2;
  CGPoint curlPoint = CGPointMake(_bedNode.position.x, curlY);
    
  // 3
  [_catNode runAction:
   [SKAction group:
    @[[SKAction moveTo:curlPoint duration:0.66],
      [SKAction rotateToAngle:0 duration:0.5]]]];
  
      [self inGameMessage:@"Good job!"];
    
  // 4
  [self runAction:
    [SKAction sequence:
     @[[SKAction waitForDuration:5.0],
       [SKAction performSelector:@selector(newGame) 
                        onTarget:self]]]];

  // 5
  [_catNode runAction:
   [SKAction animateWithTextures:
    @[[SKTexture textureWithImageNamed:@"cat_curlup1"],
      [SKTexture textureWithImageNamed:@"cat_curlup2"],
      [SKTexture textureWithImageNamed:@"cat_curlup3"]]
                    timePerFrame:0.25]];
  
  // 6
  [[SKTAudio sharedInstance] pauseBackgroundMusic];
  [self runAction:[SKAction playSoundFileNamed:@"win.mp3"
                              waitForCompletion:NO]];
}

- (void)didSimulatePhysics
{
  CGFloat angle =
    CGPointToAngle(CGPointSubtract(_hookBaseNode.position,
                                   _hookNode.position));

  _ropeNode.zRotation = M_PI + angle;

  if (_catNode.physicsBody.contactTestBitMask && 
      fabs(_catNode.zRotation) > DegreesToRadians(25)) {
    if (_isHooked==NO) [self lose];
  }
}

- (void)addSpringsFromArray:(NSArray *)springs
{
  for (NSDictionary *spring in springs) {
    
    SKSpriteNode *springSprite =
      [SKSpriteNode spriteNodeWithImageNamed: @"spring"];
    springSprite.position =
      CGPointFromString(spring[@"position"]);
    
    springSprite.physicsBody = 
      [SKPhysicsBody bodyWithRectangleOfSize:springSprite.size];
    springSprite.physicsBody.categoryBitMask =
      CNPhysicsCategorySpring;
    springSprite.physicsBody.collisionBitMask =
      CNPhysicsCategoryEdge | CNPhysicsCategoryBlock |
        CNPhysicsCategoryCat;
    
    [springSprite attachDebugRectWithSize: springSprite.size];
    
    [_gameNode addChild: springSprite];
  }
}

- (void)addHookAtPosition:(CGPoint)hookPosition
{
  _hookBaseNode = nil;
  _hookNode = nil;
  _ropeNode = nil;

  _isHooked = NO;
  _hookBaseNode =
    [SKSpriteNode spriteNodeWithImageNamed:@"hook_base"];
  _hookBaseNode.position = CGPointMake(hookPosition.x, 
    hookPosition.y-_hookBaseNode.size.height/2);
  _hookBaseNode.physicsBody =
   [SKPhysicsBody bodyWithRectangleOfSize:_hookBaseNode.size];

  [_gameNode addChild:_hookBaseNode];
  
  SKPhysicsJointFixed *ceilingFix = 
    [SKPhysicsJointFixed
      jointWithBodyA:_hookBaseNode.physicsBody
               bodyB:self.physicsBody
              anchor:CGPointZero];
  [self.physicsWorld addJoint:ceilingFix];

  _ropeNode = [SKSpriteNode spriteNodeWithImageNamed:@"rope"];
  _ropeNode.anchorPoint = CGPointMake(0, 0.5);
  _ropeNode.position = _hookBaseNode.position; 
  [_gameNode addChild: _ropeNode];

  _hookNode = [SKSpriteNode spriteNodeWithImageNamed:@"hook"];
  _hookNode.position = CGPointMake(hookPosition.x, 
    hookPosition.y-63);
  _hookNode.physicsBody = 
    [SKPhysicsBody bodyWithCircleOfRadius:
       _hookNode.size.width/2];
  _hookNode.physicsBody.categoryBitMask = CNPhysicsCategoryHook;
  _hookNode.physicsBody.contactTestBitMask = CNPhysicsCategoryCat;
  _hookNode.physicsBody.collisionBitMask = kNilOptions;

  [_gameNode addChild: _hookNode];

  SKPhysicsJointSpring *ropeJoint = [SKPhysicsJointSpring
    jointWithBodyA:_hookBaseNode.physicsBody
    bodyB:_hookNode.physicsBody
    anchorA:_hookBaseNode.position
    anchorB: CGPointMake(_hookNode.position.x, 
      _hookNode.position.y+_hookNode.size.height/2)];

  [self.physicsWorld addJoint:ropeJoint];

}

- (void)releaseHook
{
  _catNode.zRotation = 0;

  [self.physicsWorld removeJoint:
  _hookNode.physicsBody.joints.lastObject];
  _isHooked = NO;
}

-(void)addSeesawAtPosition:(CGPoint)position
{
    //self.physicsWorld.gravity = CGPointZero;
    
    SKSpriteNode* seesawFix = [SKSpriteNode spriteNodeWithImageNamed:@"45x45"];
    seesawFix.position = position;
    seesawFix.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: seesawFix.size];
    seesawFix.physicsBody.collisionBitMask = kNilOptions;
    seesawFix.physicsBody.categoryBitMask = kNilOptions;
    [_gameNode addChild: seesawFix];

    SKPhysicsJointFixed* fixJoint = [SKPhysicsJointFixed jointWithBodyA: seesawFix.physicsBody
                                                             bodyB: self.physicsBody
                                                            anchor: CGPointZero];
    [self.physicsWorld addJoint: fixJoint];

    SKSpriteNode* seesaw = [SKSpriteNode spriteNodeWithImageNamed:@"430x30"];
    seesaw.position = position;
    seesaw.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: seesaw.size];
    seesaw.physicsBody.collisionBitMask = CNPhysicsCategoryCat | CNPhysicsCategoryBlock;
    [seesaw attachDebugRectWithSize: seesaw.size];
    [_gameNode addChild: seesaw];

    SKPhysicsJointPin *pin = [SKPhysicsJointPin jointWithBodyA:seesawFix.physicsBody
                                                         bodyB:seesaw.physicsBody
                                                        anchor:position];
    [self.physicsWorld addJoint: pin];
    
}

@end
