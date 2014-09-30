SimpleFurigana
==============

A Simple iPhone Application adding Ruby Characters (Furigana) to Japanese Text.

This app uses CFStringTokenizer and CFStringTransform to parse Japanese text and automatically transliterates the contained Chinese characters (Kanji) into Hiragana.

<img src="https://github.com/shinjukunian/SimpleFurigana/blob/gh-pages/kanjiinput.png" height="500px" />

<img src="https://github.com/shinjukunian/SimpleFurigana/blob/gh-pages/hiraganaonly.png" height="500px" />

Text is displayed using CoreText, making use of CTRubyAnnotationRef (new in iOS8) to display Ruby Characters (Furigana) above the original Japanese text. 

<img src="https://github.com/shinjukunian/SimpleFurigana/blob/gh-pages/horizontal.png" height="500px" />

Both horizontal (横書き) and vertical (縦書き) text layouts are supported. 

<img src="https://github.com/shinjukunian/SimpleFurigana/blob/gh-pages/vertical.png" height="500px" />



Acknowledgements
================
This app was inspired by two articles on NSHipster on [CFStringTokenizer / CFStringTransform](http://nshipster.com/cfstringtransform/) and [CTRubyAnnotationRef](http://nshipster.com/ios8/).
String parsing and transliteration is based on the NSString Category [NSString-Japanese](https://github.com/00StevenG/NSString-Japanese) by 00StevenG.
