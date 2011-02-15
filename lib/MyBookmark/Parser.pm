package MyBookmark::Parser;
use strict;
use warnings;

use utf8;
use Encode;
use XML::LibXML;
use JSON::XS;

sub parse_json {
    my ($content) = @_;
    my $doc = decode_json($content);
    my $result = [];
    for my $entry (@{$doc->{bookmarks}}) {
        my (undef, undef, $hour, $mday, $mon, $year) = localtime($entry->{timestamp});
        push @$result, {
            title => $entry->{entry}->{title},
            link  => $entry->{entry}->{url},
            eid   => $entry->{entry}->{eid},
            date  => sprintf("%4d-%02d-%02d", $year + 1900, $mon + 1, $mday),
        };
    }
    $result;
}

sub parse_xml {
    my ($content) = @_;
    my $doc = XML::LibXML->new->parse_string(decode_utf8 $content);
    my $result = [];
    for my $entry ($doc->getElementsByTagName('entry')) {
        my $title = ($entry->getElementsByTagName('title') )[0]->textContent;
        my $date  = substr(($entry->getElementsByTagName('issued'))[0]->textContent, 0, 10);
        my $link;
        my $eid;
        for my $l ($entry->getElementsByTagName('link')) {
            my $rel = $l->getAttribute('rel');
            $link = $l->getAttribute('href')             if $rel eq 'related';
            $eid  = substr($l->getAttribute('href'), 32) if $rel eq 'service.edit';
        }
        push @$result, {
            title => $title,
            link  => $link,
            eid   => $eid,
            date  => $date,
        };
    }
    $result;
}

1;
