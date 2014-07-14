//
//  MyScene.m
//  ActionsCatalog
//
//  Created by Main Account on 6/20/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"

@interface MyScene ()

@property (nonatomic) SKSpriteNode * cat;
@property (nonatomic) SKSpriteNode * dog;
@property (nonatomic) SKSpriteNode * turtle;
@property (nonatomic) SKLabelNode * label;

@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {

        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
                
        self.cat = [SKSpriteNode spriteNodeWithImageNamed:@"cat"];
        self.cat.position = CGPointMake(self.size.width * 1/6, self.size.height/2);
        [self addChild:self.cat];
        
        self.dog = [SKSpriteNode spriteNodeWithImageNamed:@"dog"];
        self.dog.position = CGPointMake(self.size.width * 3/6, self.size.height/2);
        [self addChild:self.dog];
        
        self.turtle = [SKSpriteNode spriteNodeWithImageNamed:@"turtle"];
        self.turtle.position = CGPointMake(self.size.width * 5/6, self.size.height/2);
        [self addChild:self.turtle];
        
        self.label = [SKLabelNode labelNodeWithFontNamed:@"Verdana"];
        self.label.text = @"Test";
        self.label.fontSize = 20;
        self.label.fontColor = [SKColor blackColor];
        self.label.position = CGPointMake(self.size.width/2, self.size.height * 1/6);
        [self addChild:self.label];
        
    }
    return self;
}

@end

@implementation MoveScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
    
        // moveTo:duration
        [self.cat runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction moveTo:CGPointMake(0, 0) duration:1.0],
                [SKAction moveTo:self.cat.position duration:1.0]
            ]]
        ]];
        
        // moveByX:duration:
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:1.0],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:1.0],
            ]]
        ]];
        
        // moveToX:duration: and moveToY:duration:
        [self.turtle runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction group:@[
                    [SKAction moveToX:self.size.width duration:1.0],
                    [SKAction moveToY:0 duration:1.0],
                ]],
                [SKAction group:@[
                    [SKAction moveToX:self.turtle.position.x duration:1.0],
                    [SKAction moveToY:self.turtle.position.y duration:1.0],
                ]],
            ]]
        ]];
        
        self.label.text = @"Move Actions / Cross Fade";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKTransition *reveal = [SKTransition crossFadeWithDuration:1.0];
    SKScene * nextScene = [[RotateScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene transition: reveal];
}

@end

@implementation RotateScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
    
        // rotateByAngle:duration:
        [self.cat runAction:[SKAction repeatActionForever:
            [SKAction rotateByAngle:M_PI*2 duration:1.0]
        ]];
        
        // rotateToAngle:duration:
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction rotateToAngle:M_PI duration:1.0],
                [SKAction rotateToAngle:-M_PI duration:1.0],
            ]]
        ]];
        
        [self.turtle runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction rotateToAngle:M_PI * 1/16 duration:0.5],
                [SKAction rotateToAngle:-M_PI * 1/16 duration:0.5]
            ]]
        ]];
        
        self.label.text = @"Rotate Actions / Fade";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKTransition *reveal = [SKTransition fadeWithDuration:1.0];
    SKScene * nextScene = [[ResizeScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene transition: reveal];
}

@end

@implementation ResizeScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
    
        // resizeByWidth:height:duration
        [self.cat runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction resizeByWidth:self.cat.size.width height:-self.cat.size.height/2 duration:1.0],
                [SKAction resizeByWidth:-self.cat.size.width height:self.cat.size.height/2 duration:1.0]
            ]]
        ]];
        
        // resizeToWidth:height:duration
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction resizeToWidth:10 height:200 duration:1.0],
                [SKAction resizeToWidth:self.cat.size.width height:self.cat.size.height duration:1.0],
            ]]
        ]];
        
        // resizeToWidth:duration:
        // resizeToHeight:duration:
        [self.turtle runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction group:@[
                    [SKAction resizeToWidth:self.cat.size.width*2 duration:1.0],
                    [SKAction resizeToHeight:self.cat.size.height duration:1.0],
                ]],
                [SKAction group:@[
                    [SKAction resizeToWidth:self.cat.size.width duration:1.0],
                    [SKAction resizeToHeight:self.cat.size.height duration:1.0],
                ]],
            ]]
        ]];
                
        self.label.text = @"Resize Actions / Fade with Color";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKTransition *reveal = [SKTransition fadeWithColor:[SKColor redColor] duration:1.0];
    SKScene * nextScene = [[ScaleScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene transition: reveal];
}

