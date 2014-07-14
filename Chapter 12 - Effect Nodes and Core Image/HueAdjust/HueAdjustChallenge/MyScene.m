//
//  MyScene.m
//  HueAdjustChallenge
//
//  Created by Jake Gundersen on 8/30/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "MyScene.h"
@import CoreImage;

#define kSpeed 100

@interface MyScene() {
    SKSpriteNode *_zombie;
    SKAction *_zombieAnimation;
    
    SKSpriteNode *_zombieHat;
    SKAction *_zombieHatAnimation;
    
    CGPoint _move;
    NSTimeInterval lastTime;
  
    SKEffectNode *_effectNode;
    CIFilter *_filter;
}

@end

static inline CGPoint CGPointAdd(const CGPoint a,
                                 const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}


static inline CGPoint CGPointMultiplyScalar(const CGPoint a,
                                            const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

static inline CGFloat CGPointLength(const CGPoint a)
{
    return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint CGPointNormalize(const CGPoint a)
{
    CGFloat length = CGPointLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

static inline CGFloat CGPointToAngle(const CGPoint a)
{
    return atan2f(a.y, a.x);
}

static inline CGFloat ScalarSign(CGFloat a)
{
    return a >= 0 ? 1 : -1;
}

static inline CGFloat ScalarShortestAngleBetween(
                                                 const CGFloat a, const CGFloat b)
{
    CGFloat difference = b - a;
    CGFloat angle = fmodf(difference, M_PI * 2);
    if (angle >= M_PI) {
        angle -= M_PI * 2;
    }
    return angle;
}


#define ARC4RANDOM_MAX      0x100000000
static inline CGFloat RandomRange(CGFloat min,
                                  CGFloat max)
{
    return ((double)arc4random() / ARC4RANDOM_MAX) * (max - min) + min;
}

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithWhite:0.8 alpha:1.0];
        
        _zombie = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];
        _zombie.position = CGPointMake(100, 100);

        _effectNode = [SKEffectNode node];
        [_effectNode addChild:_zombie];
        [self addChild:_effectNode];
      
        _filter = [CIFilter filterWithName:@"CIHueAdjust"];
        [_filter setValue:@0 forKey:@"inputAngle"];
        _effectNode.filter = _filter;
        _effectNode.shouldEnableEffects = YES;

        _zombieHat = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1Hat"];
        _zombieHat.position = CGPointMake(100, 100);
        [self addChild:_zombieHat];
        
        NSMutableArray *textures =
        [NSMutableArray arrayWithCapacity:10];

        for (int i = 1; i < 4; i++) {
            NSString *textureName =
            [NSString stringWithFormat:@"zombie%d", i];
            SKTexture *texture =
            [SKTexture textureWithImageNamed:textureName];
            [textures addObject:texture];
        }

        for (int i = 4; i > 1; i--) {
            NSString *textureName =
            [NSString stringWithFormat:@"zombie%d", i];
            SKTexture *texture =
            [SKTexture textureWithImageNamed:textureName];
            [textures addObject:texture];
        }
        
        NSMutableArray *textures2 =
        [NSMutableArray arrayWithCapacity:10];
        
        for (int i = 1; i < 4; i++) {
            NSString *textureName =
            [NSString stringWithFormat:@"zombie%dHat", i];
            SKTexture *texture =
            [SKTexture textureWithImageNamed:textureName];
            [textures2 addObject:texture];
        }
        
        for (int i = 4; i > 1; i--) {
            NSString *textureName =
            [NSString stringWithFormat:@"zombie%dHat", i];
            SKTexture *texture =
            [SKTexture textureWithImageNamed:textureName];
            [textures2 addObject:texture];
        }

        _zombieAnimation = [SKAction animateWithTextures:textures timePerFrame:0.1];
        NSLog(@"%@, textures %@", _zombieAnimation, textures);
        [_zombie runAction:[SKAction repeatActionForever:_zombieAnimation]];
        
        _zombieHatAnimation = [SKAction animateWithTextures:textures2 timePerFrame:0.1];
        NSLog(@"%@, textures %@", _zombieHatAnimation, textures2);
        [_zombieHat runAction:[SKAction repeatActionForever:_zombieHatAnimation]];
        
        _move = CGPointMake(30, 50);
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        float randVal = RandomRange(0, 6.14);
        [_filter setValue:[NSNumber numberWithFloat:randVal] forKey:@"inputAngle"];
//        _zombie.color = [SKColor colorWithRed:RandomRange(0, 1) green:RandomRange(0, 1) blue:RandomRange(0, 1) alpha:1];
//        _zombie.colorBlendFactor = 1.0;
    }
}

- (void)update:(NSTimeInterval)currentTime
{
    if (_zombie.position.x > self.size.width - 20 || _zombie.position.x < 20) {
        _move = CGPointMake(-_move.x, _move.y);
    } else if (_zombie.position.y > self.size.height - 20 || _zombie.position.y < 20) {
        _move = CGPointMake(_move.x, -_move.y);
    }
    
    if (lastTime == 0) {
        lastTime = currentTime;
    }
    double delta = currentTime - lastTime;
    lastTime = currentTime;
    CGPoint moveStep = CGPointMultiplyScalar(CGPointNormalize(_move), kSpeed * delta);
    
    _zombie.position = CGPointAdd(_zombie.position, moveStep);
    _zombieHat.position = _zombie.position;
    
    [self rotateSprite:_zombie toFace:moveStep rotateRadiansPerSec:2 * M_PI delta:delta];
    _zombieHat.zRotation = _zombie.zRotation;
}

- (void)rotateSprite:(SKSpriteNode *)sprite
              toFace:(CGPoint)velocity
 rotateRadiansPerSec:(CGFloat)rotateRadiansPerSec
               delta:(NSTimeInterval)delta
{
    float targetAngle = CGPointToAngle(velocity);
    float shortest = ScalarShortestAngleBetween(sprite.zRotation, targetAngle);
    float amtToRotate = rotateRadiansPerSec * delta;
    if (ABS(shortest) < amtToRotate) {
        amtToRotate = ABS(shortest);
    }
    sprite.zRotation += ScalarSign(shortest) * amtToRotate;
}


@end
