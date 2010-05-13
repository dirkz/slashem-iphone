//
//  ESRenderer.h
//  SlashEM
//
//  Created by Dirk Zimmermann on 5/13/10.
//  Copyright Dirk Zimmermann 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@protocol ESRenderer <NSObject>

- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;

@end
