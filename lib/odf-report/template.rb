# frozen_string_literal: true

module ODFReport
  class Template

    CONTENT_FILES = %w[content.xml styles.xml].to_set
    MANIFEST_FILE = "META-INF/manifest.xml"

    attr_accessor :output_stream

    def initialize(template = nil, io: nil)
      raise "You must provide either a filename or an io: string" unless template || io
      raise "Template [#{template}] not found." unless template.nil? || ::File.exist?(template)

      @template = template
      @io = io
    end

    def update_content
      @buffer = Zip::OutputStream.write_buffer do |out|
        @output_stream = out
        yield self
      end
    end

    def update_files(&block)
      each_entry_data do |entry, data|
        process_entry(data, &block) if CONTENT_FILES.include?(entry.name)
        update_file(entry.name, data) unless entry.name == MANIFEST_FILE
      end
    end

    def update_manifest(&block)
      entry = template_entries.find_entry(MANIFEST_FILE)

      entry.get_input_stream do |is|

        data = is.sysread

        process_entry(data, &block)

        update_file(MANIFEST_FILE, data)

      end

    end

    def data
      @buffer.string
    end

    def update_file(name, data)
      @output_stream.put_next_entry(name)
      @output_stream.write data
    end

    def each_content(&block)
      each_entry_data do |entry, data|
        block.call(data) if CONTENT_FILES.include?(entry.name)
      end
    end

    private

    def each_entry_data(&block)
      template_entries.each do |entry|
        next if entry.directory?

        entry.get_input_stream do |stream|
          block.call(entry, stream.sysread)
        end
      end
    end

    def template_entries
      if @template
        Zip::File.open(@template)
      else
        Zip::File.open_buffer(@io.force_encoding("ASCII-8BIT"))
      end
    end

    def process_entry(entry)
      doc = Nokogiri::XML(entry, &:noblanks)
      yield doc
      entry.replace(doc.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML))
    end

  end
end
