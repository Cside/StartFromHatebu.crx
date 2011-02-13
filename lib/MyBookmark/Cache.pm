package MyBookmark::Cache;

use strict;
use warnings;
use utf8;
use Encode;
use Class::Accessor::Lite (
    rw => [qw/cache_dir/],
);
use Data::MessagePack;
use Digest::MD5 qw/md5_hex/;
use Path::Class;
use Carp qw/croak/;

our $default_expire = 60 * 60 * 1;

sub new {
    my ($class, %args) = @_;
    croak "needs argument \"cache_dir\"" unless $args{cache_dir};
    my $cache_dir = dir($args{cache_dir});
    if (! defined $cache_dir->stat){
        $cache_dir->mkpath;
    }
    bless {cache_dir => $cache_dir}, $class;
}

sub cache_file {
    my ($self, $key) = @_;
    $self->cache_dir->file(encrypt($key));
}

sub get_or_set {
    my ($self, $key, $cb, $expire) = @_;
    if (my $data = $self->get($key, $expire)) {
        return $data;
    }
    my $result = $cb->();
    $self->set($key, $result);
    $result;
}

sub get {
    my ($self, $key, $expire) = @_;
    my $cache_file = $self->cache_file($key);
    $expire = $default_expire unless $expire;
    return undef if ! defined $cache_file->stat;
    if (time - $cache_file->stat->ctime >= $expire) {
        $cache_file->remove;
        return undef;
    }
    Data::MessagePack->unpack($cache_file->slurp);
}

sub set {
    my ($self, $key, $data) = @_;
    my $cache_file = $self->cache_file($key);
    if (! defined $cache_file->stat) {
        $cache_file->touch;
    }
    my $writer = $cache_file->openw;
    $writer->binmode;
    $writer->print(Data::MessagePack->pack($data));
    $writer->close;
}

# Utils
sub encrypt {
    md5_hex encode_utf8(shift);
}

1;
