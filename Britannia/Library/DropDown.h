//
//  Header.h
//  Wonderpublish
//
//  Created by Apple on 20/07/20.
//  Copyright © 2020 Wonderslate. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DropDownDelegate;

IB_DESIGNABLE @interface DropDown : UIControl<UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, UIGestureRecognizerDelegate>

@property IBInspectable UIColor *textColor;
@property IBInspectable NSString *text;
@property IBInspectable UIColor *selectionColor;
@property IBInspectable UIColor *borderColor;
@property IBInspectable NSUInteger fontSize;


@property (nonatomic, weak) id <DropDownDelegate> delegate;
- (void)reloadData;
- (void)setSelectedName:(NSString *)name;
- (void)setSelectedItemPosition:(NSInteger)position;
- (void)setSelectedItemIndexPath:(NSIndexPath *)indexPath;
- (NSString *)getSelectedName;
- (NSString *)getSelectedId;
- (NSArray *)getIds;
- (NSArray *)dropDownData:(NSArray *)array keyName:(NSString *)keyName keyId:(NSString *)keyId;
- (void)provideSuggestions;

//Set this to override the default frame of the suggestions popover that will contain the suggestions pertaining to the search query. The default frame will be of the same width as textfield, of height 200px and be just below the textfield.
@property (nonatomic) CGRect popoverSize;

//Set this to override the default seperator color for tableView in search results. The default color is light gray.
@property (nonatomic) UIColor *seperatorColor;

@property (nonatomic, strong) NSString* type;
@end


@protocol DropDownDelegate <NSObject>
@required
-(NSArray *)dropDown:(DropDown *)dropDown dataForSection:(NSInteger)section;

@optional
-(NSInteger)numberOfSectionsInDropDown:(DropDown *)dropDown;
-(NSString *)dropDown:(DropDown *)dropDown titleForHeaderInSection:(NSInteger)section;
-(void)dropDown:(DropDown *)dropDown didSelectRowAtIndexPath:(NSIndexPath *)indexPath selectedId:(NSString *)selectedId andName:(NSString *)name;
-(void)dropDownDidSelectOutside:(DropDown *)dropDown;
-(void)dropDown:(DropDown *)dropDown didChangeAppearing:(BOOL)appearing;
@end
