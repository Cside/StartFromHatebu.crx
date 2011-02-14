use inc::Module::Install;

name 'MyBookmark';

all_from 'lib/MyBookmark.pm';

requires "Config::Pit";
requires "Text::Xslate";
requires "Text::Xslate::Bridge::TT2Like";
requires "Data::MessagePack";
requires "Class::Accessor::Lite";
requires "JSON::XS";
requires "XML::LibXML";
requires "Path::Class";
requires "Perl6::Say";
requires "Plack::Request";
requires "Digest::MD5";
requires "Digest::SHA1";
requires "HTTP::Request";
requires "MIME::Base64";
requires "DateTime";
requires "LWP::UserAgent";
requires "URI";

WriteAll;
