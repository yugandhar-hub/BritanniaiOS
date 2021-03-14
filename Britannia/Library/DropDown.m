//
//  DropDown.m
//  Wonderslate
//
//  Created by Apple on 20/07/20.
//  Copyright © 2020 Wonderslate. All rights reserved.
//

#import "DropDown.h"
#define FIELD_NAME @"field_name"
#define FIELD_ID @"field_id"

@interface DropDown()
{
    UIScrollView *scrollView;
    
    UILabel *label;
    UITapGestureRecognizer *tapRecognizer;
    
    //Table Creation for DropDown
    UIView *view;
    UIView *dropdownShadow;
    UITableViewController *tableViewController;
    UITableViewCell *reUsableCell;
    NSMutableArray *data;
    NSMutableArray *sectionTitle;
    NSString *key;
    
    NSInteger itemPosition;
    NSIndexPath *itemIndexPath;
    
    BOOL isPositionSet;
}
@property (nonatomic, weak) UIViewController *viewController;
@end


@implementation DropDown

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self initInternals];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initInternals];
    }
    return self;
}

- (void) initInternals{
    self.textColor = [UIColor blackColor];
    self.selectionColor = [UIColor blueColor];
    self.fontSize = 14;
    self.borderColor = [UIColor grayColor];
//    self.backgroundColor = [UIColor whiteColor];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    
    [self handleExit];
    
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            /* start special animation */
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            /* start special animation */
            break;
            
        default:
            break;
    };
}


-(CGSize)intrinsicContentSize{
    return self.frame.size;
}

- (UIViewController*)viewController
{
    if (!_viewController) {
        for (UIView* next = [self superview]; next; next = next.superview)
        {
            UIResponder* nextResponder = [next nextResponder];
            
            if ([nextResponder isKindOfClass:[UIViewController class]])
            {
                _viewController = (UIViewController*)nextResponder;
            }
        }
    }
    
    return _viewController;
}

- (UIScrollView *)getScrollView {
    for (UIView* next = [self superview]; next; next = next.superview)
    {
        if ([next isKindOfClass:[UIScrollView class]]) {
            return (UIScrollView *)next;
        }
    }
    return nil;
}

- (void)drawRect:(CGRect)rect {
    [self.borderColor setStroke];
    [self.backgroundColor setFill];
    
//    self.layer.cornerRadius = 5;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.masksToBounds = YES;
    
    UIBezierPath *boxPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height) cornerRadius:0];
    boxPath.lineWidth = 0;
    [boxPath fill];
    [boxPath stroke];
    
    if (label == nil) {
        if (self.frame.size.width > 40) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 0.0, self.frame.size.width - 28, self.frame.size.height)];
            [self addSubview:label];
//            [self addDropDownSymbol];
            
        } else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 0.0, self.frame.size.width - 16, self.frame.size.height)];
            [self addSubview:label];
        }
    }
    
    label.font = [UIFont systemFontOfSize:self.fontSize];
    label.translatesAutoresizingMaskIntoConstraints = NO;
//    label.text = @"Select";
    label.textColor = _textColor;
    NSLog(@"wedewfwefwefwefwe%@",[self getSelectedName]);
    if ([self getSelectedName] == NULL || [[self getSelectedName] isEqualToString:@""]) {
        label.text = _text;
    } else {
        label.text = [self getSelectedName];
    }
//    label.text = _text;
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:self
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:label
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:-8.f];
    
    NSLayoutConstraint *trailing = [NSLayoutConstraint
                                    constraintWithItem:self
                                    attribute:NSLayoutAttributeTrailing
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:label
                                    attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0f
                                    constant:20.f];
    
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:self
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:label
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0f
                               constant:0.f];
    
    NSLayoutConstraint *bottom = [NSLayoutConstraint
                                  constraintWithItem:self
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:label
                                  attribute:NSLayoutAttributeBottom
                                  multiplier:1.0f
                                  constant:0.f];
    [self addConstraints:@[leading, trailing, top, bottom]];
    
    //Add a tap gesture recogniser to dismiss the suggestions view when the user taps outside the suggestions view
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setCancelsTouchesInView:NO];
    [tapRecognizer setDelegate:self];
    [self setNeedsDisplay];
}

