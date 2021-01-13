//
//  GameScene.m
//  DarkKnight
//
//  Created by 谢佳培 on 2021/1/12.
//

#import "GameScene.h"
#import "ResultScene.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/NSObjCRuntime.h>

@interface GameScene()

@property (nonatomic, strong) NSMutableArray *monsters;// 怪物数组
@property (nonatomic, strong) NSMutableArray *projectiles;// 弹药数组
@property (nonatomic, strong) AVAudioPlayer *bgmPlayer;// 背景播放Player
@property(nonatomic,strong) SKAction *projectileSoundEffectAction;// 子弹声音Action
@property(nonatomic,assign) int monstersDestroyed;// 消灭怪物个数

@end

@implementation GameScene

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.monsters = [NSMutableArray array];
        self.projectiles = [NSMutableArray array];
        
        // 子弹发射声音
        self.projectileSoundEffectAction = [SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO];
        
        // 1.给Scene设置背景颜色，默认颜色是黑色
        self.backgroundColor = [SKColor colorWithRed:1.0f green:1.0 blue:1.0f alpha:1.0f];
        
        // 2.添加游戏里的玩家角色
        [self addPlayer:size];
        
        // 3.间隔1秒后创建下一个小怪兽，如此反复，使游戏里有多个小怪兽
        SKAction *actionAddMonster = [SKAction runBlock:^{ [self addMonster]; }];
        SKAction *actionWaitNextMonster = [SKAction waitForDuration:1];
        SKAction *repeatAddMonsterAction = [SKAction repeatActionForever:[SKAction sequence:@[actionAddMonster,actionWaitNextMonster]]];
        [self runAction:repeatAddMonsterAction];
        
        // 4.添加背景音乐
        [self addBGM];
    }
    return self;
}

- (void)addPlayer:(CGSize)size
{
    // 初始化一个精灵
    SKSpriteNode * player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
    // 设置精灵玩家的位置
    player.position = CGPointMake(player.size.width/2, size.height/2);
    // 将精灵玩家添加当前的场景中
    [self addChild:player];
}

- (void)addMonster
{
    // 初始化并添加一个小怪兽
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    [self addChild:monster];
    
    // 计算小怪兽的出生点
    CGSize windowSize = self.size;
    int minY = monster.size.height/2;
    int maxY = windowSize.height - monster.size.height/2;
    int rangeY = maxY - minY;// Y值的范围
    int actualY = (arc4random() % rangeY)+minY;// 将范围内产生的随机Y值作为实际Y值
    monster.position = CGPointMake(windowSize.width + monster.size.width/2, actualY);// 设定出生点恰好在屏幕右侧外面一点
    
    // 设置小怪兽的移动速度
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // 创建小怪兽移动的动作
    // 将精灵在持续时间内移动到结束点（直线横穿屏幕）
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    
    // 从屏幕中删除移动完成的小怪兽并宣告游戏失败
    SKAction *actionMoveDone = [SKAction runBlock:^{
        // 从父节点视图中移除
        [monster removeFromParent];
        // 从monsters数组中移除
        [self.monsters removeObject:monster];
        // 当小怪兽顺利移动到屏幕左侧消失掉的时候就意味着大侠的子弹没有击中它，所以要显示游戏失败的界面
        [self changeToResultSceneWithWon:NO];
    }];


    // 按照数组中的顺序调用Action
    [monster runAction:[SKAction sequence:@[actionMove,actionMoveDone]]];
    
    // 将小怪兽添加到数组中
    [self.monsters addObject:monster];
}

