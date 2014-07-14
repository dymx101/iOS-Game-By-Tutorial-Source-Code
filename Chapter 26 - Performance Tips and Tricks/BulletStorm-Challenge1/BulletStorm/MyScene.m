//
//  MyScene.m
//  BulletStorm
//
//  Created by Main Account on 10/8/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"
#import "SKTAudio.h"
#import "SKTUtils.h"
#import "Player.h"
#import "Asteroid.h"
#import "Laser.h"
#import "Enemy.h"
#import "SKEmitterNode+SKTExtras.h"
#import "SKAction+SKTExtras.h"

@import CoreMotion;

static const float BG_POINTS_PER_SEC = 400;

@interface MyScene() <SKPhysicsContactDelegate>
@end

@implementation MyScene {
  SKNode *_bgLayer;
  SKNode *_fgLayer;
  SKNode *_hudLayer;
  NSTimeInterval _lastUpdateTime;
  NSTimeInterval _dt;
  SKSpriteNode *_player;
  CMMotionManager *_motionManager;
  SKAction *_explosionSmallSound;
  SKAction *_explosionLargeSound;
  SKAction *_laserPlayerSound;
  SKAction *_laserEnemySound;
  NSMutableArray *_playerLasers;
  SKLabelNode *_scoreLabel;
  SKLabelNode *_accuracyLabel;
  SKLabelNode *_randomLabel;
  SKTexture *_scoreTexture;
  int _score;
  int _shots;
  int _hits;
//  NSMutableArray *_toAdd;
}

#pragma mark Init / dealloc

-(instancetype)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    
    _bgLayer = [SKNode node];
    [self addChild:_bgLayer];
    
    self.backgroundColor = [SKColor whiteColor];
    [[SKTAudio sharedInstance] playBackgroundMusic:@"bgMusic.mp3"];
   
    CIFilter *filter = [CIFilter filterWithName:@"CIHueAdjust"];
    float randVal = RandomFloatRange(M_PI_4, 3*M_PI_4);
    [filter setValue:[NSNumber numberWithFloat:randVal] forKey:@"inputAngle"];

//    self.filter = filter;
//    self.shouldEnableEffects = YES;
    
    for (int i = 0; i < 2; i++) {

      SKSpriteNode * bg =
      [SKSpriteNode spriteNodeWithImageNamed:@"bg-planet"];
      bg.anchorPoint = CGPointZero;
      
      SKEffectNode * bgParent = [SKEffectNode node];
      bgParent.filter = filter;
      bgParent.shouldEnableEffects = YES;
      bgParent.name = @"bg";
      bgParent.position = CGPointMake(i * bg.size.width, 0);
      bgParent.shouldRasterize = YES;
      [bgParent addChild:bg];
      [_bgLayer addChild:bgParent];
      
//      bg.position = CGPointMake(i * bg.size.width, 0);
//      bg.name = @"bg";
//      [_bgLayer addChild:bg];
      _bgLayer.zPosition = -2;
    }
    
    _fgLayer = [SKNode node];
    [self addChild:_fgLayer];
    
    _player = [[Player alloc] init];
    _player.position = CGPointMake(_player.size.width/2 + 20, self.size.height/2);
    [_fgLayer addChild:_player];

    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = 0.05;
    [_motionManager startAccelerometerUpdates];

    [self runAction:[SKAction repeatActionForever:
      [SKAction sequence:@[
        [SKAction performSelector:@selector(spawnAsteroid)
                         onTarget:self],
        [SKAction waitForDuration:0.25]]]]];

    [self runAction:[SKAction repeatActionForever:
      [SKAction sequence:@[
        [SKAction performSelector:@selector(spawnPlayerLaser)
                         onTarget:self],
        [SKAction waitForDuration:0.1]]]]];

    [self runAction:[SKAction repeatActionForever:
      [SKAction sequence:@[
        [SKAction performSelector:@selector(spawnEnemy)
                         onTarget:self],
        [SKAction waitForDuration:0.7]]]]];

    [self runAction:[SKAction repeatActionForever:
      [SKAction sequence:@[
        [SKAction performSelector:@selector(spawnEnemyLaser)
                         onTarget:self],
        [SKAction waitForDuration:0.3]]]]];
   
    _explosionSmallSound = [SKAction playSoundFileNamed:@"explosion_small.wav" waitForCompletion:NO];
    _explosionLargeSound = [SKAction playSoundFileNamed:@"explosion_large.wav" waitForCompletion:NO];
    _laserPlayerSound = [SKAction playSoundFileNamed:@"laser_player.wav" waitForCompletion:NO];
    _laserEnemySound = [SKAction playSoundFileNamed:@"laser_enemy.wav" waitForCompletion:NO];
    
    self.physicsWorld.contactDelegate = self;
    
    _hudLayer = [SKNode node];
    [self addChild:_hudLayer];
    
    _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Regular"];
    _scoreLabel.text = @"Score: 0";
    _scoreLabel.fontSize = 20.0;
    _scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _scoreLabel.position = CGPointMake(10, self.scene.size.height - 40);
    [_hudLayer addChild:_scoreLabel];
    
    _accuracyLabel = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Regular"];
    _accuracyLabel.text = @"Accuracy: 0";
    _accuracyLabel.fontSize = 20.0;
    _accuracyLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    _accuracyLabel.position = CGPointMake(self.scene.size.width - 10, self.scene.size.height - 40);
    [_hudLayer addChild:_accuracyLabel];
    
  }
  return self;
}