@end

@implementation ScaleScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
    
        // scaleBy:duration: and scaleTo:duration:
        [self.cat runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction scaleBy:2.0 duration:0.5],
                [SKAction scaleBy:2.0 duration:0.5], // now effectively at 4x
                [SKAction scaleTo:1.0 duration:1.0]
            ]]
        ]];
        
        // scaleXBy:y:duration and scaleXTo:y:duration
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction scaleXBy:0.25 y:1.25 duration:0.5],
                [SKAction scaleXBy:0.25 y:1.25 duration:0.5], // now effectively xScale 0.625, yScale 1.565
                [SKAction scaleXTo:1.0 y:1.0 duration:1.0]
            ]]
        ]];
        
        // scaleXto:duration and scaleYto:duration        
        [self.turtle runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction group:@[
                    [SKAction scaleXTo:3.0 duration:1.0],
                    [SKAction scaleYTo:0.5 duration:1.0]
                ]],
                [SKAction group:@[
                    [SKAction scaleXTo:1.0 duration:1.0],
                    [SKAction scaleYTo:1.0 duration:1.0]
                ]],
            ]]
        ]];        
    
        self.label.text = @"Scale Actions / Flip Horizontal";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:1.0];
    SKScene * nextScene = [[RepeatScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene transition: reveal];
}

@end

@implementation RepeatScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
    
        // repeatAction:count:
        [self.cat runAction:[SKAction repeatAction:
            [SKAction sequence:@[
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:0.2],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:0.2],
            ]] count:2
        ]];
        
        [self.dog runAction:[SKAction repeatAction:
            [SKAction sequence:@[
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:0.2],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:0.2],
            ]] count:4
        ]];
        
        // repeatActionForever:
        [self.turtle runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:0.2],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:0.2],
            ]]
        ]];
        
        self.label.text = @"Repeat Actions / Flip Vertical";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKTransition *reveal = [SKTransition flipVerticalWithDuration:1.0];
    SKScene * nextScene = [[FadeScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene transition: reveal];
}

@end


@implementation FadeScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
    
        // fadeOutWithDuration: and fadeInWithDuration:
        [self.cat runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
               [SKAction fadeOutWithDuration:1.0],
               [SKAction fadeInWithDuration:1.0],
            ]]
        ]];
        
        // fadeAlphaBy:duration
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction fadeAlphaBy:-0.75 duration:1.0],
                [SKAction fadeAlphaBy:0.75 duration:1.0],
            ]]
        ]];
        
        // fadeAlphaTo:duration:
        [self.turtle runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction fadeAlphaTo:0.25 duration:1.0],
                [SKAction fadeAlphaTo:1.0 duration:1.0]
            ]]
        ]];
        
        self.label.text = @"Fade Actions / Reveal";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionLeft duration:1.0];
    SKScene * nextScene = [[TextureScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene transition: reveal];
}

@end

@implementation TextureScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
    
        // setTexture:
        SKTexture * catTexture = [SKTexture textureWithImageNamed:@"cat"];
        SKTexture * dogTexture = [SKTexture textureWithImageNamed:@"dog"];
        SKTexture * turtleTexture = [SKTexture textureWithImageNamed:@"turtle"];
        [self.cat runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
               [SKAction setTexture:catTexture],
               [SKAction waitForDuration:0.25],
               [SKAction setTexture:dogTexture],
               [SKAction waitForDuration:0.25],
               [SKAction setTexture:turtleTexture],
               [SKAction waitForDuration:0.25],
            ]]
        ]];
        
        // animateWithTextures:timePerFrame:
        NSArray * textures = @[catTexture, dogTexture, turtleTexture];
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction animateWithTextures:textures timePerFrame:0.25]
        ]];
        
        // animateWithTextures:timePerFrame:resize:restore:
        NSArray * textures2 = @[catTexture, dogTexture];
        [self.turtle runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction animateWithTextures:textures2 timePerFrame:0.25 resize:YES restore:YES],
                [SKAction waitForDuration:0.25],
            ]]
        ]];
        
        
        self.label.text = @"Texture Actions / Move In";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKTransition *reveal = [SKTransition moveInWithDirection:SKTransitionDirectionLeft duration:1.0];
    SKScene * nextScene = [[SoundRemoveScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene transition: reveal];
}

