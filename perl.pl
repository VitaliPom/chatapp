#! /home/linuxbrew/.linuxbrew/opt/perl@5.18/bin/perl -w

use strict;
use Curses;
use Curses::UI;
use Curses::UI::Common;


# create a new C::UI object
my $key_up = 0;

my $cui = Curses::UI->new( -clear_on_exit => 1,

                           );

my $win = $cui->add('window_id', 'Window');

my $height = `tput rows`;
$height-=1;

my $textentry = $win->add(
    'mytextentry', 'TextEntry',
    -y => $height, 	
    -text => 'Username: '
    );

my $SERVER = "192.168.1.13/chat.php";

my $USERNAME = "";
 
my $text = `curl $SERVER`;
$text =~ s#""#"#g;
$text =~ s#``#`#g;
$text =~ s#''#'#g;


my $textviewer = $win->add( 
   	 'mytextviewer', 'TextViewer',
		-text => $text, 
    -vscrollbar => 1

                );
 

$textentry->focus();

#$text = $textentry->get();

#$textentry->set_routine('loose-focus',"\r");
#$cui->set_routine('none',KEY_UP);
#$cui->set_routine('none',KEY_DOWN);

$cui->set_binding( sub {
     $text = $textentry->get();
     $text =~ s#"#""#g;
     $text =~ s#`#``#g;  
     $text =~ s#'#''#g; 
 
     if(not defined $text or $text eq ""){
        return;
     }
     my $is_log = 0;
     if($USERNAME eq ""){
        my $tmp_username = $text;
        if($tmp_username =~ /Username:\s*/){ 
            $tmp_username =~ s#Username:\s*##; 
            if($tmp_username ne ""){
                $USERNAME = $tmp_username;
                $USERNAME =~ s#"##g;   
                $USERNAME =~ s#`##g;  
                $USERNAME =~ s#'##g; 

                $text = "$USERNAME has logged in!";
                $is_log = 1;
            }
        }
     }

     $USERNAME =~ s#"#""#g;   
     $USERNAME =~ s#`#``#g;  
     $USERNAME =~ s#'#''#g; 

     if($USERNAME ne ""){
         if(not $is_log){
             $text = $USERNAME . ": " . $text; 
         }
         my $new_text = $text;
         $USERNAME =~ s#"#""#g;    
         $USERNAME =~ s#`#``#g;  
         $USERNAME =~ s#'#''#g; 
         $new_text =~ s#$USERNAME: ##;
         $new_text =~ s#Username:\s*##;

         if($new_text eq ":q"){
             exit 0;   
         }
         `curl $SERVER -d "message=$text"`;
         $text = `curl $SERVER`;
         $text =~ s#""#"#g; 
             $text =~ s#``#`#g;
         $text =~ s#''#'#g;

         $textviewer->text($text);
         $textentry->text(""); 
     }else{
         $textentry->text("Username: "); 
     }
     
	}, KEY_ENTER()); 

#$cui->set_binding( sub {
#     $text = `curl $SERVER`;
#     $textviewer->text($text);
#
#                $cui->draw(1);
#     
##     $textviewer->{-yscrpos}++;
#     $textviewer->layout_content();
##     $textentry->focus();
#
#        }, "5" ); 

$cui->set_timer(
        'timer',
        sub {
                 $text = `curl $SERVER`;
                 $text =~ s#""#"#g;
                 $text =~ s#``#`#g;
                 $text =~ s#''#'#g;
                 
                 $textviewer->text($text);
#                $textentry->focus();
                
                 if($key_up == 0){
                    for(my $i = 0; $i<2000; $i++){
                          $textviewer->cursor_down()
                     }
                 }

                $cui->draw(1);
                return;
        },
        1,
);
for(my $i =0; $i<2000; $i++){
    $textviewer->cursor_down(); 
}


$textviewer->set_binding( sub {
        $key_up--;
        $textviewer->cursor_up()
         
        }, KEY_UP() );

$textentry->set_binding( sub {
        $key_up--;
        $textviewer->focus();
        $textviewer->cursor_up();
        $textentry->focus();
         
        }, KEY_UP() );

$textentry->set_binding( sub {
        if($key_up < 0){
            $key_up++;
        }

        $textviewer->focus();
        $textviewer->cursor_down();
        $textentry->focus();
         
        }, KEY_DOWN() );


$textviewer->set_binding( sub {
        if($key_up < 0){
            $key_up++;
        }
        $textviewer->cursor_down()

        }, KEY_DOWN() );

$cui->set_binding( sub {exit 0;}, "\e" );

$cui->mainloop;


