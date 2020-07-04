//
//  ViewController.m
//  listapp
//
//  Created by Daniel on 7/4/20.
//  Copyright © 2020 dk. All rights reserved.
//

#import "ViewController.h"

@interface DKShow: NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

@end

@implementation DKShow

- (instancetype)init;
{
    self = [super init];
    if (!self)
        return nil;

    return self;
}

@end

@interface ViewController () <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"UITableView - iOS 2 - Objective-C";

    // Setup table view
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;

    // Display table view
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];

    // Load data
    NSString *urlString = @"https://api.tvmaze.com/shows";
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *parseError;
        NSArray *parsed = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

        if (parsed != nil) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [parsed enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DKShow *show = [[DKShow alloc] init];

                NSString *name = obj[@"name"];
                show.title = name;

                NSString *status = obj[@"status"];
                NSString *premiered = obj[@"premiered"];
                NSString *summary = obj[@"summary"];
                summary = [summary stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
                summary = [summary stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n"];
                summary = [summary stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
                summary = [summary stringByReplacingOccurrencesOfString:@"</b>" withString:@""];

                show.subtitle = [NSString stringWithFormat:@"%@\n%@%@", premiered, status, summary];

                [list addObject:show];
            }];
            self.dataSource = list;

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    [task resume];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"id"];

    DKShow *show = self.dataSource[indexPath.row];
    cell.textLabel.text = show.title;
    cell.detailTextLabel.text = show.subtitle;
    cell.detailTextLabel.numberOfLines = 4;
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

@end
