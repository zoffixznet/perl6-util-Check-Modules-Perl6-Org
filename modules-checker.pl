#!/usr/bin/env perl

use strict;
use warnings;
use Mojo::UserAgent;
use JSON::Meth;
use 5.010;

my ( $REPO_URL, $SITE_URL ) = qw{
    https://raw.githubusercontent.com/perl6/ecosystem/master/META.list
    http://modules.perl6.org/
};

my $mods     = get_site_mods( $SITE_URL );
my @eco_mods = get_eco_mods( $REPO_URL );
check_duplicate_eco_mods( @eco_mods );

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

############### SUBS

sub check_duplicate_eco_mods {
    my @mods = @_;

    my %seen;
    for ( @mods ) {
        next unless $seen{ $_ }++;
        say "$_ is duplicated in ecosystem META.list";
    }
}

sub get_eco_mods {
    my $repo_url = shift;

    my @eco_mods = split /\n/,  $mu->get( $repo_url )->res->body;
    say "Found " . @eco_mods . " modules listed in ecosystem.";
    return @eco_mods;
}

sub get_site_mods {
    my $site_url = shift;

    my $mods = Mojo::UserAgent->new->get( $site_url )->res->dom;
    say "modules.perl6.org currently list " . $mods->find('.name')->size
        . " modules";

    return $mods->to_string;
}