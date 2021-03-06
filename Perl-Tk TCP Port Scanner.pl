 #!/perl/bin/perl.exe

use Tk;
use Tk::ROText;
use IO::Socket;

# Perl/Tk TCP Port Scanner.
#
# Created by CodeStar.
# E-mail: codestar@bluebottle.com
#
# This program is a basic port scanner with a GUI coded in the perl Tk module.
# The port scanning technique is a basic Syn, Syn/Ack, Ack connection on each port
# and fails to provide any stealth what-so-ever unless you edit this script yourself.
# For a decent port scanner i recommend Nmap (http://www.insecure.org).

$font = "courier";

$mw = MainWindow -> new(
   -title => "{ Perl/Tk TCP Port Scanner }"
);

$spcr_1 = $mw -> Label(-font => "$font 1");
$lbl_1 = $mw -> Label(-text => "Host:", -font => "$font 10 bold");
$spcr_2 = $mw -> Label();
$ent_host = $mw -> Entry(-font => "$font 10 bold", -font => "$font 10 bold", -border => "1", -relief => "groove", -width => "18", -justify => "center");
$spcr_3 = $mw -> Label(-font => "$font 1");
$rdb_single = $mw -> Radiobutton(-text => "Single Port(s)", -value => "single", -variable => \$scan, -font => "$font 10 bold");
$ent_single_ports = $mw -> Entry(-font => "$font 10 bold", -font => "$font 10 bold", -border => "1", -relief => "groove", -width => "18", -justify => "center");
$lbl_2 = $mw -> Label(-text => "(seperate using commas for multiple ports)", -font => "$font 9");
$spcr_4 = $mw -> Label(-font => "$font 1");
$rdb_range = $mw -> Radiobutton(-text => "Port Range", -value => "range", -variable => \$scan, -font => "$font 10 bold");
$ent_range_start = $mw -> Entry(-font => "$font 10 bold", -width => "6", -border => "1", -relief => "groove", -justify => "center");
$spcr_5 = $mw -> Label(-text => "-", -font => "$font 10 bold");
$ent_range_end = $mw -> Entry(-font => "$font 10 bold", -width => "6", -border => "1", -relief => "groove", -justify => "center");
$spcr_6 = $mw -> Label(-font => "$font 5");
$output = $mw -> Scrolled('ROText', -scrollbars => "oe", -font => "$font 9", -width => "42", -height => "14", -border => "1", -background => "white", -relief => "groove");
$spcr_11 = $mw -> Label(-font => "$font 1");
$btn_scan = $mw -> Button(-text => "Start!", -font => "$font 10 bold", -command => \&start);
$btn_about = $mw -> Button(-text => "About", -font => "$font 10 bold", -command => \&about);
$btn_quit = $mw -> Button(-text => "Quit", -font => "$font 10 bold", -command => \&quit);
$spcr_12 = $mw -> Label(-font => "$font 1");

$spcr_1 -> grid(-row => 1, -column => 1);
$lbl_1 -> grid(-row => 2, -column => 1);
$spcr_2 -> grid(-row => 2, -column => 2);
$ent_host -> grid(-row => 2, -column => 2, -columnspan => 3, -sticky => "w");
$spcr_3 -> grid(-row => 3, -column => 1);
$rdb_single -> grid(-row => 4, -column => 1);
$ent_single_ports -> grid(-row => 4, -column => 2, -columnspan => 3, -sticky => "w");
$lbl_2 -> grid(-row => 5, -column => 1, -columnspan => 4);
$spcr_4 -> grid(-row => 6, -column => 1);
$rdb_range -> grid(-row => 7, -column => 1);
$ent_range_start -> grid(-row => 7, -column => 2, -sticky => "e");
$spcr_5 -> grid(-row => 7, -column => 3);
$ent_range_end -> grid(-row => 7, -column => 4, -sticky => "w");
$spcr_6 -> grid(-row => 8, -column => 1);
$output -> grid(-row => 9, -column => 1, -columnspan => 4);
$spcr_11 -> grid(-row => 10, -column => 1);
$btn_scan -> grid(-row => 11, -column => 1);
$btn_about -> grid(-row => 11, -column => 2);
$btn_quit -> grid(-row => 11, -column => 3, -columnspan => 2);
$spcr_12 -> grid(-row => 12, -column => 1);
$rdb_single -> select();

