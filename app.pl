#!/usr/bin/perl

use Mojolicious::Lite;
use Data::Dumper;

# Set app mode to production is running on IIS
if( $ENV{APP_POOL_ID} ) {
  app->mode('production');
}

# Setup sessions
app->secrets(['SessionTest']);
app->sessions->cookie_domain('.example.com');
app->sessions->cookie_name('sessiontest');
# app->sessions->default_expiration(157248000);

helper logw => sub {
  my $c = shift;
  my $text = shift;

  unless( app->mode eq 'production' ) {
    $c->app->log->info($text);
  }

  return undef;
};

helper testvar => sub {
  my $c = shift;
  
  if($c->session('testvar')) {
    $c->logw("testvar found");
    return 1;
  } else {
    $c->logw("testvar not found");
  }

  return undef;
};

# setup base route
get '/' => sub {
  my $c = shift;
  $c->logw("/");
  
  if($c->testvar) {
    $c->logw("routing to session");
    $c->redirect_to('/session');
    return;
  }

  $c->logw("render index");
  $c->render(template => 'index');
};

get '/session' => sub {
  my $c = shift;
  $c->logw("/session");
  
  if(!$c->testvar) {
    $c->logw("routing to root");
    $c->redirect_to('/');
    return;
  }

  $c->logw("render session");
  $c->render(template => 'session');
};

get '/set' => sub {
  my $c = shift;
  
  $c->logw("set testvar");
  $c->session(testvar => 1);
  $c->redirect_to('/');
};

get '/remove' => sub {
  my $c = shift;
  
  $c->logw("expire session");
  $c->session(expires => 1);
  $c->redirect_to('/');
};

app->start();

__DATA__

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head>
    <title><%= title %></title>
  </head>
  <body>
  <%= content %>
  </body>
</html>

@@ index.html.ep
% layout 'default';

<%= link_to url_for('/set')->to_abs => begin %>Set<% end %>

@@ session.html.ep
% layout 'default';

<%= link_to url_for('/remove')->to_abs => begin %>Remove<% end %>