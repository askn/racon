module Helper
  extend self

  def pagination(total, per, current)
    page_count = total / per
    page_count += 1 unless page_count*per == total

    pages = [] of Int32

    if current > 3
      pages += ((current - 3)...current).to_a
    else
      pages += (1...current).to_a
    end

    if (page_count - current) > 3
      pages += (current..(current + 3)).to_a
    else
      pages += (current..page_count).to_a
    end
    {
      first: 1,
      pages: pages,
      last:  page_count,
    }
  end

  #  :/ TODO
  def form_render_field(field, value = nil)
    name = field[:type].not_nil!.field_type.downcase

    case name
    when "int32", "int16"
      form_int32(field, value)
    when "float32", "float64"
      form_string(field, value)
    when "string"
      form_string(field, value)
    when "time", "created_at", "updated_at"
      form_time(field, value)
    when "bool"
      form_bool(field, value)
    when "belongs_to"
      form_belongs_to(field, value)
    end
  end

  def form_int32(field, value)
    <<-INPUT
    <label for="#{field[:column_name]}" class="col-sm-2 control-label">#{field[:column_name]}</label>
    <div class="col-sm-10">
      <input type="number" name="#{field[:column_name]}" class="form-control" id="#{field[:column_name]}" #{field[:nilable] ? "" : "required"} value=#{value}>
    </div>
    INPUT
  end

  def form_string(field, value)
    <<-INPUT
    <label for="#{field[:column_name]}" class="col-sm-2 control-label">#{field[:column_name]}</label>
    <div class="col-sm-10">
      <input type="text" name="#{field[:column_name]}" class="form-control" id="#{field[:column_name]}" #{field[:nilable] ? "" : "required"} value=#{value}>
    </div>
    INPUT
  end

  def form_time(field, value)
    <<-INPUT
    <label for="#{field[:column_name]}" class="col-sm-2 control-label">#{field[:column_name]}</label>
    <div class="col-sm-10">
      <input type="datetime-local" name="#{field[:column_name]}" class="form-control" id="#{field[:column_name]}" #{field[:nilable] ? "" : "required"} value=#{value}>
    </div>
    INPUT
  end

  def form_bool(field, value)
    <<-INPUT
      <label for="#{field[:column_name]}" class="col-sm-2 control-label">#{field[:column_name]}</label>
      <div class="col-sm-10">
        <input name="#{field[:column_name]}" id="#{field[:column_name]}" type="checkbox" value="true" #{value ? "checked" : ""}>
      </div>
    INPUT
  end

  def form_belongs_to(field, value)
    options = candidate_records(field[:type].resource_class).map do |i|
      if value == i["id"]
        "<option selected>#{i["id"]}</option>"
      else
        "<option>#{i["id"]}</option>"
      end
    end

    <<-INPUT
      <label for="#{field[:column_name]}" class="col-sm-2 control-label">#{field[:column_name]}</label>
      <div class="col-sm-10">
      <select name="#{field[:column_name]}" class="form-control">
        #{options}
      </select>
      </div>
    INPUT
  end

  def index_render_field(resource, field_name, value)
    field = resource.fields.select { |r| r[:column_name] == field_name }.first
    name = field[:type].not_nil!.field_type.downcase
    case name
    when "int32", "int16"
      index_int32(field, value)
    when "float32", "float64"
      index_string(field, value)
    when "string"
      index_string(field, value)
    when "time", "created_at", "updated_at"
      index_time(field, value)
    when "bool"
      index_bool(field, value)
    when "belongs_to"
      index_belongs_to(field, value)
    end
  end

  def index_int32(field, value)
    value
  end

  def index_string(field, value)
    value
  end

  def index_time(field, value)
    value
  end

  def index_bool(field, value)
    value
  end

  def index_belongs_to(field, value)
    <<-INPUT
      <a href="/#{field[:type].resource_class.table_name}/#{value}">#{value}</a>
    INPUT
  end

  private def candidate_records(resource)
    pool = DB.pool
    result = resource.from_table(pool.connection)
    pool.release
    return result
  end
end
