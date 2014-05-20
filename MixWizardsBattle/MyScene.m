//
//  MyScene.m
//  MixWizardsBattle
//
//  Created by CS121 on 3/21/14.
//  Copyright (c) 2014 CS121. All rights reserved.
//

#import "MyScene.h"
#include <stdlib.h>

@interface MyScene()

// Sprites
@property (atomic) SKSpriteNode * playerAva;
@property (nonatomic) SKSpriteNode * petAva;
@property (atomic) SKSpriteNode * bossAva;
@property (nonatomic, strong) SKSpriteNode *selectedNode;
@property (atomic) SKEmitterNode *burst;

// Sprite Properties
@property (atomic) BOOL gender;
@property (atomic) float bounceScale;
@property (atomic) bool bounceDirection;
@property (atomic) float bossHealthPoint;

// Updates
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (atomic) SKAction *buttonPressed;

// Buttons
@property (atomic) SKSpriteNode *attack;
@property (atomic) SKSpriteNode *specialAttack1;
@property (atomic) SKSpriteNode *specialAttack2;
@property (atomic) SKSpriteNode *heal;

// Health bar
@property (atomic) SKSpriteNode *bossBar;
@property (atomic) SKSpriteNode *bossHP;
@property (atomic) SKSpriteNode *bossHurt;
@property (atomic) SKSpriteNode *playerBar;
@property (atomic) SKSpriteNode *playerHP;
@property (atomic) SKSpriteNode *playerHurt;
@property (atomic) int bossHPcount;
@property (atomic) int cur_bossHPcount;
@property (atomic) int playerHPcount;
@property (atomic) int cur_playerHPcount;
@end

