require 'drb'

DRb.start_service

def get_status
  DRbObject.new nil, 'druby://127.0.0.1:2999'
end
