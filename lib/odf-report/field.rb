module ODFReport
  class Field

    def initialize(opts, &block)
      @name = opts[:name]
      @data_source = DataSource.new(opts, &block)
    end

    def set_source(record)
      @data_source.set_source(record)
      self
    end

    def replace!(content, data_item = nil)

      txt = content.inner_html

      if txt.gsub!(to_placeholder, sanitize(@data_source.value))
        content.inner_html = txt
      end

    end

  private

    def to_placeholder
      as_is = ODFReport.config.field_delimiters_as_is
      delimiters = ODFReport.config.field_delimiters
      if as_is
        @name.to_s
      elsif delimiters.is_a?(Array)
        "#{delimiters[0]}#{@name.to_s}#{delimiters[1]}"
      else
        "#{delimiters}#{@name.to_s}#{delimiters}"
      end
    end

    def sanitize(txt)
      txt = html_escape(txt)
      txt = odf_linebreak(txt)
      txt
    end

    HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }

    def html_escape(s)
      return "" unless s
      s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
    end

    def odf_linebreak(s)
      return "" unless s
      s.to_s.gsub("\n", "<text:line-break/>")
    end

  end
end
