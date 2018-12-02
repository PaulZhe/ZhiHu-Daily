//
//  ZHDCommentsViewController.m
//  Daily
//
//  Created by 小哲的DELL on 2018/11/24.
//  Copyright © 2018年 小哲的DELL. All rights reserved.
//

#import "ZHDCommentsViewController.h"
#import "ZHDCommentsTableViewCell.h"
#import "ZHDCommentsManager.h"
#import <Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ZHDDateUtils.h"

@interface ZHDCommentsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (copy, nonatomic) NSMutableString *str;
@end

@implementation ZHDCommentsViewController{
    NSMutableArray *cellArray;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    [self postData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    cellArray = [NSMutableArray arrayWithArray:@[@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO]];
}

- (void)initUI{
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0.00f green:0.53f blue:0.85f alpha:1.00f];
    self.commentsView = [[ZHDCommmentsView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:self.commentsView];
    
    [self.commentsView.backButton addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    
    self.commentsView.tabelView.delegate = self;
    self.commentsView.tabelView.dataSource = self;
    self.commentsView.tabelView.rowHeight = UITableViewAutomaticDimension;
    self.commentsView.tabelView.estimatedRowHeight = 200;
}

- (void)postData{
    [[ZHDCommentsManager sharedManager] requestLongCommentsContentWithID:self.ID Success:^(ZHDCommentsTotalModel *commentsModel) {
        self.longCommentsModel = commentsModel;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.commentsView.tabelView reloadData];
        });
    }];
    [[ZHDCommentsManager sharedManager] requestShortCommentsContentWithID:self.ID Success:^(ZHDCommentsTotalModel *commentsModel) {
        self.shortCommentsModel = commentsModel;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.commentsView.tabelView reloadData];
        });
    }];
}

- (void)click{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if ([self.commentsModel.long_comments integerValue] > 13) {
            return 13;
        } else{
           return [self.commentsModel.long_comments integerValue];
        }
    } else{
        if ([self.commentsModel.short_comments integerValue] > 20) {
            return 20;
        } else{
            return [self.commentsModel.short_comments integerValue];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if ([self.commentsModel.long_comments isEqualToString:@"0"]) {
            return self.view.frame.size.height - 64-84;
        } else{
            return 36;
        }
    } else{
        return 36;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if ([self.commentsModel.long_comments isEqualToString:@"0"]) {
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64-84)];
            headView.backgroundColor = [UIColor whiteColor];
            UIImageView *sofaImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"沙发"]];
            [headView addSubview:sofaImageView];
            [sofaImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(headView.mas_left).offset(headView.frame.size.width/3);
                make.top.equalTo(headView.mas_top).offset(headView.frame.size.height/2-70);
                make.width.mas_equalTo(headView.frame.size.width/3);
                make.height.mas_equalTo(sofaImageView.mas_width);
            }];
            UILabel *label = [[UILabel alloc] init];
            label.text = @"深度长评虚位以待";
            label.textColor = [UIColor colorWithRed:0.75f green:0.75f blue:0.75f alpha:1.00f];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:14];
            [headView addSubview:label];;
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(sofaImageView.mas_bottom).offset(16);
                make.left.equalTo(headView.mas_left).offset(headView.frame.size.width/3);
                make.width.mas_equalTo(headView.frame.size.width/3);
                make.height.equalTo(@20);
            }];
            return headView;
        } else{
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42)];
            headView.backgroundColor = [UIColor whiteColor];
            UILabel *label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"%@条长评", self.commentsModel.long_comments];
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            [headView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(headView.mas_left).offset(20);
                make.top.mas_equalTo(headView.mas_top).offset(4);
                make.width.equalTo(@100);
                make.height.equalTo(@22);
            }];
            return headView;
        }
    } else{
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42)];
        headView.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"%@条短评", self.commentsModel.short_comments];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor blackColor];
        [headView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(headView.mas_left).offset(20);
            make.top.mas_equalTo(headView.mas_top).offset(4);
            make.width.equalTo(@100);
            make.height.equalTo(@22);
        }];
        return headView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        
        ZHDCommentsTableViewCell  *commentsTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        if (!commentsTableViewCell) {
            commentsTableViewCell = [[ZHDCommentsTableViewCell alloc] init];
        }
        
