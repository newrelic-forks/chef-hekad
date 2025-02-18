# Cookbook Name:: hekad
# Spec:: install
#
# Copyright 2015 Nathan Williams
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe 'hekad::install' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'centos', version: '7.0')
        .converge(described_recipe)
    end

    it 'downloads the package' do
      expect(chef_run).to create_remote_file 'heka_release_pkg'
    end

    it 'installs the package' do
      expect(chef_run).to install_package 'heka'
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end

  context 'When all attributes are default, on Mac OSX' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'mac_os_x', version: '10.10')
        .converge(described_recipe)
    end

    before do
      stub_command("which git").and_return("/usr/bin/git")
    end

    it 'sets up homebrew' do
      expect(chef_run).to include_recipe 'homebrew::default'
      expect(chef_run).to include_recipe 'homebrew::cask'
    end


    it 'installs homebrew package' do
      expect(chef_run).to install_homebrew_cask 'heka'
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end
end
