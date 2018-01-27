//
//  MUPInnerTextView.m
//  JiMeiUnv
//
//  Created by weikunliang on 14-9-5.
//  Copyright (c) 2014年 nd. All rights reserved.
//

#import "MUITextViewInternal.h"


@interface MUITextViewInternal() {
    
    UILabel *placeHolderLabel;
}
@end

@implementation MUITextViewInternal
@synthesize  placeholder;
@synthesize  placeholderColor;

- (id) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.placeholder = @"";
        self.placeholderColor = [UIColor lightGrayColor];
    }
    
    return  self;
}

-(void)dealloc{
    placeholderColor = nil;
    placeHolderLabel = nil;
    placeholder = nil;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setPlaceholder:@""];
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    
}

-(void)textChanged{
    if ([self.placeholder length] == 0) {
        return;
    }
    
    if ([self.text length] == 0) {
        [[self viewWithTag:999] setAlpha:1];
    }else{
        [[self viewWithTag:999] setAlpha:0];
    }
}

-(void)setText:(NSString *)text{
    [super setText:text];
    [self textChanged];
}

-(void)setContentOffset:(CGPoint)s{
	if(self.tracking || self.decelerating){
        
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
        
	} else {
        
		float bottomOffset = (self.contentSize.height - self.frame.size.height + self.contentInset.bottom);
		if(s.y < bottomOffset && self.scrollEnabled){
            UIEdgeInsets insets = self.contentInset;
            insets.bottom = 8;
            insets.top = 0;
            self.contentInset = insets;
        }
	}
    
    if (s.y > self.contentSize.height - self.frame.size.height && !self.decelerating && !self.tracking && !self.dragging)
        s = CGPointMake(s.x, self.contentSize.height - self.frame.size.height);
    
	[super setContentOffset:s];
}

-(void)setContentInset:(UIEdgeInsets)s{
	UIEdgeInsets insets = s;
	
	if(s.bottom>8) insets.bottom = 0;
	insets.top = 0;
    
	[super setContentInset:insets];
}

-(void)setContentSize:(CGSize)contentSize{
    if(self.contentSize.height > contentSize.height){
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
    }
    
    [super setContentSize:contentSize];
}

- (void)drawRect:(CGRect)rect{
    if (self.placeholder.length > 0) {
        if (placeHolderLabel == nil) {
            placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 8.0, self.bounds.size.width - 16.0, 0)];
            placeHolderLabel.numberOfLines = 0;
            placeHolderLabel.font = self.font;
            placeHolderLabel.backgroundColor = [UIColor clearColor];
            placeHolderLabel.textColor = self.placeholderColor;
            placeHolderLabel.alpha = 0;
            placeHolderLabel.tag = 999;
            [self addSubview:placeHolderLabel];
        }
        
        placeHolderLabel.text = self.placeholder;
        [placeHolderLabel sizeToFit];
        [self sendSubviewToBack:placeHolderLabel];
    }
    
    if (self.text.length == 0  && self.placeholder.length > 0) {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}


-(void) scrollToEditingRange{
    
    [self scrollRangeToVisible:self.selectedRange];
}


@end

