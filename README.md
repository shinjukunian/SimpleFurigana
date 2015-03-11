SimpleFurigana
==============

A Simple iPhone Application adding Ruby Characters (Furigana) to Japanese Text.

This app uses CFStringTokenizer and CFStringTransform to parse Japanese text.

<img src="https://github.com/shinjukunian/SimpleFurigana/blob/gh-pages/kanjiinput.png" height="500px" align="middle" />

Chinese Characters (Kanji) are automatically transliterated into Hiragana.

<img src="https://github.com/shinjukunian/SimpleFurigana/blob/gh-pages/hiraganaonly.png" height="500px" align="middle" />

Text is displayed using CoreText, making use of CTRubyAnnotationRef (new in iOS8) to display Ruby Characters (Furigana) above the original Japanese text. 

<img src="https://github.com/shinjukunian/SimpleFurigana/blob/gh-pages/horizontal.png" height="500px" align="middle" />

Both horizontal (横書き) and vertical (縦書き) text layouts are supported. 

<img src="https://github.com/shinjukunian/SimpleFurigana/blob/gh-pages/vertical.png" height="500px" align="middle" />

Layouts can be shared and printed.

Known Issues
============

- layouting text with Ruby characters is slow

~~CTFrameSetter, especially CTFramesetterSuggestFrameSizeWithConstraints occasionally crashes when laying out 'rubyfied' text. I believe this is due to some problems with the layout geometry.~~ This issue has been fixed in iOS8.2. 

Acknowledgements
================
This app was inspired by two articles on NSHipster on [CFStringTokenizer / CFStringTransform](http://nshipster.com/cfstringtransform/) and [CTRubyAnnotationRef](http://nshipster.com/ios8/).
String parsing and transliteration is based on the NSString Category [NSString-Japanese](https://github.com/00StevenG/NSString-Japanese) by 00StevenG.
