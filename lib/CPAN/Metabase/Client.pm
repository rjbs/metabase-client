use 5.006;
use strict;
use warnings;
package CPAN::Metabase::Client;

=head1 NAME

CPAN::Metabase::Client - a HTTP client for CPAN Metabase servers

=cut

our $VERSION = '0.001';

use HTTP::Request::Common ();
use JSON::XS;
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

  my $path = sprintf 'submit/dist/%s/%s/%s',
    $fact->dist_author,
    $fact->dist_file,
    $fact->type;

  my $req_url = $self->abs_url($path);

  my $req = HTTP::Request::Common::POST(
    $req_url,
    Content_Type => 'text/x-json',
    Accept       => 'text/x-json',
    Content => JSON::XS->new->encode({
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

sub search_stuff {
  my ($self, @args) = @_;

  my $req_url = $self->abs_url("search/" . join '/', @args);

  my $req = HTTP::Request::Common::GET(
     $req_url,
    'Accept' => 'text/x-json',
  );

  $self->http_request($req);
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
