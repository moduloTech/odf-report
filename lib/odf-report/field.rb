# frozen_string_literal: true

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

    def replace!(content)
      txt = content.inner_html

      if txt.gsub!(to_placeholder, sanitize(@data_source.value))
        content.inner_html = txt
      end
    end

  private

    def to_placeholder
      delimiters = ODFReport.config.field_delimiters
      if ODFReport.config.field_delimiters_as_is
        @name.to_s
      elsif delimiters.is_a?(Array)
        "#{delimiters[0]}#{@name.to_s}#{delimiters[1]}"
      else
        "#{delimiters}#{@name.to_s}#{delimiters}"
      end
    end

    def sanitize(txt)
      odf_linebreak(
        html_escape(txt)
      )
    end

    HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }.freeze

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
