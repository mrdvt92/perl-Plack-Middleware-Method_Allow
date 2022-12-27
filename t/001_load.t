use strict;
use warnings;
use Test::More tests => 53;
use HTTP::Request;
use Plack::Builder qw{builder enable};
use Plack::Test;
BEGIN { use_ok('Plack::Middleware::Method_Allow') };

my $obj = Plack::Middleware::Method_Allow->new;
can_ok($obj, 'call');
can_ok($obj, 'allow');
isa_ok($obj, 'Plack::Middleware::Method_Allow');
isa_ok($obj, 'Plack::Middleware');
isa_ok($obj->allow, 'ARRAY', 'allow');
is(scalar(@{$obj->allow}), 0, 'allow');
isa_ok($obj->allow(['foo']), 'ARRAY', 'allow');
is(scalar(@{$obj->allow}), 1, 'allow');

foreach my $ref ('foo', 0, '', {}, (\my $x), (bless []), (bless {})) {
  local $@;
  eval{$obj->allow($ref)};
  my $error = $@;
  ok($error, 'allow dies with bad data');
  like($error, qr/Syntax/, 'allow with '. ref($ref));
}

{
  my $app  = builder {
       enable 'Plack::Middleware::Method_Allow', allow => ['GET'];
       sub {return [ 200, [], ['OK']]};
     };
  my $test = Plack::Test->create($app);

  {
    my $res = $test->request(HTTP::Request->new(GET => '/'));
    ok($res->is_success, 'success');
    is($res->code, 200, 'http code');
    is($res->content, 'OK', 'content');
  }

  {
    my $res = $test->request(HTTP::Request->new(POST => '/'));
    ok(!$res->is_success, 'fail');
    is($res->code, 405, 'http code');
    is($res->content, 'Method Not Allowed', 'content');
  }
}

{
  my $app  = builder {
       enable 'Plack::Middleware::Method_Allow'; #default allow=>[] = allow nothing!
       sub {return [ 200, [], ['OK']]};
     };
  my $test = Plack::Test->create($app);

  foreach my $method (qw{GET POST PUT HEAD foo bar}) {
    my $res = $test->request(HTTP::Request->new($method => '/'));
    ok(!$res->is_success, "fail: $method");
    is($res->code, 405, 'http code');
    is($res->content, 'Method Not Allowed', 'content');
  }
}

{
  local $@;
  my $app  = eval{
     builder {
       enable 'Plack::Middleware::Method_Allow', allow=>{bad=>'call'}; #bad syntax
       sub {return [ 200, [], ['OK']]};
     }
  };
  my $error = $@;
  ok($error, 'building app dies');
  like($error, qr/Syntax/, 'error ok');
}

{
  local $@;
  my $app  = eval{
     builder {
       enable 'Plack::Middleware::Method_Allow', allow=>'BAD'; #bad syntax
       sub {return [ 200, [], ['OK']]};
     }
  };
  my $error = $@; #Error: Syntax `enable 'Plack::Middleware::Method_Allow', allow=>['METHOD', ...]`
  ok($error, 'building app dies');
  like($error, qr/Syntax/, 'error ok');
}

{
  my $scalar = '';
  local $@;
  my $app  = eval{
     builder {
       enable 'Plack::Middleware::Method_Allow', allow=>\$scalar; #bad syntax
       sub {return [ 200, [], ['OK']]};
     }
  };
  my $error = $@;
  ok($error, 'building app dies');
  like($error, qr/Syntax/, 'error ok');
}
