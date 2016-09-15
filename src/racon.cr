require "kemal"
require "pg"
require "pool/connection"

require "./racon/**"

require "baked_file_system"

class Racon::FileStorage
  BakedFileSystem.load("public", __DIR__)
end

Racon::FileStorage.files.each do |file|
  get(file.path) do |env|
    env.response.content_type = file.mime_type
    _file = Racon::FileStorage.get(file.path)
    if env.request.headers["Accept-Encoding"]? =~ /gzip/
      env.response.headers["Content-Encoding"] = "gzip"
      env.response.content_length = _file.compressed_size
      _file.write_to_io(env.response, compressed: true)
    else
      env.response.content_length = _file.size
      _file.write_to_io(env.response, compressed: false)
    end
  end
end

macro ecr(xxx)
  {% if xxx.starts_with?('_') %}
    render "#{{{__DIR__}}}/views/#{{{xxx}}}.html.ecr"
  {% else %}
    render "#{{{__DIR__}}}/views/#{{{xxx}}}.html.ecr", "#{{{__DIR__}}}/views/layout.html.ecr"
  {% end %}
end

def add_resource_to_routes(racon, db, resource)
  delete "/#{resource.table_name}/:id" do |env|
    id = env.params.url["id"]

    db.connect do |conn|
      data = resource.destroy(conn, id)
    end
    env.redirect "/" + resource.table_name + "/"
  end

  get "/#{resource.table_name}" do |env|
    table_name = resource.table_name

    num = env.params.query["page"]?
    num = (num.is_a? Nil) ? 1 : num.to_i
    pagination = Helper.pagination(resource.total_count, resource.per_page, num)

    id = nil
    data = nil

    db.connect do |conn|
      data = resource.from_table_page(conn, num)
    end

    ecr("index")
  end

  get "/#{resource.table_name}/:id" do |env|
    table_name = resource.table_name

    id = env.params.url["id"]
    data = nil

    db.connect do |conn|
      data = resource.find_by_id(conn, id)
    end

    ecr("show")
  end

  get "/#{resource.table_name}/new" do |env|
    table_name = resource.table_name

    id = nil
    data = nil

    ecr("new")
  end

  post "/#{resource.table_name}/" do |env|
    attrs = env.params.body.to_h.select(resource.field_names)

    db.connect do |conn|
      data = resource.create(conn, attrs)
    end
    env.redirect "/" + resource.table_name
  end

  get "/#{resource.table_name}/:id/edit" do |env|
    table_name = resource.table_name

    id = env.params.url["id"]
    data = nil

    db.connect do |conn|
      data = resource.find_by_id(conn, id)
    end

    ecr("edit")
  end

  put "/#{resource.table_name}/:id" do |env|
    id = env.params.url["id"]

    attrs = env.params.body.to_h.select(resource.field_names)

    db.connect do |conn|
      data = resource.update(conn, id, attrs)
    end
    env.redirect "/" + resource.table_name + "/" + id
  end
end
