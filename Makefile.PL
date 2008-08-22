use inc::Module::Install;

name     'Test-HTTP-Server-Simple-StashWarnings';
all_from 'lib/Test/HTTP/Server/Simple/StashWarnings.pm';

requires 'Test::HTTP::Server::Simple';
test_requires 'WWW::Mechanize';

WriteAll;

