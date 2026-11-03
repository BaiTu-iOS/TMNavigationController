//
//  TMSystemLayoutNavigationController.m
//  Created by xuedanwu on 2026/11/02.
//

#import "TMSystemLayoutNavigationController.h"

@implementation TMSystemLayoutNavigationController

- (BOOL)tm_prefersSystemButtons
{
    return self.systemLayout;
}

@end