//- (UIColor *) colorFromHexString: (NSString *) hex{
//    NSString *cleanString = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
//    if([cleanString length] == 3) {
//        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
//                        [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
//                        [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
//                        [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
//    }
//    if([cleanString length] == 6) {
//        cleanString = [cleanString stringByAppendingString:@"ff"];
//    }
//
//    unsigned int baseValue;
//    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
//
//    float red = ((baseValue >> 24) & 0xFF)/255.0f;
//    float green = ((baseValue >> 16) & 0xFF)/255.0f;
//    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
//    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
//
//    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
//}

//- (void)addDropDownSymbol {
//    CGFloat imageViewHeight = self.frame.size.height;
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-20, 0, 20, imageViewHeight)];
//
//    UIBezierPath* trianglePath = [UIBezierPath bezierPath];
//    [trianglePath moveToPoint:(CGPoint){2, (imageViewHeight-5)/2}];
//    [trianglePath addLineToPoint:(CGPoint){7, (imageViewHeight+5)/2}];
//    [trianglePath addLineToPoint:(CGPoint){12, (imageViewHeight-5)/2}];
//    [trianglePath closePath];
//
//    CAShapeLayer *triangleMaskLayer = [CAShapeLayer layer];
//    [triangleMaskLayer setPath:trianglePath.CGPath];
//    imageView.layer.mask = triangleMaskLayer;
//    imageView.layer.backgroundColor = [UIColor blackColor].CGColor;
//    [self addSubview:imageView];
//
//    imageView.translatesAutoresizingMaskIntoConstraints = NO;
//    NSLayoutConstraint *width = [NSLayoutConstraint
//                                 constraintWithItem:imageView
//                                 attribute:NSLayoutAttributeWidth
//                                 relatedBy:NSLayoutRelationEqual
//                                 toItem:nil
//                                 attribute:NSLayoutAttributeNotAnAttribute
//                                 multiplier:1.0f
//                                 constant:20.f];
//    [imageView addConstraint:width];
//
//    NSLayoutConstraint *trailing = [NSLayoutConstraint
//                                    constraintWithItem:self
//                                    attribute:NSLayoutAttributeTrailing
//                                    relatedBy:NSLayoutRelationEqual
//                                    toItem:imageView
//                                    attribute:NSLayoutAttributeTrailing
//                                    multiplier:1.0f
//                                    constant:0.f];
//
//    NSLayoutConstraint *top = [NSLayoutConstraint
//                               constraintWithItem:self
//                               attribute:NSLayoutAttributeTop
//                               relatedBy:NSLayoutRelationEqual
//                               toItem:imageView
//                               attribute:NSLayoutAttributeTop
//                               multiplier:1.0f
//                               constant:0.f];
//
//    NSLayoutConstraint *bottom = [NSLayoutConstraint
//                                  constraintWithItem:self
//                                  attribute:NSLayoutAttributeBottom
//                                  relatedBy:NSLayoutRelationEqual
//                                  toItem:imageView
//                                  attribute:NSLayoutAttributeBottom
//                                  multiplier:1.0f
//                                  constant:0.f];
//    [self addConstraints:@[top, trailing, bottom]];
//
//}

- (void)setSelectedName:(NSString *)name{
    label.text = name;
}

