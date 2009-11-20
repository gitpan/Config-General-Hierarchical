package MyConfigDump;
use base 'Config::General::Hierarchical::Dump';
use MyConfig;
sub parser { return 'MyConfig' };
1;
