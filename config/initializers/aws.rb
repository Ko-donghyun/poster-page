CarrierWave.configure do |config|
  config.fog_credentials = {
    provider:              'AWS',                        # required
    aws_access_key_id:     'AKIAJA5VOW5RZBLYAAMA',                        # required
    aws_secret_access_key: '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',                        # required
    region:                'ap-northeast-2',                  # optional, defaults to 'us-east-1'
    endpoint:              'https://s3.ap-northeast-2.amazonaws.com' # optional, defaults to nil
  }
  config.fog_directory  = 'ko-poster'                          # required
  # config.fog_public     = false                                        # optional, defaults to true
end