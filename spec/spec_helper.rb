require 'chefspec'
require 'chefspec/berkshelf'

ALMA_8 = {
  platform: 'almalinux',
  version: '8',
}.freeze

ALMA_10 = {
  platform: 'almalinux',
  version: '10',
}.freeze

DEBIAN_12 = {
  platform: 'debian',
  version: '12',
}.freeze

UBUNTU_2404 = {
  platform: 'ubuntu',
  version: '24.04',
}.freeze

ALL_DEBIAN = [
  DEBIAN_12,
  UBUNTU_2404,
].freeze

ALL_PLATFORMS = [
  ALMA_8,
  ALMA_10,
  DEBIAN_12,
  UBUNTU_2404,
].freeze

RSpec.configure do |config|
  config.log_level = :warn
end

shared_context 'common_stubs' do
  before do
    stub_command('/usr/bin/test /etc/alternatives/mta -ef /usr/sbin/sendmail.postfix')
  end
end
