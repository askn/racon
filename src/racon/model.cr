abstract class Racon::Resource
  def self.from_table(conn)
    data = conn.exec("SELECT * FROM #{table_name} ORDER BY id DESC")

    to_model(data.to_hash)
  end

  def self.from_table_page(conn, num)
    data = conn.exec(page_query(num))

    to_model(data.to_hash)
  end

  def self.page_query(num = nil)
    numm = (num.is_a? Nil) ? 0 : num.to_i
    offset = per_page * ((numm = numm - 1) < 0 ? 0 : numm)
    "SELECT * FROM #{table_name} ORDER BY id DESC limit #{per_page} offset #{offset}"
  end

  def self.per_page
    10
  end

  def self.total_count
    pool = DB.pool
    result = pool.connection.exec("SELECT count(*) FROM #{table_name}").to_hash.first["count"].as(Int64)
    pool.release
    return result
  end

  def self.find_by_id(conn, id)
    data = conn.exec("SELECT * FROM #{table_name} WHERE id= $1", [id])
    to_model(data.to_hash).first
  end

  def self.create(conn, attrs)
    created_at = fields.select { |r| r[:type].not_nil!.field_type == "created_at" }.first[:column_name]
    updated_at = fields.select { |r| r[:type].not_nil!.field_type == "updated_at" }.first[:column_name]

    keys = attrs.keys
    values = [] of String
    attrs.values.each { |val| values << "#{escape(val)}" }

    if created_at
      keys << created_at
      values << "#{escape(Time.now)}"
    end
    if updated_at
      keys << updated_at
      values << "#{escape(Time.now)}"
    end

    query = "INSERT INTO #{table_name} (#{keys.join(", ")}) VALUES (#{values.join(", ")})"
    data = conn.exec(query)
  end

  def self.update(conn, id, attrs)
    created_at = fields.select { |r| r[:type].not_nil!.field_type == "created_at" }.first[:column_name]
    updated_at = fields.select { |r| r[:type].not_nil!.field_type == "updated_at" }.first[:column_name]

    values = [] of String

    query = "UPDATE #{table_name} SET "
    attrs.each do |key, val|
      query += "#{key}=#{escape(val)}, "
    end
    query += "#{created_at}='#{Time.now}' where id=#{id}"
    data = conn.exec(query)
  end

  def self.destroy(conn, id)
    data = conn.exec("DELETE FROM #{table_name} WHERE id= $1", [id])
  end

  private def self.escape(data)
    "'#{data.to_s.gsub("'", "\\'")}'"
  end

  def self.form_attributes
    created_at = fields.select { |r| r[:type].not_nil!.field_type == "created_at" }.first[:column_name]
    updated_at = fields.select { |r| r[:type].not_nil!.field_type == "updated_at" }.first[:column_name]
    field_names - ["id", created_at, updated_at]
  end

  def self.index_page_attributes
    field_names
  end

  def self.show_page_attributes
    field_names
  end

  def self.field_names
    fields.map do |f|
      f[:column_name]
    end
  end

  def self.to_model(data)
    rows = [] of Hash(String, Int32 | Int16 | Float32 | Float64 | String | Time | Bool | Nil)
    data.each do |row|
      rows << mapping(row)
    end
    rows
  end

  def self.mapping(hash)
    # TODO float
    row = Hash(String, Int32 | Int16 | Float32 | Float64 | String | Time | Bool | Nil).new
    fields.each do |field|
      row[field[:column_name]] = if field[:type].not_nil!.field_type == "primary_key"
                                   hash[field[:column_name]].as Int32
                                 elsif field[:type].not_nil!.field_type == "int16"
                                   if field[:nilable]
                                     hash[field[:column_name]].as Int16?
                                   else
                                     hash[field[:column_name]].as Int16
                                   end
                                 elsif field[:type].not_nil!.field_type == "int32"
                                   if field[:nilable]
                                     hash[field[:column_name]].as Int32?
                                   else
                                     hash[field[:column_name]].as Int32
                                   end
                                 elsif field[:type].not_nil!.field_type == "float32"
                                   if field[:nilable]
                                     hash[field[:column_name]].as Float32?
                                   else
                                     hash[field[:column_name]].as Float32
                                   end
                                 elsif field[:type].not_nil!.field_type == "float64"
                                   if field[:nilable]
                                     hash[field[:column_name]].as Float64?
                                   else
                                     hash[field[:column_name]].as Float64
                                   end
                                 elsif field[:type].not_nil!.field_type == "string"
                                   if field[:nilable]
                                     hash[field[:column_name]].as String?
                                   else
                                     hash[field[:column_name]].as String
                                   end
                                 elsif field[:type].not_nil!.field_type == "time" || field[:type].not_nil!.field_type == "created_at" || field[:type].not_nil!.field_type == "updated_at"
                                   if field[:nilable]
                                     hash[field[:column_name]].as Time?
                                   else
                                     hash[field[:column_name]].as Time
                                   end
                                 elsif field[:type].not_nil!.field_type == "bool"
                                   if field[:nilable]
                                     hash[field[:column_name]].as Bool?
                                   else
                                     hash[field[:column_name]].as Bool
                                   end
                                 elsif field[:type].not_nil!.field_type == "belongs_to"
                                   if field[:nilable]
                                     hash[field[:column_name]].as Int32?
                                   else
                                     hash[field[:column_name]].as Int32
                                   end
                                 end
    end
    row
  end
end
