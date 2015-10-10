#!/usr/bin/env perl

use strict;
use warnings;
use Mojo::UserAgent;
use JSON::Meth;
use 5.010;

my $mu = Mojo::UserAgent->new;
my $mods = $mu->get('http://modules.perl6.org/')->res->dom;

say "modules.perl6.org currently list " . $mods->find('.name')->size
    . " modules";

$mods = $mods->to_string;

my @eco_mods = split /\n/,  $mu->get('https://raw.githubusercontent.com/perl6/ecosystem/master/META.list')
    ->res->body;

my %seen;
for ( @eco_mods ) {
    next unless $seen{ $_ }++;
    say "$_ is duplicated in ecosystem META.list";
}

say "Found " . @eco_mods . " modules listed in ecosystem. "
    . "Going to fetch each one (this will take a while)";

%seen = ();
for ( @eco_mods ) {
    my $res = $mu->get( $_ )->res;
    if ( $res->code != 200 ) {
        say "Failed to fetch $_: " . $res->code;
        next;
    }

    my $name = eval { $res->body->$j->{name} };
    if ( $@ ) { say "JSON decode error while doing $_\n"; next; }
    unless ( $name ) { say "$_ doesn't have a `name`!\n"; next; }

    say "$_ has the same name [$name] as $seen{$name}!\n"
        if defined $seen{$name};
    $seen{$name} = $_;

    say "$_ [$name] not found on modules.perl6.org!\n"
        unless $mods =~ /\Q$name\E/;
}

say "All done!";
