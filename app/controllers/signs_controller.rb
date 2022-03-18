class SignsController < ApplicationController
  require 'digest'
  
  def create
    path = "/home/ubuntu/signs"
    header_payload = params[:message]
    filename = Digest::MD5.hexdigest(header_payload)
    %x(mkdir -p "#{path}")
    %x(echo "#{header_payload}" >> "#{path}/#{filename}")
    %x(/opt/cprocsp/bin/amd64/cryptcp -signf -dir "#{path}" -thumbprint "#{ENV['THUMBPRINT']}" -pin "#{ENV['PIN']}" -hashalg 1.2.643.7.1.1.2.2 -detached "#{path}/#{filename}")
    sign = %x(cat "#{path}/#{filename}.sgn").gsub!(/\s+/, '')
    send_data({sign: sign}.to_json)
    %x(rm "#{path}/#{filename}")
    %x(rm "#{path}/#{filename}".sgn)
  end
end
