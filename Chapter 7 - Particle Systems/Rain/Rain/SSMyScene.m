//
//  SSMyScene.m
//  Rain
//
//  Created by Mike Daley on 31/08/2013.
//  Copyright (c) 2013 71Squared. All rights reserved.
//

#import "SSMyScene.h"

@implementation SSMyScene

-(instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        
        SKTexture *_rainTexture = [SKTexture textureWithImageNamed:@"rainDrop.png"];
        SKEmitterNode *_emitterNode = [SKEmitterNode new];
        _emitterNode.particleTexture = _rainTexture;
        _emitterNode.particleBirthRate = 80.0;
        _emitterNode.particleColor = [SKColor whiteColor];
        _emitterNode.particleSpeed = -450;
        _emitterNode.particleSpeedRange = 150;
        _emitterNode.particleLifetime = 2.0;
        _emitterNode.particleScale = 0.2;
        _emitterNode.particleAlpha = 0.75;
        _emitterNode.particleAlphaRange = 0.5;
        _emitterNode.particleColorBlendFactor = 1;
        _emitterNode.particleScale = 0.2;
        _emitterNode.particleScaleRange = 0.5;
        _emitterNode.position = CGPointMake(CGRectGetWidth(self.frame) / 2,
                                           CGRectGetHeight(self.frame) + 10);
        _emitterNode.particlePositionRange = CGVectorMake(CGRectGetMaxX(self.frame), 0);
        [self addChild:_emitterNode];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
