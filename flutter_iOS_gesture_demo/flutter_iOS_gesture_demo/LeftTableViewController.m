//
//  LeftTableViewController.m
//  flutter_iOS_gesture_demo
//
//  Created by TonyReet on 2019/7/6.
//  Copyright © 2019 TonyReet. All rights reserved.
//

#import "LeftTableViewController.h"

@interface LeftTableViewController ()

@end

@implementation LeftTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *testCellID = @"testCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:testCellID];
 
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:testCellID];
        cell.textLabel.font = [UIFont fontWithName:@"HYYaKuHeiW" size:20.0];
    }
 
    cell.textLabel.text = [NSString stringWithFormat:@"leftVc:第%@个cell",@(indexPath.row)];
    
    return cell;
}



@end