- (void)dealloc {
  [_motionManager stopAccelerometerUpdates];
  _motionManager = nil;
}

#pragma mark Physics functions

- (void)didBeginContact:(SKPhysicsContact *)contact
{
  SKNode *node = contact.bodyA.node;
  if ([node isKindOfClass:[Entity class]]) {
    [(Entity*)node collidedWith:contact.bodyB contact:contact];
  }
  
  node = contact.bodyB.node;
  if ([node isKindOfClass:[Entity class]]) {
    [(Entity*)node collidedWith:contact.bodyA contact:contact];
  }
}

#pragma mark Spawn functions

- (void)spawnAsteroid
{
  Asteroid *asteroid = [[Asteroid alloc] initWithAsteroidType:arc4random_uniform(NumAsteroidTypes)];
  asteroid.name = @"asteroid";
  asteroid.position = CGPointMake(
                               self.size.width + asteroid.size.width/2,
                               RandomFloatRange(asteroid.size.height/2,
                                                self.size.height-asteroid.size.height/2));
  [_fgLayer addChild:asteroid];
  
}

- (void)spawnPlayerLaser
{
  Laser *laser = [[Laser alloc] initWithLaserType:LaserTypePlayer];
  laser.name = @"playerLaser";
  laser.position = CGPointMake(_player.position.x + 6, _player.position.y - 4);
  laser.alpha = 0;
  [_fgLayer addChild:laser];
  [laser configureCollisionBody];
  
  [laser runAction:[SKAction fadeAlphaTo:1.0 duration:0.1]];
  SKAction *actionMove =
    [SKAction moveToX:self.size.width + laser.size.width/2 duration:0.75];
  SKAction *actionRemove = [SKAction runBlock:^{
    [laser cleanup];
  }];
  [laser runAction:
   [SKAction sequence:@[actionMove, actionRemove]]];
  
  [self runAction:_laserPlayerSound];
  _shots++;
}

- (void)spawnEnemy {
  Enemy *enemy = [[Enemy alloc] init];
  enemy.name = @"enemy";
  enemy.position = CGPointMake(
                               self.size.width + enemy.size.width/2,
                               RandomFloatRange(enemy.size.height/2,
                                                self.size.height-enemy.size.height/2));
  [_fgLayer addChild:enemy];
}

- (void)spawnEnemyLaserAtPosition:(CGPoint)position
{
  Laser *laser = [[Laser alloc] initWithLaserType:LaserTypeEnemy];
  laser.name = @"enemyLaser";
  laser.position = position;
  laser.alpha = 0;
  [_fgLayer addChild:laser];
  
  [laser runAction:[SKAction fadeAlphaTo:1.0 duration:0.1]];
  SKAction *actionMove =
    [SKAction moveByX:-self.scene.size.width y:0 duration:1.5];
  SKAction *actionRemove = [SKAction runBlock:^{
    [laser cleanup];
  }];
  [laser runAction:
   [SKAction sequence:@[actionMove, actionRemove]]];
  
  [self runAction:_laserEnemySound];
}

- (void)spawnEnemyLaser {
  [_fgLayer enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
      if (node.position.x > self.scene.size.width * 0.6 && arc4random() % 5 == 0) {
        [self spawnEnemyLaserAtPosition:CGPointMake(node.position.x-30, node.position.y+4)];
      }
  }];
}

#pragma mark External functions