@end

@implementation SoundRemoveScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
    
        [self.cat runAction:[SKAction sequence:@[
            [SKAction waitForDuration:1.0],
            [SKAction removeFromParent]]]];
 
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:YES],
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:1.0],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:1.0],
                [SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO],
                [SKAction rotateByAngle:M_PI*2 duration:1.0]
            ]]
        ]];

        [self.turtle runAction:[SKAction sequence:@[
            [SKAction waitForDuration:1.0],
            [SKAction removeFromParent]]]];
        
        self.label.text = @"Sound and Remove Actions / Push";
 
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKTransition *reveal = [SKTransition pushWithDirection:1.0 duration:1.0];
    SKScene * nextScene = [[ColorizeScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene transition: reveal];
}

@end

@implementation ColorizeScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
    
        SKTexture * dogTexture = [SKTexture textureWithImageNamed:@"dog"];
        self.cat.texture = dogTexture;
        self.turtle.texture = dogTexture;
    
        // colorizeWithColor:colorBlendFactor:duration: and colorizeWithColorBlendFactor:duration:
        [self.cat runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:1.0],
                [SKAction colorizeWithColorBlendFactor:0.0 duration:1.0],
            ]]
        ]];
        
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:0.25 duration:1.0],
                [SKAction colorizeWithColorBlendFactor:0.0 duration:1.0],
            ]]
        ]];          
        
        [self.turtle runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:1.0],
                [SKAction colorizeWithColorBlendFactor:0.0 duration:1.0],
                [SKAction colorizeWithColor:[SKColor greenColor] colorBlendFactor:1.0 duration:1.0],
                [SKAction colorizeWithColorBlendFactor:0.0 duration:1.0],
                [SKAction colorizeWithColor:[SKColor blueColor] colorBlendFactor:1.0 duration:1.0],
                [SKAction colorizeWithColorBlendFactor:0.0 duration:1.0],
            ]]
        ]];
        
        self.label.text = @"Colorize Actions / Doors Open";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKTransition *reveal = [SKTransition doorsOpenHorizontalWithDuration:1.0];
    SKScene * nextScene = [[FollowScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene transition: reveal];
}

@end

@implementation FollowScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // followPath:duration:
        // Rectangle
        self.cat.position = CGPointZero;
        UIBezierPath * screenBorders = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.size.width, self.size.height)];
        [self.cat runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction followPath:screenBorders.CGPath duration:10.0],
            ]]
        ]];
        
        // Arbitrary path
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0, 0);
        int steps = 5;
        for(int i = 0; i < steps; ++i) {
            CGPathAddLineToPoint(path, NULL, i*10, (i+1)*10);
            CGPathAddLineToPoint(path, NULL, (i+1)*10, (i+1)*10);
        }
        for(int i = 0; i < steps; ++i) {
            CGPathAddLineToPoint(path, NULL, (steps-i)*10, (steps-i-1)*10);
            CGPathAddLineToPoint(path, NULL, (steps-i-1)*10, (steps-i-1)*10);
        }
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction followPath:path duration:2.0]
            ]]
        ]];
        
        // followPath:asOffset:orientToPath:duration:
        // Circle
        self.turtle.position = CGPointMake(self.size.width/2, self.size.height/2);
        UIBezierPath * circle = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2*100, 2*100) cornerRadius:100];
        [self.turtle runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction followPath:circle.CGPath asOffset:NO orientToPath:NO duration:5.0],
                [SKAction runBlock:^{
                    self.turtle.position = CGPointMake(self.size.width/2, self.size.height/2);
            }]
            ]]
        ]];
        
        self.label.text = @"Follow Actions";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKTransition *reveal = [SKTransition doorsCloseHorizontalWithDuration:1.0];
    SKScene * nextScene = [[SpeedScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene transition: reveal];
}

