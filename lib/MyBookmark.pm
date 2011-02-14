package MyBookmark;
use strict;
use warnings;

use Encode;
use MyBookmark::Request::WSSE;
use MyBookmark::Parser;
use MyBookmark::Cache;
use URI;
use Class::Accessor::Lite (
    ro => [ qw(username password) ],
    rw => [ qw(ua_wsse cache) ],
);

sub new {
    my ($class, %args) = @_;
    my $self = bless \%args, $class;

    my $ua = MyBookmark::Request::WSSE->new;
    $ua->credentials( $self->username, $self->password );
    $self->ua_wsse($ua);

    my $cache = MyBookmark::Cache->new(cache_dir => "$ENV{HOME}/.mycache");
    $self->cache($cache);

    $self;
}

sub list {
    my ($self) = @_;

    $self->cache->get_or_set('mylist', sub {
        my $res = $self->ua_wsse->request(GET => 'http://b.hatena.ne.jp/atom/feed');
        MyBookmark::Parser::parse_xml(decode_utf8 $res->content)
    }, 60 * 60 * 1);
}

sub search {
    my ($self, %args) = @_;
    my $q     = $args{q}     || '';
    my $sort  = $args{sort}  || 'date' ;
    my $limit = $args{limit} || '20';
    my $uri = URI->new('http://b.hatena.ne.jp/' . $self->username . '/search/json');
    $uri->query_form(
        q     => $q,
        sort  => $sort,
        limit => $limit,
    );

    $self->cache->get_or_set(join('/', $q, $sort, $limit), sub {
        my $res = $self->ua_wsse->request( GET => $uri->as_string );
        MyBookmark::Parser::parse_json(decode_utf8 $res->content)
    }, 60 * 60 * 1);
}

sub delete {
    my ($self, $eid) = @_;
    my $res = $self->ua_wsse->request(DELETE => 'http://b.hatena.ne.jp/atom/edit/' . $eid);
    $res ? 1 : undef;
}

1;

