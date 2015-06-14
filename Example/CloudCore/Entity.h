//
//  Entity.h
//  CloudCore
//
//  Created by Jonathan Hersh on 6/13/15.
//  Copyright (c) 2015 Jonathan Hersh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Entity : NSManagedObject

@property (nonatomic, retain) NSString * attribute;

@end