@end

@implementation SpeedScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
    
        // speedTo:duration:
        [self.cat runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction group:@[
                    [SKAction speedTo:5.0 duration:1.0],
                    [SKAction moveByX:0 y:self.size.height * 1/6 duration:1.0],
                ]],
                [SKAction group:@[
                    [SKAction moveByX:0 y:-self.size.height * 1/6 duration:1.0],
                ]],
                [SKAction group:@[
                    [SKAction moveByX:0 y:self.size.height * 1/6 duration:1.0],
                ]],
                [SKAction group:@[
                    [SKAction speedTo:1.0 duration:1.0],
                    [SKAction moveByX:0 y:-self.size.height * 1/6 duration:1.0],
                ]],
            ]]
        ]];
        
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:0.25],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:0.25],
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:0.25],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:0.25],
                [SKAction speedTo:0.5 duration:0.1],
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:0.25],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:0.25],
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:0.25],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:0.25],
                [SKAction speedTo:1.0 duration:0.1],
            ]]
        ]];
        
        // speedBy:duration
        // TODO: BUG??? Getting unexpected behavior on this...
        
        [self.turtle runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:0.25],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:0.25],
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:0.25],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:0.25],
                [SKAction speedBy:-0.5 duration:0.1],
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:0.25],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:0.25],
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:0.25],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:0.25],
                [SKAction speedBy:0.5 duration:0.1],
            ]]
        ]];
        
        
        self.label.text = @"Speed Actions / Doorway";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKTransition *reveal = [SKTransition doorwayWithDuration:1.0];
    SKScene * nextScene = [[WaitScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene transition: reveal];
}

@end

@implementation WaitScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
    
        // waitForDuration:
        [self.cat runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:1.0],
                [SKAction waitForDuration:1.0],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:1.0],
            ]]
        ]];
        
        // waitForDuration:withRange:
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:1.0],
                [SKAction waitForDuration:1.0 withRange:1.0],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:1.0],
            ]]
        ]];
        
        // moveToX:duration: and moveToY:duration:
        [self.turtle runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction moveByX:0 y:self.size.height * 1/6 duration:1.0],
                [SKAction waitForDuration:2.0 withRange:2.0],
                [SKAction moveByX:0 y:-self.size.height * 1/6 duration:1.0],
            ]]
        ]];
        
        self.label.text = @"Wait Actions / CIFilter";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    // TODO: Is there a more interesting one to cover here that isn't already shown?
    CIFilter * filter = [CIFilter filterWithName:@"CIDissolveTransition"];
    [filter setDefaults];
    
    SKTransition *reveal = [SKTransition transitionWithCIFilter:filter duration:1.0];
    SKScene * nextScene = [[BlockSelectorScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene transition: reveal];
}

@end

@interface BlockSelectorScene ()
@property (nonatomic) BOOL workDone;
@end

@implementation BlockSelectorScene

- (void)rotateCat {
    [self.cat runAction:[SKAction rotateByAngle:M_PI*2 duration:1.0]];
}

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // performSelector:onTarget:
        [self.cat runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction performSelector:@selector(rotateCat) onTarget:self],
                [SKAction waitForDuration:2.0]
            ]]
        ]];
        
        // runBlock:
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction runBlock:^{
                    [self.dog runAction:[SKAction rotateByAngle:M_PI*2 duration:1.0]];
                }],
                [SKAction waitForDuration:2.0]
            ]]
        ]];
        
        // runBlock:queue:
        dispatch_queue_t queue = dispatch_queue_create("com.razeware.actionscatalog.bgqueue", NULL);
        self.workDone = YES;
        [self.turtle runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                [SKAction runBlock:^{
                    if (self.workDone) {
                        self.workDone = NO;
                        [self.turtle runAction:[SKAction rotateByAngle:M_PI*2 duration:1.0]];
                        [self.turtle runAction:[SKAction runBlock:^{
                            sleep(1);
                            self.workDone = YES;
                        } queue:queue]];
                    }
                }],
                [SKAction waitForDuration:1.0],
            ]]
        ]];
        
        self.label.text = @"Block/Selector Actions";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKScene * nextScene = [[ChildActionsScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene];
}