- (void)createExplosionType:(ExplosionType)explosionType atPosition:(CGPoint)position {
 
  _hits++;
  
  switch (explosionType) {
  case ExplosionTypeSmall: {
    Explosion *explosion = [[Explosion alloc] initWithExplosionType:explosionType];
    explosion.position = position;
    [self addChild:explosion];
    [self runAction:_explosionSmallSound];
    }
    break;
  case ExplosionTypeLarge: {
    SKEmitterNode *explosion = [SKEmitterNode skt_emitterNamed:@"Explosion"];
    explosion.zPosition = -1;
    explosion.position = position;
    [self addChild:explosion];
    [explosion runAction:[SKAction skt_removeFromParentAfterDelay:1.0]];
    [self runAction:_explosionLargeSound];
    
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Regular"];
    scoreLabel.text = @"+10";
    scoreLabel.fontSize = 20.0;
    scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    scoreLabel.position = position;
    [_hudLayer addChild:scoreLabel];
    [scoreLabel runAction:[SKAction sequence:@[
      [SKAction moveBy:CGVectorMake(0, 30) duration:1.0],
      [SKAction fadeOutWithDuration:1.0]
    ]]];
    
    _score += 10;
    
    }
    break;
  default:
    break;
  }

}

#pragma mark Update functions

- (void)moveBg
{
  CGPoint bgVelocity = CGPointMake(-BG_POINTS_PER_SEC, 0);
  CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity, _dt);
  _bgLayer.position = CGPointAdd(_bgLayer.position, amtToMove);
  _bgLayer.position = CGPointMake((int)_bgLayer.position.x, (int)_bgLayer.position.y);
  
  [_bgLayer enumerateChildNodesWithName:@"bg"
                         usingBlock:^(SKNode *node, BOOL *stop){
                           SKSpriteNode * bg = (SKSpriteNode *) node;
                           CGPoint bgScreenPos = [_bgLayer convertPoint:bg.position
                                                                 toNode:self];
                           if (bgScreenPos.x <= -1136) {
                             bg.position = CGPointMake(bg.position.x+1136*2,
                                                       bg.position.y);
                           }
                         }];
}

- (void)movePlayer {
    
#define kFilteringFactor 0.75
    static UIAccelerationValue rollingX = 0, rollingY = 0, rollingZ = 0;
    
    rollingX = (_motionManager.accelerometerData.acceleration.x * kFilteringFactor) +
    (rollingX * (1.0 - kFilteringFactor));
    rollingY = (_motionManager.accelerometerData.acceleration.y * kFilteringFactor) +
    (rollingY * (1.0 - kFilteringFactor));
    rollingZ = (_motionManager.accelerometerData.acceleration.z * kFilteringFactor) +
    (rollingZ * (1.0 - kFilteringFactor));
    
    float accelX = rollingX;
  
#define kRestAccelX 0.6
#define kShipMaxPointsPerSec (self.size.height*0.5)
#define kMaxDiffX 0.2
    
    float accelDiffX = kRestAccelX - ABS(accelX);
    float accelFractionX = accelDiffX / kMaxDiffX;
    float pointsPerSecX = kShipMaxPointsPerSec * accelFractionX;
    
    float shipPointsPerSecY = pointsPerSecX;
    float maxY = self.size.height - _player.size.height/2;
    float minY = _player.size.height/2;
    
    float newY = _player.position.y + (shipPointsPerSecY * _dt);
    newY = MIN(MAX(newY, minY), maxY);
    _player.position = CGPointMake(_player.position.x, newY);
  
}

-(void)update:(CFTimeInterval)currentTime {
  if (_lastUpdateTime) {
    _dt = currentTime - _lastUpdateTime;
  } else {
    _dt = 0;
  }
  _lastUpdateTime = currentTime;
  
  [self moveBg];
  [self movePlayer];
    [_fgLayer.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if ([obj isKindOfClass:[Entity class]]) {
      Entity *entity = (Entity *)obj;
      [entity update:_dt];
    }
  }];
  
  _scoreLabel.text = [NSString stringWithFormat:@"Score: %d", _score];
  _accuracyLabel.text = [NSString stringWithFormat:@"Accuracy: %0.0f%%", (float)_hits/(float)_shots * 100];

  [_fgLayer enumerateChildNodesWithName:@"asteroid" usingBlock:^(SKNode *node, BOOL *stop) {
    Asteroid *asteroid = (Asteroid *)node;
    asteroid.position = CGPointAdd(node.position, CGPointMultiplyScalar(CGPointMake(-self.size.width/2, 0), _dt));
    if (node.position.x < -asteroid.size.width/2) {
      [asteroid cleanup];
    }
  }];

}

@end
