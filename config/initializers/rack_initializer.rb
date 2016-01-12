if Rack::Utils.respond_to?("key_space_limit=")
  Rack::Utils.key_space_limit = 123456789
end
