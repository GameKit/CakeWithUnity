//
//  DSCustomView.m
//  Unity-iPhone
//
//  Created by guoq on 14-3-26.
//
//

#import "DSCustomView.h"
#import "UnityAppController.h"

@implementation DSCustomView

@synthesize backBtn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    //self = [[[NSBundle mainBundle] loadNibNamed:@"DSCustomView" owner:nil options:nil] objectAtIndex:0];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    [super hitTest:point withEvent:event];
    return  self;
}
*/

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    NSLog(@"second view pointInside");
    NSLog(@"point is %f %f", point.x, point.y);
    NSLog(@"rect is %f, %f, %f, %f", backBtn.frame.size.width, backBtn.frame.size.height, backBtn.frame.origin.x, backBtn.frame.origin.y);
    [super pointInside:point withEvent:event];
    if (CGRectContainsPoint(CGRectMake(0.f, 0.f, 200.f, 100.f), point)) {
        
            NSLog(@"second view pointInside point");
        return YES;
    }
    
    
    return NO;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)backToMain:(id)sender
{
    UnityAppController * appController = (UnityAppController*)[UIApplication sharedApplication].delegate;
    [appController backToMain];
}

@end
