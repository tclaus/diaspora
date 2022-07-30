# frozen_string_literal: true

ES_CLIENT =
  if AppConfig.elasticsearch.enable_host?
    Elasticsearch::Client.new(host:   AppConfig.elasticsearch.host.to_s,
                              transport_options: { ssl: { verify: false } },
                              ca_fingerprint: AppConfig.elasticsearch.cert_fingerprint,
                              logger: Logging.logger["elasticsearch"])
  elsif AppConfig.elasticsearch.enable_cloud?
    Elasticsearch::Client.new(cloud_id: AppConfig.elasticsearch.cloud_id.to_s,
                              user:     AppConfig.elasticsearch.user.to_s,
                              password: AppConfig.elasticsearch.password.to_s,
                              logger:   Logging.logger["elasticsearch"])
  end

Elasticsearch::Model.client = ES_CLIENT
