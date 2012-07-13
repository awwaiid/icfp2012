#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use lib 'lib';

use Plack::Request;
use JSON::XS;
use Lifter;

my $map;
my $position;

my $app = sub {
  my $req = Plack::Request->new(shift);
  if(!$map) {
    my $mapname = $req->param('map');
    $map = Lifter::load_map("map/$mapname");
  }
  return [
    200,
    ['Content-type' => 'text/json'],
    [
      encode_json({
        map => $map,
      })
    ]
  ];
};

return $app;

