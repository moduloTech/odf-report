# frozen_string_literal: true

module ODFReport
  class Nestable

    def initialize(opts)
      @name = opts[:name]
      @replace_proc = opts.delete(:replace_proc)
      @data_source = DataSource.new(opts)

      @fields   = []
      @texts    = []
      @tables   = []
      @sections = []
      @images   = []
    end

    def set_source(data_item)
      @data_source.set_source(data_item)
      self
    end

    def add_field(name, data_field=nil, &)
      @fields << Field.new({ name:, data_field: }, &)
    end
    alias_method :add_column, :add_field

    def add_text(name, data_field=nil, &)
      @texts << Text.new({ name:, data_field: }, &)
    end

    def add_image(name, data_field=nil, &)
      @images << Image.new({ name:, data_field: }, &)
    end

    def add_table(name, collection_field, opts={})
      table = Table.new(opts.merge(name:, collection_field:))
      @tables << table

      yield(table) if block_given?
    end

    def add_section(name, collection_field, opts={})
      section = Section.new(opts.merge(name:, collection_field:))
      @sections << section

      yield(section) if block_given?
    end

    def all_images
      (@images.map(&:files) + @sections.map(&:all_images) + @tables.map(&:all_images)).flatten
    end

    def wrap_with_ns(node)
      <<-XML
       <root xmlns:draw="a" xmlns:xlink="b" xmlns:text="c" xmlns:table="d">#{node.to_xml}</root>
      XML
    end
    
  end
end
