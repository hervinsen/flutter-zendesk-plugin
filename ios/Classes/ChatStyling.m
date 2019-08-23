#import "ChatStyling.h"

@implementation ChatStyling

+ (void) applyStyling
{
    UIEdgeInsets insets;

    [[ZDCChat instance].overlay setEnabled:YES];
    [[ZDCChatOverlay appearance] setAlignment:@(ZDCOverlayAlignmentBottomLeft)];
    [[ZDCChatOverlay appearance] setMessageCountColor:[UIColor greenColor]];
    [[ZDCChatOverlay appearance] setTypingIndicatorColor:[UIColor colorWithRed:0.2431f green:0.8588f blue:0.7098f alpha:1]];
    [[ZDCChatOverlay appearance] setTypingIndicatorHighlightColor:[UIColor redColor]];
    [[ZDCChatOverlay appearance] setTypingIndicatorDiameter:@(4.0f)];
    [[ZDCChatOverlay appearance] setMessageCountFont:[UIFont systemFontOfSize:15.0f]];
    [[ZDCChatOverlay appearance] setInsets:[NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(75.0f, 15.0f, 15.0f, 15.0f)]];
    

    insets = UIEdgeInsetsMake(20.0f, 30.0f, 0.0f, 30.0f);
    [[ZDCFormCellDepartment appearance] setTextFrameInsets:[NSValue valueWithUIEdgeInsets:insets]];
    insets = UIEdgeInsetsMake(15.0f, 30.0f, 15.0f, 30.0f);
    [[ZDCFormCellDepartment appearance] setTextInsets: [NSValue valueWithUIEdgeInsets:insets]];
    [[ZDCFormCellDepartment appearance] setTextFrameBorderColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    [[ZDCFormCellDepartment appearance] setTextFrameBackgroundColor:[UIColor whiteColor]];
    [[ZDCFormCellDepartment appearance] setTextFont:[UIFont systemFontOfSize:13.0f]];
    [[ZDCFormCellDepartment appearance] setTextFrameCornerRadius:@(3.0f)];
    [[ZDCFormCellDepartment appearance] setTextColor:[UIColor colorWithWhite:0.6f alpha:1.0f]];

    insets = UIEdgeInsetsMake(20.0f, 30.0f, 20.0f, 30.0f);
    [[ZDCFormCellMessage appearance] setTextFrameInsets:[NSValue valueWithUIEdgeInsets:insets]];
    insets = UIEdgeInsetsMake(15.0f, 30.0f, 15.0f, 30.0f);
    [[ZDCFormCellMessage appearance] setTextInsets: [NSValue valueWithUIEdgeInsets:insets]];
    [[ZDCFormCellMessage appearance] setTextFrameBorderColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    [[ZDCFormCellMessage appearance] setTextFrameBackgroundColor:[UIColor whiteColor]];
    [[ZDCFormCellMessage appearance] setTextFont:[UIFont systemFontOfSize:13.0f]];
    [[ZDCFormCellMessage appearance] setTextFrameCornerRadius:@(3.0f)];
    [[ZDCFormCellMessage appearance] setTextColor:[UIColor colorWithWhite:0.6f alpha:1.0f]];

    [[ZDCVisitorChatCell appearance] setBubbleCornerRadius:@(10.0f)];
    [[ZDCAgentChatCell appearance] setAvatarHeight:@(35.0f)];
    [[ZDCAgentChatCell appearance] setAvatarLeftInset:@(14.0f)];

    [[ZDCChatUI appearance] setChatBackgroundImage:@"ChangeLogo"];
    [[ZDCChatUI appearance] setBackChatButtonImage:@"ChangeLogo"];
    
    [[ZDCOfflineMessageView appearance] setTintColor:[UIColor colorWithRed:0.2431f green:0.8588f blue:0.7098f alpha:1]];
    [[ZDCLoadingErrorView appearance] setButtonBackgroundColor:[UIColor colorWithRed:0.2431f green:0.8588f blue:0.7098f alpha:1]];
    [[ZDCLoadingErrorView appearance] setIconImage:@"ChangeLogo"];
    [[ZDCLoadingErrorView appearance] setButtonImage:@"ChangeLogo"];



}

+ (UIColor*) navBarTintColor
{
  return [UINavigationBar appearance].barTintColor;
}

+ (UIColor*) navTintColor
{
  return [UINavigationBar appearance].tintColor;
}




@end