MainLoop;

sub start {
   $output -> delete('0.1', 'end');
   $host = $ent_host -> get();
   if (!$host) { $mw -> messageBox(-message => "You didn't enter a host.", -type => "ok", -icon => "error"); }
   else {
      $hostip = "";
      system("nslookup $host > temp.txt");
      open(IN, "<temp.txt");
      @data = <IN>;
      close(IN);
      $nextone = 0;
      foreach $line (@data) {
         chomp($line);
         if ($line =~ /$host/) { $nextone++; }
         if ($nextone > 0) {
            if ($line =~ /^Address:/) { $hostip .= ((split(/: /, $line))[1]); }
            elsif ($line =~ /^Addresses:/) {
               @halfs = split(/: /, $line);
               @ips = split(/,/, $halfs[1]);
               $hostip .= $ips[0];
            }
         }
      }
      system("del temp.txt");
      if ($hostip ne "") {
         $output -> delete('0.1', 'end');
         $hostip =~ s/\ //;
         @timedata = localtime(time);
         $hour = "";
         if ($timedata[2] < 10) {
            $x = "0" . $timedata[2];
            $hour .= $x;
         }
         $minute = "";
         if ($timedata[1] < 10) {
            $x = "0" . $timedata[1];
            $minute .= $x;
         }
         $time = $hour . ":" . $minute;
         $month = "";
         if ($timedata[4] < 10) {
            $x = $timedata[4] + 1;
            $y = "0" . $x;
            $month = $y;
         }
         $year = $timedata[5] + 1900;
         $date = $timedata[3] . "/" . $month . "/" . $year;
         $openports = 0;
         $closedports = 0;
         $totalports = 0;
         $then = time;
         $output -> insert('end', "Starting port scan on $hostip...\nTime: $time\t\tDate: $date\n\n");
         if ($scan eq "single") {
            $ports = $ent_single_ports -> get();
            if (!$ports) { $mw -> messageBox(-message => "You didn't enter in some ports to scan.", -type => "ok", -icon => "error"); }
            else {
               @ports = split(/,/, $ports);
               foreach $port (@ports) {
                  if ($port =~ /^[0-9]+/) {
                     $sock = new IO::Socket::INET (
                        PeerAddr => $hostip,
                        PeerPort => $port,
                        Proto => "TCP",
                        Timeout => 1
                     );
                     if ($sock) {
                        $output -> insert('end', "Port $port is open.\n");
                        $openports++;
                     }
                     $totalports++;
                  }
               }
            }
         }
         elsif ($scan eq "range") {
            $start = $ent_range_start -> get();
            if (!$start) { $mw -> messageBox(-message => "You didn't enter a starting port.", -type => "ok", -icon => "error"); }
            else {
               $end = $ent_range_end -> get();
               if (!$end) { $mw -> messageBox(-message => "You didn't enter an ending port.", -type => "ok", -icon => "error"); }
               else {
                  if ($start =~ /^[0-9]/) {
                     if ($end =~ /^[0-9]/) {
                        if ($start < $end) {
                           for ($start; $start <= $end; $start++) {
                              $sock = new IO::Socket::INET (
                                 PeerAddr => $hostip,
                                 PeerPort => $start,
                                 Proto => "TCP",
                                 Timeout => 1
                              );
                              if ($sock) {
                                 $output -> insert('end', "Port $start is open.\n");
                                 $openports++;
                              }
                              $totalports++;
                           }
                        }
                        elsif ($start > $end) {
                           for ($end; $end <= $start; $end++) {
                              $sock = new IO::Socket::INET (
                                 PeerAddr => $hostip,
                                 PeerPort => $end,
                                 Proto => "TCP",
                                 Timeout => 1
                              );
                              if ($sock) {
                                 $output -> insert('end', "Port $end is open.\n");
                                 $openports++;
                              }
                              $totalports++;
                           }
                        }
                        else {
                           if ($start == $end) {
                              $sock = new IO::Socket::INET (
                                 PeerAddr => $hostip,
                                 PeerPort => $start,
                                 Proto => "TCP",
                                 Timeout => 1   
                              );
                              if ($sock) {
                                 $output -> insert('end', "Port $start is open.\n");
                                 $openports++;
                              }
                              $totalports = 1;
                           }
                           else {
                              print "WTF?!?! how the f**k did you get here.\n";
                              exit 0;
                           }
                        }
                     }
                     else { $mw -> messageBox(-message => "Your ending port is invalid.", -type => "ok", -icon => "error"); }
                  }
                  else { $mw -> messageBox(-message => "Your starting port is invalid.", -type => "ok", -icon => "error"); }
               }
            }
         }
         $totalports = $totalports - 1;
         $closedports = $totalports - $openports;
         $now = time;
         $duration = $now - $then;
         if ($totalports > 0) { $output -> insert('end', "\nScan Complete!\n\nNum of Open Ports: $openports \nNum of Closed Ports: $closedports\nTotal Ports Scanned: $totalports\nDuration: $duration seconds.\n"); }
      }
      else {
         $mw -> messageBox(-message => "Invalid Host!", -type => "ok", -icon => "error");
      }
   }
}

