# encoding: UTF-8
#
# Copyright 2015 Shawn Neal <sneal@sneal.net>
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

require_relative 'command_executor'

module WinRM
  module FS
    module Core
      # Uploads the given source file to a temp file in 8k chunks
      class Base64FileUploader
        def initialize(command_executor)
          @command_executor = command_executor
        end

        # Uploads the given file to the specified temp file as base64 encoded.
        #
        # @param [String] Path to the local source file on this machine
        # @param [String] Path to the temporary file on the target machine
        # @param [String] Path to the target file on the target machine
        # @return [Integer] Count of bytes uploaded
        def upload_to_temp_file(local_file, temp_file, remote_file)
          base64_host_file = Base64.encode64(IO.binread(local_file)).gsub("\n", '')
          base64_array = base64_host_file.chars.to_a
          bytes_copied = 0

          base64_array.each_slice(8000 - temp_file.size) do |chunk|
            @command_executor.run_cmd("echo #{chunk.join} >> \"#{temp_file}\"")
            bytes_copied += chunk.count
            yield bytes_copied, base64_array.count, local_file, remote_file if block_given?
          end

          base64_array.length
        end
      end
    end
  end
end
