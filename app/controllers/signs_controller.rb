class SignsController < ApplicationController
  require 'digest'
  
  def create
    path = "/home/ubuntu/signs"
    header_payload = params[:message]
    filename = Digest::MD5.hexdigest(header_payload)
    %x(mkdir -p "#{path}")
    %x(echo "#{header_payload}" >> "#{path}/#{filename}")
#     %x(/opt/cprocsp/bin/amd64/cryptcp -signf -dir "#{path}" -cert -detached -thumbprint "#{ENV['THUMBPRINT']}" -pin "#{ENV['PIN']}" "#{path}/#{filename}")
#     sign = %x(cat "#{path}/#{filename}.sgn").gsub!(/\s+/, '')
#     send_data({sign: sign}.to_json)
    %x(/opt/cprocsp/bin/amd64/csptest -sfsign -sign -add -base64 -password "#{ENV['PIN']}" -in "#{path}/#{filename}" -out "#{path}/#{filename}.sig" -my "#{ENV['THUMBPRINT']}")
    sign = %x(cat "#{path}/#{filename}.sig").gsub!(/\s+/, '')
    send_data({sign: sign}.to_json)
#     %x(rm "#{path}/#{filename}")
#     %x(rm "#{path}/#{filename}".sgn)
  end
end
