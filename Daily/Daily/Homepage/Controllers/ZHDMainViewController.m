//
//  MainViewController.m
//  
//
//  Created by 小哲的DELL on 2018/10/24.
//

#import "ZHDMainViewController.h"
#import "ZHDDateUtils.h"
#import "ZHDDetailsViewController.h"
#include <SDWebImage/UIImageView+WebCache.h>

@interface ZHDMainViewController ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, ZHDCarouselViewDelegate, ZHDMainViewDelegate>
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation ZHDMainViewController

- (void)viewWillAppear:(BOOL)animated{
    _menuButton.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [self createChildView];
    [self setupHeader];
}

- (void)createChildView{
    self.days = -1;
    self.data = [NSMutableArray new];
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    //设置导航栏背景图片
    UIImage *colorImage = [ZHDMainViewController createImageWithColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setBackgroundImage:colorImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBaselineAdjustmentNone;

    //设置导航栏上的菜单按钮
    _menuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _menuButton.hidden = NO;
    [_menuButton setImage:[UIImage imageNamed:@"菜单"] forState:UIControlStateNormal];
    [_menuButton setTintColor:[UIColor whiteColor]];
    [_menuButton addTarget:self action:@selector(openCloseMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:_menuButton];
    [_menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.navigationController.navigationBar.mas_left).with.offset(15);
        make.top.equalTo(self.navigationController.navigationBar.mas_top).with.offset(10);
        make.bottom.equalTo(self.navigationController.navigationBar.mas_bottom).with.offset(-10);
        make.width.equalTo(@30);
    }];
    
    //设置tableView
    self.mainView = [[ZHDMainView alloc] initWithFrame:self.view.bounds];
    self.mainView.tableView.delegate = self;
    self.mainView.tableView.dataSource = self;
    _mainView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_mainView];
    self.mainView.delegate = self;
    
    //网络请求数据
    [self postStories];
    self.days++;
    
}

/**侧边栏的展开和关闭*/
- (void)openCloseMenu: (UIButton *)sender
{
    [self.navigationController.parentViewController performSelector:@selector(openCloseMenu)];
}

