//
//  MyScene.m
//  SpriteKitPhysicsTest
//
//  Created by Main Account on 8/30/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene
{
  SKSpriteNode *_square;
  SKSpriteNode *_circle;
  SKSpriteNode *_triangle;
  SKSpriteNode *_octagon;
}

-(instancetype)initWithSize:(CGSize)size
{
  if(self = [super initWithSize:size])
  {
//    _square = [SKSpriteNode spriteNodeWithImageNamed:@"square"];
//    _square.position = CGPointMake(self.size.width * 0.25,
//                                   self.size.height * 0.50);
//    [self addChild:_square];

    _octagon = [SKSpriteNode spriteNodeWithImageNamed:@"octagon"];
    _octagon.position = CGPointMake(self.size.width * 0.25,
                                   self.size.height * 0.50);
    [self addChild:_octagon];

    _circle = [SKSpriteNode spriteNodeWithImageNamed:@"circle"];
    _circle.position = CGPointMake(self.size.width * 0.50,
                                   self.size.height * 0.50);
    _circle.physicsBody =
      [SKPhysicsBody bodyWithCircleOfRadius:_circle.size.width/2];
    [self addChild:_circle];

    _triangle = [SKSpriteNode spriteNodeWithImageNamed:@"triangle"];
    _triangle.position = CGPointMake(self.size.width * 0.75,
                                     self.size.height * 0.5);
    [self addChild:_triangle];
    
    self.physicsBody = 
      [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
//    _square.physicsBody =
//      [SKPhysicsBody bodyWithRectangleOfSize:_square.size];

    CGMutablePathRef octagonPath = CGPathCreateMutable();
    CGPathMoveToPoint(octagonPath, nil, -_octagon.size.width/4, -_octagon.size.height/2);
    CGPathAddLineToPoint(octagonPath, nil, _octagon.size.width/4, -_octagon.size.height/2);
    CGPathAddLineToPoint(octagonPath, nil, _octagon.size.width/2, -_octagon.size.height/4);
    CGPathAddLineToPoint(octagonPath, nil, _octagon.size.width/2, _octagon.size.height/4);
    CGPathAddLineToPoint(octagonPath, nil, _octagon.size.width/4, _octagon.size.height/2);
    CGPathAddLineToPoint(octagonPath, nil, -_octagon.size.width/4, _octagon.size.height/2);
    CGPathAddLineToPoint(octagonPath, nil, -_octagon.size.width/2, _octagon.size.height/4);
    CGPathAddLineToPoint(octagonPath, nil, -_octagon.size.width/2, -_octagon.size.height/4);
    CGPathAddLineToPoint(octagonPath, nil, -_octagon.size.width/4, -_octagon.size.height/2);
    _octagon.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:octagonPath];
    CGPathRelease(octagonPath);    
    
    //1
    CGMutablePathRef trianglePath = CGPathCreateMutable();
        
    //2
    CGPathMoveToPoint(
      trianglePath, nil, -_triangle.size.width/2, -_triangle.size.height/2);
        
    //3
    CGPathAddLineToPoint(
      trianglePath, nil, _triangle.size.width/2, -_triangle.size.height/2);
    CGPathAddLineToPoint(trianglePath, nil, 0, _triangle.size.height/2);
    CGPathAddLineToPoint(
      trianglePath, nil, -_triangle.size.width/2, -_triangle.size.height/2);

    //4
    _triangle.physicsBody =
      [SKPhysicsBody bodyWithPolygonFromPath:trianglePath];

    //5
    CGPathRelease(trianglePath);
    
    [self runAction:
     [SKAction repeatAction:
      [SKAction sequence:
       @[[SKAction performSelector:@selector(spawnSand)
                          onTarget:self],
         [SKAction waitForDuration:0.02]
         ]]
                      count:100]
    ];
    
  }
  return self;
}

- (void)spawnSand
{
  //create a small ball body
  SKSpriteNode *sand =
    [SKSpriteNode spriteNodeWithImageNamed:@"sand"];
  sand.position = CGPointMake(
      (float)(arc4random()%(int)self.size.width),   
      self.size.height - sand.size.height);
  sand.physicsBody =
    [SKPhysicsBody bodyWithCircleOfRadius:sand.size.width/2];
  sand.name = @"sand";
  [self addChild:sand];
  
  sand.physicsBody.restitution = 1.0;
  sand.physicsBody.density = 20.0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  for (SKSpriteNode *node in self.children) {
    if ([node.name isEqualToString:@"sand"])
      [node.physicsBody applyImpulse:
         CGVectorMake(0, arc4random()%50)];
  }
  
  SKAction *shake = [SKAction moveByX:0 y:10 duration:0.05];
  [self runAction:
    [SKAction repeatAction:
      [SKAction sequence:@[shake, [shake reversedAction]]]
                     count:5]];
  
}

@end
