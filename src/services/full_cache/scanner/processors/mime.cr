class FullCache::Scanner::Processors::Mime
  @mime_type : String?

  def initialize(
    @file_path : String,
    @lg : Ui::Lg
  )
  end

  def call
    get_data

    return {
      mime_type: mime_type,
    }
  end

  def mime_type : String
    get_data
    return @mime_type.not_nil!
  end

  private def get_data
    return if @mime_type

    @lg.info(
      place: self.class,
      message: "mime type info",
      path: @file_path
    ) do
      mime_command = "file --mime-type \"#{@file_path}\""
      mime_result = `#{mime_command}`
      @mime_type = mime_result.gsub(/[^:]+: /, "").strip
    end
  end
end
