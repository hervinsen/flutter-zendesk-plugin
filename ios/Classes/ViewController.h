#import <UIKit/UIKit.h>
#import <ZDCChat/ZDCChat.h>

@interface ViewController: ZDUViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL modal;
@property (nonatomic, assign) BOOL nested;

- (UIButton*) buildButtonWithFrame:(CGRect)frame andTitle:(NSString*)title;

@end