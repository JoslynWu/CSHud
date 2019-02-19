//
//  ViewController.m
//  Example
//
//  Created by Joslyn on 2018/10/19.
//  Copyright © 2018 Joslyn. All rights reserved.
//

#import "ViewController.h"
#import "HUD.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *data;
@property (nonatomic, strong) NSMutableArray<NSString *> *icons;
@property (weak, nonatomic) IBOutlet UITableView *tbView;

@end

static NSString * const cellId = @"cellId";

@implementation ViewController

- (NSArray<NSDictionary<NSString *,NSString *> *> *)data {
    if (_data) {
        return _data;
    }
    return @[
             @{@"showMessageInView:message:": @"文本"},
             @{@"showSuccessAnimation": @"成功(动画) >>"},
             @{@"showFailedAnimation": @"失败(动画) >>"},
             
             @{@"showLoadingInView:": @"菊花"},
             @{@"showLoadingInView:message:": @"菊花 + 文本"},
             @{@"showLoadingUpDateInView:": @"菊花 + 上次更新时间"},
             @{@"showBlurInView:message:": @"菊花 + 文本 + 蒙版"},
             @{@"showRoundLoadingInView:message:": @"环形加载动画"},
             @{@"showCustomAnimateInView:message:imageArray:duration:": @"自定义加载动画"}
             ];
}

- (NSMutableArray<NSString *> *)icons {
    if (_icons) {
        return _icons;
    }
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:8];
    for (NSInteger i = 0; i < 8; i++) {
        [temp addObject:[NSString stringWithFormat: @"icon%zd", i]];
    }
    return temp;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tbView registerClass:UITableViewCell.class forCellReuseIdentifier:cellId];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.textLabel.text = self.data[indexPath.row].allValues.firstObject;
    NSDictionary *data_cell = self.data[indexPath.row];
    NSString *key = data_cell.allKeys.firstObject;
    if ([key isEqualToString:@"showFailedAnimation"]
        || [key isEqualToString:@"showSuccessAnimation"]) {
        cell.textLabel.textColor = UIColor.blueColor;
    } else if ([key isEqualToString:@"hideWithView:"]) {
        cell.textLabel.textColor = UIColor.redColor;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSDictionary *data_cell = self.data[indexPath.row];
    NSString *key = data_cell.allKeys.firstObject;
    NSString *value = data_cell[key];
    SEL sel = NSSelectorFromString(key);
    void (*imp) (id, SEL, ...) = (void *)[HUD methodForSelector:sel];
    NSArray<NSString *> *selParts = [key componentsSeparatedByString:@":"];
    if ([HUD respondsToSelector:sel]) {
        if (selParts.count > 3) {
            imp(HUD.class, sel, self.view, value, self.icons);
        } else if (selParts.count > 2) {
            imp(HUD.class, sel, self.view, value);
        } else if (selParts.count > 1) {
            imp(HUD.class, sel, self.view);
        }
    } else {
        if ([selParts.firstObject containsString:@"showFailedAnimation"]) {
            [self showFailedHud:selParts];
            return;
        } else if ([selParts.firstObject containsString:@"showSuccessAnimation"]) {
            [self showSuccessHud:selParts];
            return;
        } else {
            [HUD showFailedInView:self.view message:@"无对应Action"];
        }
    }
    
    if ([value containsString:@"成功"] || [value containsString:@"失败"] || [value isEqualToString:@"文本"]) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD hideWithView:self.view];
    });
}

- (void)showSuccessHud:(NSArray<NSString *> *)arr {
    NSArray<NSString *> *flags = [arr.firstObject componentsSeparatedByString:@"+"];
    if (flags.count > 1) {
        if ([flags.lastObject isEqualToString:@"default"]) {
            SEL sel = NSSelectorFromString(@"showSuccessInView:message:");
            if (![HUD respondsToSelector:sel]) {
                return;
            }
            void (*imp) (id, SEL, ...) = (void *)[HUD methodForSelector:sel];
            imp(HUD.class, sel, self.view, @"成功");
            return;
        }
        NSInteger type = flags.lastObject.integerValue;
        SEL sel = NSSelectorFromString(@"showSuccessInView:message:animation:");
        if (![HUD respondsToSelector:sel]) {
            return;
        }
        void (*imp) (id, SEL, ...) = (void *)[HUD methodForSelector:sel];
        imp(HUD.class, sel, self.view, @"成功", type);
        return;
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *vc = (ViewController *)[sb instantiateViewControllerWithIdentifier:@"ViewController"];
    vc.navigationItem.title = @"Success";
    vc.data = @[@{@"showSuccessAnimation+default": @"默认"},
                @{@"showSuccessAnimation+0": @"无外环 + 无动画"},
                @{@"showSuccessAnimation+1": @"无外环 + 自左向右动画"},
                @{@"showSuccessAnimation+2": @"无外环 + 自左向右动画 + 内部"},
                
                @{@"showSuccessAnimation+3": @"带外环 + 无动画"},
                @{@"showSuccessAnimation+4": @"带外环 + 自左向右动画"},
                @{@"showSuccessAnimation+5": @"带外环 + 自左向右动画 + 内部"},
                @{@"showSuccessAnimation+6": @"带外环 + 超出外环动画"},
                @{@"showSuccessAnimation+7": @"带外环 + 超出外环动画 + 内部"}];
    [self.navigationController pushViewController:vc animated:true];
}

- (void)showFailedHud:(NSArray<NSString *> *)arr {
    NSArray<NSString *> *flags = [arr.firstObject componentsSeparatedByString:@"+"];
    if (flags.count > 1) {
        if ([flags.lastObject isEqualToString:@"default"]) {
            SEL sel = NSSelectorFromString(@"showFailedInView:message:");
            if (![HUD respondsToSelector:sel]) {
                return;
            }
            void (*imp) (id, SEL, ...) = (void *)[HUD methodForSelector:sel];
            imp(HUD.class, sel, self.view, @"失败");
            return;
        }
        NSInteger type = flags.lastObject.integerValue;
        SEL sel = NSSelectorFromString(@"showFailedInView:message:animation:");
        if (![HUD respondsToSelector:sel]) {
            return;
        }
        void (*imp) (id, SEL, ...) = (void *)[HUD methodForSelector:sel];
        imp(HUD.class, sel, self.view, @"失败", type);
        return;
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *vc = (ViewController *)[sb instantiateViewControllerWithIdentifier:@"ViewController"];
    vc.navigationItem.title = @"Failed";
    vc.data = @[@{@"showFailedAnimation+default": @"默认"},
                @{@"showFailedAnimation+0": @"无外环 + 无动画"},
                @{@"showFailedAnimation+1": @"无外环 + 一起出现"},
                @{@"showFailedAnimation+2": @"无外环 + 先后依次出现"},
                
                @{@"showFailedAnimation+3": @"带外环 + 无动画"},
                @{@"showFailedAnimation+4": @"带外环 + 一起出现"},
                @{@"showFailedAnimation+5": @"带外环 + 先后依次出现"}];
    [self.navigationController pushViewController:vc animated:true];
}

@end


