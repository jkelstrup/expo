/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI32_0_0RCTTextAttributes.h"

#import <ReactABI32_0_0/ABI32_0_0RCTAssert.h>
#import <ReactABI32_0_0/ABI32_0_0RCTFont.h>
#import <ReactABI32_0_0/ABI32_0_0RCTLog.h>

NSString *const ABI32_0_0RCTTextAttributesIsHighlightedAttributeName = @"ABI32_0_0RCTTextAttributesIsHighlightedAttributeName";
NSString *const ABI32_0_0RCTTextAttributesTagAttributeName = @"ABI32_0_0RCTTextAttributesTagAttributeName";

@implementation ABI32_0_0RCTTextAttributes

- (instancetype)init
{
  if (self = [super init]) {
    _fontSize = NAN;
    _letterSpacing = NAN;
    _lineHeight = NAN;
    _textDecorationStyle = NSUnderlineStyleSingle;
    _fontSizeMultiplier = NAN;
    _alignment = NSTextAlignmentNatural;
    _baseWritingDirection = NSWritingDirectionNatural;
    _textShadowRadius = NAN;
    _opacity = NAN;
    _textTransform = ABI32_0_0RCTTextTransformUndefined;
  }

  return self;
}

- (void)applyTextAttributes:(ABI32_0_0RCTTextAttributes *)textAttributes
{
  // Note: All lines marked with `*` does not use explicit/correct rules to compare old and new values becuase
  // their types do not have special designated value representing undefined/unspecified/inherit meaning.
  // We will address this in the future.

  // Color
  _foregroundColor = textAttributes->_foregroundColor ?: _foregroundColor;
  _backgroundColor = textAttributes->_backgroundColor ?: _backgroundColor;
  _opacity = !isnan(textAttributes->_opacity) ? (isnan(_opacity) ? 1.0 : _opacity) * textAttributes->_opacity : _opacity;

  // Font
  _fontFamily = textAttributes->_fontFamily ?: _fontFamily;
  _fontSize = !isnan(textAttributes->_fontSize) ? textAttributes->_fontSize : _fontSize;
  _fontSizeMultiplier = !isnan(textAttributes->_fontSizeMultiplier) ? textAttributes->_fontSizeMultiplier : _fontSizeMultiplier;
  _fontWeight = textAttributes->_fontWeight ?: _fontWeight;
  _fontStyle = textAttributes->_fontStyle ?: _fontStyle;
  _fontVariant = textAttributes->_fontVariant ?: _fontVariant;
  _allowFontScaling = textAttributes->_allowFontScaling || _allowFontScaling;  // *
  _letterSpacing = !isnan(textAttributes->_letterSpacing) ? textAttributes->_letterSpacing : _letterSpacing;

  // Paragraph Styles
  _lineHeight = !isnan(textAttributes->_lineHeight) ? textAttributes->_lineHeight : _lineHeight;
  _alignment = textAttributes->_alignment != NSTextAlignmentNatural ? textAttributes->_alignment : _alignment; // *
  _baseWritingDirection = textAttributes->_baseWritingDirection != NSWritingDirectionNatural ? textAttributes->_baseWritingDirection : _baseWritingDirection; // *

  // Decoration
  _textDecorationColor = textAttributes->_textDecorationColor ?: _textDecorationColor;
  _textDecorationStyle = textAttributes->_textDecorationStyle != NSUnderlineStyleSingle ? textAttributes->_textDecorationStyle : _textDecorationStyle; // *
  _textDecorationLine = textAttributes->_textDecorationLine != ABI32_0_0RCTTextDecorationLineTypeNone ? textAttributes->_textDecorationLine : _textDecorationLine; // *

  // Shadow
  _textShadowOffset = !CGSizeEqualToSize(textAttributes->_textShadowOffset, CGSizeZero) ? textAttributes->_textShadowOffset : _textShadowOffset; // *
  _textShadowRadius = !isnan(textAttributes->_textShadowRadius) ? textAttributes->_textShadowRadius : _textShadowRadius;
  _textShadowColor = textAttributes->_textShadowColor ?: _textShadowColor;

  // Special
  _isHighlighted = textAttributes->_isHighlighted || _isHighlighted;  // *
  _tag = textAttributes->_tag ?: _tag;
  _layoutDirection = textAttributes->_layoutDirection != UIUserInterfaceLayoutDirectionLeftToRight ? textAttributes->_layoutDirection : _layoutDirection;
  _textTransform = textAttributes->_textTransform != ABI32_0_0RCTTextTransformUndefined ? textAttributes->_textTransform : _textTransform;
}

