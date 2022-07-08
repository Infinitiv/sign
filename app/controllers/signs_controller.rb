class SignsController < ApplicationController
  require 'digest'
  
  def create
    path = "/home/ubuntu/signs"
    header_payload = params[:message] ? params[:message] : params[:file]
    filename = Digest::MD5.hexdigest(header_payload)
    %x(mkdir -p "#{path}")
    if params[:message]
      %x(printf "#{header_payload}" >> "#{path}/#{filename}")
    else
      File.open("#{path}/#{filename}", 'wb'){|f| f.write(Base64.decode64(header_payload))}
    end
    %x(/opt/cprocsp/bin/amd64/cryptcp -signf -dir "#{path}" -cert -detached -thumbprint "#{ENV['THUMBPRINT']}" -pin "#{ENV['PIN']}" "#{path}/#{filename}")
    sign = File.read("#{path}/#{filename}.sgn").gsub(/\s+/, '')
    send_data({sign: sign}.to_json)
    %x(rm "#{path}/#{filename}")
    %x(rm "#{path}/#{filename}".sgn)
  end
end
