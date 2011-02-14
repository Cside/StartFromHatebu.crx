#!/Users/cside/perl5/perlbrew/bin/perl

use strict;
use warnings;
use lib 'lib';
use utf8;
use Encode;
use Config::Pit;
use Path::Class;

use Perl6::Say;
use MyBookmark;
use Plack::Request;

use Text::Xslate;

my $config = pit_get(
    'hatena.ne.jp',
    require => {
        username => 'your username on Hatena',
        password => 'your password on Hatena',
    },
);

my $my_bookmark = MyBookmark->new(
    username => $config->{username},
    password => $config->{password},
);

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);

    my ($result, $q);

    if ($req->path eq '/') {
        $result = $my_bookmark->list;
    } elsif ($req->path eq '/search') {
        $q        = $req->param('q');
        my $sort  = $req->param('sort');
        my $limit = $req->param('limit');
        $result = $my_bookmark->search(
                q     => $q,
                sort  => $sort,
                limit => $limit,
        );
    } elsif ($req->path eq '/delete') {
        $result = $my_bookmark->delete($req->param('eid'));
        return (defined $result)
            ? [ 200, ["text/html; charset=utf-8"], ["success"]]
            : [ 404, [], []];
    }
    my $res = $req->new_response($result ? 200 : 404);
    $res->content_type('text/html; charset=utf-8');
    $res->body(encode_utf8(render(
        components => $result ne 'empty' ? $result : [],
        q => $q
    )));
    $res->finalize;
};

sub render {
    my $tx = Text::Xslate->new(
        syntax => 'TTerse',
        module => [
            'URI::Escape',
            'Encode' => ['encode_utf8'],
            'Text::Xslate::Bridge::TT2Like',
        ],
        function => {
            truncates => sub {
                my ($str, $size, $suffix) = @_;
                $str = decode_utf8($str);
                $str    = ''    unless $str;
                $size   = 64    unless $size;
                $suffix = "..." unless $suffix;
                my $b = 0;
                for (my $i = 0; $i < length $str; $i++) {
                    $b += length(encode_utf8 substr($str, $i, 1)) == 1 ? 1 : 2;
                    if ($b > $size) {
                        return substr($str, 0, $i) . $suffix;
                    }
                }
                encode_utf8 $str;
            },
            bookmark_page => sub {
                my $url = decode_utf8(shift);
                encode_utf8(
                    "http://b.hatena.ne.jp/entry/" . ($url =~ /https?:\/\/(.+)/ ? $1 : $url)
                );
            },
        },
    );
    my $template = decode_utf8(scalar file('template/index.html')->slurp);
    my $result = $tx->render_string(
        $template,
        { @_ },
    );
}

$app;
