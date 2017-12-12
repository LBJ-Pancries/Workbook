class AvatarUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :file

  process resize_to_fit: [800, 800]

  version :thumb do
    process resize_to_fill: [200,200]
  end

  version :medium do
    process resize_to_fill: [400,400]
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

end
