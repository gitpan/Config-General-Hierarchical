# testscript for Config::General::Hierarchical::Dump module
#
# needs to be invoked using the command "make test" from
# the Config::General::Hierarchical source directory.
#
# under normal circumstances every test should succeed.

my $tests;
my $skip;

BEGIN {
    $tests = 41;
}

use Test::More tests => $tests;
use Test::Differences;

require_ok Config::General::Hierarchical::Dump;
require_ok Config::General::Hierarchical::DumpTest;

`perl -e '' 2> /dev/null`;
$skip = $?;

SKIP: {
    skip "perl executable can't be found", $tests - 3 if $skip;

    is( `t/dump.conf`, <<EOF, 'self execution' );
defined = '';
node->key = 'value';
node->keys = '';
variable = 'value';
EOF

    like(
        Config::General::Hierarchical::Dump->do_all( 't/dump_error.conf', [] ),
qr{Parsing error: Config::General::Hierarchical: Config::General: Block "<node>" has no EndBlock statement \(level: 2, chunk 1\)\!\nin file: (/[^/]+)+/t/dump_error.conf\n  at (/[^/]+)+/Hierarchical/Dump.pm line \d+\n$},
        'parse error'
    );

    is(
        join( '',
            Config::General::Hierarchical::Dump->do_all( 't/dump.conf', [] ) ),
        <<EOF, 'execution' );
defined = '';
node->key = 'value';
node->keys = '';
variable = 'value';
EOF

    my $path = "(/[^/]+)+/t/";
    my @out =
      Config::General::Hierarchical::Dump->do_all( 't/dump.conf', ['-f'] );
    like( $out[0], qr{Configuration files base dir: $path}, '-f 1' );
    like( $out[1], qr{defined = ''; dump.conf},             '-f 2' );
    like( $out[2], qr{node->key = 'value'; dump.conf},      '-f 3' );
    like( $out[3], qr{node->keys = ''; dump.conf},          '-f 4' );
    like( $out[4], qr{variable = 'value'; dump.conf},       '-f 5' );

    @out =
      Config::General::Hierarchical::Dump->do_all( 't/dump.conf', ['-fl'] );
    like( $out[0], qr{Configuration files base dir: $path}, '-fl 1' );
    like( $out[1], qr{defined    = '';      dump.conf},     '-fl 2' );
    like( $out[2], qr{node->key  = 'value'; dump.conf},     '-fl 3' );
    like( $out[3], qr{node->keys = '';      dump.conf},     '-fl 4' );
    like( $out[4], qr{variable   = 'value'; dump.conf},     '-fl 5' );

    @out = Config::General::Hierarchical::Dump->do_all( 't/dump.conf', ['-l'] );
    like( $out[0], qr{defined    = '';},      '-l 1' );
    like( $out[1], qr{node->key  = 'value';}, '-l 2' );
    like( $out[2], qr{node->keys = '';},      '-l 3' );
    like( $out[3], qr{variable   = 'value';}, '-l 4' );

    is(
        join(
            '',
            Config::General::Hierarchical::Dump->do_all(
                't/dump.conf', ['-h']
            )
        ),
        <<EOF, '-h' );
Usage: t/99_dump.t
Dumps the Config::General::Hierarchical configuration file itself

 -c, --check          if present, prints only the variables that do
                      not respect syntax constraint
 -f, --file           shows in which file variables are defined
 -l, --fixed-length   formats output as fixed length fields
 -h, --help           prints this help and exits
 -j, --json           prints output as json
EOF

    is( `t/dir/dump_inherits.conf`, <<EOF, 'inherited self execution' );
array = ( '1', '2' );
defined = 'really defined';
node->array = ( 's1', 's2' );
node->key = undef;
node->value = error;
value = error;
EOF

    is(
        join(
            '',
            Config::General::Hierarchical::DumpTest->do_all(
                't/dir/dump_inherits.conf', ['-l']
            )
        ),
        <<EOF, 'execution 2' );
array       = ( '1', '2' );
defined     = 'really defined';
node->array = ( 's1', 's2' );
node->key   = undef;
node->value = error;
value       = error;
EOF

    @out = Config::General::Hierarchical::DumpTest->do_all(
        't/dir/dump_inherits.conf', ['-fl'] );
    like( $out[0], qr{Configuration files base dir: $path}, '-fl 2 1' );
    like( $out[1], qr{Files inheritance structure:},        '-fl 2 2' );
    like( $out[2], qr{dir/dump_inherits.conf},              '-fl 2 3' );
    like( $out[3], qr{  dump_inherited.conf},               '-fl 2 4' );
    like( $out[4], qr{array       = \( '1', '2' \);     dir/dump_inherits.conf},
        '-fl 2 5' );
    like( $out[5], qr{defined     = 'really defined'; dump_inherited.conf},
        '-fl 2 6' );
    like( $out[6], qr{node->array = \( 's1', 's2' \);   dump_inherited.conf},
        '-fl 2 7' );
    like( $out[7], qr{node->key   = undef;            dir/dump_inherits.conf},
        '-fl 2 8' );
    like( $out[8], qr{node->value = error;            dir/dump_inherits.conf},
        '-fl 2 9' );
    like( $out[9], qr{value       = error;            dir/dump_inherits.conf},
        '-fl 2 10' );
    is( scalar @out, 10, '-fl 2 11' );

    is(
        Config::General::Hierarchical::DumpTest->do_all(
            't/dir/dump_inherits.conf', ['-j']
        ),
'{"array":["1","2"],"defined":"really defined","node":{"array":["s1","s2"],"key":null,"value":"error"},"value":"error"}',
        '-j'
    );

    is(
        join(
            '',
            Config::General::Hierarchical::DumpTest->do_all(
                't/dir/dump_inherits.conf', ['-c']
            )
        ),
        "node->value = error;\nvalue = error;\n",
        '-c'
    );

    is(
        join(
            '',
            Config::General::Hierarchical::Dump->do_all(
                't/dump_eof.conf', ['-l']
            )
        ),
"var1 = <<EOF;\na\nb\nc//--new line added\nEOF\nvar2 = <<EOF;\na\nb\nEOF\n",
        'eof'
    );

    eq_or_diff(
        [
            unpack 'C*',
            join(
                '',
                Config::General::Hierarchical::Dump->do_all(
                    't/dump_substitutions.conf', ['']
                )
            )
        ],
        [
            118, 32, 61, 32, 39,  36, 92, 7, 8, 12,
            13,  9,  11, 92, 100, 39, 59, 10
        ],
        'subs'
    );

    is(
        join(
            '',
            Config::General::Hierarchical::DumpTest->do_all(
                't/dump_substitutions2.conf', ['-l']
            )
        ),
        "node->array = *;\n* = ( 'a\nb', 'a\nb\n' );\nnode->key   = 'ab';\n",
        'subs 2'
    );

    is( `t/import.conf`, <<EOF, 'import param 1' );
defined = '';
node->key = 'value';
node->keys = '';
value = error;
variable = 'value';
EOF

    is(
        join(
            '',
            Config::General::Hierarchical::Dump->do_all(
                't/import.conf', [], 'Config::General::Hierarchical::Test'
            )
        ),
        <<EOF, 'import param 2' );
defined = '';
node->key = 'value';
node->keys = '';
value = error;
variable = 'value';
EOF

}

package other;

use Test::More;

use_ok Config::General::Hierarchical::Dump;

package main;

$0 = '';

use_ok Config::General::Hierarchical::Dump;

ok( 0, 'not execute' );
