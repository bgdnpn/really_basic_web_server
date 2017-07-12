require 'socket'

WEBROOT = "/var/www/static"
HEADER = "HTTP/1.1 %s\r\nContent-Type: %s\r\nContent-Length: %s\r\n\r\n"
CONTENT_TYPE_MAPPING = {
  'html' => 'text/html',
  'txt' => 'text/plain',
  'png' => 'image/png',
  'jpg' => 'image/jpeg'
}

def runserver(host="localhost", port=3000)
  Socket.tcp_server_loop(host, port) do |client|
    fork do
      handle_client client
    end
    client.close
  end
end

def handle_client(c)
  _, req, _ = c.gets.split " "
  build_response(req).each do |el|
    c.puts el
  end
  c.close
end

def build_response(r)
  path = get_path_or_index r
  type = CONTENT_TYPE_MAPPING[path.split(".").last]
  begin
    body = File.open(path).read
    header = HEADER % ["200 OK", type, body.bytesize]
  rescue
    body = "body not found. 404. bye"
    header = HEADER % ["404 NOT FOUND", "text/html", body.bytesize]
  end
  return header, body
end

def get_path_or_index(r)
  if r == "/" or r.include?("..") then
    path = WEBROOT + "/index.html"
  else
    path = WEBROOT + r
  end
end

runserver

