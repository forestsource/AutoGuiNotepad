use strict;
use warnings;
use utf8;
use Encode;
use Win32::GuiTest qw(:ALL);
use Win32::Clipboard;
use Getopt::Std;
use Getopt::Long;
use Time::HiRes 'sleep';

my $cp932 = find_encoding('cp932');

UnicodeSemantics(1);
#オプションの設定
my $file_name = 'memo';
my $use_clipboard = 0;
my $string = 'none';

#引数を変数にいれる
GetOptions('filename=s' => \$file_name, 'string=s' => \$string);

#メモ帳を起動
system('start notepad');
sleep(0.3);
my ($notepad) = FindWindowLike(0, 'メモ帳$');
#ウィンドウを手前に出す
SetForegroundWindow($notepad);
# エディットボックスを取得
my ($edit) = FindWindowLike($notepad, undef, '^Edit$');
# フォーカスを当てる
SetFocus($edit);
# sオプションならば任意の文字列を書き込む
#なければclipboardの内容を書き込む
if ($string ne 'none'){
    WMSetText($edit, $cp932->encode($string));
}else{
    #select clipboard
    my $clip = Win32::Clipboard();
    #get text for clipboard
    my $text = $clip->GetText();
    WMSetText($edit, $cp932->encode($text));
}
# 0 番目のメニューアイテムからサブメニューを取得して、
# サブメニューから 2 番目のメニューアイテムの ID を取得してくる
# （メモ帳では、「ファイル」→「名前を付けて保存」メニュー)
my $id = GetMenuItemID(GetSubMenu(GetMenu($notepad), 0), 3);
# メッセージでメモ帳に、メニューが選択されたと通知する
PostMessage($notepad, Win32::GuiTest::WM_COMMAND, $id, 0);

#保存用の確認windowを取得
my $dialog = FindWindowLike(0, '名前を付けて保存$');
SetForegroundWindow($dialog);
sleep(0.5);

# エディットボックスを取得
($edit) = FindWindowLike($dialog, undef, '^Edit$');

#fileの名前を入力
WMSetText($edit, $cp932->encode($file_name));
SendKeys('{ENTER}');
#名前を付けて保存にフォーカス
($dialog) = FindWindowLike(0, '名前を付けて保存の確認$');
if($dialog){
    SetForegroundWindow($dialog);
    #windowの名前を確認
    #はい　を選択する。
    SendKeys('{LEFT}{ENTER}');
}
#メモ帳を閉じる (Alt-f, q).
SendKeys('%(f)X');