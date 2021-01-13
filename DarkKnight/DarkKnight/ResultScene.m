//
//  ResultScene.m
//  DarkKnight
//
//  Created by 谢佳培 on 2021/1/12.
//

#import "ResultScene.h"
#import "GameScene.h"

@implementation ResultScene

- (instancetype)initWithSize:(CGSize)size won:(BOOL)won
{
    if (self = [super initWithSize:size])
    {
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0f blue:1.0f alpha:1.0f];
        NSLog(@"视图的宽：%f，高：%f",size.width,size.height);
        
        [self createSubviews:won];
    }
    
    return self;
}

- (void)createSubviews:(BOOL)won
{
    // 开辟空间，设置字体
    SKLabelNode *resultLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    // 设置text内容
    resultLabel.text = won ? @"大侠真是天赋异禀" : @"大侠请重新来过";
    // 设置字体大小
    resultLabel.fontSize = 30;
    // 设置字体颜色
    resultLabel.fontColor = [SKColor blackColor];
    // 设置位置为屏幕中央
    resultLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    // 添加子节点
    [self addChild:resultLabel];
    
    SKLabelNode *retryLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    retryLabel.text = @"重出江湖";
    retryLabel.fontSize = 20;
    retryLabel.fontColor = [SKColor blueColor];
    retryLabel.position = CGPointMake(resultLabel.position.x, resultLabel.position.y * 0.8);
    // 给节点命名，方便找到节点
    retryLabel.name = @"retryLabel";
    [self addChild:retryLabel];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        // 获取当前点击位置
        CGPoint touchuLocation = [touch locationInNode:self];
        // 根据点击的位置获取点击到的节点，如果有则返回对应节点，否则返回空
        SKNode *node = [self nodeAtPoint:touchuLocation];
        // 判断当前点击的节点是否是retryLabel
        if ([node.name isEqualToString:@"retryLabel"])
        {
            // 重新进入游戏界面
            [self changeToGameScene];
        }
    }
}

- (void)changeToGameScene
{
    GameScene *gameScene = [GameScene sceneWithSize:self.size];
    SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
    [self.scene.view presentScene:gameScene transition:reveal];
}


@end
