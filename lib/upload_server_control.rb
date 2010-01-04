require 'rubygems'
require 'daemons'

Daemons.run('lib/upload_server.rb')