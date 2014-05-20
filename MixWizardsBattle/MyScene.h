//
//  MyScene.h
//  MixWizardsBattle
//

//  Copyright (c) 2014 CS121. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MyScene : SKScene
{
    // Sounds
    SystemSoundID attackSound;
    SystemSoundID healSound;
    SystemSoundID specialSound1;
    SystemSoundID specialSound2;
}

@end