//将请求得的数据放到主界面
-(void)postStories{
    self.isLoading = YES;
    if (self.days == -1) {
        [[ZHDNowManager sharedManager] requestNowStoriesWith:self.days Success:^(ZHDTotalJSONModel *resultModel) {
            NSLog(@"传值成功1");
            self.totalModel = resultModel;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mainView.tableView reloadData];
            });
            self.isLoading = NO;
            
            //设置轮播图图片
            NSMutableArray *imageAarray = [NSMutableArray new];
            for (ZHDTop_storiesModel *ts in self.totalModel.top_stories) {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:ts.image]];
                UIImage *image = [UIImage imageWithData:data];
                [imageAarray addObject:image];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.mainView.carousel.images = imageAarray;
                self.mainView.tableView.tableHeaderView = self.mainView.carousel;
            });
            
        }];
    } else{
        [[ZHDNowManager sharedManager] requestRecentStoriesWith:self.days :self.data Success:^(NSMutableArray *storiesArray) {
            NSLog(@"传值成功2");
            self.data = storiesArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mainView.tableView reloadData];
            });
            self.isLoading = NO;
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 0.13 * self.mainView.frame.size.height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.days + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.totalModel.stories.count;
    } else{
        return [self.data[section-1] count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    } else {
        NSDate *date = [[NSDate alloc] init];
        
        _headerView = [[ZHDHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        _headerView.lable.text = [ZHDDateUtils getDate:date :-section];
        _headerView.lable.tag = section;
        return _headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    } else return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        self.mainView.tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        self.mainView.tableViewCell.label.text = [self.totalModel.stories[indexPath.row] title];

        NSString *str = [self.totalModel.stories[indexPath.row] images][0];
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
//        UIImage *image = [UIImage imageWithData:data];
        [self.mainView.tableViewCell.rightImageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];

        return self.mainView.tableViewCell;
    } else{
        self.mainView.tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        ZHDStoriesJSONModel *story = self.data[indexPath.section-1][indexPath.row];
        self.mainView.tableViewCell.label.text = story.title;
        [self.mainView.tableViewCell.rightImageView sd_setImageWithURL:[NSURL URLWithString:story.images[0]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
        
        return self.mainView.tableViewCell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ZHDDetailsViewController *detailsViewController = [[ZHDDetailsViewController alloc] init];
    if (indexPath.section == 0) {
        detailsViewController.ID = [self.totalModel.stories[indexPath.row] id];
        [self presentViewController:detailsViewController animated:YES completion:nil];
    } else{
        ZHDStoriesJSONModel *story = self.data[indexPath.section-1][indexPath.row];
        detailsViewController.ID = story.id;
        [self presentViewController:detailsViewController animated:YES completion:nil];
    }
}

//mainView的代理方法

- (void)pass:(NSInteger)index{
    ZHDDetailsViewController *detailsViewController = [[ZHDDetailsViewController alloc] init];
    detailsViewController.ID = [self.totalModel.top_stories[index] id];
    [self presentViewController:detailsViewController animated:YES completion:nil];
}


//设置图片透明度
+ (UIImage *)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

//设置纯色图片
+ (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

//if (scrollView.contentOffset.y < 0.1245 * self.mainView.frame.size.height * self.totalModel.stories.count + 200)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //下拉刷新所需属性
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize contentSize = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = contentSize.height;
    float reload_distance = 10;
    
    if (scrollView.contentOffset.y < 0.13 * self.mainView.frame.size.height * self.totalModel.stories.count + 300) {
        // 设置状态栏颜色
        self.statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        if ([self.statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            self.statusBar.backgroundColor = [UIColor clearColor];
        }
        
        //设置tableView内边距
        self.mainView.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        self.navigationController.navigationBar.hidden = NO;
        self.navigationItem.title = @"今日热闻";
        
        UIImage *colorImage = [ZHDMainViewController createImageWithColor:[UIColor colorWithRed:0.00f green:0.53f blue:0.85f alpha:1.00f]];
        UIImage *colorLastImage = [ZHDMainViewController imageByApplyingAlpha:scrollView.contentOffset.y / 200.0 image:colorImage];
        
        [self.navigationController.navigationBar setBackgroundImage:colorLastImage forBarMetrics:UIBarMetricsDefault];
//        NSLog(@"----NO.1--%f--", scrollView.contentOffset.y);
        
        if (scrollView.contentOffset.y > 0.13 * self.mainView.frame.size.height * self.totalModel.stories.count + 200 - self.view.frame.size.height) {
            if (y > h + reload_distance) {
                if (self.isLoading) {
                    return;
                } else{
                    self.days++;
                    [self postStories];
                }
            }
        }
    } else{
        //设置状态栏颜色
        self.statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        if ([self.statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            self.statusBar.backgroundColor = [UIColor colorWithRed:0.00f green:0.53f blue:0.85f alpha:1.00f];
        }
        self.mainView.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        self.navigationController.navigationBar.hidden = YES;
//        NSLog(@"----NO.2--%f--", scrollView.contentOffset.y);

        if (y > h + reload_distance) {
            if (self.isLoading) {
                return;
            } else{
                self.days++;
                [self postStories];
            }
        }
    }
}

- (void)setupHeader
{
    SDRefreshHeaderView *refreshHeader = [SDRefreshHeaderView refreshView];
    
    // 默认是在navigationController环境下，如果不是在此环境下，请设置 refreshHeader.isEffectedByNavigationController = NO;
    [refreshHeader addToScrollView:self.mainView.tableView];
    
    __weak SDRefreshHeaderView *weakRefreshHeader = refreshHeader;
    __weak typeof(self) weakSelf = self;
    refreshHeader.beginRefreshingOperation = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf postStories];
            [weakRefreshHeader endRefreshing];
        });
    };
    
    // 进入页面自动加载一次数据
    [refreshHeader autoRefreshWhenViewDidAppear];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
