package MyBookmark::Request::WSSE;
use strict;
use warnings;

use DateTime;
use Digest::SHA1 qw (sha1);
use HTTP::Request;
use MIME::Base64 qw (encode_base64);
use LWP::UserAgent;
use Carp;
use utf8;

use Class::Accessor::Lite (
    new => 1,
    rw =>[ qw(header) ],
);

sub credentials {
    my ($self, $username, $password) = @_;

    my $nonce       = sha1(sha1(time() . {} . rand() . $$));
    my $now         = DateTime->now->iso8601 . 'Z';
    my $digest      = encode_base64(sha1($nonce . $now . $password || ''), '');
    my $credentials = sprintf(
        qq(UsernameToken Username="%s", PasswordDigest="%s", Nonce="%s", Created="%s"),
        $username, $digest,  encode_base64($nonce, ''), $now
    );

    $self->header($credentials);
}

sub request {
    my ($self, %args) = @_;

    my $req = HTTP::Request->new(%args);
    $req->header( Accept => 'application/x.atom+xml, application/xml, text/xml, */*');
    $req->header( 'X-WSSE' => $self->header );
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    my $res = $ua->request($req);
    $res->is_success ? $res : undef;
}

1;
