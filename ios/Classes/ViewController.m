#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UISwitch *enableAgentAvailabilityObservingSwitch;
@property (nonatomic, strong) NSString *department;

@end

@implementation ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Testing";
    self.view.backgroundColor = [UIColor colorWithWhite:0.94f alpha:1.0f];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    _scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.contentView addSubview:_scrollView];
}

@end