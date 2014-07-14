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
    
    SKTextureAtlas *textureAtlas =
    [SKTextureAtlas atlasNamed:@"3elements"];
    
    SKTexture *catTexture =
    [textureAtlas textureNamed:@"cat_sleepy"];
    SKSpriteNode *cat =
    [SKSpriteNode spriteNodeWithTexture:catTexture];
    [cat setPosition:CGPointMake(screenCenter.x,
                                 screenCenter.y + 50.0)];
    [self addChild:cat];
    
    SKTexture *zombieTexture =
    [textureAtlas textureNamed:@"zombie1"];
    SKSpriteNode *zombie =
    [SKSpriteNode spriteNodeWithTexture:zombieTexture];
    [zombie setPosition:CGPointMake(screenCenter.x - 100.0f,
                                    screenCenter.y + 50.0)];
    [self addChild:zombie];
    
    SKTexture *carTexture =
    [textureAtlas textureNamed:@"car_1"];
    SKSpriteNode *car =
    [SKSpriteNode spriteNodeWithTexture:carTexture];
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
