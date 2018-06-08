//
//  RLKTextField.m
//  NumberTextField
//
//  Created by Realank on 2018/6/6.
//  Copyright © 2018年 Realank. All rights reserved.
//

#import "RLKTextField.h"
#import <objc/runtime.h>
#import <objc/message.h>

//static void switchMethod(Class aClass, SEL originMeth, SEL newMeth)
//{
//    Method origMethod = class_getInstanceMethod(aClass, originMeth);
//    Method newMethod = class_getInstanceMethod(aClass, newMeth);
//
//    method_exchangeImplementations(origMethod, newMethod);
//}

@implementation RLKTextField

//+ (void)load{
//    NSLog(@"load");
//    switchMethod([self class], @selector(sendAction:to:forEvent:), @selector(ucar_sendAction:to:forEvent:));
//}

- (NSString *)seperatorChar{
    if (_seperatorChar.length == 0) {
        return @"";
    }
    return _seperatorChar;
}
- (void)setFormat:(NSArray *)format{
    if (format.count <= 1) {
        return;
    }
    for (NSNumber* length in format) {
        if (![length isKindOfClass:[NSNumber class]] || length.integerValue == 0) {
            return;
        }
    }
    _format = format;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self config];
    }
    
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    [self config];
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

- (void)config{
    [self addTarget:self action:@selector(textDidChangeWithTextField:) forControlEvents:UIControlEventEditingChanged];
    self.keyboardType = UIKeyboardTypeNumberPad;
}

- (NSString*)subStringOf:(NSString*)rawString toIndex:(NSInteger) index{
    if (index <= 0) {
        return @"";
    }
    if (index >= rawString.length) {
        return rawString;
    }
    
    return [rawString substringToIndex:index];
}

- (void)textDidChangeWithTextField:(UITextField*)textField {
    NSLog(@"change to %@",textField.text);
    if (_format) {
        NSString* rawString = [self stringByRemoveSeparateCharInString:textField.text];
        NSInteger startIndex = 0;
        NSMutableArray* subStringsM = [NSMutableArray array];
        for (NSNumber* length in _format) {
            NSInteger end = MIN(startIndex + length.integerValue, rawString.length);
            if (startIndex < rawString.length && end <= rawString.length && startIndex < end) {
                //可以截断
                NSString* subString = [rawString substringWithRange:NSMakeRange(startIndex, end - startIndex)];
                [subStringsM addObject:subString];
            }
            startIndex = end;
        }
        
        NSString* separatedString = [subStringsM componentsJoinedByString:self.seperatorChar];
        if (![separatedString isEqualToString:textField.text]) {
            NSLog(@"分隔符与光标修正");
            
            UITextPosition* beginning = self.beginningOfDocument;
            UITextRange* selectedRange = self.selectedTextRange;
            UITextPosition* selectionStart = selectedRange.start;
            UITextPosition* selectionEnd = selectedRange.end;
            NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
            NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
            NSString* beforePrefix = [self subStringOf:textField.text toIndex:location+length];
            NSString* afterPrefix = [self subStringOf:separatedString toIndex:location+length];
            NSInteger beforeSeparateCount = [beforePrefix componentsSeparatedByString:self.seperatorChar].count;
            NSInteger afterSeparateCount = [afterPrefix componentsSeparatedByString:self.seperatorChar].count;
            location += afterSeparateCount - beforeSeparateCount;
            if (location < 0) {
                location = 0;
            }
            if (location > separatedString.length) {
                location = separatedString.length -1;
            }
            textField.text = separatedString;

            beginning = self.beginningOfDocument;
            UITextPosition* startPosition = [self positionFromPosition:beginning offset:location];
            UITextPosition* endPosition = [self positionFromPosition:beginning offset:location];
            UITextRange* selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
            
            [self setSelectedTextRange:selectionRange];
            
        }
        
    }
}

- (NSInteger)limitLength{
    NSInteger limitCount = 0;
    for (NSNumber* subCount in _format) {
        limitCount += subCount.integerValue;
    }
    return limitCount;
}

- (NSString*)stringByRemoveSeparateCharInString:(NSString*)string{
    NSString* clearSeparatorString = [string stringByReplacingOccurrencesOfString:self.seperatorChar withString:@""];
    clearSeparatorString = [clearSeparatorString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [clearSeparatorString stringByReplacingOccurrencesOfString:@"\\p{Cf}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, clearSeparatorString.length)];
}

- (BOOL)shouldChangeStringInRange:(NSRange)range toString:(NSString *)string{
    NSLog(@"[%@] -> [%@] @ (%ld , %ld)",self.text,string,range.location,range.length);
//    NSString* beforeString =
//    //禁止中途插入
//    if (self.text.length > 0 && range.length > 0 && string.length > 1) {
//        NSLog(@"禁止中途替换");
//        return NO;
//    }
    //越界检测
    if (range.location > self.text.length) {
        NSLog(@"越界检测");
        return NO;
    }
    //越界修正
    if (range.location + range.length > self.text.length) {
        NSLog(@"越界修正");
        range.length = self.text.length - range.location;
    }
    
    //输入内容判断

    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[0-9]*"];
    NSString* clearSeparatorString = [self stringByRemoveSeparateCharInString:string];
    if (![clearSeparatorString isEqualToString:@""] && ![numberPre evaluateWithObject:clearSeparatorString])
    {
        NSLog(@"输入内容不合法");
        return NO;
    }
    //长度判断
    NSString* changedString = [self.text stringByReplacingCharactersInRange:range withString:string];
    changedString = [changedString stringByReplacingOccurrencesOfString:self.seperatorChar withString:@""];
    
    if (changedString.length > [self limitLength]) {
        NSLog(@"长度过长");
        return NO;
    }
    return YES;
}

@end