- (void)addBGM
{
    NSString *bgmPath = [[NSBundle mainBundle] pathForResource:@"background-music-aac" ofType:@"caf"];
    self.bgmPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:bgmPath] error:nil];
    self.bgmPlayer.numberOfLoops = -1;// 无限循环
    [self.bgmPlayer play];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        // 1.创建子弹节点并设置其初始位置
        SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile.png"];
        CGSize windowSize = self.size;
        projectile.position = CGPointMake(projectile.size.width/2, windowSize.height/2);
        
        // 2.获取场景中的手指触摸位置并计算和子弹节点位置之间的偏移量
        CGPoint location = [touch locationInNode:self];
        CGPoint offset = CGPointMake(location.x - projectile.position.x, location.y - projectile.position.y);
        if (offset.x <= 0) return;
        
        // 3.将子弹节点添加到场景中并计算实际的x和y的位置
        [self addChild:projectile];
        int realX = windowSize.width + projectile.size.width/2;// 实际上X的位置
        float ratio = offset.y/offset.x;// 比率
        int realY = realX * ratio + projectile.position.y;// 实际上Y的位置
        CGPoint realDest = CGPointMake(realX, realY);// 获取到实际位置
        
        // 4.获取子弹移动耗时
        int offRealX = realX - projectile.position.x;
        int offRealY = realY - projectile.position.y;
        float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));// 路径长度
        float velocity = self.size.width/1;// 速度
        float realMoveDuration = length/velocity;// 时间=路程/速度
        
        // 5.为子弹添加移动动作
        SKAction *moveAction = [SKAction moveTo:realDest duration:realMoveDuration];
        
        // 6.将移动和子弹声音动画组合使播放音效的action和移动精灵的action同时执行
        SKAction *projectileCastAction = [SKAction group:@[moveAction,self.projectileSoundEffectAction]];
        
        // 7.执行动画
        [projectile runAction:projectileCastAction completion:^{
            // 动画执行完毕后从父节点中移除子弹
            [projectile removeFromParent];
            // 动画执行完毕后将子弹从子弹数组中移除
            [self.projectiles removeObject:projectile];
        }];
        
        // 往子弹数组中添加刚刚产生的子弹
        [self.projectiles addObject:projectile];
    }
}

- (void)update:(NSTimeInterval)currentTime
{
    // 定义将要删除的子弹组成的数组
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    
    // 遍历子弹数组
    for (SKSpriteNode *projectile in self.projectiles)
    {
        // 定义将要删除的怪兽组成的数组
        NSMutableArray *monsterToDelete = [[NSMutableArray alloc] init];
        
        // 遍历怪物数组判断子弹是否和怪物相交(碰撞检测)
        for (SKSpriteNode *monster in self.monsters)
        {
            if (CGRectIntersectsRect(projectile.frame, monster.frame))
            {
                [monsterToDelete addObject:monster];
            }
        }
        
        // 3.遍历将要删除的怪兽组成的数组
        for (SKSpriteNode *monster in monsterToDelete)
        {
            // 从怪物数组删除该怪物
            [self.monsters removeObject:monster];
            // 将该怪物从父节点中移除(怪物消失)
            [monster removeFromParent];
            
            // 记录战绩，如果战绩大于30则切换到成功的界面
            self.monstersDestroyed++;
            if (self.monstersDestroyed >= 30)
            {
                [self changeToResultSceneWithWon:YES];
            }
        }
        
        // 如果将要删除的怪物数量大于0，说明有子弹击中了，则需要将该子弹加入到子弹删除数组
        if (monsterToDelete.count > 0)
        {
            [projectilesToDelete addObject:projectile];
        }
    }
    
    // 遍历将要删除的子弹组成的数组
    for (SKSpriteNode *projectile in projectilesToDelete)
    {
        // 将子弹从子弹数组删除
        [self.projectiles removeObject:projectile];
        // 将该子弹从父节点中移除(子弹消失)
        [projectile removeFromParent];
    }
}

- (void)changeToResultSceneWithWon:(BOOL)won
{
    // 1.停止背景音乐
    [self.bgmPlayer stop];
    self.bgmPlayer = nil;
    
    // 2.切换到结果场景
    ResultScene *resultScene = [[ResultScene alloc] initWithSize:self.size won:won];
    
    // 3.设置转场动画
    SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionUp duration:1.0];
    
    // 4.切换场景
    [self.scene.view presentScene:resultScene transition:reveal];
}

@end




