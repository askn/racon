require "./racon/*"

require "kemal"
require "pg"
require "pool/connection"

require "./views/*"

serve_static false
add_handler Kemal::StaticFileHandler.new "./public"

add_handler Kemal::StaticFileHandler.new "./node_modules/jquery/dist"
add_handler Kemal::StaticFileHandler.new "./node_modules/what-input"
add_handler Kemal::StaticFileHandler.new "./node_modules/foundation-sites/dist"

get "/" do
  render "src/views/index.html.ecr", "src/views/layout.html.ecr"
end

Kemal.run
