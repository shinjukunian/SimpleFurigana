SimpleFurigana
==============

A Simple iPhone Application adding Ruby Characters (Furigana) to Japanese Text.

This app uses CFStringTokenizerRef to parse Japanese text and automatically transliterates the contained Chinese characters (Kanji) into Hiragana.

Text is displayed using CoreText, making use of CTRubyAnnotationRef (new in iOS8) to display Ruby Characters (Furigana) above the original Japanese text. 

Both horizontal (横書き) and vertical (縦書き) text layouts are supported. 


