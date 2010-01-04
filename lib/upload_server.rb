require 'rubygems'
require 'fastthread'
require 'drb'
require 'gem_plugin'
GemPlugin::Manager.instance.load 'mongrel' => GemPlugin::INCLUDE
DRb.start_service 'druby://127.0.0.1:2999', Mongrel::UploadProgress.new
DRb.thread.join