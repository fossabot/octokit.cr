require "json"
require "base64"
require "spec"
require "webmock"
require "../src/octokit"

# Webmock.stub(:any, )

def b64toJSON(string : String, model = JSON::Any)
  decoded = Base64.decode_string(string)
  model.from_json(decoded)
end