- (NSDictionary<NSAttributedStringKey, id> *)effectiveTextAttributes
{
  NSMutableDictionary<NSAttributedStringKey, id> *attributes =
    [NSMutableDictionary dictionaryWithCapacity:10];

  // Font
  UIFont *font = self.effectiveFont;
  if (font) {
    attributes[NSFontAttributeName] = font;
  }

  // Colors
  UIColor *effectiveForegroundColor = self.effectiveForegroundColor;

  if (_foregroundColor || !isnan(_opacity)) {
    attributes[NSForegroundColorAttributeName] = effectiveForegroundColor;
  }

  if (_backgroundColor || !isnan(_opacity)) {
    attributes[NSBackgroundColorAttributeName] = self.effectiveBackgroundColor;
  }

  // Kerning
  if (!isnan(_letterSpacing)) {
    attributes[NSKernAttributeName] = @(_letterSpacing);
  }

  // Paragraph Style
  NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
  BOOL isParagraphStyleUsed = NO;
  if (_alignment != NSTextAlignmentNatural) {
    NSTextAlignment alignment = _alignment;
    if (_layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
      if (alignment == NSTextAlignmentRight) {
        alignment = NSTextAlignmentLeft;
      } else if (alignment == NSTextAlignmentLeft) {
        alignment = NSTextAlignmentRight;
      }
    }

    paragraphStyle.alignment = alignment;
    isParagraphStyleUsed = YES;
  }

  if (_baseWritingDirection != NSWritingDirectionNatural) {
    paragraphStyle.baseWritingDirection = _baseWritingDirection;
    isParagraphStyleUsed = YES;
  }

  if (!isnan(_lineHeight)) {
    CGFloat lineHeight = _lineHeight * self.effectiveFontSizeMultiplier;
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    isParagraphStyleUsed = YES;
  }

  if (isParagraphStyleUsed) {
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
  }

  // Decoration
  BOOL isTextDecorationEnabled = NO;
  if (_textDecorationLine == ABI32_0_0RCTTextDecorationLineTypeUnderline ||
      _textDecorationLine == ABI32_0_0RCTTextDecorationLineTypeUnderlineStrikethrough) {
    isTextDecorationEnabled = YES;
    attributes[NSUnderlineStyleAttributeName] = @(_textDecorationStyle);
  }

  if (_textDecorationLine == ABI32_0_0RCTTextDecorationLineTypeStrikethrough ||
      _textDecorationLine == ABI32_0_0RCTTextDecorationLineTypeUnderlineStrikethrough){
    isTextDecorationEnabled = YES;
    attributes[NSStrikethroughStyleAttributeName] = @(_textDecorationStyle);
  }

  if (_textDecorationColor || isTextDecorationEnabled) {
    attributes[NSStrikethroughColorAttributeName] = _textDecorationColor ?: effectiveForegroundColor;
    attributes[NSUnderlineColorAttributeName] = _textDecorationColor ?: effectiveForegroundColor;
  }

  // Shadow
  if (!CGSizeEqualToSize(_textShadowOffset, CGSizeZero)) {
    NSShadow *shadow = [NSShadow new];
    shadow.shadowOffset = _textShadowOffset;
    shadow.shadowBlurRadius = _textShadowRadius;
    shadow.shadowColor = _textShadowColor;
    attributes[NSShadowAttributeName] = shadow;
  }

  // Special
  if (_isHighlighted) {
    attributes[ABI32_0_0RCTTextAttributesIsHighlightedAttributeName] = @YES;
  }

  if (_tag) {
    attributes[ABI32_0_0RCTTextAttributesTagAttributeName] = _tag;
  }

  return [attributes copy];
}

- (UIFont *)effectiveFont
{
  // FIXME: ABI32_0_0RCTFont has thread-safety issues and must be rewritten.
  return [ABI32_0_0RCTFont updateFont:nil
                  withFamily:_fontFamily
                        size:@(isnan(_fontSize) ? 0 : _fontSize)
                      weight:_fontWeight
                       style:_fontStyle
                     variant:_fontVariant
             scaleMultiplier:self.effectiveFontSizeMultiplier];
}

- (CGFloat)effectiveFontSizeMultiplier
{
  return !ABI32_0_0RCTHasFontHandlerSet() && _allowFontScaling && !isnan(_fontSizeMultiplier) ? _fontSizeMultiplier : 1.0;
}

- (UIColor *)effectiveForegroundColor
{
  UIColor *effectiveForegroundColor = _foregroundColor ?: [UIColor blackColor];

  if (!isnan(_opacity)) {
    effectiveForegroundColor = [effectiveForegroundColor colorWithAlphaComponent:CGColorGetAlpha(effectiveForegroundColor.CGColor) * _opacity];
  }

  return effectiveForegroundColor;
}