@implementation MyScene
{
    SKAction *playerAttack;
    SKAction *playerRetreat;
    SKAction *bossAttack;
    SKAction *playerDefend;
    SKAction *bossDefend;

}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.bounceScale = 0.0;
        SKSpriteNode *bgImage = [SKSpriteNode spriteNodeWithImageNamed:@"battleBG"];
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2);
        bgImage.name = @"BACKGROUND";
        [self addChild:bgImage];
        
        self.gender = 1;
        [self setUpPlayerAvatar];
        
        [self setUpBossAvatar];
        
        // Define actions
        int moveDistanceX = self.bossAva.position.x - self.playerAva.position.x;
        playerAttack = [SKAction moveByX:moveDistanceX y:0 duration:1.0];
        playerRetreat = [SKAction moveByX:-moveDistanceX y:0 duration:1.5];
        
        [self setUpHealthBar];
        
        [self setUpBurst];
        
        [self setUpButtons];
        
        [self setUpSounds];
       
    }
    return self;
}
- (void) setUpPlayerAvatar
{
    // Adding player avatar
    //self.gender = 1;
    if (self.gender == 0) {
        self.playerAva = [SKSpriteNode spriteNodeWithImageNamed:@"maleMage"];
    }
    else {
        self.playerAva = [SKSpriteNode spriteNodeWithImageNamed:@"femaleMage"];
    }
    self.playerAva.position = CGPointMake(self.playerAva.size.width/2,self.frame.size.height/2);
    self.playerAva.anchorPoint = CGPointMake(0.5, 0);
    self.playerAva.name = @"PLAYER";
    [self addChild:self.playerAva];
}
- (void) setUpBossAvatar
{
    // Adding boss avatar
    self.bossAva = [SKSpriteNode spriteNodeWithImageNamed:@"femaleBoss"];
    self.bossAva.name = @"BOSS";
    self.bossAva.xScale = 0.8;
    self.bossAva.yScale = 0.8;
    self.bossAva.position = CGPointMake(self.frame.size.width - self.bossAva.size.width/2 + 20, self.frame.size.height/2);
    [self addChild:self.bossAva];
}
- (void) setUpHealthBar
{
    // Health Bar
    self.bossHPcount = 100;
    self.cur_bossHPcount = self.bossHPcount;
    
    self.playerHPcount = 50;
    self.cur_playerHPcount = self.playerHPcount;
    
    self.bossHP = [SKSpriteNode spriteNodeWithImageNamed:@"health.png"];
    self.bossBar = [SKSpriteNode spriteNodeWithImageNamed:@"bar.png"];
    self.bossHurt = [SKSpriteNode spriteNodeWithImageNamed:@"hurt.png"];
    
    self.bossBar.position = CGPointMake(self.bossAva.position.x, self.frame.size.height - 29);
    self.bossHP.anchorPoint = CGPointMake(0, 0.5);
    self.bossHP.position = CGPointMake(self.bossBar.position.x - (self.bossBar.size.width/2), self.bossBar.position.y);
    
    self.bossHurt.position = CGPointMake(self.bossHP.position.x + self.bossHP.size.width, self.bossHP.position.y);
    self.bossHurt.anchorPoint = CGPointMake(1, 0.5);
    self.bossHurt.xScale = 1 - (self.cur_bossHPcount / self.bossHPcount);
    
    [self addChild:self.bossHP];
    [self addChild:self.bossHurt];
    [self addChild:self.bossBar];
    
    self.playerHP = [SKSpriteNode spriteNodeWithImageNamed:@"health.png"];
    self.playerBar = [SKSpriteNode spriteNodeWithImageNamed:@"bar.png"];
    self.playerHurt = [SKSpriteNode spriteNodeWithImageNamed:@"hurt.png"];
    
    self.playerBar.position = CGPointMake(self.playerAva.position.x + 50, self.size.height - 29);
    self.playerHP.position = CGPointMake(self.playerBar.position.x, self.playerBar.position.y);
    [self addChild:self.playerHP];
    [self addChild:self.playerBar];
    

}
- (void) setUpBurst
{
    // Particles
    NSString *burstPath =
    [[NSBundle mainBundle] pathForResource:@"ParticleOneSpark" ofType:@"sks"];
    
    self.burst =
    [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
    
    self.burst.position = CGPointMake(self.playerAva.position.x, 400);
    
    [self addChild:self.burst];
    self.burst.emissionAngle = -0.5 * 3.14;
    self.burst.emissionAngleRange = 0.5*3.14;
}
- (void) setUpButtons
{
    // Buttons

    self.attack = [SKSpriteNode spriteNodeWithImageNamed:@"sword-icon.png"];
    self.attack.name = @"attack";
    self.attack.position = CGPointMake(60, 100);
    self.attack.xScale = 0.8;
    self.attack.yScale = 0.8;
   
    
    self.specialAttack1 = [SKSpriteNode spriteNodeWithImageNamed:@"Spells-icon.png"];
    self.specialAttack1.name = @"spell";
    self.specialAttack1.position = CGPointMake(self.attack.position.x + 150,100);
    self.specialAttack1.xScale = 0.8;
    self.specialAttack1.yScale = 0.8;
    
    self.specialAttack2 = [SKSpriteNode spriteNodeWithImageNamed:@"blood-icon.png"];
    self.specialAttack2.name = @"bleed";
    self.specialAttack2.position = CGPointMake(self.specialAttack1.position.x + 150,100);
    self.specialAttack2.xScale = 0.8;
    self.specialAttack2.yScale = 0.8;
    
    
    self.heal = [SKSpriteNode spriteNodeWithImageNamed:@"cosmic-heart-compact-icon.png"];
    self.heal.name = @"heal";
    self.heal.position = CGPointMake(self.specialAttack2.position.x + 150, 100);
    self.heal.xScale = 0.8;
    self.heal.yScale = 0.8;
    
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:0.8 alpha:0.3] size:CGSizeMake((self.attack.size.width)*4 + 50*3, self.attack.size.height*1.2)];
    background.position = CGPointMake((self.specialAttack1.position.x + self.specialAttack2.position.x)/2, self.attack.position.y);
    
    [self addChild:background];
    [self addChild:self.attack];
    [self addChild:self.specialAttack1];
    [self addChild:self.specialAttack2];
    [self addChild:self.heal];
    
    
    // SKActions
    SKAction *darkenButton = [SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:0.5 duration:0.5];
    SKAction *brightenButton = [SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:-0.5 duration:0.5];
    
    self.buttonPressed = [SKAction sequence:@[darkenButton,brightenButton]];
}
- (void) setUpSounds
{
    
    // Sound effects

    NSString *path1 = [[NSBundle mainBundle]
                       pathForResource:@"punch" ofType:@"mp3"];
    NSURL *path1url = [NSURL fileURLWithPath:path1];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)path1url, &attackSound);
    
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"pew" ofType:@"mp3"];
    NSURL *path2url = [NSURL fileURLWithPath:path2];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)path2url, &specialSound1);
    
    NSString *path3 = [[NSBundle mainBundle] pathForResource:@"specialattackk" ofType:@"mp3"];
    NSURL *path3url = [NSURL fileURLWithPath:path3];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)path3url, &specialSound2);
    
    NSString *path4 = [[NSBundle mainBundle] pathForResource:@"heal" ofType:@"mp3"];
    NSURL *path4url = [NSURL fileURLWithPath:path4];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)path4url, &healSound);
}

