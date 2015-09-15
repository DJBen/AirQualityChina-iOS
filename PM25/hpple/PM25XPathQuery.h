//
//  XPathQuery.h
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

NSArray *pm25_PerformHTMLXPathQuery(NSData *document, NSString *query);
NSArray *pm25_PerformHTMLXPathQueryWithEncoding(NSData *document, NSString *query,NSString *encoding);
NSArray *pm25_PerformXMLXPathQuery(NSData *document, NSString *query);
NSArray *pm25_PerformXMLXPathQueryWithEncoding(NSData *document, NSString *query,NSString *encoding);
