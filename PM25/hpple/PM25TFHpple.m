//
//  PM25TFHpple.m
//  Hpple
//
//  Created by Geoffrey Grosenbach on 1/31/09.
//
//  Copyright (c) 2009 Topfunky Corporation, http://topfunky.com
//
//  MIT LICENSE
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "PM25TFHpple.h"
#import "PM25XPathQuery.h"

@interface PM25TFHpple ()
{
    NSData * data;
    NSString * encoding;
    BOOL isXML;
}

@end


@implementation PM25TFHpple

@synthesize data;
@synthesize encoding;


- (id) initWithData:(NSData *)theData encoding:(NSString *)theEncoding isXML:(BOOL)isDataXML
{
  if (!(self = [super init])) {
    return nil;
  }

  data = theData;
  encoding = theEncoding;
  isXML = isDataXML;

  return self;
}

- (id) initWithData:(NSData *)theData isXML:(BOOL)isDataXML
{
    return [self initWithData:theData encoding:nil isXML:isDataXML];
}

- (id) initWithXMLData:(NSData *)theData encoding:(NSString *)theEncoding
{
  return [self initWithData:theData encoding:theEncoding isXML:YES];
}

- (id) initWithXMLData:(NSData *)theData
{
  return [self initWithData:theData encoding:nil isXML:YES];
}

- (id) initWithHTMLData:(NSData *)theData encoding:(NSString *)theEncoding
{
    return [self initWithData:theData encoding:theEncoding isXML:NO];
}

- (id) initWithHTMLData:(NSData *)theData
{
  return [self initWithData:theData encoding:nil isXML:NO];
}

+ (PM25TFHpple *) hppleWithData:(NSData *)theData encoding:(NSString *)theEncoding isXML:(BOOL)isDataXML {
  return [[[self class] alloc] initWithData:theData encoding:theEncoding isXML:isDataXML];
}

+ (PM25TFHpple *) hppleWithData:(NSData *)theData isXML:(BOOL)isDataXML {
  return [[self class] hppleWithData:theData encoding:nil isXML:isDataXML];
}

+ (PM25TFHpple *) hppleWithHTMLData:(NSData *)theData encoding:(NSString *)theEncoding {
  return [[self class] hppleWithData:theData encoding:theEncoding isXML:NO];
}

+ (PM25TFHpple *) hppleWithHTMLData:(NSData *)theData {
  return [[self class] hppleWithData:theData encoding:nil isXML:NO];
}

+ (PM25TFHpple *) hppleWithXMLData:(NSData *)theData encoding:(NSString *)theEncoding {
  return [[self class] hppleWithData:theData encoding:theEncoding isXML:YES];
}

+ (PM25TFHpple *) hppleWithXMLData:(NSData *)theData {
  return [[self class] hppleWithData:theData encoding:nil isXML:YES];
}

#pragma mark -

// Returns all elements at xPath.
- (NSArray *) searchWithXPathQuery:(NSString *)xPathOrCSS
{
  NSArray * detailNodes = nil;
  if (isXML) {
    detailNodes = pm25_PerformXMLXPathQueryWithEncoding(data, xPathOrCSS, encoding);
  } else {
    detailNodes = pm25_PerformHTMLXPathQueryWithEncoding(data, xPathOrCSS, encoding);
  }

  NSMutableArray * hppleElements = [NSMutableArray array];
  for (id node in detailNodes) {
    [hppleElements addObject:[PM25TFHppleElement hppleElementWithNode:node isXML:isXML withEncoding:encoding]];
  }
  return hppleElements;
}

// Returns first element at xPath
- (PM25TFHppleElement *) peekAtSearchWithXPathQuery:(NSString *)xPathOrCSS
{
  NSArray * elements = [self searchWithXPathQuery:xPathOrCSS];
  if ([elements count] >= 1) {
    return [elements objectAtIndex:0];
  }

  return nil;
}

@end