- (void)bounce {
    
    float bGranualiry = 0.01;
    float bMaximum = 0.08;
    
    self.playerAva.yScale = 1 - self.bounceScale;
    if (self.bounceScale + bGranualiry > bMaximum && self.bounceDirection == 0)
    {
        self.bounceScale -= bGranualiry;
        self.bounceDirection = 1 - self.bounceDirection;
    }
    else if (self.bounceScale - bGranualiry < 0 && self.bounceDirection == 1)
    {
        self.bounceScale += bGranualiry;
        self.bounceDirection = 1 - self.bounceDirection;
    }
    else if (self.bounceDirection == 0)
    {
        self.bounceScale += bGranualiry;
    }
    else if (self.bounceDirection == 1)
    {
        self.bounceScale -= bGranualiry;
    }
}

- (void) updateBossHealth
{
    self.bossHP.xScale = ((float)self.cur_bossHPcount)/self.bossHPcount;
    self.bossHurt.xScale = 1 - self.bossHP.xScale;
    //NSLog(@"boss hp portion %f", self.bossHP.xScale);
    


}
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 0.1) {
        self.lastSpawnTimeInterval = 0;
        [self bounce];
        [self updateBossHealth];
    }
}

- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
    [self selectNodeForTouch:touchLocation];
}

- (void)selectNodeForTouch:(CGPoint)touchLocation {
    
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    
    if([[touchedNode name] isEqualToString:self.attack.name]) {
        [self.attack runAction:self.buttonPressed];
        [self attackBoss];
        NSLog(@"Tabbed on the %@",[touchedNode name]);
    }
    
    else if([[touchedNode name] isEqualToString:self.heal.name]) {
        [self.heal runAction:self.buttonPressed];
        [self playerHeals];
        NSLog(@"Healed.");
    }
    
    else if ([[touchedNode name] isEqualToString:self.specialAttack1.name])
    {
        [self.specialAttack1 runAction:self.buttonPressed];
        [self specAttack1];
        NSLog(@"special attack 1");
    }
    
    else if ([[touchedNode name] isEqualToString:self.specialAttack2.name])
    {
        [self.specialAttack2 runAction:self.buttonPressed];
        [self specAttack2];
        NSLog(@"special attack 2");
    }
    
    else if ([[touchedNode name] isEqualToString:self.playerAva.name])
    {
        [self.playerAva runAction:self.buttonPressed];
        [self.playerAva runAction:[SKAction removeFromParent]];
        self.gender = 1 - self.gender;
        [self setUpPlayerAvatar];
    }
    
    
}

- (void)attackBoss {
    int reduction = 10;

    SKAction *wait = [SKAction waitForDuration: 2];
    SKAction *colorize = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:0.5 duration:0.7];
    SKAction *uncolorize = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:-0.5 duration:0.7];
    SKAction *music = [SKAction playSoundFileNamed:@"punch.mp3" waitForCompletion:0];
    SKAction *sequencePlayer = [SKAction sequence:@[playerAttack,playerRetreat]];
    SKAction *sequenceBoss = [SKAction sequence:@[wait, music,colorize, uncolorize]];
    
    // Health Bar
    if (self.cur_bossHPcount - reduction > 0)
    {
        self.cur_bossHPcount -= reduction;

    }
    else
    {
        UIAlertView *winAlert = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"You have defeated the boss" delegate:nil cancelButtonTitle:@"Hooray." otherButtonTitles:nil, nil];
        [winAlert show];
        [self winGame];
    }
    
    NSLog(@"boss current health %d, total heal is %d", self.cur_bossHPcount, self.bossHPcount);

    [self.playerAva runAction:sequencePlayer];
    [self.burst runAction:sequencePlayer];
    [self.bossAva runAction:sequenceBoss];
    
}