@end

@implementation ChildActionsScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        [self.cat removeFromParent];
        self.cat.position = CGPointMake(-self.size.width * 1/3, 0);
        self.cat.name = @"cat";
        [self.dog addChild:self.cat];
        
        [self.turtle removeFromParent];
        self.turtle.position = CGPointMake(self.size.width * 1/3, 0);
        self.turtle.name = @"turtle";
        [self.dog addChild:self.turtle];
        
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction rotateByAngle:M_PI*2 duration:3.0]
        ]];
        
        // runAction:onChildWithName:
        [self.dog runAction:[SKAction runAction:
            [SKAction repeatActionForever:
                [SKAction rotateByAngle:M_PI*2 duration:3.0]
            ] onChildWithName:@"cat"]];
        
        [self.dog runAction:[SKAction runAction:
            [SKAction repeatActionForever:
                [SKAction sequence:@[
                    [SKAction moveByX:-100 y:0 duration:1.0],
                    [SKAction moveByX:100 y:0 duration:1.0]
                ]]
            ] onChildWithName:@"turtle"]];        
        
        self.label.text = @"Child Actions";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKScene * nextScene = [[CustomActionScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene];
}


@end

@implementation CustomActionScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // customActionWithDuration:actionBlock:
        
        // "Blink" action
        float blinkTimes = 6;
        float catDuration = 2.0;
        [self.cat runAction:[SKAction repeatActionForever:
            [SKAction customActionWithDuration:catDuration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                float slice = catDuration / blinkTimes;
                float remainder = fmodf(elapsedTime, slice);
                self.cat.hidden = remainder > slice / 2;
            }]
        ]];
      
        // "Jump" action
        CGPoint dogStart = self.dog.position;
        float jumpHeight = 100;
        float dogDuration = 2.0;
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction customActionWithDuration:dogDuration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                float fraction = elapsedTime / dogDuration;
                float yOff = jumpHeight * 4 * fraction * (1 - fraction);
                node.position = CGPointMake(node.position.x, dogStart.y + yOff);
            }]
        ]];
        
        // "Sin wave"
        CGPoint turtleStart = self.turtle.position;
        float amplitude = 25;
        float turtleDuration = 1.0;
        [self.turtle runAction:[SKAction repeatActionForever:
            [SKAction customActionWithDuration:turtleDuration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                float fraction = elapsedTime / turtleDuration;
                float yOff = sinf(M_PI * 2 * fraction) * amplitude;
                node.position = CGPointMake(node.position.x, turtleStart.y + yOff);
            }]
        ]];

        
        self.label.text = @"Custom Actions";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKScene * nextScene = [[TimingScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene];
}

@end

@implementation TimingScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
    
        // SKActionTimingEaseIn
        SKAction * catMoveUp = [SKAction moveByX:0 y:self.size.height * 1/6 duration:1.0];
        catMoveUp.timingMode = SKActionTimingEaseIn;
        SKAction * catMoveDown = [catMoveUp reversedAction];
        [self.cat runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                catMoveUp, catMoveDown
            ]]
        ]];
        
        // SKActionTimingEaseOut
        SKAction * dogMoveUp = [SKAction moveByX:0 y:self.size.height * 1/6 duration:1.0];
        catMoveUp.timingMode = SKActionTimingEaseOut;
        SKAction * dogMoveDown = [dogMoveUp reversedAction];
        [self.dog runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                dogMoveUp, dogMoveDown
            ]]
        ]];
        
        // SKActionTimingEaseInEaseOut
        SKAction * turtleMoveUp = [SKAction moveByX:0 y:self.size.height * 1/6 duration:1.0];
        turtleMoveUp.timingMode = SKActionTimingEaseInEaseOut;
        SKAction * turtleMoveDown = [turtleMoveUp reversedAction];
        [self.turtle runAction:[SKAction repeatActionForever:
            [SKAction sequence:@[
                turtleMoveUp, turtleMoveDown
            ]]
        ]];
        
        self.label.text = @"Timing Actions";
    
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKScene * nextScene = [[MoveScene alloc] initWithSize:self.size];
    [self.view presentScene:nextScene];
}

@end