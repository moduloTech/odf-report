# frozen_string_literal: true

module ODFReport

class Report

  def initialize(name = nil, io: nil)
    @template = ODFReport::Template.new(name, io:)

    @texts = []
    @fields = []
    @tables = []
    @sections = []
    @images = []

    yield(self) if block_given?
  end

  def add_field(name, value='')
    @fields << Field.new({ name:, value: })
  end

  def add_text(name, value='')
    @texts << Text.new({ name:, value: })
  end

  def add_table(name, collection, opts={})
    table = Table.new(opts.merge(name:, collection:))
    @tables << table

    yield(table) if block_given?
  end

  def add_section(name, collection, opts={})
    section = Section.new(opts.merge(name:, collection:))
    @sections << section

    yield(section) if block_given?
  end

  def add_image(name, value=nil)
    @images << Image.new({ name:, value: })
  end

  def generate(dest = nil)
    @template.update_content do |file|
      file.update_files do |doc|
        yield(self, doc) if block_given?

        @sections.each { |c| c.replace!(doc) }
        @tables.each   { |c| c.replace!(doc) }
        @texts.each    { |c| c.replace!(doc) }
        @fields.each   { |c| c.replace!(doc) }
        @images.each   { |c| c.replace!(doc) }
      end

      all_images.each { |i| Image.include_image_file(file, i) }

      file.update_manifest do |content|
        all_images.each { |i| Image.include_manifest_entry(content, i) }
      end

    end

    if dest
      File.open(dest, "wb") { |f| f.write(@template.data) }
    else
      @template.data
    end
  end

  def all_images
    @all_images ||= (@images.map(&:files) + @sections.map(&:all_images) + @tables.map(&:all_images)).flatten.uniq
  end

end

end
