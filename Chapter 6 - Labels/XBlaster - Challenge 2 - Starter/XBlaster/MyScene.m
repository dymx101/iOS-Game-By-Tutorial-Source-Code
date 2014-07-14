//
//  MyScene.m
//  XBlaster
//
//  Created by Main Account on 8/31/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"
#import "PlayerShip.h"
#import "Bullet.h"
#import "EnemyA.h"
#import "EnemyB.h"

@implementation MyScene {
  SKAction *_scoreFlashAction;
  SKLabelNode *_playerHealthLabel;
  NSString    *_healthBar;
  PlayerShip *_playerShip;
  CGPoint _deltaPoint;
  float _bulletInterval;
  CFTimeInterval _lastUpdateTime;
  NSTimeInterval _dt;
  
  SKAction    *_gameOverPulse;
  SKLabelNode *_gameOverLabel;
  SKLabelNode *_tapScreenLabel;
  CGFloat _score;
  int _gameState;
}

-(id)initWithSize:(CGSize)size {    
   if (self = [super initWithSize:size]) {
    // Configure the physics world
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;

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
  
  _bulletLayerNode = [SKNode node];
  [self addChild:_bulletLayerNode];
  
  _enemyLayerNode = [SKNode node];
  [self addChild:_enemyLayerNode];
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

  _gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
  _gameOverLabel.name = @"gameOver";
  _gameOverLabel.fontSize = 40.0f;
  _gameOverLabel.fontColor = [SKColor whiteColor];
  _gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
  _gameOverLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  _gameOverLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
  _gameOverLabel.text = @"GAME OVER";
  
  _tapScreenLabel = [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
  _tapScreenLabel.name = @"tapScreen";
  _tapScreenLabel.fontSize = 20.0f;
  _tapScreenLabel.fontColor = [SKColor whiteColor];
  _tapScreenLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
  _tapScreenLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  _tapScreenLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - 100);
  _tapScreenLabel.text = @"Tap Screen To Restart";
  
  _gameOverPulse = [SKAction repeatActionForever:
                    [SKAction sequence:@[[SKAction fadeOutWithDuration:1.0],
                                         [SKAction fadeInWithDuration:1.0]]]
                    ];
  
}

- (void)setupEntities
{
  _playerShip =
    [[PlayerShip alloc]
     initWithPosition:CGPointMake(self.size.width / 2,
                                  100)];
  [_playerLayerNode addChild:_playerShip];

  for (int i=0; i < 5; i++) {
    EnemyA *enemy = [[EnemyA alloc] initWithPosition:CGPointMake(RandomFloatRange(50, self.size.width - 50), self.size.height + 50)];
    [_enemyLayerNode addChild:enemy];
  }

  for (int i=0; i < 4; i++) {
    EnemyB *enemy = [[EnemyB alloc] initWithPosition:CGPointMake(RandomFloatRange(50, self.frame.size.width - 50), self.frame.size.height + 50)];
    [_enemyLayerNode addChild:enemy];
  }

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  
  if (_gameState == GameOver)
    [self restartGame];
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

  if (_lastUpdateTime) {
    _dt = currentTime - _lastUpdateTime;
  } else {
    _dt = 0;
  }
  _lastUpdateTime = currentTime;
  
  CFTimeInterval timeDelta = currentTime - _lastUpdateTime;
  _lastUpdateTime = currentTime;

  switch (_gameState) {
    case GameRunning:
    {
      _bulletInterval += _dt;
      if (_bulletInterval > 0.15) {
        _bulletInterval = 0;
        
        Bullet *bullet = [[Bullet alloc] initWithPosition:_playerShip.position];
        [_bulletLayerNode addChild:bullet];
        [bullet runAction:[SKAction sequence:@[
          [SKAction moveByX:0 y:self.size.height duration:0.5],
          [SKAction removeFromParent]
        ]]];
      }
      
      // Update player
      [_playerShip update:timeDelta];
      
      // Update all enemies
      [_enemyLayerNode enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
        [(Entity *)node update:timeDelta];
      }];
      
      // Update the healthbar color and length based on the...urm...players health :)
      _playerHealthLabel.fontColor = [SKColor colorWithRed:2.0f * (1.0f - _playerShip.health / 100.0f)
                                                     green:2.0f * _playerShip.health / 100.0f
                                                      blue:0 alpha:1.0];
      _playerHealthLabel.text = [_healthBar substringToIndex:(_playerShip.health / 100 * _healthBar.length)];
      
      // If the players health has dropped to <= 0 then set the game state to game over
      if (_playerShip.health <= 0) {
        _gameState = GameOver;
      }
    }
    break;
    case GameOver:
    {
      // If the game over message has not been added to the scene yet then add it
      if (!_gameOverLabel.parent) {
        
        // Remove the bullets, enemites and player from the scene as the game is over
        [_bulletLayerNode enumerateChildNodesWithName:@"bullet" usingBlock:^(SKNode *node, BOOL *stop) {
          [(Entity *)node removeFromParent];
        }];
        
        [_enemyLayerNode enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
          [(Entity *)node removeFromParent];
        }];
        
        [_playerShip removeFromParent];
        
        [_hudLayerNode addChild:_gameOverLabel];
        [_hudLayerNode addChild:_tapScreenLabel];
        [_tapScreenLabel runAction:_gameOverPulse];
      }
      
      // Randonly set the color of the game over label
      SKColor *newColor = [SKColor colorWithRed:drand48() green:drand48() blue:drand48() alpha:1.0];
      _gameOverLabel.fontColor = newColor;
    }
  }

}

- (void)increaseScoreBy:(float)increment
{
  _score += increment;
  SKLabelNode *scoreLabel = (SKLabelNode*)[_hudLayerNode childNodeWithName:@"scoreLabel"];
  scoreLabel.text = [NSString stringWithFormat:@"Score: %1.0f", _score];
  [scoreLabel removeAllActions];
  [scoreLabel runAction:_scoreFlashAction];
}

- (void)restartGame
{
  // Reset the state of the game
  _gameState = GameRunning;
  
  // Set up the entities again and the score
  [self setupEntities];
  _score = 0;
  
  // Reset the score and the players health
  SKLabelNode *scoreLabel = (SKLabelNode *)[_hudLayerNode childNodeWithName:@"scoreLabel"];
  scoreLabel.text = @"Score: 0";
  _playerShip.health = 100;
  _playerShip.position = CGPointMake(self.frame.size.width / 2, 100);
  
  // Remove the game over HUD labels
  [[_hudLayerNode childNodeWithName:@"gameOver"] removeFromParent];
  [[_hudLayerNode childNodeWithName:@"tapScreen"] removeAllActions];
  [[_hudLayerNode childNodeWithName:@"tapScreen"] removeFromParent];
}

#pragma mark -
#pragma mark Physics Contact Delegate

- (void)didBeginContact:(SKPhysicsContact *)contact
{
  
  // Grab the first body that has been involved in the collision and call it's collidedWith method
  // allowing it to react to the collision...
  SKNode *node = contact.bodyA.node;
  if ([node isKindOfClass:[Entity class]]) {
    [(Entity*)node collidedWith:contact.bodyB contact:contact];
  }
  
  // ... and do the same for the second body
  node = contact.bodyB.node;
  if ([node isKindOfClass:[Entity class]]) {
    [(Entity*)node collidedWith:contact.bodyA contact:contact];
  }
  
}

@end
