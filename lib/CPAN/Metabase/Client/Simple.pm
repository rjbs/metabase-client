use 5.006;
use strict;
use warnings;
package CPAN::Metabase::Client::Simple;

=head1 NAME

CPAN::Metabase::Client::Simple - a client that submits to CPAN Metabase servers

=cut

our $VERSION = '0.001';

use HTTP::Request::Common ();
use JSON 2;
use Params::Validate;
use LWP::UserAgent;
use URI;

my @valid_args;
BEGIN { @valid_args = qw(user key url) };
use Object::Tiny @valid_args;

sub new {
  my ($class, @args) = @_;

  my %args = Params::Validate::validate(
    @args,
    { map { $_ => 1 } @valid_args }
  );

  my $self = bless \%args, $class;

  return $self;
}   

sub http_request {
  my ($self, $request) = @_;
  LWP::UserAgent->new->request($request);
}

sub submit_fact {
  my ($self, $fact) = @_;

  my $path = sprintf 'submit/%s/dist/%s/%s/',
    $fact->type,
    $fact->dist_author,
    $fact->dist_file;

  my $req_url = $self->abs_url($path);

  my $req = HTTP::Request::Common::POST(
    $req_url,
    Content_Type => 'text/x-json',
    Accept       => 'text/x-json',
    Content => JSON->new->encode({
      version => $fact->schema_version,
      content => $fact->content_as_string,
    })
  );

  # Is it reasonable to return an HTTP::Response?  I don't know.  For now,
  # let's say yes.
  my $response = $self->http_request($req);
}

sub retrieve_fact {
  my ($self, $guid) = @_;

  my $req_url = $self->abs_url("guid/$guid");

  my $req = HTTP::Request::Common::GET(
     $req_url,
    'Accept' => 'text/x-json',
  );

  $self->http_request($req);
}

sub search {
  my ($self, $method, $args) = @_;

  my $req_url = $self->abs_url("search/" . join('/', $method, @$args));

  my $req = HTTP::Request::Common::GET(
     $req_url,
    'Accept' => 'text/x-json',
  );

  my $res = $self->http_request($req);

  die { response => $res } unless $res->is_success;

  my $results = JSON->new->allow_nonref(1)->decode($res->content);
  return ref $results ? @$results : ();
}

sub abs_url {
  my ($self, $str) = @_;
  my $req_url = URI->new($str)->abs($self->url);
}

=head1 LICENSE

Copyright (C) 2008, Ricardo SIGNES.

This is free software, available under the same terms as perl itself.

=cut

1;
