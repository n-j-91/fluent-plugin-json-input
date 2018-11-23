#
# Fluentd
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

require 'fluent/plugin/input'

module Fluent::Plugin
  class TcpInput < Input
    Fluent::Plugin.register_input('json', self)

    helpers :server, :parser, :extract, :compat_parameters

    desc 'Tag of output events.'
    config_param :tag, :string
    desc 'The port to listen to.'
    config_param :port, :integer, default: 55444
    desc 'The bind address to listen to.'
    config_param :bind, :string, default: '0.0.0.0'

    desc "The field name of the client's hostname."
    config_param :source_host_key, :string, default: nil, deprecated: "use source_hostname_key instead."
    desc "The field name of the client's hostname."
    config_param :source_hostname_key, :string, default: nil

    desc "The field name of the client's ipv4"
    config_param :source_ipv4, :string, default: nil

    config_param :blocking_timeout, :time, default: 0.5

    desc 'The payload is read up to this character.'
    config_param :delimiter, :string, default: "\n" # syslog family add "\n" to each message and this seems only way to split messages in tcp stream

    def configure(conf)
      compat_parameters_convert(conf, :parser)
      super
      @_event_loop_blocking_timeout = @blocking_timeout
      @source_hostname_key ||= @source_host_key if @source_host_key

      @parser = parser_create
    end

    def multi_workers_ready?
      true
    end

    def start
      super
      
      newchunk = 1
      first = nil
      last = nil
      remoteip = "unable to locate" 
      server_create(:in_tcp_server, @port, bind: @bind, resolve_name: !!@source_hostname_key) do |data, conn|
        conn.buffer << data
        begin
          log.info "Received: ", data
          if newchunk == 1
            proxyheaderend = conn.buffer.index("\r\n")
            proxyheader = conn.buffer.slice!(0, proxyheaderend+1)
            remoteip = proxyheader.gsub(/\s+/m, ' ').strip.split(" ")[2]
          end
          log.info "remoiteip: ", remoteip
          first = conn.buffer.index("{")
          last  = conn.buffer.rindex("}")

          if first.nil? || last.nil?
              log.info "incomplete json received: ", data
              newchunk = 0
              next
          end
          msg = conn.buffer.slice!(first, last+1)
          log.info "sliced json string: ", msg
          @parser.parse(msg) do |time, record|
            unless time && record
              log.error "pattern not match", message: msg
              next
            end

            tag = extract_tag_from_record(record)
            tag ||= @tag
            time ||= extract_time_from_record(record) || Fluent::EventTime.now
            record[@source_hostname_key] = conn.remote_host if @source_hostname_key
            record[@source_ipv4] = remoteip if @source_ipv4
            router.emit(tag, time, record)
          end
          conn.close()
          newchunk = 1
          msg          
        end
      end
    end
  end
end
