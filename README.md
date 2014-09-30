SimpleFurigana
==============

A Simple iPhone Application adding Ruby Characters (Furigana) to Japanese Text.

This app uses CFStringTokenizer and CFStringTransform to parse Japanese text and automatically transliterates the contained Chinese characters (Kanji) into Hiragana.

![alt tag](https://github.com/shinjukunian/SimpleFurigana/blob/gh-pages/kanjiinput.png)


![alt tag](https://github.com/shinjukunian/SimpleFurigana/blob/gh-pages/hiraganaonly.png)

Text is displayed using CoreText, making use of CTRubyAnnotationRef (new in iOS8) to display Ruby Characters (Furigana) above the original Japanese text. 

![alt tag](https://github.com/shinjukunian/SimpleFurigana/blob/gh-pages/horizontal.png)

Both horizontal (横書き) and vertical (縦書き) text layouts are supported. 

![alt tag](https://github.com/shinjukunian/SimpleFurigana/blob/gh-pages/vertical.png)


Acknowledgements
================
This app was inspired by two articles on NSHipster on [CFStringTokenizer / CFStringTransform](http://nshipster.com/cfstringtransform/) and [CTRubyAnnotationRef](http://nshipster.com/ios8/).
String parsing and transliteration is based on the NSString Category [NSString-Japanese](https://github.com/00StevenG/NSString-Japanese) by 00StevenG.
