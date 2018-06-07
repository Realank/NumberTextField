//
//  RLKTextField.h
//  NumberTextField
//
//  Created by Realank on 2018/6/6.
//  Copyright © 2018年 Realank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLKTextField : UITextField

@property (nonatomic, copy) NSString* seperatorChar;
@property (nonatomic, strong) NSArray* format;

- (BOOL)shouldChangeStringInRange:(NSRange)range toString:(NSString *)string;

@end
