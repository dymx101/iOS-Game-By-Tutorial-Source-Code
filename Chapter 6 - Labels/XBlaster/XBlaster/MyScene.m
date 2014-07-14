//
//  MyScene.m
//  XBlaster
//
//  Created by Main Account on 8/31/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"
#import "PlayerShip.h"

@implementation MyScene {
  SKNode *_playerLayerNode;
  SKNode *_hudLayerNode;
  SKAction *_scoreFlashAction;
  SKLabelNode *_playerHealthLabel;
  NSString    *_healthBar;
  PlayerShip *_playerShip;
  CGPoint _deltaPoint;
}

-(id)initWithSize:(CGSize)size {    
   if (self = [super initWithSize:size]) {
    [self setupSceneLayers];
    [self setupUI];
    [self setupEntities];
  }
  return self;
}

- (void)setupSceneLayers
{
  _playerLayerNode = [SKNode node];
  [self addChild:_playerLayerNode];
  
  _hudLayerNode = [SKNode node];
  [self addChild:_hudLayerNode]; 
}

- (void)setupUI
{
  int barHeight = 45;
  CGSize backgroundSize = 
    CGSizeMake(self.size.width, barHeight);

  SKColor *backgroundColor =
    [SKColor colorWithRed:0 green:0 blue:0.05 alpha:1.0];
  SKSpriteNode *hudBarBackground = 
    [SKSpriteNode spriteNodeWithColor:backgroundColor
                                 size:backgroundSize];
  hudBarBackground.position = 
    CGPointMake(0, self.size.height - barHeight);  
  hudBarBackground.anchorPoint = CGPointZero;
  [_hudLayerNode addChild:hudBarBackground];
  
  // 1
  SKLabelNode *scoreLabel =
    [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
  // 2
  scoreLabel.fontSize = 20.0;
  scoreLabel.text = @"Score: 0";
  scoreLabel.name = @"scoreLabel";
  // 3
  scoreLabel.verticalAlignmentMode = 
    SKLabelVerticalAlignmentModeCenter;
  // 4
  scoreLabel.position = 
    CGPointMake(self.size.width / 2, 
                self.size.height - scoreLabel.frame.size.height + 3);
  // 5
  [_hudLayerNode addChild:scoreLabel];
  
  _scoreFlashAction = [SKAction sequence:
                     @[[SKAction scaleTo:1.5 duration:0.1],
                       [SKAction scaleTo:1.0 duration:0.1]]];
  [scoreLabel runAction:
    [SKAction repeatAction:_scoreFlashAction count:10]];

  // 1
  _healthBar =
    @"===================================================";
  float testHealth = 75;
  NSString * actualHealth = [_healthBar substringToIndex:
    (testHealth / 100 * _healthBar.length)];

  // 2
  SKLabelNode *playerHealthBackground = 
    [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
  playerHealthBackground.name = @"playerHealthBackground";
  playerHealthBackground.fontColor = [SKColor darkGrayColor];
  playerHealthBackground.fontSize = 10.0f;
  playerHealthBackground.text = _healthBar;

  // 3
  playerHealthBackground.horizontalAlignmentMode = 
    SKLabelHorizontalAlignmentModeLeft;
  playerHealthBackground.verticalAlignmentMode = 
    SKLabelVerticalAlignmentModeTop;
  playerHealthBackground.position = 
    CGPointMake(0, 
                self.size.height - barHeight + 
                  playerHealthBackground.frame.size.height);
  [_hudLayerNode addChild:playerHealthBackground];

  // 4
  _playerHealthLabel = 
    [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
  _playerHealthLabel.name = @"playerHealth";
  _playerHealthLabel.fontColor = [SKColor whiteColor];
  _playerHealthLabel.fontSize = 10.0f;
  _playerHealthLabel.text = actualHealth;
  _playerHealthLabel.horizontalAlignmentMode = 
    SKLabelHorizontalAlignmentModeLeft;
  _playerHealthLabel.verticalAlignmentMode = 
    SKLabelVerticalAlignmentModeTop;
  _playerHealthLabel.position = 
    CGPointMake(0, 
                self.size.height - barHeight + 
                  _playerHealthLabel.frame.size.height);
  [_hudLayerNode addChild:_playerHealthLabel];

}

- (void)setupEntities
{
  _playerShip =
    [[PlayerShip alloc]
     initWithPosition:CGPointMake(self.size.width / 2,
                                  100)];
  [_playerLayerNode addChild:_playerShip];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint currentPoint = 
    [[touches anyObject] locationInNode:self];
  CGPoint previousPoint = 
    [[touches anyObject] previousLocationInNode:self];
  _deltaPoint = CGPointSubtract(currentPoint, previousPoint);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  _deltaPoint = CGPointZero;
}

- (void)touchesCancelled:(NSSet *)touches 
               withEvent:(UIEvent *)event
{
  _deltaPoint = CGPointZero;
}

- (void)update:(NSTimeInterval)currentTime {

  // 1
  CGPoint newPoint =
    CGPointAdd(_playerShip.position, _deltaPoint);

  // 2
  newPoint.x =
    Clamp(newPoint.x,
          _playerShip.size.width / 2,
          self.size.width - _playerShip.size.width / 2);
    
  newPoint.y =
    Clamp(newPoint.y,
          _playerShip.size.height / 2,
          self.size.height - _playerShip.size.height / 2);
  // 3
  _playerShip.position = newPoint;
  _deltaPoint = CGPointZero;

}

@end
