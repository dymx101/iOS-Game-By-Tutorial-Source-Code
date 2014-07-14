//
//  MyScene.m
//  MemoryHog
//
#import "MyScene.h"

@implementation MyScene {
  CFTimeInterval _start;
  int _frames;
  NSArray *_textureAtlases;
}

- (id)initWithSize:(CGSize)size textureAtlases:(NSArray *)textureAtlases {
  if (self = [super initWithSize:size]) {
    
    _start = CACurrentMediaTime();
    _textureAtlases = textureAtlases;
    
    self.backgroundColor = [SKColor whiteColor];
    
    CGPoint screenCenter =
    CGPointMake(CGRectGetMidX(self.frame),
                CGRectGetMidY(self.frame));
    
    SKSpriteNode *cat =
    [SKSpriteNode spriteNodeWithImageNamed:@"cat_sleepy"];
    [cat setPosition:CGPointMake(screenCenter.x,
                                 screenCenter.y + 50.0)];
    [self addChild:cat];
    
    SKSpriteNode *zombie =
    [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];
    [zombie setPosition:CGPointMake(screenCenter.x - 100.0f,
                                    screenCenter.y + 50.0)];
    [self addChild:zombie];
    
    SKSpriteNode *car =
    [SKSpriteNode spriteNodeWithImageNamed:@"car_1"];
    [car setPosition:CGPointMake(screenCenter.x + 100.0f,
                                 screenCenter.y + 50.0)];
    [self addChild:car];
    
    [self loadRandomImageFromAllGameAtlases];
    
  }
  return self;
}

- (void)loadRandomImageFromAllGameAtlases {
    
  for (SKTextureAtlas * atlas in _textureAtlases) {    
    NSString * textureName = atlas.textureNames[arc4random() % atlas.textureNames.count];
    SKTexture * texture = [SKTexture textureWithImageNamed:textureName];
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:texture];
    sprite.position = CGPointMake(arc4random() % (int) self.size.width, arc4random() % (int) self.size.height);
    [self addChild:sprite];
  }
  
}

- (void)update:(NSTimeInterval)currentTime {
  
  if (_frames == 1) {
    CFTimeInterval end = CACurrentMediaTime();
    CFTimeInterval diff = end - _start;
    NSLog(@"First render performed in: %0.2f seconds", diff);
  }
  _frames++;
  
}

@end
