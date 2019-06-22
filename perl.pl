#! /home/linuxbrew/.linuxbrew/opt/perl@5.18/bin/perl -w

use strict;
use Curses;
use Curses::UI;
use Curses::UI::Common;

# create a new C::UI object
my $cui = Curses::UI->new( -clear_on_exit => 1,

                           );

my $win = $cui->add('window_id', 'Window');

my $height = `tput rows`;
$height-=1;

my $textentry = $win->add(
    'mytextentry', 'TextEntry',
    -y => $height 	
);

my $SERVER = "192.168.1.13/chat.php";
 
my $text = `curl $SERVER`;

my $textviewer = $win->add( 
   	 'mytextviewer', 'TextViewer',
		-text => $text 
);
 


$textentry->focus();

#$text = $textentry->get();

$textentry->set_routine('loose-focus',"\r");


$cui->set_binding( sub {
     $text = $textentry->get();
     $text =~ s#"#""#;
     $text =~ s#`#``#;
     `curl $SERVER -d "message=$text"`;
     $text = `curl $SERVER`;
     $textviewer->text($text);
     $textentry->text("");     
	}, KEY_ENTER()); 

$cui->set_binding( sub {
     $text = `curl $SERVER`;
     $textviewer->text($text);
     $textentry->focus();

	}, "5" ); 

$cui->set_timer(
        'timer',
        sub {
                 $text = `curl $SERVER`;
                 $textviewer->text($text);
                 $textentry->focus();

                $cui->draw(1);
                return;
        },
        1,
);

$cui->set_binding( sub {exit 0;}, "\e" );

$cui->mainloop;
