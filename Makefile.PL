use inc::Module::Install;

name 'MyBookmark';

all_from 'lib/MyBookmark.pm';

requires "Config::Pit";
requires "Path::Class";
requires "Perl6::Say";
requires "Plack::Request";
requires "Text::Xslate";
requires "Class::Accessor::Lite";
requires "Data::MessagePack";
requires "Digest::MD5";
requires "XML::LibXML";
requires "JSON::XS";
requires "DateTime";
requires "Digest::SHA1";
requires "HTTP::Request";
requires "MIME::Base64";
requires "LWP::UserAgent";
requires "URI";

WriteAll;