- (void)playerHeals {
    SKEmitterNode *healing;
    SKAction *wait = [SKAction waitForDuration: 5];
    SKAction *remove = [SKAction removeFromParent];
    NSString *burstPath =
    [[NSBundle mainBundle] pathForResource:@"heal2" ofType:@"sks"];
    
    healing =
    [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
    
    healing.position = CGPointMake(self.playerAva.position.x, self.playerAva.position.y+100);
    AudioServicesPlaySystemSound(healSound);
    
    [self addChild:healing];
    
    SKAction *sequenceHeal = [SKAction sequence:@[wait, remove]];
    [healing runAction:sequenceHeal];
    
}

- (void)specAttack1 {
    int reduction = 5;
    SKEmitterNode *spell;
    SKAction *jump;
    SKAction *jumpback;
    SKAction *remove;
    SKAction *sound = [SKAction playSoundFileNamed:@"specialattackk.mp3" waitForCompletion:0];
    SKAction *specAttkSequence_player;
    SKAction *specAttkSequence_particle;
    SKAction *wait = [SKAction waitForDuration:5];

    
    NSString *particlePath = [[NSBundle mainBundle] pathForResource:@"spell" ofType:@"sks"];
    spell = [NSKeyedUnarchiver unarchiveObjectWithFile:particlePath];
    spell.position = CGPointMake(self.bossAva.position.x, self.bossAva.position.y);
    
    jump = [SKAction moveToY:self.playerAva.position.y + 100 duration:0.5];
    jumpback = [SKAction moveToY:self.playerAva.position.y duration:0.5];
    remove = [SKAction removeFromParent];
    specAttkSequence_player = [SKAction sequence:@[jump, jumpback]];
    specAttkSequence_particle = [SKAction sequence:@[sound, wait, remove]];
    

    // Health Bar
    if (self.cur_bossHPcount - reduction > 0)
    {
        self.cur_bossHPcount -= reduction;
        
    }
    else
    {
        UIAlertView *winAlert = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"You have defeated the boss" delegate:nil cancelButtonTitle:@"Hooray." otherButtonTitles:nil, nil];
        [winAlert show];
        [self winGame];
    }
    
    [self addChild:spell];
    [self.playerAva runAction:specAttkSequence_player];
    [self.burst runAction:specAttkSequence_player];
    [spell runAction:specAttkSequence_particle];
    
    
}

- (void)specAttack2 {
    int reduction = 30;
    SKEmitterNode *spell;
    SKAction *scale;
    SKAction *scaleBack;
    SKAction *remove = [SKAction removeFromParent];
    SKAction *sound = [SKAction playSoundFileNamed:@"pew.mp3" waitForCompletion:0];
    SKAction *wait = [SKAction waitForDuration:5];
    SKAction *sequence_player;
    SKAction *sequence_particle;
    SKAction *sequence_boss;
    
    SKAction *colorize = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:0.5 duration:0.2];
    SKAction *uncolorize = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:-0.5 duration:0.2];
    
    NSString *particlePath = [[NSBundle mainBundle] pathForResource:@"bleed" ofType:@"sks"];
    spell = [NSKeyedUnarchiver unarchiveObjectWithFile:particlePath];
    spell.position = CGPointMake(self.bossAva.position.x, self.bossAva.position.y);
    
    scale = [SKAction scaleBy:2 duration:0.5];
    scaleBack = [SKAction scaleBy:0.5 duration:0.5];
    
    sequence_particle = [SKAction sequence:@[sound, wait, remove]];
    sequence_player = [SKAction sequence:@[scale, scaleBack]];
    sequence_boss = [SKAction sequence:@[colorize, uncolorize, colorize, uncolorize, colorize, uncolorize]];
    
    // Health Bar
    if (self.cur_bossHPcount - reduction > 0)
    {
        self.cur_bossHPcount -= reduction;
        
    }
    else
    {
        UIAlertView *winAlert = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"You have defeated the boss" delegate:nil cancelButtonTitle:@"Hooray." otherButtonTitles:nil, nil];
        [winAlert show];
        [self winGame];
    }
    
    [self addChild:spell];
    [spell runAction:sequence_particle];
    [self.playerAva runAction:sequence_player];
    [self.bossAva runAction:sequence_boss];
    
}

-(void) winGame
{
    SKAction *sequence = [SKAction sequence:@[[SKAction fadeAlphaTo:0.0 duration:3], [SKAction removeFromParent]]];
    [self.bossAva runAction:sequence];
    [self.bossBar removeFromParent];
    [self.bossHP removeFromParent];
    [self.bossHurt removeFromParent];

}
@end
