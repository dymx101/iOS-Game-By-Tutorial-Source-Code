//
//  MyScene.m
//  MultipleTexturesInASingleNode
//
#import "MyScene.h"
#define kNUMBER_OF_SHIPS 500
@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"bg-space"];
        [background setPosition:CGPointMake(CGRectGetMidX(self.frame),
                                            CGRectGetMidY(self.frame))];
        [self addChild:background];
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    int numberOfShips = [[self children] count];
    for (int x=numberOfShips; x < kNUMBER_OF_SHIPS; x++) {
        [self createEnemyShip];
    }
}

-(void)createEnemyShip  {
    SKSpriteNode *tmpShip = [SKSpriteNode spriteNodeWithImageNamed:[self getNextItemFileName]];
    [tmpShip setPosition:CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame))];
    
    [self addChild:tmpShip];
}

-(NSString*)getNextItemFileName {
	int itemType = random() % 8;
	NSString *fileName;
	switch (itemType) {
		case 0:
			fileName = [NSString stringWithFormat:@"asteroid-large"];
			break;
		case 1:
			fileName = [NSString stringWithFormat:@"asteroid-medium"];
			break;
		case 2:
			fileName = [NSString stringWithFormat:@"asteroid-small"];
			break;
		case 3:
			fileName = [NSString stringWithFormat:@"enemy-ship"];
			break;
		case 4:
			fileName = [NSString stringWithFormat:@"player-ship"];
			break;
		case 5:
			fileName = [NSString stringWithFormat:@"player-ship-flaps-open"];
			break;
		case 6:
			fileName = [NSString stringWithFormat:@"explosion0001"];
			break;
		case 7:
			fileName = [NSString stringWithFormat:@"explosion0002"];
			break;
		default:
			fileName = [NSString stringWithFormat:@"explosion0003"];
			break;
	}
	return fileName;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
