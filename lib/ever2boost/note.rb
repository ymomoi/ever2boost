require 'securerandom'

module Ever2boost
  class Note
    DEFAULT_BYTES_NUMBER = 10
    attr_accessor :title, :content, :created_at, :updated_at, :hash, :notebook_guid, :file_name, :output_dir
    def initialize(title: nil, content: nil, created_at: nil, updated_at: nil, notebook_guid: nil, output_dir: nil)
      @title = title
      @content = MdConverter.convert(content)
      @created_at = created_at
      @updated_at = updated_at
      @notebook_guid = notebook_guid
      @file_name = SecureRandom.hex(DEFAULT_BYTES_NUMBER)
      @output_dir = output_dir
    end

    def md_content
      build_image_link(self.content)
    end

    def build_image_link(content_str)
      content_str.gsub(/<en-media\ hash=['|"](.+?)['|"](.*?).\ type=.(.+?)\/(.+?)['|"](.*?)\/>/, "![#{'\1'}](#{self.output_dir}/images/#{'\1'}.#{'\4'})")
    end
  end
end
