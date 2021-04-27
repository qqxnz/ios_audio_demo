//
//  MZDFileViewController.m
//  iLoving
//
//  Created by 纬洲 冯 on 28/11/2017.
//  Copyright © 2017 MZD. All rights reserved.
//

#import "MZDFileViewController.h"

@interface MZDFileViewController ()
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) UILabel *bg;
@property (nonatomic, strong) NSMutableArray *subDirs;
@property (nonatomic, strong) NSMutableArray *files;
@end

@implementation MZDFileViewController

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        if (path.length > 0) {
            _path = path;
        } else {
            _path = NSHomeDirectory();
        }
        _subDirs = [NSMutableArray array];
        _files = [NSMutableArray array];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.title = [NSURL URLWithString:self.path].lastPathComponent;
    self.bg = [[UILabel alloc] init];
    self.bg.numberOfLines = 0;
    self.bg.textAlignment = NSTextAlignmentCenter;
    self.tableView.backgroundView = self.bg;
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    for (NSString *element in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:nil]) {
        NSString *fullPath = [self.path stringByAppendingPathComponent:element];
        if ([[NSFileManager defaultManager] isReadableFileAtPath:fullPath]) {
            BOOL isDir = NO;
            [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir];
            if (isDir) {
                [self.subDirs addObject:element];
            } else {
                [self.files addObject:element];
            }
        }
    }
    
    [self refreshBg];
}

- (void)refreshBg
{
    self.bg.text = self.subDirs.count+self.files.count > 0 ? @"" : @"空" ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return self.subDirs.count; break;
        case 1: return self.files.count; break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    switch (indexPath.section) {
        case 0:{
            cell.textLabel.text = self.subDirs[indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } break;
        case 1: {
            cell.textLabel.text = self.files[indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } break;
        default: break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            NSString *fullPath = [self.path stringByAppendingPathComponent:self.subDirs[indexPath.row]];
            MZDFileViewController *vc = [[MZDFileViewController alloc] initWithPath:fullPath];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        case 1: {
            NSString *fullPath = [self.path stringByAppendingPathComponent:self.files[indexPath.row]];
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"share by airdrop" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self shareByAirDrop:fullPath];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
            [ac addAction:action];
            [ac addAction:cancel];
            [self presentViewController:ac animated:YES completion:nil];
        } break;
            
        default:
            break;
    }
}

- (void)shareByAirDrop:(NSString *)path
{
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
