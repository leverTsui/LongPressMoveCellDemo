//
//  MUIGrowingTextView.m
//  JiMeiUnv
//
//  Created by weikunliang on 14-9-5.
//  Copyright (c) 2014年 nd. All rights reserved.
//

#import "MUIGrowingTextView.h"
@implementation MUIGrowingTextView
@synthesize internalTextView;
@synthesize maxNumberOfLines;
@synthesize minNumberOfLines;
@synthesize maxHeight;
@synthesize minHeight;

@synthesize placeholder;
@synthesize placeholderColor;
@synthesize contentInset;
@synthesize animationDuration;
@synthesize allowAnimation;
@synthesize attributedText;
@synthesize delegate;
//@synthesize delegate;

#pragma mark - initial and dealloc -
-(id) init{
    if (self = [super init]) {
        [self myInitialize];
    }
    return  self;
}

-(id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self myInitialize];
    }
    return  self;
}


-(void)dealloc{
    internalTextView = nil;
}

-(void)myInitialize{
    
    CGRect myRect = self.frame;
    myRect.origin.y = 0;
    myRect.origin.x = 0;
    
    //IOS7适配 滚动到底部是UItextView不稳定问题 ，IOS7要用IOS7的初始化方法
    BOOL IOS7 = [UIDevice currentDevice].systemVersion.floatValue >= 7.0;
    if (IOS7) {
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        NSTextStorage *textStorage = [[NSTextStorage alloc] init];
        [textStorage addLayoutManager:layoutManager];
        NSTextContainer *textConainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(myRect.size.width,CGFLOAT_MAX)];
        [layoutManager addTextContainer:textConainer];
        
        internalTextView = [[MUITextViewInternal alloc] initWithFrame:myRect textContainer:textConainer];
        self.internalTextView.layoutManager.allowsNonContiguousLayout = NO;
        
    }else{
        internalTextView = [[MUITextViewInternal alloc] initWithFrame:myRect];
    }
    
    internalTextView.delegate = self;
    //internalTextView.scrollEnabled = NO;
    internalTextView.font = [UIFont systemFontOfSize:13];
    internalTextView.contentInset = UIEdgeInsetsMake(0, 0, 10.0, 0.0);
    internalTextView.showsHorizontalScrollIndicator = NO;
    internalTextView.text = @"&";
    internalTextView.contentMode = UIViewContentModeRedraw;
    [self addSubview:internalTextView];
    minHeight = internalTextView.frame.size.height;
    minNumberOfLines = 1;
    
    allowAnimation= YES;
    animationDuration = 0.1f;
    
    internalTextView.text = @"";
    
    self.maxNumberOfLines = 3;
    
    //    [self setPlaceholderColor:[UIColor lightGrayColor]];
    //    [self setPlaceholder:@""];
    self.placeholderColor = [UIColor lightGrayColor];
    self.placeholder = @"";
}


#pragma mark - placeHolder -
- (NSString *)placeholder
{
    return placeholder;
}

- (void)setPlaceholder:(NSString *)placeholdert
{
    placeholder = placeholdert;
    internalTextView.placeholder = placeholder;
}