sub about {
   $aboutinfo = "This is a Simple TCP connect port scanner written in Perl Tk, by no means should you rely on it for accuracy and speed. This is just the result of me pissing about in Perl/Tk. :P :)\n\nCoded by: CodeStar\nEmail: codestar@bluebottle.com";

   $tw = $mw -> Toplevel(
      -title => "{ Perl/Tk TCP Port Scanner }"
   );

   $tw_spcr_1 = $tw -> Label(-font => "$font 1");
   $tw_lbl_title = $tw -> Label(-text => "{ About }", -font => "$font 12 bold",);
   $tw_spcr_2 = $tw -> Label(-font => "$font 1");
   $tw_about_info = $tw -> ROText(-font => "$font 10", -width => "35", -height => "9", -border => 1, -relief => "groove", -background => "white");
   $tw_spcr_3 = $tw -> Label(-font => "$font 1");
   $tw_spcr_4 = $tw -> Label();
   $tw_btn_close = $tw -> Button(-text => "Close", -command => \&close, -font => "$font 10 bold");
   $tw_spcr_5 = $tw -> Label();
   $tw_spcr_6 = $tw -> Label(-font => "$font 1");

   $tw_spcr_1 -> grid(-row => 1, -column => 1);
   $tw_lbl_title -> grid(-row => 2, -column => 1, -columnspan => 3);
   $tw_spcr_2 -> grid(-row => 3, -column => 1);
   $tw_about_info -> grid(-row => 4, -column => 1, -columnspan => 3);
   $tw_spcr_3 -> grid(-row => 5, -column => 1);
   $tw_spcr_4 -> grid(-row => 6, -column => 1);
   $tw_btn_close -> grid(-row => 6, -column => 2);
   $tw_spcr_6 -> grid(-row => 7, -column => 1);
   $tw_spcr_5 -> grid(-row => 6, -column => 3);
   $tw_about_info -> insert('end', "$aboutinfo");
}

sub quit {
   $confirm = $mw -> messageBox(-message => "Really Quit?", -type => "yesno", -icon => "question");
   if ($confirm =~ /^[Yy]+/) { exit 0; }
}

sub close {
   $tw -> destroy();
}