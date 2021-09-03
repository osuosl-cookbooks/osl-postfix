require 'chefspec'
require 'chefspec/berkshelf'

CENTOS_8 = {
  platform: 'centos',
  version: '8',
}.freeze

CENTOS_7 = {
  platform: 'centos',
  version: '7',
}.freeze

DEBIAN_10 = {
  platform: 'debian',
  version: '10',
}.freeze

DEBIAN_11 = {
  platform: 'debian',
  version: '11',
}.freeze

ALL_PLATFORMS = [
  CENTOS_8,
  CENTOS_7,
  DEBIAN_10,
  DEBIAN_11,
].freeze

RSpec.configure do |config|
  config.log_level = :warn
end

shared_context 'common_stubs' do
  before do
    stub_command('/usr/bin/test /etc/alternatives/mta -ef /usr/sbin/sendmail.postfix')
  end
end
