//
//  GameViewController.m
//  DarkKnight
//
//  Created by 谢佳培 on 2021/1/12.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 配置视图
    SKView *skView = (SKView *)self.view;
    // 显示FPS
    skView.showsFPS = YES;
    // 显示节点数量
    skView.showsNodeCount = YES;
    
    // 创建场景
    SKScene *scene = [GameScene sceneWithSize:skView.bounds.size];
    // 展现场景
    [skView presentScene:scene];
    // 展示时适配屏幕大小
    scene.scaleMode = SKSceneScaleModeAspectFill;
}

@end
