require File.dirname(__FILE__) + '/../../config/boot'

class FileUpload < ActiveRecord::Base
  has_one :track

  FILE_DIRECTORY = "public/mp3s/"

  HTTP_OK_CODE = "200"
  MIN_FILE_LENGTH = 100000

  def file=(file_field)
    self.save_content_and_upload(file_field.original_filename, file_field.read)
    
    self
  end

  def self.new_and_save_from_remote_url(url)
    file_upload = nil
    track = get_remote_track(url)

    if track && track.code == HTTP_OK_CODE # got track OK so save it locally
      if track.body.length > MIN_FILE_LENGTH
        file_upload = self.new()
        file_upload.save_content_and_upload(File.basename(url), track.body)
      end
    end
    
    file_upload
  end

  def save_content_and_upload(basename, content)
    self.save()
    sanitised_basename = basename.downcase().gsub(/\.mp3/, "extensionextensionextension").gsub(/\W/, "").gsub(/extensionextensionextension/, ".mp3")
    name = FileUpload::get_next_filename(sanitised_basename, self.id)
    File.open("#{FILE_DIRECTORY}#{name}", "w") { |f| f.write(content) }
    self.local_path = FILE_DIRECTORY.to_s + name.to_s
    upload_file_to_s3(self.local_path) # send file to S3    
  end

  # returns url to submission file for this uploaded file (stored on S3)
  def url()
    Configuring.get("static_repository") + self.filename()
  end

  # returns local filename of submission file for this uploaded file
  def filename()
    File.basename(self.local_path)
  end

  private 
    def self.get_remote_track(url)
      track = nil
      begin
        Timeout::timeout(60) do
          track = Net::HTTP.get_response(URI.parse(APIUtil::make_url_safe(url))) # get_response takes an URI object
        end
      rescue Timeout::Error # failure - got_track is already false
      rescue # let through other errors
      end

      track
    end

    # formulate a filename
    def self.get_next_filename(original_filename, unique_id)
      unique_id.to_s + original_filename
    end

    # uploads file at passed path to S3
    def upload_file_to_s3(path)
      if /^#{ FILE_DIRECTORY }(.+[^~])$/.match(path) && File.readable?(path)
        key = Regexp.last_match[1]
        mime = 'text/jpeg'
        datafile = File.open(path)
        filesize = File.size(path)
        puts "uploading #{ path } as #{ key } mime #{ mime }"
        conn = S3::AWSAuthConnection.new(Configuring.get("aws_access_key_id"), Configuring.get("aws_secret_access_key"), false)
        conn.put(Configuring.get("bucket_name"), key, datafile.read,
                { "Content-Type" => mime, "Content-Length" => filesize.to_s,
                  "Content-Disposition"=> "inline;filename=#{File.basename(key).gsub(/\s/, '_')}",
                  "x-amz-acl" => "public-read" })
      end
    end
end