- (UIColor *)placeholderColor
{
    return placeholderColor;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColort
{
    placeholderColor = placeholderColort;
    internalTextView.placeholderColor = placeholderColor;
}


#pragma mark - height and numberOfLines -
-(NSInteger)minNumberOfLines {
    return minNumberOfLines;
}

-(void)setMinNumberOfLines:(NSInteger)amount {
    if(amount == 0 && minHeight > 0) {
        return;
    }
    
    NSString *saveText = internalTextView.text;
    NSString *newText = @"*";
    
    internalTextView.delegate = nil;
    internalTextView.hidden = YES;
    
    for (int i = 1; i < amount; ++i){
        newText = [newText stringByAppendingString:@"\n*"]; //填充换行和字符串，以便计算高度
    }
    internalTextView.text = newText;
    
    minHeight = [self measureHeight];
    
    internalTextView.text = saveText;
    internalTextView.hidden = NO;
    internalTextView.delegate = self;
    
    [self sizeToFit];
    
    minNumberOfLines = amount;
}

- (NSInteger)maxNumberOfLines {
    return maxNumberOfLines;
}

- (void)setMaxNumberOfLines:(NSInteger)amount{
    if(amount == 0 && maxHeight > 0) {
        return;
    } // the user specified a minHeight themselves.
    
    NSString *saveText = internalTextView.text;
    NSString *newText = @"*";
    
    internalTextView.delegate = nil;
    internalTextView.hidden = YES;
    
    for (int i = 1; i < amount; ++i)
        newText = [newText stringByAppendingString:@"\n*"];
    
    internalTextView.text = newText;
    
    maxHeight = [self measureHeight];
    
    internalTextView.text = saveText;
    internalTextView.hidden = NO;
    internalTextView.delegate = self;
    
    [self sizeToFit];
    
    maxNumberOfLines = amount;
}

-(NSInteger)minHeight{
    return minHeight;
}

-(void)setMinHeight:(NSInteger)heightt {
    minHeight = heightt;
    minNumberOfLines = 0;
}

-(NSInteger)maxHeight {
    return maxHeight;
}

-(void)setMaxHeight:(NSInteger)maxHeightt {
    maxHeight = maxHeightt;
    maxNumberOfLines = 0;
}

-(CGFloat) measureHeight{
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]){
        return ceilf([self.internalTextView sizeThatFits:self.internalTextView.frame.size].height);
    }
    else {
        return self.internalTextView.contentSize.height;
    }
}

- (void)resetScrollPositionForIOS7{
    CGRect r = [internalTextView caretRectForPosition:internalTextView.selectedTextRange.end];
    CGFloat caretY =  MAX(r.origin.y - internalTextView.frame.size.height + r.size.height + 8, 0);
    if (internalTextView.contentOffset.y < caretY && r.origin.y != INFINITY)
        internalTextView.contentOffset = CGPointMake(0, caretY);
}

#pragma mark - contentInset -
-(UIEdgeInsets)contentInset{
    return contentInset;
}

-(void)setContentInset:(UIEdgeInsets)content{
    contentInset = content;
    
    CGRect rect = self.frame;
    rect.origin.y = content.top - content.bottom;
    rect.origin.x = content.left;
    rect.size.width -= content.left + content.right;
    
    internalTextView.frame = rect;
    
    [self setMaxNumberOfLines:maxNumberOfLines];
    [self setMinNumberOfLines:minNumberOfLines];
}

-(CGSize)sizeThatFits:(CGSize)size{
    if (self.text.length == 0) {
        size.height = minHeight;
    }
    return size;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect r = self.bounds;
    r.origin.y = 0;
    r.origin.x = contentInset.left;
    r.size.width -= contentInset.left + contentInset.right;
    
    internalTextView.frame = r;
}

#pragma mark - UITextView Properties -
-(void)setText:(NSString *)newText{
    internalTextView.text = newText;
    
    [self performSelector:@selector(textViewDidChange:) withObject:internalTextView];
}

-(NSString*) text{
    return internalTextView.text;
}

- (void)setAttributedText:(NSMutableAttributedString *)attrText{
    if (internalTextView.attributedText != attrText) {
        attributedText = attrText;
        internalTextView.attributedText = attributedText;
        [self performSelector:@selector(textViewDidChange:) withObject:internalTextView];
    }
}

-(NSMutableAttributedString *) attributedText{
    return attributedText;
}

-(void)setFont:(UIFont *)afont{
    if (internalTextView.font != afont) {
        internalTextView.font = afont;
        [self setMaxNumberOfLines:maxNumberOfLines];
        [self setMinNumberOfLines:minNumberOfLines];
    }
}

-(UIFont *)font{
    return internalTextView.font;
}


-(void)setTextColor:(UIColor *)color{
    if (internalTextView.textColor != color) {
        internalTextView.textColor = color;
    }
}

