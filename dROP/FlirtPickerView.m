//
//  FlirtPickerView.m
//  JVFloatLabeledTextField
//
//  Created by Moses Esan on 15/05/2015.
//  Copyright (c) 2015 Jared Verdi. All rights reserved.
//

#import "FlirtPickerView.h"

@implementation FlirtPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        //self.title = NSLocalizedString(@"Floating Label Demo", @"");
        
        self.clipsToBounds = YES;
        
        _textFieldImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, (CGRectGetHeight(self.frame) / 2) - 10, 20.0f, 20.0f)];
        _textFieldImage.backgroundColor = [UIColor clearColor];
        [self addSubview:_textFieldImage];
        
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(32.0f, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.font = [UIFont fontWithName:@"AvenirNext-Medium" size:18.0f];
        _textField.textColor = [UIColor darkGrayColor];
        [self addSubview:_textField];
        
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(15.0f, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];

        _pickerView.showsSelectionIndicator = YES;
        
        /*
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Done" style:UIBarButtonItemStyleDone
                                       target:self action:@selector(done:)];
        
        UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:
                              CGRectMake(0, self.frame.size.height-
                                         myDatePicker.frame.size.height-50, 320, 50)];
        [toolBar setBarStyle:UIBarStyleBlackOpaque];
        NSArray *toolbarItems = [NSArray arrayWithObjects: 
                                 doneButton, nil];
        [toolBar setItems:toolbarItems];
        */
        
        _textField.inputView = _pickerView;
        //myTextField.inputAccessoryView = toolBar;
    }
    
    return self;
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    _textField.text = _placeHolder;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
