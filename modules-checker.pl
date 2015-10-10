#!/usr/bin/env perl

use strict;
use warnings;
use Mojo::UserAgent;
use JSON::Meth;
use Mojo::DOM;
use 5.010;

my ( $REPO_URL, $SITE_URL ) = qw{
    https://raw.githubusercontent.com/perl6/ecosystem/master/META.list
    http://modules.perl6.org/
};

my $mods     = get_site_mods( $SITE_URL );
my @eco_mods = get_eco_mods( $REPO_URL );

check_empty_github_urls( $mods );
check_duplicate_eco_mods( @eco_mods );

my %seen;
my $mu = Mojo::UserAgent->new;
for ( @eco_mods ) {
    my $res = $mu->get( $_ )->res;
    if ( $res->code != 200 ) {
        say "Failed to fetch $_: " . $res->code;
        next;
    }

    my $name = eval { $res->body->$j->{name} };
    if ( $@ ) { say "JSON decode error while doing $_"; next; }
    unless ( $name ) { say "$_ doesn't have a `name`!"; next; }

    say "$_ has the same name [$name] as $seen{$name}!"
        if defined $seen{$name};
    $seen{$name} = $_;

    say "$_ [$name] not found on modules.perl6.org!"
        unless $mods =~ /\Q$name\E/;
}

say "All done!";

############### SUBS

sub check_empty_github_urls {
    my $page = shift;

    my $empties = Mojo::DOM->new( $page )
        ->find('[href="https://github.com///"]')
        ->to_array;

    for ( @$empties ) {
        say $_->all_text . ' is listed with an empty GitHub URL';
    }
}

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

    my @eco_mods = split /\n/, Mojo::UserAgent->new
        ->get( $repo_url )->res->body;

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