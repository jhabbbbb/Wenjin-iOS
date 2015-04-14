//
//  QuestionHeaderView.m
//  Wenjin
//
//  Created by 秦昱博 on 15/4/1.
//  Copyright (c) 2015年 TWT Studio. All rights reserved.
//

#import "QuestionHeaderView.h"
#import "wjStringProcessor.h"
#import "ALActionBlocks.h"
#import "wjOperationManager.h"
#import "MsgDisplay.h"
#import "TLTagsControl.h"
#import "wjAPIs.h"

@implementation QuestionHeaderView {
    int _borderDist;
    
    UILabel *questionTitle;
    UITextView *detailView;
}

@synthesize delegate;

- (id)init {
    if (self = [super init]) {
        // self = [[[NSBundle mainBundle] loadNibNamed:@"QuestionHeaderView" owner:self options:nil] objectAtIndex:0];
    }
    return self;
}

- (id)initWithQuestionInfo:(NSDictionary *)questionInfo andTopics:(NSArray *)topics {
    if (self = [self init]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        //_borderDist = 14 ;
        CGFloat width = [UIApplication sharedApplication].keyWindow.frame.size.width;
        
        NSMutableArray *topicsArr = [[NSMutableArray alloc]init];
        for (NSDictionary *tmp in topics) {
            [topicsArr addObject:(NSString *)tmp[@"topic_title"]];
        }
        
        TLTagsControl *topicsControl = [[TLTagsControl alloc]initWithFrame:CGRectMake(16, 8, width - 32, 22)];
        // TLTagsControl *topicsControl = [[TLTagsControl alloc]init];
        topicsControl.mode = TLTagsControlModeList;
        topicsControl.tags = topicsArr;
        topicsControl.tagsBackgroundColor = [UIColor colorWithRed:75.0/255.0 green:186.0/255.0 blue:251.0/255.0 alpha:1];
        topicsControl.tagsTextColor = [UIColor whiteColor];
        topicsControl.tagsDeleteButtonColor = [UIColor whiteColor];
        [topicsControl reloadTagSubviews];
        topicsControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:topicsControl];
        
        questionTitle = [[UILabel alloc]init];
        questionTitle.numberOfLines = 0;
        questionTitle.lineBreakMode = NSLineBreakByWordWrapping;
        questionTitle.text = [wjStringProcessor filterHTMLWithString:questionInfo[@"question_content"]];
        questionTitle.font = [UIFont systemFontOfSize:20];
        questionTitle.translatesAutoresizingMaskIntoConstraints = NO;
        //CGSize maxSize = CGSizeMake(width - _borderDist * 2, 1000);
        //CGSize questionFitSize = [questionTitle sizeThatFits:maxSize];
        //questionTitle.frame = CGRectMake(_borderDist + 4, 42, width - 2 * _borderDist, questionFitSize.height + 20);
        [self addSubview:questionTitle];
        
        /*
        UIWebView *detailTextView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 42 + questionTitle.frame.size.height, self.frame.size.width, 200)];
        [detailTextView loadHTMLString:[wjStringProcessor convertToBootstrapHTMLWithContent:questionInfo[@"question_detail"]] baseURL:[NSURL URLWithString:[wjAPIs baseURL]]];
         */
        
        detailView = [[UITextView alloc]init];
        detailView.editable = NO;
        detailView.scrollEnabled = NO;
        detailView.font = [UIFont systemFontOfSize:14];
        detailView.text = [wjStringProcessor filterHTMLWithString:questionInfo[@"question_detail"]];
        detailView.translatesAutoresizingMaskIntoConstraints = NO;
        //CGSize detailFitSize = [detailView sizeThatFits:maxSize];
        //detailView.frame = CGRectMake(_borderDist, 42 + questionTitle.frame.size.height, width - 2 * _borderDist, ([detailView.text isEqualToString: @""]) ? 14 : detailFitSize.height + 20);
        [self addSubview:detailView];
        
        UIButton *focusQuestion = [UIButton buttonWithType:UIButtonTypeSystem];
        [focusQuestion setTitle:(([questionInfo[@"has_focus"] isEqual:@1]) ? @"取消关注" : @"关注问题") forState:UIControlStateNormal];
        //focusQuestion.frame = CGRectMake(0, 42 + questionTitle.frame.size.height + detailView.frame.size.height, 0.5 * width, 30);
        [focusQuestion handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakSender) {
            NSLog(@"Focus Action");
            
            [wjOperationManager followQuestionWithQuestionID:questionInfo[@"question_id"] success:^(NSString *operationType) {
                
                if ([operationType isEqualToString:@"remove"]) {
                    [focusQuestion setTitle:@"关注问题" forState:UIControlStateNormal];
                } else if ([operationType isEqualToString:@"add"]) {
                    [focusQuestion setTitle:@"取消关注" forState:UIControlStateNormal];
                }
                
            } failure:^(NSString *errStr) {
                [MsgDisplay showErrorMsg:errStr];
            }];
            
        }];
        focusQuestion.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:focusQuestion];
        
        UIButton *addAnswer = [UIButton buttonWithType:UIButtonTypeSystem];
        [addAnswer setTitle:@"添加回答" forState:UIControlStateNormal];
        //addAnswer.frame = CGRectMake(0.5 * width, 42 + questionTitle.frame.size.height + detailView.frame.size.height, 0.5 * width, 30);
        [addAnswer handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakSender) {
            NSLog(@"Add answer action");
            // 添加回答
            [delegate presentPostAnswerController];
        }];
        addAnswer.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:addAnswer];
        
        //self.frame = CGRectMake(0, 0, width, 42 + questionTitle.frame.size.height + detailView.frame.size.height + 42);
        
        self.frame = CGRectMake(0, 0, width, 0);
        
        NSDictionary *views = NSDictionaryOfVariableBindings(topicsControl, questionTitle, detailView, focusQuestion, addAnswer);
        NSDictionary *metrics = @{@"borderDist": @16,
                                  @"rowDist": @14};
        NSString *vfl1 = @"|-borderDist-[topicsControl]-borderDist-|";
        NSString *vfl2 = @"|-borderDist-[questionTitle]-borderDist-|";
        NSString *vfl3 = @"|-borderDist-[detailView]-borderDist-|";
        NSString *vfl4 = @"|-0-[focusQuestion]-0-[addAnswer(focusQuestion)]-0-|";
        NSString *vfl5 = ([questionInfo[@"question_detail"] isEqualToString:@""]) ? @"V:|-8-[topicsControl(22)]-rowDist-[questionTitle]-rowDist-[detailView(0)]-50-|" : @"V:|-8-[topicsControl(22)]-rowDist-[questionTitle]-rowDist-[detailView]-50-|";
        NSString *vfl6 = @"V:[focusQuestion(30)]-12-|";
        NSString *vfl7 = @"V:[addAnswer(30)]-12-|";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl3 options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl4 options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl5 options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl6 options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl7 options:0 metrics:metrics views:views]];
        
        
        CGFloat headerHeight = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        CGRect headerFrame = self.frame;
        headerFrame.size.height = headerHeight;
        
        self.frame = headerFrame;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];

    
}


@end