- (UIColor *)effectiveBackgroundColor
{
  UIColor *effectiveBackgroundColor = _backgroundColor;// ?: [[UIColor whiteColor] colorWithAlphaComponent:0];

  if (effectiveBackgroundColor && !isnan(_opacity)) {
    effectiveBackgroundColor = [effectiveBackgroundColor colorWithAlphaComponent:CGColorGetAlpha(effectiveBackgroundColor.CGColor) * _opacity];
  }

  return effectiveBackgroundColor ?: [UIColor clearColor];
}

- (NSString *)applyTextAttributesToText:(NSString *)text
{
  switch (_textTransform) {
    case ABI32_0_0RCTTextTransformUndefined:
    case ABI32_0_0RCTTextTransformNone:
      return text;
    case ABI32_0_0RCTTextTransformLowercase:
      return [text lowercaseString];
    case ABI32_0_0RCTTextTransformUppercase:
      return [text uppercaseString];
    case ABI32_0_0RCTTextTransformCapitalize:
      return [text capitalizedString];
  }
}

- (ABI32_0_0RCTTextAttributes *)copyWithZone:(NSZone *)zone
{
  ABI32_0_0RCTTextAttributes *textAttributes = [ABI32_0_0RCTTextAttributes new];
  [textAttributes applyTextAttributes:self];
  return textAttributes;
}

#pragma mark - NSObject

- (BOOL)isEqual:(ABI32_0_0RCTTextAttributes *)textAttributes
{
  if (self == textAttributes) {
    return YES;
  }

#define ABI32_0_0RCTTextAttributesCompareFloats(a) ((a == textAttributes->a) || (isnan(a) && isnan(textAttributes->a)))
#define ABI32_0_0RCTTextAttributesCompareSize(a) CGSizeEqualToSize(a, textAttributes->a)
#define ABI32_0_0RCTTextAttributesCompareObjects(a) ((a == textAttributes->a) || [a isEqual:textAttributes->a])
#define ABI32_0_0RCTTextAttributesCompareStrings(a) ((a == textAttributes->a) || [a isEqualToString:textAttributes->a])
#define ABI32_0_0RCTTextAttributesCompareOthers(a) (a == textAttributes->a)

  return
    ABI32_0_0RCTTextAttributesCompareObjects(_foregroundColor) &&
    ABI32_0_0RCTTextAttributesCompareObjects(_backgroundColor) &&
    ABI32_0_0RCTTextAttributesCompareFloats(_opacity) &&
    // Font
    ABI32_0_0RCTTextAttributesCompareObjects(_fontFamily) &&
    ABI32_0_0RCTTextAttributesCompareFloats(_fontSize) &&
    ABI32_0_0RCTTextAttributesCompareFloats(_fontSizeMultiplier) &&
    ABI32_0_0RCTTextAttributesCompareStrings(_fontWeight) &&
    ABI32_0_0RCTTextAttributesCompareObjects(_fontStyle) &&
    ABI32_0_0RCTTextAttributesCompareObjects(_fontVariant) &&
    ABI32_0_0RCTTextAttributesCompareOthers(_allowFontScaling) &&
    ABI32_0_0RCTTextAttributesCompareFloats(_letterSpacing) &&
    // Paragraph Styles
    ABI32_0_0RCTTextAttributesCompareFloats(_lineHeight) &&
    ABI32_0_0RCTTextAttributesCompareFloats(_alignment) &&
    ABI32_0_0RCTTextAttributesCompareOthers(_baseWritingDirection) &&
    // Decoration
    ABI32_0_0RCTTextAttributesCompareObjects(_textDecorationColor) &&
    ABI32_0_0RCTTextAttributesCompareOthers(_textDecorationStyle) &&
    ABI32_0_0RCTTextAttributesCompareOthers(_textDecorationLine) &&
    // Shadow
    ABI32_0_0RCTTextAttributesCompareSize(_textShadowOffset) &&
    ABI32_0_0RCTTextAttributesCompareFloats(_textShadowRadius) &&
    ABI32_0_0RCTTextAttributesCompareObjects(_textShadowColor) &&
    // Special
    ABI32_0_0RCTTextAttributesCompareOthers(_isHighlighted) &&
    ABI32_0_0RCTTextAttributesCompareObjects(_tag) &&
    ABI32_0_0RCTTextAttributesCompareOthers(_layoutDirection) &&
    ABI32_0_0RCTTextAttributesCompareOthers(_textTransform);
}

@end
