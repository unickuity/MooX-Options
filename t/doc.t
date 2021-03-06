#!perl
use strict;
use warnings;
use Test::More;
use Test::Trap;
use Carp;
use FindBin qw/$RealBin/;
use Try::Tiny;

{

    package t;
    use Moo;
    use MooX::Options;

    option 't' => (
        is            => 'ro',
        documentation => 'this is a test',
    );

    1;
}

{

    package t1;
    use Moo;
    use MooX::Options;

    option 't' => (
        is            => 'ro',
        doc           => 'this pass first',
        documentation => 'this is a test',
    );

    1;
}

{

    package t2;
    use Moo;
    use Test::More;

    sub filter_opt {
        my ( $attr, %opt ) = @_;

        ok !defined $opt{doc},          'doc has been filtered';
        ok defined $opt{documentation}, 'documentation has been keeped';

        return has( $attr, %opt );
    }

    use MooX::Options option_chain_method => 'filter_opt';

    option 't' => (
        is            => 'ro',
        doc           => 'this pass first',
        documentation => 'this is a test',
    );

    1;
}

{
    my $opt = t->new_with_options;
    trap { $opt->options_usage };
    ok $trap->stdout =~ /\s+\-t\s+this\sis\sa\stest/x, 'documentation work';
}

{
    my $opt = t1->new_with_options;
    trap { $opt->options_usage };
    ok $trap->stdout =~ /\s+\-t\s+this\spass\sfirst/x, 'doc pass first';
}

{
    my $opt = t2->new_with_options;
    trap { $opt->options_usage };
    ok $trap->stdout =~ /\s+\-t\s+this\spass\sfirst/x, 'doc pass first';
}

done_testing;
