class SignsController < ApplicationController
  require 'digest'
  
  def create
    path = "/home/ubuntu/signs"
    header_payload = params[:message] ? params[:message] : params[:file]
    filename = Digest::MD5.hexdigest(header_payload)
    thumbprint = params[:message] ? ENV['THUMBPRINT'] : ENV['THUMBPRINT_PERSONAL']
    %x(mkdir -p "#{path}")
    if params[:message]
      %x(printf "#{header_payload}" >> "#{path}/#{filename}")
    else
      File.open("#{path}/#{filename}", 'wb'){|f| f.write(Base64.decode64(header_payload))}
    end
    %x(/opt/cprocsp/bin/amd64/cryptcp -signf -dir "#{path}" -cert -detached -thumbprint "#{thumbprint}" -pin "#{ENV['PIN']}" "#{path}/#{filename}")
    sign = File.read("#{path}/#{filename}.sgn").gsub(/\s+/, '')
    send_data({sign: sign}.to_json)
    %x(rm "#{path}/#{filename}")
    %x(rm "#{path}/#{filename}".sgn)
  end
  
  def check
    path = "/home/ubuntu/signs"
    file = params[:file]
    sign = params[:sign]
    filename = Digest::MD5.hexdigest(file)
    signname = Digest::MD5.hexdigest(sign)
    %x(mkdir -p "#{path}")
    File.open("#{path}/#{filename}", 'wb'){|f| f.write(Base64.decode64(file))}
    File.open("#{path}/#{signname}.sgn", 'wb'){|f| f.write(Base64.decode64(sign))}
    result = %x(/opt/cprocsp/bin/amd64/cryptcp -vsign "#{path}/#{filename}").split("\n")
    send_data({result: result[8], author: result[7]}.to_json)
    %x(rm "#{path}/#{filename}")
    %x(rm "#{path}/#{signname}.sgn")
  end
end
