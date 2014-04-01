//
//  DiyCakeViewController.m
//  Unity-iPhone
//
//  Created by guoq on 14-3-25.
//
//

#import "DiyCakeViewController.h"
#import "UnityAppController.h"

@interface DiyCakeViewController ()

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *sideLv1Labels;


@end

@implementation DiyCakeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    for (UILabel *oneLabel in self.sideLv1Labels) {
        [oneLabel setFont:[UIFont fontWithName:@"GJJZQJW--GB1-0" size:18]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (IBAction)backToMain:(id)sender
{
    UnityAppController * appController = (UnityAppController*)[UIApplication sharedApplication].delegate;
    [appController backToMain];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
     UnityAppController * appController = (UnityAppController*)[UIApplication sharedApplication].delegate;
    [super touchesBegan:touches withEvent:event];
    [[appController unityView] touchesBegan : touches withEvent:event ];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UnityAppController * appController = (UnityAppController*)[UIApplication sharedApplication].delegate;
    NSLog(@"B - touchesCancelled..");
    // 把事件传递下去给父View或包含他的ViewController
    [super touchesCancelled:touches withEvent:event];
    [[appController unityView] touchesCancelled : touches withEvent:event ];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UnityAppController * appController = (UnityAppController*)[UIApplication sharedApplication].delegate;
    NSLog(@"B - touchesEnded..");
    // 把事件传递下去给父View或包含他的ViewController
    [super touchesEnded:touches withEvent:event];
    [[appController unityView] touchesEnded : touches withEvent:event ];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UnityAppController * appController = (UnityAppController*)[UIApplication sharedApplication].delegate;
    NSLog(@"B - touchesMoved..");
    // 把事件传递下去给父View或包含他的ViewController
    [super touchesMoved:touches withEvent:event];
    [[appController unityView] touchesMoved : touches withEvent:event ];
}



@end
