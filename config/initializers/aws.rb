CarrierWave.configure do |config|
  config.fog_credentials = {
    provider:              'AWS',                        # required
    aws_access_key_id:     '',                        # required
    aws_secret_access_key: '',                        # required
    region:                '',                  # optional, defaults to 'us-east-1'
    endpoint:              '' # optional, defaults to nil
  }
  config.fog_directory  = ''                          # required
  # config.fog_public     = false                                        # optional, defaults to true
end