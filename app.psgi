#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use utf8;
use Encode;
use Config::Pit;

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

my $tx = Text::Xslate->new(
    syntax => 'TTerse',
    module => [
        'Text::Xslate::Bridge::TT2Like',
    ],
    function => {
        truncates => sub {
            my ($str, $size, $suffix) = @_;
            $str    = decode_utf8($str || '');
            $size   ||= 64;
            $suffix ||= "...";
            my $b = 0;
            for (my $i = 0; $i < length $str; $i++) {
                $b += length(encode_utf8 substr($str, $i, 1)) == 1 ? 1 : 2;
                return substr($str, 0, $i) . $suffix if $b > $size;
            }
            $str;
        },
        bookmark_page => sub {
            my $url = decode_utf8(shift);
            "http://b.hatena.ne.jp/entry/" . ($url =~ /https?:\/\/(.+)/ ? $1 : $url);
        },
    },
    path => ['template'],
);

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);

    my ($result, $q);

    if ($req->path eq '/') {
        $result = $my_bookmark->list;
    }
    elsif ($req->path eq '/search') {
        $q        = $req->param('q');
        my $sort  = $req->param('sort');
        my $limit = $req->param('limit');
        $result = $my_bookmark->search(
                q     => $q,
                sort  => $sort,
                limit => $limit,
        );
    }
    elsif ($req->path eq '/delete') {
        $result = $my_bookmark->delete($req->param('eid'));
        return [ 200, ["Content-Type" => "text/plain"], ["success"] ] if $result;
    }

    return [ 404, [], [] ] if ! $result;

    my $res = $req->new_response(200);
    $res->content_type('text/html; charset=utf-8');
    $res->body(encode_utf8(
        $tx->render('index.html', {
            components => $result,
            q          => $q,
        })
    ));
    $res->finalize;
};
