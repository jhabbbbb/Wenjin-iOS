//
//  TopicBestAnswerViewController.m
//  Wenjin
//
//  Created by 秦昱博 on 15/4/15.
//  Copyright (c) 2015年 TWT Studio. All rights reserved.
//

#import "TopicBestAnswerViewController.h"
#import "MsgDisplay.h"
#import "TopicDataManager.h"
#import "wjStringProcessor.h"
#import "data.h"
#import "UIImageView+AFNetworking.h"
#import "wjAPIs.h"
#import <KVOController/FBKVOController.h>
#import "wjOperationManager.h"
#import "UserViewController.h"
#import "AnswerViewController.h"
#import "QuestionViewController.h"

@interface TopicBestAnswerViewController ()

@end

@implementation TopicBestAnswerViewController {
    NSMutableArray *rowsData;
}

@synthesize topicDescription;
@synthesize topicImage;
@synthesize topicTitle;
@synthesize focusTopic;
@synthesize bestAnswerTableView;
@synthesize topicId;

@synthesize topicFollowed;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    bestAnswerTableView.delegate = self;
    bestAnswerTableView.dataSource = self;
    bestAnswerTableView.tableFooterView = [[UIView alloc]init];
    bestAnswerTableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 130 - 64)];
    bestAnswerTableView.allowsSelection = NO;
    
    topicImage.layer.cornerRadius = topicImage.frame.size.width / 2;
    topicImage.clipsToBounds = YES;
    
    topicTitle.text = @"";
    topicDescription.text = @"";
    [focusTopic setTitle:@"" forState:UIControlStateNormal];
    
    rowsData = [[NSMutableArray alloc]init];
    
    topicFollowed = NO;
    FBKVOController *kvoController = [FBKVOController controllerWithObserver:self];
    self.KVOController = kvoController;
    [self.KVOController observe:self keyPath:@"topicFollowed" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        if (topicFollowed == YES) {
            [focusTopic setTitle:@"取消关注" forState:UIControlStateNormal];
        } else {
            [focusTopic setTitle:@"关注" forState:UIControlStateNormal];
        }
    }];
    
    [TopicDataManager getTopicBestAnswerWithTopicID:topicId success:^(NSUInteger _totalRows, NSArray *_rows) {
        
        if (_totalRows != 0) {
            rowsData = [[NSMutableArray alloc]initWithArray:_rows];
        } else {
            UILabel *noCLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height / 2 - 10, self.view.frame.size.width, 20)];
            noCLabel.text = @"话题下暂无回答";
            noCLabel.font = [UIFont systemFontOfSize:20];
            noCLabel.textColor = [UIColor lightGrayColor];
            noCLabel.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:noCLabel];
        }
        
        [bestAnswerTableView reloadData];
        
    } failure:^(NSString *errStr) {
        [MsgDisplay showErrorMsg:errStr];
    }];
    
    [TopicDataManager getTopicInfoWithTopicID:topicId userID:[data shareInstance].myUID success:^(NSDictionary *topicInfo) {
        self.title = topicInfo[@"topic_title"];
        topicTitle.text = topicInfo[@"topic_title"];
        topicDescription.text = topicInfo[@"topic_description"];
        [topicImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [wjAPIs topicImagePath], topicInfo[@"topic_pic"]]] placeholderImage:[UIImage imageNamed:@"tabBarIcon"]];
        if ([topicInfo[@"has_focus"] isEqual:@0]) {
            [self setValue:@NO forKey:@"topicFollowed"];
        } else if ([topicInfo[@"has_focus"] isEqual:@1]) {
            [self setValue:@YES forKey:@"topicFollowed"];
        }
    } failure:^(NSString *errStr) {
        [MsgDisplay showErrorMsg:errStr];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)followTopic {
    [wjOperationManager followTopicWithTopicID:topicId success:^(NSString *_type) {
        
        if ([_type isEqualToString:@"add"]) {
            [self setValue:@YES forKey:@"topicFollowed"];
        } else if ([_type isEqualToString:@"remove"]) {
            [self setValue:@NO forKey:@"topicFollowed"];
        }
        
    } failure:^(NSString *errStr) {
        [MsgDisplay showErrorMsg:errStr];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [rowsData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    NSString *questionTitle = ((rowsData[row])[@"question_info"])[@"question_content"];
    NSString *detailStr = [wjStringProcessor processAnswerDetailString:((rowsData[row])[@"answer_info"])[@"answer_content"]];
    return 56 + [self heightOfLabelWithTextString:questionTitle andFontSize:17.0] + [self heightOfLabelWithTextString:detailStr andFontSize:15.0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    HomeTableViewCell *cell = (HomeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSUInteger row = [indexPath row];
    NSDictionary *tmp = rowsData[row];
    cell.actionLabel.text = [NSString stringWithFormat:@"%@ 回答了问题", (tmp[@"answer_info"])[@"nick_name"]];
    cell.questionLabel.text = [wjStringProcessor filterHTMLWithString:(tmp[@"question_info"])[@"question_content"]];
    cell.detailLabel.text = [wjStringProcessor processAnswerDetailString:(tmp[@"answer_info"])[@"answer_content"]];
    cell.actionLabel.tag = row;
    cell.questionLabel.tag = row;
    cell.detailLabel.tag = row;
    cell.avatarView.tag = row;
    cell.delegate = self;
    [cell loadAvatarImageWithApartURL:(tmp[@"answer_info"])[@"avatar_file"]];
    return cell;

}

- (CGFloat)heightOfLabelWithTextString:(NSString *)textString andFontSize:(CGFloat)fontSize {
    CGFloat width = bestAnswerTableView.frame.size.width - 32;
    
    UILabel *gettingSizeLabel = [[UILabel alloc]init];
    gettingSizeLabel.text = textString;
    gettingSizeLabel.font = [UIFont systemFontOfSize:fontSize];
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize maxSize = CGSizeMake(width, 1000.0);
    
    CGSize size = [gettingSizeLabel sizeThatFits:maxSize];
    return size.height;
}

// HomeCellDelegate

- (void)pushUserControllerWithRow:(NSUInteger)row {
    UserViewController *uVC = [[UserViewController alloc]initWithNibName:@"UserViewController" bundle:nil];
    uVC.userId = [((rowsData[row])[@"answer_info"])[@"uid"] stringValue];
    [self.navigationController pushViewController:uVC animated:YES];
}

- (void)pushQuestionControllerWithRow:(NSUInteger)row {
    QuestionViewController *qVC = [[QuestionViewController alloc]initWithNibName:@"QuestionViewController" bundle:nil];
    qVC.questionId = ((rowsData[row])[@"question_info"])[@"question_id"];
    [self.navigationController pushViewController:qVC animated:YES];
}

- (void)pushAnswerControllerWithRow:(NSUInteger)row {
    AnswerViewController *aVC = [[AnswerViewController alloc]initWithNibName:@"AnswerViewController" bundle:nil];
    aVC.answerId = ((rowsData[row])[@"answer_info"])[@"answer_id"];
    [self.navigationController pushViewController:aVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
