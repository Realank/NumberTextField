//
//  ViewController.m
//  NumberTextField
//
//  Created by Realank on 2018/6/6.
//  Copyright © 2018年 Realank. All rights reserved.
//

#import "ViewController.h"
#import "RLKTextField.h"
@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet RLKTextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _textField.delegate = self;
    _textField.format = @[@3,@4,@4,@5];
    _textField.seperatorChar = @"-";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    if ([textField isKindOfClass:[RLKTextField class]]) {
        return [(RLKTextField*)textField shouldChangeStringInRange:range toString:string];
    }
    return YES;
}




@end
