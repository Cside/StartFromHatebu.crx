use inc::Module::Install;

name 'MyBookmark';

all_from 'lib/MyBookmark.pm';

requires "Plack::Request";
requires "Plack::Runner";

requires "Config::Pit";

requires "Text::Xslate";
requires "Text::Xslate::Bridge::TT2Like";

requires "Data::MessagePack";

requires "Class::Accessor::Lite";

requires "JSON::XS";
requires "XML::LibXML";

requires "Digest::MD5";
requires "Digest::SHA1";
requires "MIME::Base64";

requires "Path::Class";
requires "Perl6::Say";
requires "URI";
requires "DateTime";
requires "LWP::UserAgent";
requires "HTTP::Request";

WriteAll;
