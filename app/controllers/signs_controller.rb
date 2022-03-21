class SignsController < ApplicationController
  require 'digest'
  
  def create
    path = "/home/ubuntu/signs"
    header_payload = params[:message]
    filename = Digest::MD5.hexdigest(header_payload)
    %x(mkdir -p "#{path}")
    %x(echo "#{header_payload}" >> "#{path}/#{filename}")
    %x(/opt/cprocsp/bin/amd64/cryptcp -sign -thumbprint "#{ENV['THUMBPRINT']}" -pin "#{ENV['PIN']}" -cert -detached "#{path}/#{filename}" "#{path}/#{filename}.sig")
#     %x(/opt/cprocsp/bin/amd64/csptest -sfsign -sign -add -detached -base64 -my "#{ENV['THUMBPRINT']}" -password "#{ENV['PIN']}" -in "#{path}/#{filename}" -out "#{path}/#{filename}.sig")
    sign = %x(cat "#{path}/#{filename}.sig").gsub!(/\s+/, '')
    send_data({sign: sign}.to_json)
#     %x(rm "#{path}/#{filename}")
#     %x(rm "#{path}/#{filename}".sig)
  end
end
