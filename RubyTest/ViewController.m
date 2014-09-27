//
//  ViewController.m
//  RubyTest
//
//  Created by Morten Bertz on 9/18/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import "ViewController.h"
#import "RubyView.h"
#import "FullScreenViewController.h"
@import CoreText;

@interface ViewController (){
 
    NSDictionary *attributes;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *input=@"神戸市長田区で行方不明の市立名倉小1年、生田美玲さんとみられる遺体が見つかった事件。遺体を入れたポリ袋は美玲さん宅からわずか100メートルの雑木林の草むらに無造作に捨てられていたが、兵庫県警は複数回周囲を捜索しながら、袋を発見できなかった。現場は住宅街に近く、車では行けない場所。大胆な犯行に不安が広がる。\r　県警はこれまで大量の捜査員で美玲さん宅周辺の茂みや川を連日捜索。ところが、県警は雑木林を捜索エリアに指定し、17日に隣接する空き家を調査するなど何度も周囲を調べながら、袋のあった場所は未確認だった。\r　23日の捜索で異臭に気付いた捜査員が腰丈の草むらから袋を発見。袋は厳重に包まれてはいたが、狭い範囲に無造作に置かれ、埋めたり隠したりした形跡もなかった。\r　遺棄現場は地元の人でも分かりにくい場所で、人通りはほとんどない。ただ車が入れる道はない上、住宅街ですぐ裏には高層マンションも建つ。県警は徒歩で複数の袋を気付かれずに捨てるのは困難とみられることから、土地勘がある人物の関与を疑っている。\r　遺体は裸で、頭、胴体、両足が切断され、衣服や下着とともに数個の袋に入っていた。腰の部分は別の場所にあるとみられ、まだ見つかっていない。猟奇的な犯行に、県警は不審者情報を確認するなどして、容疑者特定に全力を挙げている。";
   
    attributes=@{NSFontAttributeName:[UIFont systemFontOfSize:20]};
    
    NSAttributedString *inputAttributed=[[NSAttributedString alloc]initWithString:input attributes:attributes];
    [self.inputTextView setDelegate:self];
    [self.inputTextView setAttributedText:inputAttributed];
    [self.rubyView setStringToTransform:inputAttributed];
    [self.rubyView setType:RubyTypeNone];
    [self.rubyView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.rubyView.hostingScrollView=self.scrollView;
   
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

  //  [self.rubyView sizeToFit];
    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
    if ([pasteBoard containsPasteboardTypes:UIPasteboardTypeListString]) {
        NSArray *array=[pasteBoard strings];
        NSString *string=[array componentsJoinedByString:@""];
        if (string.length>0) {
            NSAttributedString *att=[[NSAttributedString alloc]initWithString:string attributes:attributes];
            [self.inputTextView setAttributedText:att];
            [self.rubyView setStringToTransform:att];
           // [self.rubyView sizeToFit];
            //[self.rubyView setNeedsDisplay];

        }
    }
    
}




-(void)viewDidLayoutSubviews{
   // NSLog(@"%@",NSStringFromCGSize(self.scrollView.bounds.size));
    if (![self presentedViewController]) {
         [self.rubyView sizeToFit];
    }
   
   }


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
   // [self.rubyView setNeedsDisplay];
}


-(IBAction)showActivityViewController:(UIBarButtonItem*)sender{
    
    
    UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:@[self.rubyView] applicationActivities:nil];
    [self presentViewController:activity animated:YES completion:nil];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
 
    NSString *new=[textView.text stringByReplacingCharactersInRange:range withString:text];
    NSAttributedString *newAttributed=[[NSAttributedString alloc]initWithString:new attributes:attributes];
    [self.rubyView setStringToTransform:newAttributed];
    [self.rubyView sizeToFit];
    [self.rubyView setNeedsDisplay];
        
    return YES;
}


-(IBAction)transliterationMethodDidChange:(UISegmentedControl*)sender{
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.rubyView setType:RubyTypeNone];
            break;
        
        case 1:
            [self.rubyView setType:RubyTypeHiraganaOnly];
            break;
        case 2:
            [self.rubyView setType:RubyTypeFurigana];
            break;
        default:
            break;
    }
    [self.rubyView sizeToFit];
    [self.rubyView setNeedsDisplay];
    
    
}

-(IBAction)writingOrientationDidChange:(UISegmentedControl*)sender{
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.rubyView setOrientation:RubyHorizontalText];
            [self.rubyView sizeToFit];
            [self.rubyView setNeedsDisplay];
            break;
        case 1:
            [self.rubyView setOrientation:RubyVerticalText];
            [self.rubyView sizeToFit];
            [self.rubyView setNeedsDisplay];
            
            break;
        default:
            break;
    }

}


-(IBAction)tapToDismissKeyboard:(id)sender{
    [self.inputTextView resignFirstResponder];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if([segue.identifier isEqualToString:@"toFullscreen"]){
        
        FullScreenViewController *fullScreen=segue.destinationViewController;
        fullScreen.stringToTransform=self.rubyView.stringToTransform;
        fullScreen.type=self.rubyView.type;
        fullScreen.orientation=self.rubyView.orientation;
               
    }
    
    
    
}


@end