//        NSMutableString *mutableStr = [[NSMutableString alloc] initWithString:[self.longCommentsModel.comments[indexPath.row] avatar]];
        _str = [self.longCommentsModel.comments[indexPath.row] avatar];
        if ([_str characterAtIndex:4] != 's') {
            [_str insertString:@"s" atIndex:4];
        }
        

        [commentsTableViewCell.headImageView sd_setImageWithURL:[NSURL URLWithString:_str] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
        NSLog(@"-------%@", _str);
        
        commentsTableViewCell.idLabel.text = [self.longCommentsModel.comments[indexPath.row] author];
        commentsTableViewCell.contentLabel.text = [self.longCommentsModel.comments[indexPath.row] content];
        [commentsTableViewCell.likeButton setTitle:[self.longCommentsModel.comments[indexPath.row] likes] forState:UIControlStateNormal];
        [commentsTableViewCell.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        commentsTableViewCell.timeLabel.text = [ZHDDateUtils getDateStringWithTimeStr:[self.longCommentsModel.comments[indexPath.row] time]];
        
        
        if ([self.longCommentsModel.comments[indexPath.row] reply] == nil) {
            commentsTableViewCell.replyLabel.text = nil;
            commentsTableViewCell.foldButton.hidden = YES;
        } else{
            commentsTableViewCell.foldButton.hidden = NO;

            NSString *str = [NSString stringWithFormat:@"//%@：", [[self.longCommentsModel.comments[indexPath.row] reply] author]];
            NSMutableString *replyStr = [[NSMutableString alloc] initWithString:str];
            [replyStr appendString:[[self.longCommentsModel.comments[indexPath.row] reply] content]];
            
            NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:replyStr];
            NSRange range1 = NSMakeRange(0, [str length] - 1);
            NSRange range2 = NSMakeRange([str length] + 1, [[[self.longCommentsModel.comments[indexPath.row] reply] content] length] - 1);
            [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range1];
            [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.53f green:0.53f blue:0.53f alpha:1.00f] range:range2];
            [commentsTableViewCell.replyLabel setAttributedText:noteStr];
            
            
        }
        return commentsTableViewCell;
    } else{
        ZHDCommentsTableViewCell *commentsTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        if ([cellArray[indexPath.row]  isEqual: @YES]) {
            [commentsTableViewCell cellOpen];
            commentsTableViewCell.foldButton.selected = YES;
        }

        if (!commentsTableViewCell) {
            commentsTableViewCell = [[ZHDCommentsTableViewCell alloc] init];
        }
        _str = [self.shortCommentsModel.comments[indexPath.row] avatar];
        
        if ([_str characterAtIndex:4] != 's') {
            [_str insertString:@"s" atIndex:4];
        }
        
        [commentsTableViewCell.headImageView sd_setImageWithURL:[NSURL URLWithString:_str] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
        
        commentsTableViewCell.idLabel.text = [self.shortCommentsModel.comments[indexPath.row] author];
        commentsTableViewCell.contentLabel.text = [self.shortCommentsModel.comments[indexPath.row] content];
        [commentsTableViewCell.likeButton setTitle:[self.shortCommentsModel.comments[indexPath.row] likes] forState:UIControlStateNormal];
        [commentsTableViewCell.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        commentsTableViewCell.timeLabel.text = [ZHDDateUtils getDateStringWithTimeStr:[self.shortCommentsModel.comments[indexPath.row] time]];
        
        if ([self.shortCommentsModel.comments[indexPath.row] reply] == nil) {
            commentsTableViewCell.foldButton.hidden = YES;
            commentsTableViewCell.replyLabel.text = nil;
        } else{
            commentsTableViewCell.foldButton.hidden = NO;
            
            NSString *str = [NSString stringWithFormat:@"//%@：", [[self.shortCommentsModel.comments[indexPath.row] reply] author]];
            NSMutableString *replyStr = [[NSMutableString alloc] initWithString:str];
            [replyStr appendString:[[self.shortCommentsModel.comments[indexPath.row] reply] content]];
            
            NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:replyStr];
            NSRange range1 = NSMakeRange(0, [str length] - 1);
            NSRange range2 = NSMakeRange([str length] + 1, [[[self.shortCommentsModel.comments[indexPath.row] reply] content] length] - 1);
            [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range1];
            [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.53f green:0.53f blue:0.53f alpha:1.00f] range:range2];

            [commentsTableViewCell.replyLabel setAttributedText:noteStr];
            if ([cellArray[indexPath.row]  isEqual: @NO]){
                [commentsTableViewCell cellClose];
                commentsTableViewCell.foldButton.selected = NO;
            }
            [commentsTableViewCell.foldButton addTarget:self action:@selector(reloadCell:) forControlEvents:UIControlEventTouchUpInside];
            
            //计算回复label中隐藏的文字长度
            NSInteger count = [self textHeightFromTextString:replyStr width:328 fontSize:17].height / commentsTableViewCell.replyLabel.font.lineHeight;
            NSLog(@"%f %@ %ld",commentsTableViewCell.replyLabel.frame.size.width,replyStr,(long)count);
            if (count <= 2) {
                commentsTableViewCell.foldButton.hidden = YES;
            } else{
                commentsTableViewCell.foldButton.hidden = NO;
            }
        }
        
        return commentsTableViewCell;
    }
}

- (void)reloadCell:(UIButton *)button{
    NSLog(@"%@",[button superview]);
    ZHDCommentsTableViewCell *cell = (ZHDCommentsTableViewCell *)[[button superview] superview];
    NSIndexPath *indexPath = [_commentsView.tabelView indexPathForCell:cell];
    NSLog(@"%ld, %ld", indexPath.section, indexPath.row);
    if ([cellArray[indexPath.row]  isEqual:@YES]) {
        cellArray[indexPath.row] = @NO;
    } else {
        cellArray[indexPath.row] = @YES;
    }
    [_commentsView.tabelView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(CGSize)textHeightFromTextString:(NSString *)text width:(CGFloat)textWidth fontSize:(CGFloat)size{
    //计算 label需要的宽度和高度
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:size]};
    CGRect rect = [text boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    
    CGSize size1 = [text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:size]}];
    
    return CGSizeMake(size1.width, rect.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
