use FindBin qw/$Bin/;
use File::Basename;
use Tk;
use lib "$Bin/lib";
use IRacing::Setup::Parser;
use strict;
use warnings;
use encoding "cp932";
my $config = require "$Bin/setting.ini";
my $const_vars;
my $text_vars;

my $top = MainWindow->new();
$top->geometry("200x300");
my $menu = $top->Menu( -type => 'menubar' );
$top->configure( -menu => $menu );

my $m_file = $menu->cascade( -label => 'File', -under => 0, -tearoff => 0 );
$m_file->command(
    -label   => 'Load Setup',
    -under   => 0,
    -command => sub {
        my $setup_file = $top->getOpenFile(
            -filetypes =>
              [ [ "HTML Files", [qw/.htm .html/] ], [ 'All Files', '*', ] ],
            -initialdir => $config->{setup_dir}
        );
        if ($setup_file) {
            $config->{setup_dir} = dirname($setup_file) . "\\";
            my $s = IRacing::Setup::Parser->new($setup_file);
            $const_vars = <<"EOL";
LFshockIniDefl\t@{[$s->data_wou( 'CHASSIS' => 'LEFT FRONT' => 'Shock deflection')]}
LFshockMaxDefl\t@{[$s->data_wou( 'CHASSIS' => 'LEFT FRONT' => 'Shock deflection (of)')]}
RFshockIniDefl\t@{[$s->data_wou( 'CHASSIS' => 'RIGHT FRONT' => 'Shock deflection')]}
RFshockMaxDefl\t@{[$s->data_wou( 'CHASSIS' => 'RIGHT FRONT' => 'Shock deflection (of)')]}
EOL
            $text_vars->delete( '1.0', 'end' );
            $text_vars->insert( '0.0', $const_vars );
        }
    }
);
$m_file->separator;
$m_file->command( -label => 'Exit', -under => 0, -command => \&exit );

my $btn_export = $top->Button(
    -text    => 'Save as "default_constants.txt"',
    -command => sub {
        my $export_file = $top->getSaveFile(
            -filetypes => [ [ "Text Files", '.txt' ], [ 'All Files', '*', ] ],
            -initialdir  => $config->{atlas_config_dir},
            -initialfile => "default_constants.txt",
        );
        if ($export_file) {
            print "[[$export_file]]";
            $config->{atlas_config_dir} = dirname($export_file) . "\\";
            open( my $fh, '>', $export_file ) or die "Can't open $export_file";
            print $fh $const_vars;
            close $fh;
        }
    }
);
$btn_export->pack;

my $label_frame = $top->Labelframe( -text => "Constant Variables" );
$label_frame->pack;

$text_vars = $label_frame->Text( -width => 25, -height => 15 );
$text_vars->pack;

MainLoop();
