//
//  ViewController.m
//  Dispatch_source_timer
//
//  Created by Gujy on 2021/8/17.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,strong) dispatch_source_t t_source;
@property (nonatomic,assign) NSTimeInterval seconds;
@property (nonatomic,assign) BOOL isSuspend;
@property (nonatomic,assign) BOOL isCancel;


@property (nonatomic,strong) UIButton *sbutton;
@property (nonatomic,strong) UIButton *ebutton;
@property (nonatomic,strong) UIButton *rtbutton;
@property (nonatomic,strong) UILabel *secondLabel;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.seconds = 0;
    self.isSuspend = false;
    self.isCancel  = false;
    
    _sbutton = [UIButton buttonWithType:UIButtonTypeSystem];
    _sbutton.frame = CGRectMake(10, 64, 100, 50);
    _sbutton.backgroundColor = [UIColor lightGrayColor];
    [_sbutton setTitle:@"开始" forState:UIControlStateNormal];
    [self.view addSubview:_sbutton];
    [_sbutton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    
    _ebutton = [UIButton buttonWithType:UIButtonTypeSystem];
    _ebutton.frame = CGRectMake(120, 64, 100, 50);
    _ebutton.backgroundColor = [UIColor lightGrayColor];
    [_ebutton setTitle:@"暂停" forState:UIControlStateNormal];
    [_ebutton setTitle:@"不可用" forState:UIControlStateDisabled];
    [_ebutton setEnabled:NO];
    [self.view addSubview:_ebutton];
    [_ebutton addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    
    _rtbutton = [UIButton buttonWithType:UIButtonTypeSystem];
    _rtbutton.frame = CGRectMake(230, 64, 100, 50);
    _rtbutton.backgroundColor = [UIColor lightGrayColor];
    [_rtbutton setTitle:@"重置" forState:UIControlStateNormal];
    [self.view addSubview:_rtbutton];
    [_rtbutton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    
    _secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 124, 150, 50)];
    _secondLabel.text = @"0";
    [self.view addSubview:_secondLabel];
    
    // 定义一个 ScrollView 测试是否影响主线程
    UIScrollView *s = [[UIScrollView alloc] initWithFrame:CGRectMake(10,200, 300, 100)];
    s.backgroundColor = [UIColor yellowColor];
    [s setContentSize:CGSizeMake(600,100)];
    [self.view addSubview:s];
    
    UIView *v1 = [[UIView alloc] initWithFrame:CGRectMake(0,0, 300, 100)];
    v1.backgroundColor = [UIColor greenColor];
    
    UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(300,0, 300, 100)];
    v2.backgroundColor = [UIColor blueColor];
    [s addSubview:v1];
    [s addSubview:v2];
    
    [self createTimer];
    
}

- (void) createTimer {
    dispatch_queue_t queue = dispatch_queue_create("timeQueue", DISPATCH_QUEUE_CONCURRENT);
    // 创建源
    self.t_source =  dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0,0, queue);
    dispatch_time_t start = DISPATCH_TIME_NOW; //dispatch_walltime(NULL,0);
    dispatch_source_set_timer(self.t_source,start,1.0*NSEC_PER_SEC,0);
    __weak typeof(self) weakSelf = self;
    // 设置源数据回调
    dispatch_source_set_event_handler(self.t_source, ^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.seconds++;
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新 UI
            strongSelf.secondLabel.text = [NSString stringWithFormat:@"%.f",strongSelf.seconds];
        });
    });
}

- (void) start {
    
    [_sbutton setEnabled:NO];
    if(!self.t_source) {
        [self createTimer];
    }
    dispatch_resume(self.t_source);
    // 可以进行挂起
    [_ebutton setEnabled:YES];
    _isSuspend = false;
}


- (void) stop {
    if(self.t_source) {
        if(_isSuspend){ // 已挂起
            NSLog(@">>>>>> 已挂起，无法继续挂起");
            return;
        }
        dispatch_suspend(self.t_source); // 挂起
        _isSuspend = true;
        [_sbutton setEnabled:YES];
        [_sbutton setTitle:@"继续" forState:UIControlStateNormal];
    }
}

// 重置
- (void) reset {
 
    if(_t_source) {
        if(_isSuspend) {
            dispatch_resume(self.t_source); // 不继续，无法进行销毁
        }
        dispatch_source_cancel(self.t_source);
        self.t_source = nil;
    }
    [_sbutton setTitle:@"开始" forState:UIControlStateNormal];
    [_sbutton setEnabled:YES];
    [_ebutton setEnabled:NO];
    _secondLabel.text = @"0";
    _seconds = 0;
}




@end


//if(self.preTime > 0) {
//            self.currInterval = CFAbsoluteTimeGetCurrent() - self.preTime;
//
//            NSLog(@">>>>> self.preTime is %f currInterval = %f",self.preTime,self.currInterval * 1000);
//
//        }else {
//            // 只存储第一次的
//            self.preTime = CFAbsoluteTimeGetCurrent();
//
//        }
