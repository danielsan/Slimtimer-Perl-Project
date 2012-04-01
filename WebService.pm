use reform;

package WebService;

use Encode;
use LWP;
use YAML qw(LoadFile);
use XML::Simple;
use Carp;
use Data::Dumper;

use constant {
	FALSE => 0 ,
	TRUE  => 1 ,
	LOCK_EXCLUSIVE => 2,
	UNLOCK         => 8,
	NOT_GET_ROWS => 1
};

fields browser, token, user_id;

sub initialize
{
  my $config_file = 'configs.yml';
  if (-e $config_file)
  {
    my $configs = YAML::LoadFile( $config_file );
    self->{cfg} = $configs->{slimtimer} if defined( $configs->{slimtimer} );
  }
  self->browser  = LWP::UserAgent->new;
  #self->xmparser = XML::Simple->new;
  self->browser->default_header('Accept'       => 'application/x-yaml');
}

sub test {
  self->browser->get( self->{cfg}{url} );
}


sub login( )
{
  my $yaml = sprintf(qq(---
user:
  email: %s
  password: %s
api_key: %s), self->{cfg}{email}, self->{cfg}{password}, self->{cfg}{api_key});

  my $response = self->post_yaml_data(self->{cfg}{url}{login}, $yaml);
  my $objyaml = YAML::Load( $response->content );
  self->user_id = $objyaml->{user_id};
  self->token   = $objyaml->{access_token};
  $response;
}

sub task_list()
{
  get_yaml_data(self->{cfg}{url}{task_list});
}

sub post_yaml_data ( $url, $data)
{
  my $user_id = self->user_id;
  $url =~ s/user_id/$user_id/ if $user_id;

  my $req = HTTP::Request->new(POST => sprintf('%s%s', self->{cfg}{url}{base}, $url));
  $req->content_type('application/x-yaml');
  $req->content($data);

  my $response = self->browser->request($req);
  $response;
}

sub get_yaml_data ( $url, $data )
{
  my $user_id = self->user_id;
  if ($user_id) {
    $url =~ s/user_id/$user_id/;
    push(@$data, 'api_key'     , self->{cfg}{api_key});
    push(@$data, 'access_token', self->token);
  }

  my $req = HTTP::Request->new(GET =>  sprintf('%s%s', self->{cfg}{url}{base}, $url));
  $req->content_type('application/x-yaml');
  $req->content(*data);

  my $response = self->browser->request($req);
  $response;
}
