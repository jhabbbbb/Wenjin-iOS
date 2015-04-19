//
//  SettingTableViewController.m
//  Wenjin
//
//  Created by 秦昱博 on 15/4/10.
//  Copyright (c) 2015年 TWT Studio. All rights reserved.
//

#import "SettingTableViewController.h"
#import "wjAccountManager.h"
#import "AboutViewController.h"

@interface SettingTableViewController ()

@end

@implementation SettingTableViewController {
    NSArray *cellValues;
    NSArray *headerTitles;
    NSString *autoFocusKey;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    headerTitles = @[@"关于", @"设置", @"帐号"];
    cellValues = @[@[@"关于问津", @"联系我们"], @[@"回答后自动关注"], @[@"注销帐号"]];
    
    autoFocusKey = @"autoFocus";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logout {
    UIAlertController *logoutAlert = [UIAlertController alertControllerWithTitle:@"注销" message:@"确定要注销吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [wjAccountManager logout];
        [self.tabBarController setValue:@YES forKey:@"showNotLoggedInView"];
        [self.navigationController.tabBarController setSelectedIndex:0];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [logoutAlert addAction:cancelAction];
    [logoutAlert addAction:confirmAction];
    [self presentViewController:logoutAlert animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [headerTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return ((NSArray *)(cellValues[section])).count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return headerTitles[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    if (section == 0) {
        if (row == 0) {
            AboutViewController *about = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
            [self.navigationController pushViewController:about animated:YES];
        }
    }
    
    if (section == 2) {
        if (row == 0) {
            [self logout];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifer"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    cell.textLabel.text = ((NSArray *)(cellValues[section]))[row];
    
    if (section == 0) {
        if (row == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (section == 1) {
        if (row == 0) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults objectForKey:autoFocusKey] == nil) {
                [defaults setInteger:1 forKey:autoFocusKey];
            }
            UISwitch *autoFocusSwitch = [[UISwitch alloc]init];
            autoFocusSwitch.on = ([defaults integerForKey:autoFocusKey] == 1) ? YES : NO;
            [autoFocusSwitch addTarget:self action:@selector(autoFocusSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = autoFocusSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    return cell;
}

- (void)autoFocusSwitchChanged:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (sender.on == YES) {
        [defaults setInteger:1 forKey:autoFocusKey];
    } else {
        [defaults setInteger:0 forKey:autoFocusKey];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