-(UIColor*)textColor{
    return internalTextView.textColor;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor{
    if (internalTextView.backgroundColor != backgroundColor) {
        [super setBackgroundColor:backgroundColor];
        internalTextView.backgroundColor = backgroundColor;
    }
}

-(UIColor*)backgroundColor{
    return internalTextView.backgroundColor;
}



-(void)setTextAlignment:(NSTextAlignment)aligment{
    if (internalTextView.textAlignment != aligment) {
        internalTextView.textAlignment = aligment;
    }
}

-(NSTextAlignment)textAlignment{
    return internalTextView.textAlignment;
}


-(void)setSelectedRange:(NSRange)range{
    internalTextView.selectedRange = range;
}

-(NSRange)selectedRange{
    return internalTextView.selectedRange;
}


- (void)setIsScrollable:(BOOL)isScrollable{
    if (internalTextView.scrollEnabled != isScrollable) {
        internalTextView.scrollEnabled = isScrollable;
    }
}

- (BOOL)isScrollable{
    return internalTextView.scrollEnabled;
}

-(void)setEditable:(BOOL)beditable{
    if (internalTextView.editable != beditable) {
        internalTextView.editable = beditable;
    }
}

-(BOOL)isEditable{
    return internalTextView.editable;
}

-(void)setReturnKeyType:(UIReturnKeyType)keyType{
    if (internalTextView.returnKeyType != keyType) {
        internalTextView.returnKeyType = keyType;
    }
}

-(UIReturnKeyType)returnKeyType{
    return internalTextView.returnKeyType;
}

- (void)setKeyboardType:(UIKeyboardType)keyType{
    if (internalTextView.keyboardType != keyType) {
        internalTextView.keyboardType = keyType;
    }
}

-(UIKeyboardType)keyboardType{
    return internalTextView.keyboardType;
}

- (void)setEnablesReturnKeyAutomatically:(BOOL)enablesReturnKeyAuto{
    if (internalTextView.enablesReturnKeyAutomatically != enablesReturnKeyAuto) {
        internalTextView.enablesReturnKeyAutomatically = enablesReturnKeyAuto;
    }
}

-(BOOL)enablesReturnKeyAutomatically{
    return internalTextView.enablesReturnKeyAutomatically;
}

-(void)setDataDetectorTypes:(UIDataDetectorTypes)datadetector{
    if (internalTextView.dataDetectorTypes != datadetector) {
        internalTextView.dataDetectorTypes = datadetector;
    }
}

-(UIDataDetectorTypes)dataDetectorTypes{
    return internalTextView.dataDetectorTypes;
}

- (BOOL)hasText{
    return [internalTextView hasText];
}

- (void)scrollRangeToVisible:(NSRange)range{
    [internalTextView scrollRangeToVisible:range];
}

#pragma mark - UITextView delegate -
-(void)textViewDidChange:(UITextView *)textView{
    //IOS7 适配 处理编辑进入最后一行时光标消失的问题es
    [self.internalTextView textChanged];
    [self refreshHeight];
    BOOL IOS7 = [UIDevice currentDevice].systemVersion.floatValue >= 7.0;
    if (IOS7) {
        CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
        CGFloat overflow = line.origin.y + line.size.height - (textView.contentOffset.y  + textView.bounds.size.height  - textView.contentInset.bottom - textView.contentInset.top);
        if (overflow > 0) {
            CGPoint offset = textView.contentOffset;
            offset.y += overflow + 7;
            [UIView animateWithDuration:0.2 animations:^{
                [textView setContentOffset:offset];
            }];
        }
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([delegate respondsToSelector:@selector(growingTextViewShouldBeginEditing:)]) {
        return [delegate growingTextViewShouldBeginEditing:self];
        
    } else {
        return YES;
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if ([delegate respondsToSelector:@selector(growingTextViewShouldEndEditing:)]) {
        return [delegate growingTextViewShouldEndEditing:self];
        
    } else {
        return YES;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([delegate respondsToSelector:@selector(growingTextViewDidBeginEditing:)]) {
        [delegate growingTextViewDidBeginEditing:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([delegate respondsToSelector:@selector(growingTextViewDidEndEditing:)]) {
        [delegate growingTextViewDidEndEditing:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)atext {
    
    //weird 1 pixel bug when clicking backspace when textView is empty
    if(![textView hasText] && [atext isEqualToString:@""]) return NO;
    
    //Added by bretdabaker: sometimes we want to handle this ourselves
    if ([delegate respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)]) {
        
        if ([delegate growingTextView:self shouldChangeTextInRange:range replacementText:atext]) {
            if ([atext isEqualToString:@"\n"]) {
                if ([delegate respondsToSelector:@selector(growingTextViewShouldReturn:)]) {
                    if (![delegate performSelector:@selector(growingTextViewShouldReturn:) withObject:self]) {
                        return YES;
                    } else {
                        
                        return NO;
                    }
                }
            }
        } else {
            return NO;
        };
    }
    
    if ([atext isEqualToString:@"\n"]) {
        if ([delegate respondsToSelector:@selector(growingTextViewShouldReturn:)]) {
            if (![delegate performSelector:@selector(growingTextViewShouldReturn:) withObject:self]) {
                return YES;
            } else {
                
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    CGRect caretRect = [internalTextView caretRectForPosition:internalTextView.selectedTextRange.end];
    [internalTextView scrollRectToVisible:caretRect animated:NO];
    if ([delegate respondsToSelector:@selector(growingTextViewDidChangeSelection:)]) {
        [delegate growingTextViewDidChangeSelection:self];
    }
}

- (void)growDidStop{
    // scroll to caret (needed on iOS7)
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]){
        [self resetScrollPositionForIOS7];
    }
    
    if ([delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
        [delegate growingTextView:self didChangeHeight:self.frame.size.height];
    }
}

- (void)refreshHeight
{
    //size of content, so we can set the frame of self
    NSInteger newSizeH = [self measureHeight];
    if (newSizeH < minHeight || !internalTextView.hasText) {
        newSizeH = minHeight; // 大于最小高度
    }
    else if (maxHeight && newSizeH > maxHeight) {
        newSizeH = maxHeight; // 小于最大高度
    }
    
    if (internalTextView.frame.size.height != newSizeH)
    {
        if (newSizeH >= maxHeight){
            if(!internalTextView.scrollEnabled){
                internalTextView.scrollEnabled = YES;
                [internalTextView flashScrollIndicators];
            }
            
        } else {
            internalTextView.scrollEnabled = NO;
        }
        
        if (newSizeH <= maxHeight){
            if(allowAnimation) {
                
                if ([UIView resolveClassMethod:@selector(animateWithDuration:animations:)]) {
                    
                    [UIView animateWithDuration:animationDuration
                                          delay:0
                                        options:(UIViewAnimationOptionAllowUserInteraction|
                                                 UIViewAnimationOptionBeginFromCurrentState)
                                     animations:^(void) {
                                         [self resizeTextView:newSizeH];
                                     }
                                     completion:^(BOOL finished) {
                                     }];
                } else {
                    [UIView beginAnimations:@"" context:nil];
                    [UIView setAnimationDuration:animationDuration];
                    [UIView setAnimationDelegate:self];
                    [UIView setAnimationDidStopSelector:@selector(growDidStop)];
                    [UIView setAnimationBeginsFromCurrentState:YES];
                    [self resizeTextView:newSizeH];
                    [UIView commitAnimations];
                }
            } else {
                [self resizeTextView:newSizeH];
                if ([delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
                    [delegate growingTextView:self didChangeHeight:newSizeH];
                }
            }
        }
        
        if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]){
            //IOS7 执行以下代码，解决文字截断问题
            self.internalTextView.scrollEnabled = NO;
            self.internalTextView.scrollEnabled = YES;
        }
    }
    
    if ([delegate respondsToSelector:@selector(growingTextViewDidChange:)]) {
        [delegate growingTextViewDidChange:self];
    }
}

-(void)resizeTextView:(NSInteger)newSizeH{
    
    if ([delegate respondsToSelector:@selector(growingTextView:willChangeHeight:)]) {
        [delegate growingTextView:self willChangeHeight:newSizeH];
    }
    CGRect internalTextViewFrame = self.frame;
    internalTextViewFrame.size.height = newSizeH;
    self.frame = internalTextViewFrame;
    
    internalTextViewFrame.origin.y = contentInset.top - contentInset.bottom;
    internalTextViewFrame.origin.x = contentInset.left;
    
    if(!CGRectEqualToRect(internalTextView.frame, internalTextViewFrame)) {
        internalTextView.frame = internalTextViewFrame;
    }
}

- (BOOL)becomeFirstResponder{
    [super becomeFirstResponder];
    return [self.internalTextView becomeFirstResponder];
}

-(BOOL)resignFirstResponder{
    [super resignFirstResponder];
    return [internalTextView resignFirstResponder];
}

-(BOOL)isFirstResponder{
    return [self.internalTextView isFirstResponder];
}
@end



