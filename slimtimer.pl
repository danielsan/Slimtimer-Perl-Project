use reform;

package Slimtimer;
use WebService;

use Data::Dumper;

fields config;

sub initialize
{
  my $ws = new WebService();
  my $logon = $ws->login();
  my $task_list = $ws->task_list();
  print "finished\n";
}

new Slimtimer();
