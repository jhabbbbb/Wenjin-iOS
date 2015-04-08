//
//  PostAnswerCommentViewController.m
//  Wenjin
//
//  Created by 秦昱博 on 15/4/8.
//  Copyright (c) 2015年 TWT Studio. All rights reserved.
//

#import "PostAnswerCommentViewController.h"
#import "ALActionBlocks.h"
#import "PostDataManager.h"
#import "MsgDisplay.h"
#import "AnswerCommentTableViewController.h"

@interface PostAnswerCommentViewController ()

@end

@implementation PostAnswerCommentViewController

@synthesize commentTextView;
@synthesize answerId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"写评论";
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    commentTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    commentTextView.font = [UIFont systemFontOfSize:17.0];
    [self.view addSubview:commentTextView];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel block:^(id weakSender) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    [self.navigationItem setLeftBarButtonItem:cancelBtn];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone block:^(id weakSender) {
        
        [PostDataManager postAnswerCommentWithAnswerID:answerId andMessage:commentTextView.text success:^{
            [MsgDisplay showSuccessMsg:@"评论添加成功！"];
            // what the fuck
            // 如何让 commentTable 刷新？
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } failure:^(NSString *errStr) {
            [MsgDisplay showErrorMsg:errStr];
        }];
        
    }];
    [self.navigationItem setRightBarButtonItem:doneBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [commentTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification *)notification {
    // float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [commentTextView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - keyboardHeight)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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