- (void)setSelectedItemPosition:(NSInteger)position {
    
        label.text = @"";
        NSInteger numberOfSec = [data count];
        if (numberOfSec == 1) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:position inSection:0];
            NSInteger position = 0;
            for (int i=0; i<indexPath.section; i++) {
                position += [[data objectAtIndex:i] count];
            }
            position += indexPath.row;
            isPositionSet = YES;
            itemIndexPath = indexPath;
            itemPosition = position;
            
            label.text = [[[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:FIELD_NAME];
            NSLog(@"%@",[[[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:FIELD_NAME]);
        } else if (numberOfSec > 1) {
            NSInteger itemsCount = 0;
            for (int i=0; i<numberOfSec; i++) {
                itemsCount += [[data objectAtIndex:i] count];
                if (itemsCount > position) {
                    itemsCount -= [[data objectAtIndex:i] count];
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:position-itemsCount inSection:i];
                    NSInteger position = 0;
                    for (int i=0; i<indexPath.section; i++) {
                        position += [[data objectAtIndex:i] count];
                    }
                    position += indexPath.row;
                    isPositionSet = YES;
                    itemIndexPath = indexPath;
                    itemPosition = position;
                    
                    label.text = [[[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:FIELD_NAME];
                    break;
                }
            }
        }
}

- (void)setSelectedItemIndexPath:(NSIndexPath *)indexPath {
    if (isPositionSet) {
        isPositionSet = NO;
    } else {
        NSInteger position = 0;
        for (int i=0; i<indexPath.section; i++) {
            position += [[data objectAtIndex:i] count];
        }
        position += indexPath.row;
        itemPosition = position;
        
        label.text = [[[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:FIELD_NAME];
    }
}

- (NSString *)getSelectedName {
    return label.text;
}

- (NSString *)getSelectedId {
    if (data.count > itemIndexPath.section && [[data objectAtIndex:itemIndexPath.section] count] > itemIndexPath.row) {
        return [[[data objectAtIndex:itemIndexPath.section] objectAtIndex:itemIndexPath.row] objectForKey:FIELD_ID];
    }
    return nil;
}

- (NSArray *)getIds {
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (int i =0 ; i<data.count; i ++) {
        for (int j=0; j<[[data objectAtIndex:i] count]; j++) {
            [arr addObject:[[[data objectAtIndex:i] objectAtIndex:j] objectForKey:FIELD_ID]];
        }
    }
    return arr;
}

- (void)reloadData{
    data = [[NSMutableArray alloc] init];
    sectionTitle = [[NSMutableArray alloc] init];
    itemPosition = 0;
    itemIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSInteger sectionCount = 1;
    
    scrollView = [self getScrollView];
    
    if ([[self delegate] respondsToSelector:@selector(numberOfSectionsInDropDown:)]) {
        sectionCount = [self.delegate numberOfSectionsInDropDown:self];
    }
    for (int i=0; i<sectionCount; i++) {
        
        NSArray *arr = [[self delegate] dropDown:self dataForSection:i];
        if (arr == nil) {
            [data addObject:[[NSArray alloc] init]];
        } else {
            [data addObject:arr];
        }
        
        NSString *title = @"";
        if ([[self delegate] respondsToSelector:@selector(dropDown:titleForHeaderInSection:)]) {
            title = [[self delegate] dropDown:self titleForHeaderInSection:i];
        }
        if (title == nil) {
            [sectionTitle addObject:@""];
        } else {
            [sectionTitle addObject:title];
        }
    }
    if (data.count == 0) {
        label.text = @"Select";
    } else {
        BOOL valueNeed = YES;
        for (NSArray *arr in data) {
            if (arr.count > 0) {
                label.text = [[arr objectAtIndex:0] objectForKey:FIELD_NAME];
                valueNeed = NO;
                break;
            }
        }
        if (valueNeed) {
//            label.text = @"Select";
        }
    }
    NSLog(@"qgwvgwqvdgqd%@",[self getSelectedName]);
    if ([[self getSelectedName] isEqualToString:@""]) {
        label.text = _text;
    } else {
        label.text = [self getSelectedName];
    }
    if (tableViewController.tableView != nil) {
        [tableViewController.tableView reloadData];
    }
}


#pragma mark UITableView DataSource & Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([[self delegate] respondsToSelector:@selector(numberOfSectionsInDropDown:)]) {
        return [self.delegate numberOfSectionsInDropDown:self];
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (![[sectionTitle objectAtIndex:section] isEqualToString:@""]) {
        return 30.0;
    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (sectionTitle != nil && sectionTitle.count >= section) {
        return [sectionTitle objectAtIndex:section];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (data != nil && data.count >= section) {
        return [[data objectAtIndex:section] count];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CFSearchTextFieldCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:self.fontSize];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    [cell setBackgroundColor:[UIColor whiteColor]];
    if (indexPath.section == itemIndexPath.section && indexPath.row == itemIndexPath.row) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [[cell textLabel] setText:[[[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:FIELD_NAME]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self handleExit];
    
    NSInteger position = 0;
    for (int i=0; i<indexPath.section; i++) {
        position += [[data objectAtIndex:i] count];
    }
    position += indexPath.row;
    
//    if (itemPosition != position || indexPath.section != itemIndexPath.section || indexPath.row != itemIndexPath.row) {
        itemPosition = position;
        itemIndexPath = indexPath;
        
        label.text = [[[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:FIELD_NAME];
        if ([[self delegate] respondsToSelector:@selector(dropDown:didSelectRowAtIndexPath:selectedId:andName:)]) {
            NSLog(@"qweqweqweqwew%@", [[[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:FIELD_NAME]);
            [self.delegate dropDown:self didSelectRowAtIndexPath:indexPath
                         selectedId:[[[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:FIELD_ID]
                            andName:[[[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:FIELD_NAME]];
        }
//    }
}

#pragma mark Popover Method(s)


//TableView Creation for DropDown
- (void)provideSuggestions
{
    if (scrollView) {
        scrollView.scrollEnabled = NO;
    }
    //Providing suggestions
    if (view.superview == nil) {
        if (!view) {
            view = [[UIView alloc] initWithFrame:self.viewController.view.bounds];
//            view.backgroundColor = [UIColor clearColor];
        }
        
        if (view) {
            [view addGestureRecognizer:tapRecognizer];
            [view gestureRecognizers];
        } else {
            [self.superview addGestureRecognizer:tapRecognizer];
            [self.superview gestureRecognizers];
        }
        
        
        tableViewController = [[UITableViewController alloc] init];
        [tableViewController.tableView setDelegate:self];
        [tableViewController.tableView setDataSource:self];
        tableViewController.tableView.alpha = 0.0;
        
        dropdownShadow = [[UIView alloc] init];
        dropdownShadow.layer.shadowColor = [UIColor grayColor].CGColor;
        dropdownShadow.layer.shadowRadius = 5;
        dropdownShadow.layer.shadowOpacity = 1.0;
        dropdownShadow.layer.shadowOffset = CGSizeMake(0, 3);
        dropdownShadow.layer.masksToBounds = NO;
        dropdownShadow.layer.cornerRadius = 5;
//        dropdownShadow.layer.borderColor = [self colorFromHexString:@"ffd601"].CGColor;
        dropdownShadow.layer.borderWidth = 0;
        
        if (self.borderColor == nil) {
            tableViewController.tableView.layer.borderColor = [UIColor blackColor].CGColor;
        } else {
            tableViewController.tableView.layer.borderColor = self.borderColor.CGColor;
        }
        
        if (self.backgroundColor == nil) {
            [tableViewController.tableView setBackgroundColor:[UIColor whiteColor]];
        } else {
            [tableViewController.tableView setBackgroundColor:self.backgroundColor];
        }
        
        [tableViewController.tableView setSeparatorColor:[UIColor whiteColor]];
        [tableViewController.tableView reloadData];
        [self updateTableFrame];
        
        if (self.viewController.view) {
            [view addSubview:dropdownShadow];
            [self.viewController.view addSubview:view];
        } else {
            [[self superview] addSubview:dropdownShadow];
        }
        
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             [tableViewController.tableView setAlpha:1.0];
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        [self updateTableFrame];
        [tableViewController.tableView reloadData];
    }
//    if (itemIndexPath )
    if ([itemIndexPath row] > 0) {
        [tableViewController.tableView scrollToRowAtIndexPath:itemIndexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

- (void)updateTableFrame{
    
    if (self.popoverSize.size.height == 0.0) {
        //PopoverSize frame has not been set. Use default parameters instead.
        CGRect frameForPresentation;
        CGFloat below;
        CGFloat above;
        
        if (self.viewController.view) {
            CGRect frame = [self.viewController.view.window convertRect:self.bounds fromView:self];
            below = self.viewController.view.window.frame.size.height - frame.origin.y - frame.size.height - 20;
            above = frame.origin.y - 20;
            
            frameForPresentation = frame;
        } else {
            CGRect fr = [self.superview.window convertRect:self.superview.frame fromView:self.superview];
            CGRect frame = [self.superview.window convertRect:self.bounds fromView:self];
            above = (frame.origin.y - fr.origin.y);
            below = self.superview.window.frame.size.height - frame.origin.y - frame.size.height - 10;
            
            frameForPresentation = [self frame];
        }
        
        CGFloat tableHeight = 0;
        NSInteger dataCount = 0;
        if (data == nil || [data count] == 0) {
            tableHeight = 0.0;
        } else {
            for (int i=0; i<data.count; i++) {
                dataCount += [[data objectAtIndex:i] count];
                for (int j=0; j<[[data objectAtIndex:i] count]; j++) {
                    int lines = [self getLinesForText:[[[data objectAtIndex:i] objectAtIndex:j]objectForKey:@"field_name"] withFont:[UIFont systemFontOfSize:self.fontSize] andWidth:frameForPresentation.size.width];
                    if (lines == 1) {
                        tableHeight += 44;
                    } else {
                        tableHeight += 24 * lines;
                    }
                }
            }
            
            for (int i=0; i<sectionTitle.count; i++) {
                if (![[sectionTitle objectAtIndex:i] isEqualToString:@""]) {
                    dataCount++;
                    int lines = [self getLinesForText:[sectionTitle objectAtIndex:i] withFont:[UIFont systemFontOfSize:self.fontSize] andWidth:frameForPresentation.size.width];
                    if (lines == 1) {
                        tableHeight += 44;
                    } else {
                        tableHeight += 24 * lines;
                    }
                }
            }
//            tableHeight = dataCount * 44.0;
        }
        
        if (below > above || below > 100 || tableHeight < below) {
            frameForPresentation.origin.y += self.frame.size.height;
            if (tableHeight > below) {
                frameForPresentation.size.height = below;
            } else {
                frameForPresentation.size.height = tableHeight;
            }
        } else {
            if (tableHeight > above) {
                frameForPresentation.origin.y -= above;
                frameForPresentation.size.height = above;
            } else {
                frameForPresentation.origin.y -= tableHeight;
                frameForPresentation.size.height = tableHeight;
            }
        }
        frameForPresentation.origin.y += 10;
        
        [tableViewController.tableView setFrame:CGRectMake(0, 0, frameForPresentation.size.width, frameForPresentation.size.height)];
        [dropdownShadow setFrame:frameForPresentation];
        
        if ([[self delegate] respondsToSelector:@selector(dropDown:didChangeAppearing:)]) {
            [self.delegate dropDown:self didChangeAppearing:YES];
        }
        [dropdownShadow addSubview:tableViewController.tableView];
        
    }
    else{
        [dropdownShadow setFrame:self.popoverSize];
        [tableViewController.tableView setFrame:CGRectMake(0, 0, self.popoverSize.size.width, self.popoverSize.size.height)];
    }
}


-(int) getLinesForText:(NSString*) text withFont:(UIFont*) font andWidth:(float) width{
    CGSize constraint = CGSizeMake(width , 20000.0f);
    CGSize title_size;
    float totalHeight;

    SEL selector = @selector(boundingRectWithSize:options:attributes:context:);
    if ([text respondsToSelector:selector]) {
        title_size = [text boundingRectWithSize:constraint
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{ NSFontAttributeName : font }
                                        context:nil].size;

        totalHeight = ceil(title_size.height);
    } else {
        title_size = [text sizeWithFont:font
                      constrainedToSize:constraint
                          lineBreakMode:NSLineBreakByWordWrapping];
        totalHeight = title_size.height ;
    }
    CGFloat height = MAX(totalHeight, 40.0f);
    long charSize = lroundf(font.lineHeight);
    int lineCount = totalHeight/charSize;
    NSLog(@"dvwdfefefefeefdwdfwdscscas%i",lineCount);
    if (lineCount > 1) {
        return lineCount + 1;
    }
    return lineCount;
}

//This method checks if a selection needs to be made from the suggestions box using the delegate method -textFieldShouldSelect. If a user doesn't tap any search suggestion, the textfield automatically selects the top result. If there is no result available and the delegate method is set to return YES, the textfield will wrap the entered the text in a NSDictionary and send it back to the delegate with 'CustomObject' key set to 'NEW'
- (void)handleExit
{
    if (scrollView) {
        scrollView.scrollEnabled = YES;
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [tableViewController.tableView setAlpha:0.0];
                     }
                     completion:^(BOOL finished){
                         [view removeFromSuperview];
                         view = nil;
                         tableViewController.tableView = nil;
                         
                         if ([[self delegate] respondsToSelector:@selector(dropDown:didChangeAppearing:)]) {
                             [self.delegate dropDown:self didChangeAppearing:NO];
                         }
                     }];
    if ([view superview] != nil) {
        [view removeFromSuperview];
    }
    if ([tableViewController.tableView superview] != nil) {
        [tableViewController.tableView removeFromSuperview];
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (view == nil) {
        if (data.count > 0 && [[data objectAtIndex:0] count] > 0) {
            [self provideSuggestions];
        }
    } else {
        [self handleExit];
    }
}

- (void)tapped:(UIGestureRecognizer *)gesture{
    if ([self.superview isUserInteractionEnabled]) {
        if (self.viewController.view) {
            [self.viewController.view endEditing:YES];
        } else {
            [self.superview endEditing:YES];
        }
        
        CGPoint location = [gesture locationInView:tableViewController.tableView];
        NSIndexPath *path = [tableViewController.tableView indexPathForRowAtPoint:location];
        CGPoint locationView = [gesture locationInView:dropdownShadow];
        
        if((!path || !CGRectContainsPoint(dropdownShadow.bounds, locationView)) && view != nil) {
            [self handleExit];
            if ([[self delegate] respondsToSelector:@selector(dropDownDidSelectOutside:)]) {
                [self.delegate dropDownDidSelectOutside:self];
            }
        }
    }
}

- (NSArray *)dropDownData:(NSArray *)array keyName:(NSString *)keyName keyId:(NSString *)keyId{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in array) {
        NSMutableDictionary *dict2 = [[NSMutableDictionary alloc] init];
        
        NSString *name = @"";
        NSString *fId = @"";
        if ([dict objectForKey:keyName] != nil) {
            name = [dict objectForKey:keyName];
        }
        if ([dict objectForKey:keyId] != nil) {
            fId = [dict objectForKey:keyId];
        }
        
        [dict2 setObject:name forKey:FIELD_NAME];
        [dict2 setObject:fId forKey:FIELD_ID];
        [arr addObject:dict2];
    }
    
    return arr;
}



@end
